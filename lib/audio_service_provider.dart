import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lunify/image_util.dart';
import 'package:lunify/models/album_model.dart';
import 'package:lunify/models/artist_model.dart';
import 'package:lunify/models/song_model.dart';
import 'package:audio_metadata_extractor/audio_metadata_extractor.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:messagepack/messagepack.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:path/path.dart' as p;

class AudioPlaylist {
  String playlistName;
  List<SongModel> songs = [];

  AudioPlaylist({
    required this.playlistName
  });
}

// This class is the heart of the music functionality.
// This class should be able to:
//  - Scan for music files and have a record of it. (also cache it and load from the cache if required)
//  - Deal with playlists
//    - There is a playlist called the "current playlist", from where the music should be played.
//    - During the initial stages, the entire library would be read and added to the current playlist
//  - Play/Pause/Next/Prev/Shuffle/Loop playlists
class AudioServiceProvider extends ChangeNotifier {
  // List that contatins the URLs of the folders where the audio files are located.
  // Maybe not cross platform friendly?
  List<String> _audioLibraryUrls = <String>["/storage/emulated/0/Music"];
  final String _audioCacheFileName = "audio_cache.bin";
  final String _audioPlaylistDataFileName = "playlists.bin";

  // This audio player object is owned by this class
  final _audioPlayer = AudioPlayer();
  
  // List of playlists
  List<AudioPlaylist> _playlists = [];

  AudioPlaylist _currentPlaylist = AudioPlaylist(playlistName: "Current Playlist");
  late ConcatenatingAudioSource _currentPlaylistAudioSource;

  AudioPlaylist _library = AudioPlaylist(playlistName: "Library");  // Contains all the audio files that the device has to offer.
  AudioPlaylist _liked = AudioPlaylist(playlistName: "Liked");
  AudioPlaylist _recentlyPlayed = AudioPlaylist(playlistName: "Recently Played");

  // Convinient list of albums. This will be filled when deserializing from cache or loading from disk.
  List<AlbumModel> _albums = [];
  List<ArtistModel> _artists = [];

  bool _audioMetadataLoaded = false;
  bool _audioMetadataLoadingAsync = false;

  // These are used to switch to the player tab when a song is clicked.
  late TabController _currentTabs;
  late int _playerTabIndex;
  
  // The current song playing: initially it contains empty values.
  SongModel _currentSongPlaying = SongModel(
    songUrl: "", 
    songName: "", 
    songAlbum: "", 
    songArtist: "", 
    coverPicture: null,
    coverPictureRaw: [],
    trackNumber: 0
  );

  final SongModel _nullSong = SongModel(
    songUrl: "", 
    songName: "", 
    songAlbum: "", 
    songArtist: "", 
    coverPicture: null,
    coverPictureRaw: [],
    trackNumber: 0
  );

  int _currentSongPlayingIndexInCurrentPlaylist = 0;

  // The progress of loading the metadata of the songs. 0 represents 0% done, 1.0 repesents 100% done
  double _audioMetadataLoadingProgress = 0.0; 

  AudioServiceProvider(List<String> additionalAudioLibraryUrls) {
    // Add the additional URLs
    for (String url in additionalAudioLibraryUrls) {
      _audioLibraryUrls.add(url);
    }

    
    _currentPlaylistAudioSource = ConcatenatingAudioSource(children: []);
    _audioPlayer.setAudioSource(_currentPlaylistAudioSource, initialIndex: 0, initialPosition: Duration.zero);
  }

  SongModel getCurrentSongPlaying()             { return _currentSongPlaying; }
  AudioPlaylist getCurrentPlaylist()            { return _currentPlaylist; }

  void setCurrentSongPlaying(SongModel model)   { _currentSongPlaying = model; notifyListeners(); }

  Future<String> getCacheEntryPath(String cacheFileName) async {
    final Directory? directory = await getExternalStorageDirectory();
    final String cacheFilePath = "${directory!.path}/$cacheFileName";

    return cacheFilePath;
  }

  Future<bool> loadAudioMetadata(void Function(double)onProgressCallback, [bool forceReload = false]) async {
    // This is what this should do:
    //  During Startup, check if the cache exists
    //   If exists, get the last modified dates of the library directories
    //   If the last modified dates match with that of the existing directories, load from cache.
    //   If not, reload only that directory and rebuild cache.  

    if(_audioMetadataLoaded) return true;

    if(_audioMetadataLoadingAsync) return false;
     _audioMetadataLoadingAsync = true;

    bool returnValue = false;

    // Check if the cache exists:
    File audioCacheFile = File(await getCacheEntryPath(_audioCacheFileName));
    bool cacheFileExists = await audioCacheFile.exists();

    if(!cacheFileExists) {
      returnValue = await loadAudioMetadataFromDisk(onProgressCallback, null);
    } 
    else {
      returnValue = true; // WTF??.

      File cacheFile = File(await getCacheEntryPath(_audioCacheFileName));
      Uint8List cacheBytes = await cacheFile.readAsBytes();

      Unpacker unpacker = Unpacker(cacheBytes);

      int? libUrlCount = unpacker.unpackInt();
      print("Audio Library URL Count: $libUrlCount");

      List<String> loadFromCacheEntries = [];   // URL's that require loading from the cache.
      List<String> loadFromDiskEntries  = [];   // URL's that require loading from the disk.

      // Get the last modified time for the audio library URLs
      for(int i = 0; i < libUrlCount!; i++) {
        String? audioLibUrl = unpacker.unpackString();
        String? lastModified = unpacker.unpackString();
        DateTime lastModifiedTimeStamp = DateTime.parse(lastModified!);

        if(!_audioLibraryUrls.contains(audioLibUrl)) continue; // Skip entries that is not present in the current audio library URLs

        print("Path: $audioLibUrl Last Modified: $lastModifiedTimeStamp");

        // Get the last modified time of the url entries that are present in _audioLibraryUrls
        Directory d = Directory(audioLibUrl!);
        FileStat fileStat = await d.stat();

        if(fileStat.modified != lastModifiedTimeStamp) {
          loadFromDiskEntries.add(audioLibUrl);
        } else {
          loadFromCacheEntries.add(audioLibUrl);
        }
      }

      await deserializeAudioLibrary(unpacker, loadFromCacheEntries);
      await loadAudioMetadataFromDisk(onProgressCallback, loadFromDiskEntries);

      organizeAlbumsAndArtists();
      
      onProgressCallback(1.0);
    }
    serializeAudioLibrary();

    // Also load the playlists. Because the playlists can only be loaded if the audio libarary is loaded.
    await deserializePlaylists();
    
    _audioMetadataLoaded = true;

    _audioMetadataLoadingAsync = false;
    return returnValue;
  }

  Future<bool> loadAudioMetadataFromDisk(void Function(double)onProgressCallback, List<String>? urlEntries) async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      var result = await Permission.storage.request();
      if(result.isDenied) {
        return false;
      }
    } 
    
    print("Storage Permission Accepted!");
      
    int totalFiles = 0;
    int fileCount = 0;
      
    List<List<FileSystemEntity>> fileEachAudioUrl = [];
      
    // Load from _audioLibraryUrls if urlEntries is empty, else load from urlEntries.
    for(String url in urlEntries ?? _audioLibraryUrls) {
      Directory urlDirectory = Directory(url);
      List<FileSystemEntity> files = urlDirectory.listSync(recursive: true);
      fileEachAudioUrl.add(files);
      totalFiles += files.length;
    }
      
    for(List<FileSystemEntity> files in fileEachAudioUrl) {
      for(var file in files) {
        print("--------------------------------------------------------------------------------------------------");
        if(file is File && (file.path.endsWith('mp3') || file.path.endsWith('flac'))) {
          var songMetadata = await AudioMetadata.extract(file);
          if(songMetadata != null) {
            Image? imageToAdd = null;
            if(ImageUtil.isValidImage(songMetadata.coverData ?? [])) {
              imageToAdd = Image.memory(Uint8List.fromList(songMetadata.coverData ?? []), fit: BoxFit.cover);
            }
            _library.songs.add(
              SongModel(
                songUrl: file.path,
                songName: songMetadata.trackName ?? "Unknown name", 
                songAlbum: songMetadata.album ?? "Unknown Album", 
                trackNumber: decodeTrackNumber(songMetadata.trackNo ?? "0"),
                songArtist: songMetadata.firstArtists  ?? "Unknown artist", 
                coverPicture: imageToAdd,
                coverPictureRaw: songMetadata.coverData
              )
            );

            if(_albums.any((album) => album.name == songMetadata.album)) {
              AlbumModel? album = _albums.firstWhere(
                (album) => album.name == songMetadata.album,
              );
              album.trackCount++;
              album.tracks.add(_library.songs[_library.songs.length - 1]);
            }
            else {
              _albums.add(
                AlbumModel(
                  name: songMetadata.album ?? "Unknown Album", 
                  artist: songMetadata.firstArtists ?? "Unknown artist", 
                  trackCount: 1,
                  coverImage: imageToAdd,
                )
              );
              _albums[_albums.length - 1].tracks.add(_library.songs[_library.songs.length - 1]);
            }
          }
        }
      
        fileCount++;
        onProgressCallback(fileCount / totalFiles);
        _audioMetadataLoadingProgress = fileCount / totalFiles;
      }
    }

    return true;
  }

  void organizeAlbumsAndArtists() {
    // Sort all the songs in the albums according to the track number.
    for(AlbumModel album in _albums) {
      album.tracks.sort((a, b) => a.trackNumber.compareTo(b.trackNumber));

      if(!_artists.any((artist) => artist.name == album.artist)) {
        _artists.add(
          ArtistModel(
            name: album.artist, 
            albums: [album], 
          )
        );
      }
      else {
        ArtistModel artist = _artists.lastWhere((a) => a.name == album.artist);
        artist.albums.add(album);
      }
    }
    
    for(int i = 0; i < _artists.length; i++) {
      ArtistModel artist = _artists[i];
      List<Image> coverImages = [];
      for(AlbumModel album in artist.albums) {
        if(album.coverImage != null) {
          coverImages.add(album.coverImage!);
        }
      }

      if(coverImages.isEmpty) {
        continue;
      }
      else if(coverImages.length == 1) {
        artist.cover = coverImages[0];
      }
      else if(coverImages.length == 2) {
        artist.cover = Row(
          children: [
            coverImages[0],
            coverImages[1]
          ],
        );
      }
      else if(coverImages.length == 3) {
        
        List<int> idxs = [0, 1, 2];
        idxs.shuffle();
        int idx1 = idxs[0], idx2 = idxs[1]; 

        artist.cover = Row(
          children: [ // To clip properly.
            Expanded(
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.center,
                  maxWidth: double.infinity,
                  child: coverImages[idx1]
                )
              ),
            ),
            Expanded(
              child: ClipRect(
                child: OverflowBox(
                  maxWidth: double.infinity,
                  alignment: Alignment.center,
                  child: coverImages[idx2]
                )
              ),
            ),
          ],
        );
      }
      else {
        List<int> idxs = List.generate(coverImages.length, (index) => index);
        idxs.shuffle();
        int idx1 = idxs[0], idx2 = idxs[1], idx3 = idxs[2], idx4 = idxs[3];

        artist.cover = Row(
          children: [
            Flexible(
              child: Column(
                children: [
                  Expanded(
                    child: ClipRect(
                      child: OverflowBox(
                        maxWidth: double.infinity,
                        alignment: Alignment.center,
                        child: coverImages[idx1]
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRect(
                      child: OverflowBox(
                        maxWidth: double.infinity,
                        alignment: Alignment.center,
                        child: coverImages[idx2]
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Column(
                children: [
                  Expanded(
                    child: ClipRect(
                      child: OverflowBox(
                        maxWidth: double.infinity,
                        alignment: Alignment.center,
                        child: coverImages[idx3]
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRect(
                      child: OverflowBox(
                        maxWidth: double.infinity,
                        alignment: Alignment.center,
                        child: coverImages[idx4]
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      }
    }
  }

  Future<void> serializeAudioLibrary() async {
    Packer p = Packer();

    // Pack the last modified time.
    p.packInt(_audioLibraryUrls.length);
    for(String url in _audioLibraryUrls) {
      Directory d = Directory(url);
      final FileStat stats = await d.stat();
      p.packString(url);
      p.packString(stats.modified.toIso8601String());
    }

    p.packInt(_library.songs.length);
    for(SongModel audioFile in _library.songs) {
      p.packString(audioFile.songUrl);
      p.packString(audioFile.songName);
      p.packString(audioFile.songAlbum);
      p.packInt(audioFile.trackNumber);
      p.packString(audioFile.songArtist);
      p.packBinary(audioFile.coverPictureRaw);
    }
    
    File cacheFile = File(await getCacheEntryPath(_audioCacheFileName));
    await cacheFile.writeAsBytes(p.takeBytes());
  }

  // urlEntries refers to the list of URL's from where the audio files are that needs to be reloaded from cache.
  Future<void> deserializeAudioLibrary(Unpacker unpacker, List<String> urlEntries) async { 
    // This function is called knowing that the cache file exists.

    int? songCount = unpacker.unpackInt();

    for(int i = 0; i < songCount!; i++) {
      
      String? sUrl = unpacker.unpackString();
      String? sName = unpacker.unpackString();
      String? sAlbum = unpacker.unpackString();
      int? sTrackNumber = unpacker.unpackInt();
      String? sArtist = unpacker.unpackString();
      
      List<int>? sCoverPic = unpacker.unpackBinary();

      SongModel model = SongModel(
        songUrl: sUrl ?? "", 
        songName: sName ?? "Unknown Song", 
        songAlbum: sAlbum ?? "Unknown Album", 
        trackNumber: sTrackNumber ?? 0,
        songArtist: sArtist ?? "Unknown Artist", 
        coverPicture: sCoverPic.isEmpty ? null : Image.memory(Uint8List.fromList(sCoverPic), fit: BoxFit.cover), 
        coverPictureRaw: sCoverPic,
      );

      // Check if parent path of sUrl is present in urlEntries
      // Add to the library only if the parent path is present in urlEntries
      String parentPath = Directory(sUrl!).parent.path;
      bool within = false;
      for(String parentPath in urlEntries) {
        String normalizedParent = p.normalize(p.absolute(parentPath));
        String normalizedChild = p.normalize(p.absolute(sUrl));

        if(p.isWithin(normalizedParent, normalizedChild)) {
          within = true;
          break;
        }
      }

      if(within) {
        _library.songs.add(model);

        if(_albums.any((album) => album.name == sAlbum)) {
          AlbumModel? album = _albums.firstWhere(
            (album) => album.name == sAlbum,
          );
          album.trackCount++;
          album.tracks.add(_library.songs[_library.songs.length - 1]);
        }
        else {
          _albums.add(
            AlbumModel(
              name: sAlbum ?? "Unknown Album", 
              artist: sArtist ?? "Unknown artist", 
              trackCount: 1,
              coverImage: sCoverPic.isEmpty ? null : Image.memory(Uint8List.fromList(sCoverPic), fit: BoxFit.cover)
            )
          );
          _albums[_albums.length - 1].tracks.add(_library.songs[_library.songs.length - 1]);
        }
      }
    }
    print("Read $songCount items from the cache.");
  }

  // This method is used to decode track numbers of various types:
  int decodeTrackNumber(String trackNumber) {
    // Split the track number by '/' to handle formats like '5/12'
    List<String> parts = trackNumber.split('/');

    try {
      // Parse the first part as an integer
      return int.parse(parts[0].trim());
    } catch (e) {
      // Return 0 or an appropriate fallback if parsing fails
      print("Error decoding track number: $e");
      return 0;
    }
  }

  Future<void> serializePlaylists() async {
    File serializedFile = File(await getCacheEntryPath(_audioPlaylistDataFileName));
    Packer packer = Packer();

    packer.packInt(_playlists.length + 2); // 2 extra playlists: Liked songs and Recently Played

    List<AudioPlaylist> playlistsToSerialize = [_liked, _recentlyPlayed, ..._playlists];

    for(AudioPlaylist playlist in playlistsToSerialize) {
      packer.packString(playlist.playlistName);
      packer.packInt(playlist.songs.length);

      for(SongModel song in playlist.songs) {
        packer.packString(song.songUrl);
      }
    }

    serializedFile.writeAsBytes(packer.takeBytes());
  }

  Future<void> deserializePlaylists() async {
    File deserializedFile = File(await getCacheEntryPath(_audioPlaylistDataFileName));
    if(!deserializedFile.existsSync()) return;

    _playlists.clear();
    List<AudioPlaylist> deserializedPlaylists = [];

    Uint8List cacheBytes = await deserializedFile.readAsBytes();

    Unpacker unpacker = Unpacker(cacheBytes);

    int playlistCount = unpacker.unpackInt()!;
    for(int i = 0; i < playlistCount; i++) {
      
      String name = unpacker.unpackString()!;
      deserializedPlaylists.add(AudioPlaylist(playlistName: name));

      int trackCount = unpacker.unpackInt()!;

      for(int i = 0; i < trackCount; i++) {
        String songUrl = unpacker.unpackString()!;
        SongModel song = _library.songs.lastWhere((songModel) => songModel.songUrl == songUrl, orElse: () => _nullSong);
        if(song != _nullSong) deserializedPlaylists.last.songs.add(song);
      }
    }

    _liked = deserializedPlaylists[0];
    _recentlyPlayed = deserializedPlaylists[1];

    // The remaining playlists
    _playlists = deserializedPlaylists.sublist(2);
  }

  double getAudioMetadataLoadingProgress()       { return _audioMetadataLoadingProgress; }
  AudioPlaylist getAudioLibrary()                { return _library; }
  List<AlbumModel> getAlbums()                   { return _albums; }
  List<ArtistModel> getArtists()                 { return _artists; }
  List<AudioPlaylist> getPlaylists()             { return _playlists; }
  AudioPlaylist getLikedSongs()                  { return _liked; }
  AudioPlaylist getRecentlyPlayedSongs()         { return _recentlyPlayed; }
  AudioPlaylist getPlaylistAtIndex(int index)    { return _playlists[index]; }
  int getPlaylistCount()                         { return _playlists.length; }

  void addSongToPlaylist(AudioPlaylist playlist, SongModel song) {
    if(_playlists.contains(playlist) && !playlist.songs.contains(song)) {
      _playlists.firstWhere((p) => p == playlist).songs.add(song);
    }
  }

  void deleteSongFromPlaylist(AudioPlaylist playlist, SongModel song) {
    if(_playlists.contains(playlist) && playlist.songs.contains(song)) {
      playlist.songs.remove(song);
    }
  }

  void deleteFromCurrentQueue(SongModel song) {
    int idx = _currentPlaylist.songs.indexOf(song);

    _currentPlaylist.songs.remove(song);
    _currentPlaylistAudioSource.removeAt(idx);
  }

  void addPlaylist(AudioPlaylist playlist) {
    _playlists.add(playlist);
  }

  void deletePlaylist(AudioPlaylist playlist) {
    _playlists.remove(playlist);
  }

  AudioPlaylist? getPlaylist(String name) {
    if(_playlists.any((playlist) => playlist.playlistName != name)) {
      return null;
    }
    else {
      return _playlists.lastWhere((playlist) => playlist.playlistName == name);
    }
  }

  void addLikedSong(SongModel song) {
    _liked.songs.add(song);
  }

  void deleteLikedSong(SongModel song) {
    _liked.songs.remove(song);
  }

  void addAudioLibraryUrl(String url) {
    _audioLibraryUrls.add(url);
  }

  bool isMetadataLoaded() { 
    return _audioMetadataLoaded; 
  }

  void setLoadMetadataFlag() { 
    _audioMetadataLoaded = false; 
  }

  void setTabController(TabController controller) {
    _currentTabs = controller;
  }

  void setPlayerTabIndex(int index) {
    _playerTabIndex = index;
  }

  AudioPlayer getAudioPlayer() {
    return _audioPlayer;
  }

  void setPlaybackSpeed(double speedFactor) {
    _audioPlayer.setSpeed(speedFactor);
  }

  void setPlaybackPitch(double pitchFactor) {
    _audioPlayer.setPitch(pitchFactor);
  }

  // A song is clicked in the album page or a playlist page. Either the user has clicked in the song itself, 
  // or clicked the play button. Clicking on the play button will play the first song.
  void playSongs(List<SongModel> songs, int playIndex, {bool append = false}) async {
    List<AudioSource> sources = [];
    int id = 0;

    for(SongModel track in songs) {
      sources.add(
        AudioSource.file(
          track.songUrl,
          tag: MediaItem(
            id: id.toString(),
            title: track.songName,
            album: track.songAlbum,
            artist: track.songArtist,
          )
        )
      );
      id++;
    }

    int prevCount = _currentPlaylist.songs.length;
    
    if(!append) {
      _currentPlaylist.songs.clear();
    }

    _currentPlaylist.songs.addAll(songs);

    if(!append){
      prevCount = 0;
      await _currentPlaylistAudioSource.clear();
    }

    await _currentPlaylistAudioSource.addAll(sources);

    if(_audioPlayer.playing) {
      _audioPlayer.stop();
    }

    playSongWithinQueue(prevCount + playIndex);
  }

  void playSongWithinQueue(int index) {
    if(_audioPlayer.playing) {
      _audioPlayer.stop();
    }

    _audioPlayer.seek(Duration.zero, index: index);
    _currentSongPlaying = _currentPlaylist.songs[index];
    _audioPlayer.play();

    addToRecentlyPlayed(_currentSongPlaying);
  }

  // A single song is clicked. add this to the current playlist play the song.
  // if the song is already present in the playlist, dont add this to the playlist.
  void appendSongInQueueAndPlay(SongModel model, {bool play = true}) {
    int idx = 0;
    if(!_currentPlaylist.songs.contains(model)) {
      AudioSource source = AudioSource.file(
        model.songUrl,
        tag: MediaItem(
          id: _currentPlaylist.songs.length.toString(),
          title: model.songName,
          album: model.songAlbum,
          artist: model.songArtist,
        )
      );
      _currentPlaylistAudioSource.add(source);
      _currentPlaylist.songs.add(model);

      if(_audioPlayer.playing) {
        _audioPlayer.stop();
      }

      idx = _currentPlaylist.songs.length - 1;
    }
    else {
      if(play) {
        idx = _currentPlaylist.songs.indexOf(model);
      }
    }

    if(play) {
      _audioPlayer.seek(Duration.zero, index: idx);
    
      _currentSongPlaying = model;
      _audioPlayer.play();
    }

    addToRecentlyPlayed(_currentSongPlaying);
  }

  void addToRecentlyPlayed(SongModel song) {
    if(_recentlyPlayed.songs.contains(song)) {
      _recentlyPlayed.songs.remove(song);
    }

    // Add at the beginning:
    _recentlyPlayed.songs.insert(0, song);

    // Limit the Recently Played songs to 20:
    if(_recentlyPlayed.songs.length > 20) {
      _recentlyPlayed.songs = _recentlyPlayed.songs.sublist(0, 20);
    }

    serializePlaylists();
  }

  Future<void> previousSong() async {
    await _audioPlayer.seekToPrevious();

    if(_audioPlayer.currentIndex != null) {
      _currentSongPlaying = _currentPlaylist.songs[_audioPlayer.currentIndex!];
    }
  }

  Future<void> nextSong() async {    
    await _audioPlayer.seekToNext();

    if(_audioPlayer.currentIndex != null) {
      _currentSongPlaying = _currentPlaylist.songs[_audioPlayer.currentIndex!];
    }
  }
}
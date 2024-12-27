import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lunify/image_util.dart';
import 'package:lunify/models/song_model.dart';
import 'package:audio_metadata_extractor/audio_metadata_extractor.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

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
  List<String> _audioLibraryUrls = <String>["/storage/emulated/0/test_lunify"];

  // This audio player object is owned by this class
  final _audioPlayer = AudioPlayer();
  
  // List of playlists
  List<AudioPlaylist> _playlists = [];

  AudioPlaylist _currentPlaylist = AudioPlaylist(playlistName: "Current Playlist");
  AudioPlaylist _library = AudioPlaylist(playlistName: "Library");  // Contains all the audio files that the device has to offer.

  bool _audioMetadataLoaded = false;
  bool _audioMetadataLoadingAsync = false;

  // These are used to switch to the player tab when a song is clicked.
  late TabController _currentTabs;
  late int _playerTabIndex;
  
  // The current song playing: initially it contains empty values.
  SongModel _currentSongPlaying = SongModel(
    songUrl: "", 
    songName: "", 
    songArtist: "", 
    coverPicture: null);

  int _currentSongPlayingIndexInCurrentPlaylist = 0;

  // The progress of loading the metadata of the songs. 0 represents 0% done, 1.0 repesents 100% done
  double _audioMetadataLoadingProgress = 0.0; 

  AudioServiceProvider(List<String> additionalAudioLibraryUrls) {
    // Add the additional URLs
    for (String url in additionalAudioLibraryUrls) {
      _audioLibraryUrls.add(url);
    }
  }

  SongModel getCurrentSongPlaying()             { return _currentSongPlaying; }
  AudioPlaylist getCurrentPlaylist()            { return _currentPlaylist; }

  void setCurrentSongPlaying(SongModel model)   { _currentSongPlaying = model; notifyListeners(); }

  Future<bool> loadAudioMetadataFromDisk(void Function(double)onProgressCallback, [bool forceReload = false]) async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      return false;
    } else {
      if(_audioMetadataLoadingAsync) return false;

      _audioMetadataLoadingAsync = true;
      if(forceReload || !_audioMetadataLoaded) {

        print("Storage Permission Accepted!");

        int totalFiles = 0;
        int fileCount = 0;

        List<List<FileSystemEntity>> fileEachAudioUrl = [];

        for(String url in _audioLibraryUrls) {
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
                  imageToAdd = Image.memory(Uint8List.fromList(songMetadata.coverData ?? []));
                }
                _library.songs.add(
                  SongModel(
                    songUrl: file.path,
                    songName: songMetadata.trackName ?? "Unknown name", 
                    songArtist: songMetadata.firstArtists  ?? "Unknown artist", 
                    coverPicture: imageToAdd
                  )
                );
              }
            }
            fileCount++;
            onProgressCallback(fileCount / totalFiles);
            _audioMetadataLoadingProgress = fileCount / totalFiles;
          }
        }

        _audioMetadataLoaded = true;
        
        // TEMP
        // _currentPlaylist = _library;

        List<AudioSource> _currentPlaylistAudioSources = [];
        for(SongModel song in _currentPlaylist.songs) {
          _currentPlaylistAudioSources.add(AudioSource.uri(Uri.parse(song.songUrl)));
        }
        // Create the playlist in the "audio player"
        final playlist = ConcatenatingAudioSource(
          useLazyPreparation: false,
          shuffleOrder: null,
          children: _currentPlaylistAudioSources
        );
        
        _audioPlayer.setAudioSource(playlist, initialIndex: 0, initialPosition: Duration.zero);

        _audioMetadataLoadingAsync = false;
        return true;
      } else {
        _audioMetadataLoadingAsync = false;
        return false;
      }
    }
  }

  double getAudioMetadataLoadingProgress() { return _audioMetadataLoadingProgress; }
  AudioPlaylist getAudioLibrary() { return _library; }

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

  void songClickedCallback(int indexInCurrentPlaylist) {
    _currentSongPlayingIndexInCurrentPlaylist = indexInCurrentPlaylist;
    print("Song: $_currentSongPlayingIndexInCurrentPlaylist");
    _currentTabs.animateTo(_playerTabIndex);
    _currentSongPlaying = _currentPlaylist.songs[indexInCurrentPlaylist];
    _audioPlayer.seek(Duration.zero, index: _currentSongPlayingIndexInCurrentPlaylist);
    _audioPlayer.play();
  }

  void previousSong() {
    if (_currentSongPlayingIndexInCurrentPlaylist > -1) {
      _audioPlayer.seekToPrevious();
      _currentSongPlaying = _currentPlaylist.songs[
        _currentSongPlayingIndexInCurrentPlaylist == 0 ? 
        0 :
        --_currentSongPlayingIndexInCurrentPlaylist 
      ];
    }
  }

  void nextSong() {    
    if (_currentSongPlayingIndexInCurrentPlaylist < _currentPlaylist.songs.length) {
      _audioPlayer.seekToNext();
      _currentSongPlaying = _currentPlaylist.songs[
        _currentSongPlayingIndexInCurrentPlaylist == _currentPlaylist.songs.length - 1 ? 
        _currentPlaylist.songs.length - 1 :
        ++_currentSongPlayingIndexInCurrentPlaylist
      ];
    }
  }
}
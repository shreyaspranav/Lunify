import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lunify/models/song_model.dart';
import 'package:audio_metadata_extractor/audio_metadata_extractor.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';

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
class AudioFileHandler extends ChangeNotifier {
  // List that contatins the URLs of the folders where the audio files are located.
  // Maybe not cross platform friendly?
  List<String> audioLibraryUrls = <String>["/storage/emulated/0/test_lunify"];
  
  // List of playlists
  List<AudioPlaylist> playlists = [];

  AudioPlaylist currentPlaylist = AudioPlaylist(playlistName: "Current Playlist");
  AudioPlaylist library = AudioPlaylist(playlistName: "Library");  // Contains all the audio files that the device has to offer.

  late Function(SongModel) _onSongClicked;

  // These are used to switch to the player tab when a song is clicked.
  late TabController _currentTabs;
  late int _playerTabIndex;

  late AudioPlayer _audioPlayer;
  
  // The current song playing: initially it contains empty values.
  SongModel currentSongPlaying = SongModel(
    songUrl: "", 
    songName: "", 
    songArtist: "", 
    coverPicture: []);

  AudioFileHandler(List<String> additionalAudioLibraryUrls) {
    // Add the additional URLs
    for (String url in additionalAudioLibraryUrls) {
      audioLibraryUrls.add(url);
    }

    _onSongClicked = (model) {};
  }

  SongModel getCurrentSongPlaying()             { return currentSongPlaying; }
  AudioPlaylist getCurrentPlaylist()            { return currentPlaylist; }

  void setCurrentSongPlaying(SongModel model)   { currentSongPlaying = model; notifyListeners(); }

  Future<bool> loadAudioMetadataFromDisk(void Function(double)onProgressCallback) async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      return false;
    } else {
      print("Storage Permission Accepted!");

      int totalFiles = 0;
      int fileCount = 0;

      List<List<FileSystemEntity>> fileEachAudioUrl = [];

      for(String url in audioLibraryUrls) {
        Directory urlDirectory = Directory(url);
        List<FileSystemEntity> files = urlDirectory.listSync(recursive: true);

        fileEachAudioUrl.add(files);
        totalFiles += files.length;
      }

      for(List<FileSystemEntity> files in fileEachAudioUrl) {
        for(var file in files) {
          if(file is File && (file.path.endsWith('mp3') || file.path.endsWith('flac'))) {
            var songMetadata = await AudioMetadata.extract(file);
            if(songMetadata != null) {
              library.songs.add(
                SongModel(
                  songUrl: file.path,
                  songName: songMetadata.trackName ?? "Unknown name", 
                  songArtist: songMetadata.firstArtists  ?? "Unknown artist", 
                  coverPicture: songMetadata.coverData ?? []
                )
              );
            }
            fileCount++;
            onProgressCallback(fileCount / totalFiles);
          }
        }
      }

      // TEMP
      currentPlaylist = library;
      return true;
    }
  }

  void setTabController(TabController controller) {
    _currentTabs = controller;
  }

  void setPlayerTabIndex(int index) {
    _playerTabIndex = index;
  }

  void setAudioPlayer(AudioPlayer player) {
    _audioPlayer = player;
  }

  void setSongClickedCallback(void Function(SongModel)onSongClicked) {
    _onSongClicked = onSongClicked;
  }

  void songClickedCallback(SongModel model) {
    _currentTabs.animateTo(_playerTabIndex);
    _audioPlayer.stop();
    _onSongClicked(model);
    currentSongPlaying = model;
  }
}
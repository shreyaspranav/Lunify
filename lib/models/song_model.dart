import 'package:flutter/material.dart';

class SongModel {
  String songUrl;
  String songName;
  String songArtist;
  Image? coverPicture;
  List<int>? coverPictureRaw;

  SongModel({
    required this.songUrl,
    required this.songName,
    required this.songArtist,
    required this.coverPicture,
    required this.coverPictureRaw
  });
}

class SharedSongData with ChangeNotifier {
  SongModel _model = SongModel(
    songUrl: "", 
    songName: "", 
    songArtist: "", 
    coverPicture: null,
    coverPictureRaw: []
  );

  SongModel get model => _model;

  set model(SongModel model) {
    _model = model;
    notifyListeners(); // Run the build() function again.
  }
}
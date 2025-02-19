import 'package:flutter/material.dart';
import 'package:lunify/models/song_model.dart';

class AlbumModel {
  String name;
  String artist;
  int trackCount;
  Image? coverImage;
  List<SongModel> tracks = []; // This is sorted in track order.

  AlbumModel({
    required this.name,
    required this.artist, 
    required this.trackCount,
    required this.coverImage
  });
}
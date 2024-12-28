import 'package:flutter/material.dart';

class AlbumModel {
  String name;
  String artist;
  int trackCount;
  Image? coverImage;

  AlbumModel({
    required this.name,
    required this.artist, 
    required this.trackCount,
    required this.coverImage
  });
}
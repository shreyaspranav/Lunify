import 'package:flutter/material.dart';
import 'package:lunify/models/album_model.dart';

class ArtistModel {
  String name;
  List<AlbumModel> albums;
  Widget? cover;

  ArtistModel({required this.name, required this.albums});
}
import 'package:flutter/material.dart';
import 'package:lunify/models/album_model.dart';

class ArtistModel {
  String name;
  List<AlbumModel> albums;
  Image? coverImage; // Cover Image of a album.

  ArtistModel({required this.name, required this.albums, required this.coverImage});
}
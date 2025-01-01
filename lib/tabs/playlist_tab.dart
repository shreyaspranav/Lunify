import 'dart:core';
import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';
import 'package:lunify/audio_service_provider.dart';
import 'package:lunify/image_util.dart';
import 'package:lunify/models/song_model.dart';
import 'package:lunify/widgets/song_list_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_metadata_extractor/audio_metadata_extractor.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

class PlaylistTab extends StatefulWidget {
  const PlaylistTab({super.key});

  @override
  State<PlaylistTab> createState() => _PlaylistTabState();
}

class _PlaylistTabState extends State<PlaylistTab> {
  
  AudioServiceProvider? _audioServiceProvider;

  bool _isAudioMetadataLoading = true;
  double _audioMetadataLoadingProgress = 0.0;
  
  @override
  void initState() {
    super.initState();

    _audioServiceProvider = Provider.of<AudioServiceProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {

    AudioPlaylist currentPlaylist = _audioServiceProvider!.getCurrentPlaylist();

    return Scaffold(
      body: currentPlaylist.songs.isEmpty ? 
        Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.playlist_remove, 
                  size: 200,),
                SizedBox(height: 10),
                Text("The Current Playlist seems to be empty, add songs to the current playlist."),
                SizedBox(width: 10),
              ],
            )
          )
        ) : 
        SongListView(
          songsToDisplay: currentPlaylist.songs, 
          loading: false,
          displayIndex: false,
          onTapFn: () {

          },
        )
    );
  }
}
import 'dart:core';
import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';
import 'package:lunify/audio_service_provider.dart';
import 'package:lunify/image_util.dart';
import 'package:lunify/models/song_model.dart';
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
    // _requstPermissionAndScanSongs();

    _audioServiceProvider = Provider.of<AudioServiceProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadAudioMetadata();
    });
  }

  @override
  Widget build(BuildContext context) {

    AudioPlaylist currentPlaylist = _audioServiceProvider!.getCurrentPlaylist();

    return Scaffold(
      body: 
      _audioServiceProvider!.isMetadataLoaded() ? 
        ListView.builder(
          itemCount: currentPlaylist.songs.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(currentPlaylist.songs[index].songName),
              subtitle: Text(currentPlaylist.songs[index].songArtist),
              leading:  currentPlaylist.songs[index].coverPicture ?? 
                const Icon(
                  Icons.music_note_outlined,
                  size: 55,
                ),
              onTap: () {
                Provider.of<AudioServiceProvider>(context, listen: false).songClickedCallback(index);
              },
            );
          }
        ) : 
        Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                Text("Loading Audio Metadata..."),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  value: _audioMetadataLoadingProgress,
                  minHeight: 12,
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                SizedBox(width: 10),
              ],
            )
          )
        )
    );
  }

  void _loadAudioMetadata() {
    setState(() {
      _isAudioMetadataLoading = true;
    });

    var success = Provider.of<AudioServiceProvider>(context, listen: false).loadAudioMetadataFromDisk((progress) {
      if(mounted) {
        setState(() {
          _audioMetadataLoadingProgress = progress;
          print(progress);
          if(_audioMetadataLoadingProgress == 1.0) {
              _isAudioMetadataLoading = false;
              print("False Set.");
          }
        });  
      }
    });

    success.then((is_success){

    });
  }
}
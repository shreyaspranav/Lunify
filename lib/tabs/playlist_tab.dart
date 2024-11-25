import 'dart:core';
import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';
import 'package:lunify/audio_file_handler.dart';
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
  
  AudioFileHandler? _audioFileHandler;
  
  @override
  void initState() {
    super.initState();
    // _requstPermissionAndScanSongs();

    _audioFileHandler = Provider.of<AudioFileHandler>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {

    AudioPlaylist currentPlaylist = _audioFileHandler!.getCurrentPlaylist();

    return Scaffold(
      body: 
      // _audioFileHandler. ? 
      //   Padding(
      //     padding: const EdgeInsets.all(20),
      //     child: Center(
      //       child: LinearProgressIndicator(value: _scanningProgress)
      //     ),
      //   ) :  
      ListView.builder(
        itemCount: currentPlaylist.songs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(currentPlaylist.songs[index].songName),
            subtitle: Text(currentPlaylist.songs[index].songArtist),
            leading:  ImageUtil.isValidImage(currentPlaylist.songs[index].coverPicture) ?  
              Image.memory(Uint8List.fromList(currentPlaylist.songs[index].coverPicture)) : 
              const Icon(
                Icons.music_note_outlined,
                size: 55,
              ),
            onTap: () {
              Provider.of<AudioFileHandler>(context, listen: false).songClickedCallback(
                SongModel(
                  songUrl:       currentPlaylist.songs[index].songUrl, 
                  songName:      currentPlaylist.songs[index].songName, 
                  songArtist:    currentPlaylist.songs[index].songArtist, 
                  coverPicture:  currentPlaylist.songs[index].coverPicture
              ));
            },
          );
        }
      )
    );
  }
}
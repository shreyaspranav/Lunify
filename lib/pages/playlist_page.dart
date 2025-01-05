import 'dart:ui';
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lunify/audio_service_provider.dart';
import 'package:lunify/models/album_model.dart';
import 'package:lunify/models/song_model.dart';
import 'package:lunify/theme_provider.dart';
import 'package:lunify/widgets/song_list_view.dart';
import 'package:provider/provider.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:lunify/theme_provider.dart';

class PlaylistPage extends StatefulWidget {
  final Image cover;
  AudioPlaylist playlist;

  PlaylistPage({super.key, required this.cover, required this.playlist});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {

  late SongModel _highlightedSong;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      _highlightedSong = Provider.of<AudioServiceProvider>(context, listen: false).getCurrentSongPlaying();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 340.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title:  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.playlist.playlistName,
                  ), // Space for symmetry with the back button
                ],
              ),
              centerTitle: true,
              background: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: widget.cover.image,
                        fit: BoxFit.fitWidth
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Provider.of<ThemeProvider>(context, listen: true).currentTheme == ThemeMode.light ? 
                            const Color.fromRGBO(245, 245, 245, 1) : const Color.fromRGBO(20, 20, 20, 1), 
                          colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 2 : 1].withOpacity(0.2)
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _containerButton(177, 50, 
                        colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 2 : 3], 0.4, const Icon(Icons.play_arrow, size: 40), 
                      () {

                      }),
                      _containerButton(177, 50, 
                        colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 2 : 3], 0.4, const Icon(Icons.shuffle, size: 35), 
                      () {
                        
                      })
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    top: 7,
                    left: 0
                  ),
                  child: Text(
                    "Tracks",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 25
                    ),
                  ),
                )
              ],
            ),
          ),
          // SliverList for song tracks
          SliverToBoxAdapter(
            child: SongListView(
              songsToDisplay: widget.playlist.songs, 
              loading: false,
              displayIndex: false,
              scrollable: false,
              displayContext: DisplayContext.playlistContext,
              playlist: widget.playlist,
            ),
          )
        ],
      ),
    );
  }

  Widget _containerButton(double width, double height, Color color, double opacity, Icon icon, Function() onClicked) {
    return SizedBox(
      width: width,
      height: height,
      child: InkWell(
        onTap: onClicked,
        child: Container(
          padding: const EdgeInsets.only(
            left: 10,
            right: 10
          ),
          decoration: BoxDecoration(
            color: Color.fromRGBO(color.red, color.green, color.blue, opacity),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Center(child: icon)
        ),
      ),
    );
  }
}
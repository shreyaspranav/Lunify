import 'dart:ui';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lunify/audio_service_provider.dart';
import 'package:lunify/models/album_model.dart';
import 'package:lunify/theme_provider.dart';
import 'package:lunify/widgets/song_list_view.dart';
import 'package:provider/provider.dart';
import 'package:palette_generator/palette_generator.dart';

class AlbumPage extends StatefulWidget {
  final AlbumModel album;

  const AlbumPage({required this.album, Key? key}) : super(key: key);

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {

  Color _albumCoverPrimaryColor = Color.fromARGB(0, 0, 0, 0);

  Future<Color> _getPrimaryColor(Image? image) async {
    if(image == null) {
      return const Color.fromARGB(0, 0, 0, 0);
    }

    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(widget.album.coverImage!.image);
    return generator.dominantColor!.color;
  }

  @override
  void initState() {
    super.initState();

    var color = _getPrimaryColor(widget.album.coverImage);
    color.then((c) {
      setState(() {
        _albumCoverPrimaryColor = c;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                padding: const EdgeInsets.only(
                  left: 15,
                ),
                child: Text(
                  widget.album.name,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 18
                  ),
                ),
              ),
              centerTitle: true,
              background: widget.album.coverImage != null ?
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: widget.album.coverImage!.image,
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
                            Color.fromRGBO(_albumCoverPrimaryColor.red, _albumCoverPrimaryColor.green, _albumCoverPrimaryColor.blue, 0.3)
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter
                        ),
                      ),
                    )
                  ],
                ) : 
                Container(
                  color: Provider.of<ThemeProvider>(context, listen: true).currentTheme == ThemeMode.light ? 
                    const Color.fromRGBO(245, 245, 245, 1) : const Color.fromRGBO(20, 20, 20, 1),
                  child: Icon(
                    Icons.album,
                    size: 100,
                    color: Provider.of<ThemeProvider>(context, listen: true).currentTheme == ThemeMode.light ? 
                      const Color.fromRGBO(20, 20, 20, 1) : const Color.fromRGBO(245, 245, 245, 1),
                  ),
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
                      _containerButton(177, 50, _albumCoverPrimaryColor, 0.4, const Icon(Icons.play_arrow, size: 40), 
                      () {

                      }),
                      _containerButton(177, 50, _albumCoverPrimaryColor, 0.4, const Icon(Icons.shuffle, size: 35), 
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final track = widget.album.tracks[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                    backgroundColor: Color.fromRGBO(_albumCoverPrimaryColor.red, _albumCoverPrimaryColor.green, _albumCoverPrimaryColor.blue, 0.4),
                  ),
                  title: Text(track.songName),
                  subtitle: Text(track.songArtist),
                  onTap: () {
                    // Handle track click (e.g., play song)
                    Provider.of<AudioServiceProvider>(context, listen: false).songClickedCallbackOnAlbum(widget.album, index);
                    print("Selected Index: $index");
                  },
                );
              },
              childCount: widget.album.tracks.length,
            ),
          ),
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
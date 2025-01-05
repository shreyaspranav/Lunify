import 'package:flutter/material.dart';
import 'package:lunify/audio_service_provider.dart';
import 'package:lunify/models/album_model.dart';
import 'package:lunify/models/artist_model.dart';
import 'package:lunify/models/song_model.dart';
import 'package:lunify/pages/album_page.dart';
import 'package:lunify/theme_provider.dart';
import 'package:lunify/widgets/song_list_view.dart';
import 'package:provider/provider.dart';
import 'package:marquee/marquee.dart';

class ArtistPage extends StatefulWidget {
  final ArtistModel artist;

  const ArtistPage({super.key, required this.artist});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {

  List<SongModel> _artistTracks = [];
  late SongModel _highlightedSong;

  @override
  void initState() {
    super.initState();
    _processArtistTracks();

    _highlightedSong = Provider.of<AudioServiceProvider>(context, listen: false).getCurrentSongPlaying();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.artist.name),
              centerTitle: true,
              background: Stack(
                children: [
                  widget.artist.cover ?? Icon(Icons.person),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Provider.of<ThemeProvider>(context, listen: true).currentTheme == ThemeMode.light ? 
                              const Color.fromRGBO(245, 245, 245, 1) : const Color.fromRGBO(20, 20, 20, 1),
                          Color.fromRGBO(0, 0, 0, 0),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      )
                    ),
                  )
                ]
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _containerButton(183, 50, Provider.of<ThemeProvider>(context, listen: true).currentTheme == ThemeMode.dark ? 
                              const Color.fromRGBO(245, 245, 245, 1) : const Color.fromRGBO(20, 20, 20, 1), 0.2, const Icon(Icons.play_arrow, size: 40), 
                      () {

                      }),
                      _containerButton(183, 50, Provider.of<ThemeProvider>(context, listen: true).currentTheme == ThemeMode.dark ? 
                              const Color.fromRGBO(245, 245, 245, 1) : const Color.fromRGBO(20, 20, 20, 1), 0.2, const Icon(Icons.shuffle, size: 35), 
                      () {
                        
                      })
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: 12,
                top: 5,
                bottom: 5
              ),
              child: Text(
                "Albums",
                style: TextStyle(
                  fontSize: 20
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10
              ),
              child: SizedBox(
                height: 200,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    childAspectRatio: 4 / 3
                  ), 
                  itemCount: widget.artist.albums.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Provider.of<ThemeProvider>(context, listen: true).currentTheme == ThemeMode.light ? Colors.grey[200] : const Color.fromARGB(20, 255, 255, 255),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: widget.artist.albums[index].coverImage ??
                              const Icon(
                                Icons.album,
                                size: 120,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                              child: SizedBox(
                                height: 20,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final textPainter = TextPainter(
                                      text: TextSpan(
                                        text: widget.artist.albums[index].name,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                      maxLines: 1,
                                      textDirection: TextDirection.ltr,
                                    );
                                    textPainter.layout(maxWidth: constraints.maxWidth);
              
                                    if (textPainter.didExceedMaxLines) {
                                      // Use Marquee if text overflows
                                      return Marquee(
                                        text: widget.artist.albums[index].name,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        scrollAxis: Axis.horizontal,
                                        blankSpace: 40.0,
                                        velocity: 30.0,
                                        startPadding: 10.0,
                                        accelerationDuration: const Duration(seconds: 1),
                                        decelerationDuration: const Duration(seconds: 1),
                                      );
                                    } else {
                                      // Use Text if it fits
                                      return Text(
                                        widget.artist.albums[index].name,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: SizedBox(
                                      height: 17,
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          final textPainter = TextPainter(
                                            text: TextSpan(
                                              text: widget.artist.albums[index].artist,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            maxLines: 1,
                                            textDirection: TextDirection.ltr,
                                          );
                                          textPainter.layout(maxWidth: constraints.maxWidth);
              
                                          if (textPainter.didExceedMaxLines) {
                                            return Marquee(
                                              text: widget.artist.albums[index].artist,
                                              style: const TextStyle(fontSize: 12),
                                              scrollAxis: Axis.horizontal,
                                              blankSpace: 30.0,
                                              velocity: 20.0,
                                            );
                                          } else {
                                            return Text(
                                              widget.artist.albums[index].artist,
                                              style: const TextStyle(fontSize: 12),
                                              textAlign: TextAlign.start,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "${widget.artist.albums[index].trackCount} Tracks",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => AlbumPage(album: widget.artist.albums[index]))
                        );
                      },
                    );
                  }
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: 12,
                top: 10,
                bottom: 5
              ),
              child: Text(
                "Tracks",
                style: TextStyle(
                  fontSize: 20
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SongListView(
              songsToDisplay: _artistTracks, 
              loading: false, 
              displayContext: DisplayContext.artistsContext,
              displayIndex: false,
              scrollable: false,
            ),
          ),
        ]
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
  
  Future<void> _processArtistTracks() async {
    for(AlbumModel album in widget.artist.albums) {
      for(SongModel song in album.tracks) {
        setState(() {
          _artistTracks.add(song);
        });
      }
    }
  }
}
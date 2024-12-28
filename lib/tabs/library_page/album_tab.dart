import 'package:flutter/material.dart';
import 'package:lunify/audio_service_provider.dart';
import 'package:lunify/models/album_model.dart';
import 'package:lunify/theme_provider.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';


class AlbumTab extends StatefulWidget {
  const AlbumTab({super.key});

  @override
  State<AlbumTab> createState() => _AlbumTabState();
}

class _AlbumTabState extends State<AlbumTab> {
  List<AlbumModel> _albums = [];
  
  @override
  void initState() {
    var _audioServiceProvider = Provider.of<AudioServiceProvider>(context, listen: false);
    _albums = _audioServiceProvider.getAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 0.75,
          ),
          itemCount: _albums.length,
          itemBuilder: (context, index) {
            return Material(
              child: InkWell(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Provider.of<ThemeProvider>(context, listen: true).currentTheme == ThemeMode.light ? Colors.grey[200] : const Color.fromARGB(20, 255, 255, 255),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _albums[index].coverImage ??
                        const Icon(
                          Icons.album,
                          size: 120,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 20,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final textPainter = TextPainter(
                              text: TextSpan(
                                text: _albums[index].name,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              maxLines: 1,
                              textDirection: TextDirection.ltr,
                            );
                            textPainter.layout(maxWidth: constraints.maxWidth);
                
                            if (textPainter.didExceedMaxLines) {
                              // Use Marquee if text overflows
                              return Marquee(
                                text: _albums[index].name,
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
                                _albums[index].name,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: SizedBox(
                              height: 17,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final textPainter = TextPainter(
                                    text: TextSpan(
                                      text: _albums[index].artist,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    maxLines: 1,
                                    textDirection: TextDirection.ltr,
                                  );
                                  textPainter.layout(maxWidth: constraints.maxWidth);
                
                                  if (textPainter.didExceedMaxLines) {
                                    return Marquee(
                                      text: _albums[index].artist,
                                      style: const TextStyle(fontSize: 12),
                                      scrollAxis: Axis.horizontal,
                                      blankSpace: 30.0,
                                      velocity: 20.0,
                                    );
                                  } else {
                                    return Text(
                                      _albums[index].artist,
                                      style: const TextStyle(fontSize: 12),
                                      textAlign: TextAlign.start,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          Text(
                            "${_albums[index].trackCount} Tracks",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  // On Album tap
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

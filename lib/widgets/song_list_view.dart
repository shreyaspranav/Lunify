import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lunify/audio_service_provider.dart';
import 'package:lunify/models/song_model.dart';
import 'package:lunify/theme_provider.dart';
import 'package:provider/provider.dart';

enum DisplayContext {
  songsContext, playlistContext, currentPlayingQueueContext, artistsContext
}

class SongListView extends StatefulWidget {

  List<SongModel> songsToDisplay;
  bool loading;
  bool displayIndex;
  bool scrollable;
  DisplayContext displayContext;
  AudioPlaylist? playlist;

  SongListView({super.key, required this.songsToDisplay, required this.loading, required this.displayContext, this.displayIndex = true, this.scrollable = true, this.playlist});

  @override
  State<SongListView> createState() => _SongListViewState();
}

class _SongListViewState extends State<SongListView> with TickerProviderStateMixin {

  late SongModel _highlightedSong;

  void initState() {
    super.initState();

    setState(() {
      _highlightedSong = Provider.of<AudioServiceProvider>(context, listen: false).getCurrentSongPlaying();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: widget.scrollable ? null : const NeverScrollableScrollPhysics(),
      shrinkWrap: !widget.scrollable,
      itemCount: widget.songsToDisplay.length,
      itemBuilder: (context, index) {
        if(index == widget.songsToDisplay.length - 1 && widget.loading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return ListTile(
          title: Text(
            widget.songsToDisplay[index].songName,
            style: TextStyle(
              fontWeight: _highlightedSong == widget.songsToDisplay[index] ?
                FontWeight.bold : FontWeight.normal, 
              color: _highlightedSong == widget.songsToDisplay[index] ? colorPalette[2] : 
                Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? Colors.black : Colors.white
            ), 
          ),
          contentPadding: const EdgeInsets.only(
            top: 0,
            bottom: 0,
            left: 10,
            right: 6
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert), 
            onPressed: () {
              switch (widget.displayContext) {
                case DisplayContext.currentPlayingQueueContext:
                  _showOptionsInCurrentPlayingQueueContext(context, widget.songsToDisplay[index]);
                  break;
                case DisplayContext.playlistContext:
                  _showOptionsInPlaylistContext(context, widget.playlist!, widget.songsToDisplay[index]);
                  break;
                case DisplayContext.songsContext:
                case DisplayContext.artistsContext:
                  _showOptionsInSongsContext(context, widget.songsToDisplay[index]);
                  break;
                default:
              }
            }
          ),
          subtitle: Text(widget.songsToDisplay[index].songArtist),
          leading:  Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.displayIndex ? SizedBox(
                width: 30,
                child: Center(
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                )
              ) : Container(),
              const SizedBox(width: 5),
              widget.songsToDisplay[index].coverPicture ?? 
                const Icon(
                  Icons.music_note_outlined,
                  size: 55,
                ),
            ],
          ),
          onTap: () {
            switch (widget.displayContext) {
              case DisplayContext.currentPlayingQueueContext:
                Provider.of<AudioServiceProvider>(context, listen: false).playSongWithinQueue(index);
                break;
              case DisplayContext.playlistContext:
              case DisplayContext.artistsContext:
                Provider.of<AudioServiceProvider>(context, listen: false).playSongs(widget.songsToDisplay, index);
                break;
              case DisplayContext.songsContext:
                Provider.of<AudioServiceProvider>(context, listen: false).appendSongInQueueAndPlay(widget.songsToDisplay[index]);
                break;
              default:
            }

            setState(() {
              _highlightedSong = widget.songsToDisplay[index];
            });
          },
        );
      }
    );
  }

  void _showOptionsInSongsContext(BuildContext context, SongModel song) {
    showModalBottomSheet(
      context: context, 
      builder: (context) {
        return FractionallySizedBox(
          widthFactor: 1,
          heightFactor: 0.45,

          child: Padding(
            padding: const EdgeInsets.only(
              left: 15,
              right: 10,
              top: 15
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          child: song.coverPicture ?? const Icon(Icons.music_note),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 15
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.songName,
                              style: const TextStyle(
                                fontSize: 20
                              ),
                            ),
                            Text(
                              song.songArtist,
                              style: const TextStyle(
                                fontSize: 15
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                SizedBox(
                  height: 5,
                ),
                ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6
                      ),
                      leading: Icon(
                        Icons.queue_music_rounded,
                        color: colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 2 : 3],
                        size: 40,
                      ),
                      title: const Text("Add to the Playing Queue"),
                      onTap: () {
                        Provider.of<AudioServiceProvider>(context, listen: false).appendSongInQueueAndPlay(song, play: false);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6
                      ),
                      leading: Icon(
                        Icons.playlist_add_rounded,
                        color: colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 2 : 3],
                        size: 40,
                      ),
                      title: Text("Add to Playlist..."),
                      onTap: () {
                        Navigator.pop(context);

                        showDialog(
                          context: context, 
                          builder: (context) {
                            List<AudioPlaylist> playlists = Provider.of<AudioServiceProvider>(context, listen: false).getPlaylists();

                            return SizedBox(
                              child: Stack(
                                children: [
                                  BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                    child: Container(color: Colors.black.withOpacity(0.0)),
                                  ),
                                  Center(
                                    child: FadeTransition(
                                      opacity: Tween<double>(begin: 0, end: 1).animate(
                                        CurvedAnimation(
                                          parent: AnimationController(
                                            vsync: this,
                                            duration: Durations.medium3,
                                          )..forward(),
                                          curve: Curves.easeInOut,
                                        ),
                                      ),
                                      child: SizedBox(
                                        width: 400,
                                        height: 300,
                                        child: Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: SizedBox(
                                            width: 400,
                                            height: 500,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 20,
                                                horizontal: 15
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.playlist_add_rounded,
                                                        size: 35,
                                                        color: colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 2 : 3],
                                                      ),
                                                      const SizedBox(width: 10),
                                                      const Text(
                                                        "Add to Playlist",
                                                        style: TextStyle(
                                                          fontSize: 22, 
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  const Divider(),
                                                  Expanded(
                                                    child: ListView.builder(
                                                      itemCount: playlists.length,
                                                      itemBuilder: (context, index) {
                                                        return ListTile(
                                                          title: Text(playlists[index].playlistName),
                                                          onTap: () {
                                                            setState(() {
                                                              Provider.of<AudioServiceProvider>(context, listen: false).addSongToPlaylist(playlists[index], song);
                                                              Provider.of<AudioServiceProvider>(context, listen: false).serializePlaylists();
                                                            });
                                                            Navigator.pop(context);
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }

  void _showOptionsInPlaylistContext(BuildContext context, AudioPlaylist playlist, SongModel song) {
    showModalBottomSheet(
      context: context, 
      builder: (context) {
        return FractionallySizedBox(
          widthFactor: 1,
          heightFactor: 0.45,

          child: Padding(
            padding: const EdgeInsets.only(
              left: 15,
              right: 10,
              top: 15
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          child: song.coverPicture ?? const Icon(Icons.music_note),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 15
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.songName,
                              style: const TextStyle(
                                fontSize: 20
                              ),
                            ),
                            Text(
                              song.songArtist,
                              style: const TextStyle(
                                fontSize: 15
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                SizedBox(
                  height: 5,
                ),
                ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6
                      ),
                      leading: Icon(
                        Icons.queue_music_rounded,
                        color: colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 2 : 3],
                        size: 40,
                      ),
                      title: const Text("Add to the Playing Queue"),
                      onTap: () {
                        Provider.of<AudioServiceProvider>(context, listen: false).appendSongInQueueAndPlay(song, play: false);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6
                      ),
                      leading: Icon(
                        Icons.playlist_remove_rounded,
                        color: colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 2 : 3],
                        size: 40,
                      ),
                      title: Text("Delete From Playlist"),
                      onTap: () {
                        setState(() {
                          Provider.of<AudioServiceProvider>(context, listen: false).deleteSongFromPlaylist(playlist, song);
                          Provider.of<AudioServiceProvider>(context, listen: false).serializePlaylists();
                        });
                        Navigator.pop(context);
                        
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }

  void _showOptionsInCurrentPlayingQueueContext(BuildContext context, SongModel song) {
    showModalBottomSheet(
      context: context, 
      builder: (context) {
        return FractionallySizedBox(
          widthFactor: 1,
          heightFactor: 0.34,

          child: Padding(
            padding: const EdgeInsets.only(
              left: 15,
              right: 10,
              top: 15
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          child: song.coverPicture ?? const Icon(Icons.music_note),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 15
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.songName,
                              style: const TextStyle(
                                fontSize: 20
                              ),
                            ),
                            Text(
                              song.songArtist,
                              style: const TextStyle(
                                fontSize: 15
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                SizedBox(
                  height: 5,
                ),
                ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6
                      ),
                      leading: Icon(
                        Icons.playlist_remove_rounded,
                        color: colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 2 : 3],
                        size: 40,
                      ),
                      title: Text("Delete From Playing Queue"),
                      onTap: () {
                        setState(() {
                          Provider.of<AudioServiceProvider>(context, listen: false).deleteFromCurrentQueue(song);
                        });
                        Navigator.pop(context);
                        
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }
}
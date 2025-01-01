import 'package:flutter/material.dart';
import 'package:lunify/audio_service_provider.dart';
import 'package:lunify/models/song_model.dart';
import 'package:lunify/theme_provider.dart';
import 'package:provider/provider.dart';

class SongListView extends StatefulWidget {

  List<SongModel> songsToDisplay;
  bool loading;
  bool displayIndex;
  Function onTapFn;

  SongListView({super.key, required this.songsToDisplay, required this.loading, required this.onTapFn, this.displayIndex = true});

  @override
  State<SongListView> createState() => _SongListViewState();
}

class _SongListViewState extends State<SongListView> {

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
              color: _highlightedSong == widget.songsToDisplay[index] ? const Color(0xFF7E60BF) : 
                Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? Colors.black : Colors.white
            ), 
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
            widget.onTapFn();
            Provider.of<AudioServiceProvider>(context, listen: false).songClickedCallback(widget.songsToDisplay[index]);

            setState(() {
              _highlightedSong = widget.songsToDisplay[index];
            });
          },
        );
      }
    );
  }
}
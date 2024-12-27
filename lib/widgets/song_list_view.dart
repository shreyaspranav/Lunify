import 'package:flutter/material.dart';
import 'package:lunify/audio_service_provider.dart';
import 'package:lunify/models/song_model.dart';
import 'package:provider/provider.dart';

class SongListView extends StatelessWidget {

  List<SongModel> songsToDisplay;
  bool loading;

  SongListView({required this.songsToDisplay, required this.loading});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: songsToDisplay.length,
      itemBuilder: (context, index) {
        if(index == songsToDisplay.length - 1 && loading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return ListTile(
          title: Text(songsToDisplay[index].songName),
          subtitle: Text(songsToDisplay[index].songArtist),
          leading:  songsToDisplay[index].coverPicture ?? 
            const Icon(
              Icons.music_note_outlined,
              size: 55,
            ),
          onTap: () {
            Provider.of<AudioServiceProvider>(context, listen: false).songClickedCallback(index);
          },
        );
      }
    );
  }
}
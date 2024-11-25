import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:lunify/audio_file_handler.dart';
import 'package:lunify/image_util.dart';
import 'package:lunify/models/song_model.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

class PlayerTab extends StatefulWidget {
  PlayerTab({super.key});

  @override
  State<PlayerTab> createState() => _PlayerTabState();
}

// Repeat States
enum RepeatState { off, playlist, current }

class _PlayerTabState extends State<PlayerTab> {

  // The audio player object:
  final audioPlayer = AudioPlayer();
  Widget? coverPicture;

  // Variables that handle the state of the  player
  bool _paused = true;
  bool _isShuffleOn = false;
  RepeatState _repeatState = RepeatState.off;

  // TEMP: Song seconds calculation:
  late SongModel _currentSongPlaying;
  Duration _songDuration = Duration.zero;
  Duration _songProgess = Duration.zero;

  String _convertDurationToString(Duration d) {
    // For now only deal with seconds, minutes and hours.
    int hours = d.inHours;
    int minutes = d.inMinutes.remainder(60); 
    int seconds = d.inSeconds.remainder(60);

    return hours == 0 ? 
    "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}" : 
    "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}"; 
  }

  // Methods that modifies the state: ---------------------------------------------------------------------------
  void _togglePlayPause() {
    setState(() {
      _paused = !_paused;
      if(_paused) {
        audioPlayer.pause();
      } else {
        audioPlayer.play();
      } 
    });
  }

  void _toggleShuffle() {
    setState(() {
      _isShuffleOn = !_isShuffleOn;
    });
  }

  void _toggleRepeatState() {
    setState(() {
      // Toggling between RepeatState.off -> RepeatState.playlist -> RepeatState.current 
      if(_repeatState == RepeatState.off) {
        _repeatState = RepeatState.playlist;
      }
      else if(_repeatState == RepeatState.playlist) {
        _repeatState = RepeatState.current;
      }
      else if(_repeatState == RepeatState.current) {
        _repeatState = RepeatState.off;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    Provider.of<AudioFileHandler>(context, listen: false).setAudioPlayer(audioPlayer);

    Provider.of<AudioFileHandler>(context, listen: false).setSongClickedCallback((currentSong) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        print("Mounted: $mounted");
        if(mounted) {
          setState(() {
            // if(Directory(currentSong.songUrl).exists()) 
            {
              audioPlayer.stop();
              audioPlayer.setUrl(currentSong.songUrl);
              _paused = false;
              _songProgess = Duration(seconds: 0);
              audioPlayer.play();
            }
          });
        }
      });
    });

    _currentSongPlaying = Provider.of<AudioFileHandler>(context, listen: false).getCurrentSongPlaying();
    if(!_currentSongPlaying.songUrl.isEmpty) {
      audioPlayer.setUrl(_currentSongPlaying.songUrl);
    }

    // This fixed the image flickering issues
    coverPicture = ImageUtil.isValidImage(_currentSongPlaying.coverPicture) ?  
              Image.memory(Uint8List.fromList(_currentSongPlaying.coverPicture)) : 
              const Padding(
                padding: EdgeInsets.only(
                  top: 27,
                  bottom: 27
                ),
                child: Icon(
                  Icons.music_note_outlined,
                  size: 300,
                ),
              );
              
    audioPlayer.positionStream.listen((position) {
      if(mounted) {
        setState(() {
          _songProgess = position;
        });
      }
    });

    audioPlayer.durationStream.listen((duration) {
      if(mounted) {
        setState(() {
          _songDuration = duration!;
        });
      }
    });
  }

  

  // The build method: --------------------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 40, 
              bottom: 40,
              left: 20,
              right: 20
            ),
            child: coverPicture ?? const Placeholder(),
          ),

          // Name of the song
          Text(
            _currentSongPlaying.songName.isEmpty ?
            "Unknown Title" : _currentSongPlaying.songName,
            style: const TextStyle(
              fontSize: 24.0
            ),
          ),

          const SizedBox(
            height: 10,
          ),
          // Name of the artist
          Text(
            _currentSongPlaying.songArtist.isEmpty ?
            "Unknown Artist" : _currentSongPlaying.songArtist,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 50
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(_convertDurationToString(_songProgess)),
                Spacer(),
                Text(_convertDurationToString(_songDuration))
              ],
            ),
          ),
          Slider(
            value: _songProgess.inSeconds.toDouble(), 
            min: 0.0,
            max: _songDuration.inSeconds.toDouble(),
            divisions: _songDuration.inSeconds == 0 ? 1 : _songDuration.inSeconds,
            onChanged: (val) {
              setState(() {
                _songProgess = Duration(seconds: val.toInt());
                audioPlayer.seek(_songProgess);
              });
            }
          ),

          SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _toggleRepeatState, 
                  icon: getCurrentRepeatIcon()
                ),
                IconButton(
                  onPressed: () {}, 
                  icon: const Icon(Icons.skip_previous)
                ),
                IconButton(
                  onPressed: _togglePlayPause,
                  icon: _paused ? const Icon(Icons.play_arrow) : const Icon(Icons.pause),
                  iconSize: 50,
                ),
                IconButton(
                  onPressed: () {}, 
                  icon: const Icon(Icons.skip_next)
                ),
                IconButton(
                  onPressed: _toggleShuffle, 
                  icon: _isShuffleOn ? const Icon(Icons.shuffle_on_rounded) : const Icon(Icons.shuffle)
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // Get the current icon of repeat button:
  Icon getCurrentRepeatIcon() {
    switch(_repeatState) {
      case RepeatState.off:
        return const Icon(Icons.repeat);
      case RepeatState.playlist:
        return const Icon(Icons.repeat_on_rounded);
      case RepeatState.current:
        return const Icon(Icons.repeat_one_on_rounded); 
    }
  } 
}
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:lunify/audio_service_provider.dart';
import 'package:lunify/image_util.dart';
import 'package:lunify/models/song_model.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';

class PlayerTab extends StatefulWidget {
  PlayerTab({super.key});

  @override
  State<PlayerTab> createState() => _PlayerTabState();
}

// Repeat States
enum RepeatState { off, playlist, current }

class _PlayerTabState extends State<PlayerTab> {

  Widget? coverPicture;

  bool _favorite = false;

  // Variables that handle the state of the player
  bool _paused = true;
  bool _isShuffleOn = false;
  RepeatState _repeatState = RepeatState.off;

  // TEMP: Song seconds calculation:
  late SongModel _currentSongPlaying;
  late Duration _songDuration;
  late Duration _songProgess;

  double _playbackSpeed = 1.0;
  double _playbackPitch = 1.0;
  final Color _transparentColor = Color.fromARGB(0, 0, 0, 0);

  List<Color> _songCoverTintPalette = [Color.fromARGB(0, 0, 0, 0), Color.fromARGB(0, 0, 0, 0)];

  String _convertDurationToString(Duration d) {
    // For now only deal with seconds, minutes and hours.
    int hours = d.inHours;
    int minutes = d.inMinutes.remainder(60); 
    int seconds = d.inSeconds.remainder(60);

    return hours == 0 ? 
    "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}" : 
    "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}"; 
  }

  Future<List<Color>> _getPrimaryColor(Image? image) async {
    if(image == null) {
      return [const Color.fromARGB(0, 0, 0, 0), const Color.fromARGB(0, 0, 0, 0)];
    }

    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(image.image);
    return [generator.colors.elementAt(0), generator.colors.elementAt(1)];
  }

  // Methods that modifies the state: ---------------------------------------------------------------------------
  void _togglePlayPause() {
    setState(() {
      _paused = !_paused;
      if(_paused) {
        Provider.of<AudioServiceProvider>(context, listen: false).getAudioPlayer().pause();
      } else {
        Provider.of<AudioServiceProvider>(context, listen: false).getAudioPlayer().play();
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

    // Doing this because the state of the player needs to be restored based upon the "audio player" object.
    _songProgess = Provider.of<AudioServiceProvider>(context, listen: false).getAudioPlayer().position;
    _songDuration = Provider.of<AudioServiceProvider>(context, listen: false).getAudioPlayer().duration ?? Durations.extralong4;
    _paused = !Provider.of<AudioServiceProvider>(context, listen: false).getAudioPlayer().playerState.playing;

    _playbackSpeed = Provider.of<AudioServiceProvider>(context, listen: false).getAudioPlayer().speed;
    
    // For now, let playback speed and pitch be the same(this offers best audio quality)
    // There is only one slider thats sets both the speed and pitch 
    _playbackPitch = _playbackSpeed;

    initCurrentSong();
    
    Provider.of<AudioServiceProvider>(context, listen: false).getAudioPlayer().positionStream.listen((position) {
      if(mounted) {
        setState(() {
          _songProgess = position;
        });
      }
    });

    Provider.of<AudioServiceProvider>(context, listen: false).getAudioPlayer().durationStream.listen((duration) {
      if(mounted) {
        setState(() {
          _songDuration = duration ?? Duration.zero;
        });
      }
    });

    var colors = _getPrimaryColor(_currentSongPlaying.coverPicture);
    colors.then((c) {
      setState(() {
        _songCoverTintPalette = c;
      });
    });

    Provider.of<AudioServiceProvider>(context, listen: false).getAudioPlayer().sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null) {
        if (mounted) {
          setState(() {
            final _audioPlayer = Provider.of<AudioServiceProvider>(context, listen: false);
            if(!_audioPlayer.getCurrentPlaylist().songs.isEmpty) {
              _audioPlayer.setCurrentSongPlaying(_audioPlayer.getCurrentPlaylist().songs[sequenceState.currentIndex]);
            }
            initCurrentSong();
          });
        }
      }
    });
  }

  void initCurrentSong() {
    _currentSongPlaying = Provider.of<AudioServiceProvider>(context, listen: false).getCurrentSongPlaying();
    
    // Set it cover everything:
    // This fixed the image flickering issues
    coverPicture = _currentSongPlaying.coverPicture ?? 
      const Padding(
        padding: EdgeInsets.only(
          top: 20,
          bottom: 20
        ),
        child: Icon(
          Icons.music_note_outlined,
          size: 300,
        ),
      ); 

    var colors = _getPrimaryColor(_currentSongPlaying.coverPicture);
    colors.then((c) {
      setState(() {
        _songCoverTintPalette = c;
      });
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
              top: 20, 
              bottom: 20,
              left: 20,
              right: 20
            ),
            child: Container(
              child: coverPicture ?? const Placeholder(),
            )
          ),

          Padding(
            padding: EdgeInsets.only(
              left: 10,
              right: 10
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context, 
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setter) {
                            return FractionallySizedBox(
                              widthFactor: 1.0,
                              heightFactor: 0.3,
                              child: Column(
                                children: [
                                  SizedBox(height: 25),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 10
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Set Playback Speed/Pitch"),
                                        TextButton(
                                          onPressed: () {
                                            setter(() {
                                              _playbackSpeed = 1.0;
                                              _playbackPitch = 1.0;
                                              Provider.of<AudioServiceProvider>(context, listen: false).setPlaybackSpeed(_playbackSpeed);
                                              Provider.of<AudioServiceProvider>(context, listen: false).setPlaybackPitch(_playbackPitch);
                                              setState(() {});
                                            });
                                          }, 
                                          child: Text("Reset"))
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Slider(
                                    min: 0.6,
                                    max: 1.4,
                                    divisions: 20,
                                    value: _playbackSpeed, 
                                    onChanged: (v) {
                                      setter(() {
                                        _playbackSpeed = v;
                                        _playbackPitch = v;
                                        Provider.of<AudioServiceProvider>(context, listen: false).setPlaybackSpeed(v);
                                        Provider.of<AudioServiceProvider>(context, listen: false).setPlaybackPitch(v);
                                        setState(() {});
                                      });
                                    },
                                    thumbColor: _songCoverTintPalette[0],
                                    activeColor: _songCoverTintPalette[1],
                                  )
                                ],
                              )
                          );
                          },
                          
                        );
                      });
                  }, 
                  child: Text(
                    "S/P:${_playbackPitch.toStringAsFixed(2)}"
                  )
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _favorite = !_favorite;
                    });
                  }, 
                  icon: Icon(_favorite ? Icons.favorite : Icons.favorite_border)
                ),
              ],
            ),
          ),

          // Name of the song
          Padding(
            padding: const EdgeInsets.only(
              top: 15,
              left: 10,
              right: 10
            ),
            child: Center(
              child: 
                Text(
                  _currentSongPlaying.songName.isEmpty ?
                  "Unknown Title" : _currentSongPlaying.songName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24.0,
                  ),
                ),
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
              top: 20
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
                Provider.of<AudioServiceProvider>(context, listen: false).getAudioPlayer().seek(_songProgess);
              });
            },
            thumbColor: _songCoverTintPalette[0] == _transparentColor ? null : _songCoverTintPalette[0],
            activeColor: _songCoverTintPalette[1] == _transparentColor ? null : _songCoverTintPalette[1],
          ),

          const SizedBox(
            height: 35,
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
                  onPressed: () async {
                    await Provider.of<AudioServiceProvider>(context, listen: false).previousSong();
                    setState(() {
                      _currentSongPlaying = Provider.of<AudioServiceProvider>(context, listen: false).getCurrentSongPlaying();
                      coverPicture = _currentSongPlaying.coverPicture ?? 
                        const Padding(
                          padding: EdgeInsets.only(
                            top: 20,
                            bottom: 20
                          ),
                          child: Icon(
                            Icons.music_note_outlined,
                            size: 300,
                          ),
                        );
                    });
                  }, 
                  icon: const Icon(Icons.skip_previous)
                ),
                IconButton(
                  onPressed: _togglePlayPause,
                  icon: _paused ? const Icon(Icons.play_arrow) : const Icon(Icons.pause),
                  iconSize: 50,
                ),
                IconButton(
                  onPressed: () async {
                    await Provider.of<AudioServiceProvider>(context, listen: false).nextSong();
                    setState(() {
                      _currentSongPlaying = Provider.of<AudioServiceProvider>(context, listen: false).getCurrentSongPlaying();
                      coverPicture = _currentSongPlaying.coverPicture ?? 
                        const Padding(
                          padding: EdgeInsets.only(
                            top: 20,
                            bottom: 20
                          ),
                          child: Icon(
                            Icons.music_note_outlined,
                            size: 300,
                          ),
                        );
                    });
                  }, 
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
import 'package:flutter/material.dart';
import 'package:lunify/audio_service_provider.dart';
import 'package:lunify/widgets/song_list_view.dart';
import 'package:provider/provider.dart';

class MusicTab extends StatefulWidget {

  final bool Function() isLoading;

  const MusicTab({required this.isLoading});
  @override
  State<MusicTab> createState() => _MusicTabState();
}

class _MusicTabState extends State<MusicTab> {

  late AudioServiceProvider _audioServiceProvider;

  void initState() {
    super.initState();
    _audioServiceProvider = Provider.of<AudioServiceProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SongListView(
        songsToDisplay: _audioServiceProvider.getAudioLibrary().songs, 
        loading: widget.isLoading(), 
        displayIndex: false,
        optionButtonTapFunction: OptionButtonTapFunction.OptionsInSongsContext
      ),
    );
  }
}
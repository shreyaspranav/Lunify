import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lunify/audio_service_provider.dart';
import 'package:lunify/tabs/library_page/music_tab.dart';
import 'package:lunify/tabs/library_page/album_tab.dart';
import 'package:lunify/tabs/library_page/artist_tab.dart';
import 'package:provider/provider.dart';

class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key});

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  bool _isAudioMetadataLoading = true;
  double _audioMetadataLoadingProgress = 0.0;

  void _loadAudioMetadata() {
    setState(() {
      _isAudioMetadataLoading = true;
    });

    var success = Provider.of<AudioServiceProvider>(context, listen: false).loadAudioMetadata((progress) {
      if(mounted) {
        setState(() {
          _audioMetadataLoadingProgress = progress;
          print(progress);
          if(_audioMetadataLoadingProgress == 1.0) {
              _isAudioMetadataLoading = false;
          }
        });
      }
    });

    success.then((isSuccess) {
        _isAudioMetadataLoading = false;
    });
  }

  bool isMetadataLoading() {
    return _isAudioMetadataLoading;
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController.new(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _loadAudioMetadata();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Library"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            iconText("Music", Icons.music_note, Colors.purple),
            iconText("Albums", Icons.album, Colors.purple),
            iconText("Artists", Icons.person_2_rounded, Colors.purple),
          ] 
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MusicTab(isLoading: isMetadataLoading),
          AlbumTab(),
          ArtistTab()
        ] 
      ),
    );
  }

  Widget iconText(String text, IconData icon, Color iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor),
        Text(" $text"),
      ],
    );
  }
}
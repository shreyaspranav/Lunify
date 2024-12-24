import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lunify/tabs/playlist_tab.dart';

class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key});

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController.new(length: 3, vsync: this);
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
        children: const [
          PlaylistTab(),
          Placeholder(color: Colors.green,),
          Placeholder(color: Colors.blue,)
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
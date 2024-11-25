import 'package:flutter/material.dart';
import 'package:lunify/audio_file_handler.dart';
import 'package:lunify/tabs/home_tab.dart';
import 'package:lunify/tabs/player_tab.dart';
import 'package:lunify/tabs/playlist_tab.dart';

import 'package:lunify/models/song_model.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => 
      AudioFileHandler(
        // Additional audio file lookup directories:
        []
      ),
      child: const MyApp()
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // TEMP: Until all the pages get finished.
  static const Widget toBeImplemented = Scaffold(
    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            "TODO: To be implemented!",
            style: TextStyle(
              fontSize: 24,
            ),
          ),
        )
      ],
    ),
  );

  static List<Widget> childrenTabs = <Widget>[
    const PlaylistTab(),
    PlayerTab(),
    const HomeTab(),
    toBeImplemented,
  ];

  static const List<Tab> tabs = <Tab>[
    Tab(icon: Icon(Icons.home_filled)),
    Tab(icon: Icon(Icons.music_note)),
    Tab(icon: Icon(Icons.album)),
    Tab(icon: Icon(Icons.person_2_sharp))
  ];

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: MyApp.tabs.length, 
      initialIndex: 2,
      vsync: this
    );    

    Provider.of<AudioFileHandler>(context, listen: false).loadAudioMetadataFromDisk((progress) {
      print("Progress of loading songs: ${progress * 100}");
    });

    Provider.of<AudioFileHandler>(context, listen: false).setTabController(_tabController);
    Provider.of<AudioFileHandler>(context, listen: false).setPlayerTabIndex(1);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: getRootPage(),
      theme: ThemeData(
        brightness: Brightness.light,
        // fontFamily: 'DMSerif', 
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        // fontFamily: 'DMSerif', 
      ),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
    );
  }

  Widget getRootPage() {
    return Scaffold (
    appBar: AppBar(
      title: const Text(
          "Lunify",
          style: TextStyle(
            color: Color.fromARGB(128, 140, 0, 255),
            fontSize: 25.0
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {

            }, 
            icon: const Icon(Icons.more_vert)
          )
        ],
      ),
      drawer: const Drawer(
        child: Text("This is a drawer"),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const PlaylistTab(),
          PlayerTab(),
          const HomeTab(),
          MyApp.toBeImplemented
        ]
      ),
          // bottomNavigationBar: BottomAppBar(
          //   child: TabBar(tabs: tabs),
          // 
    );
  }
}
import 'package:flutter/material.dart';
import 'package:lunify/audio_file_handler.dart';
import 'package:lunify/pages/settings_page.dart';
import 'package:lunify/tabs/home_tab.dart';
import 'package:lunify/tabs/player_tab.dart';
import 'package:lunify/tabs/playlist_tab.dart';

import 'package:lunify/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AudioFileHandler([])),
        ChangeNotifierProvider(create: (context) => ThemeProvider())
      ],
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
  bool _isAudioMetadataLoading = true;
  double _audioMetadataLoadingProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: MyApp.tabs.length, 
      initialIndex: 2,
      vsync: this
    );

    Provider.of<AudioFileHandler>(context, listen: false).setTabController(_tabController);
    Provider.of<AudioFileHandler>(context, listen: false).setPlayerTabIndex(1);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: getRootPage(),

      theme: lightTheme,
      darkTheme: darkTheme,

      themeMode: Provider.of<ThemeProvider>(context, listen: true).currentTheme,
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
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 10),
                    Text("Settings")
                  ]
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage())
                  );
                },
              )
            ]
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
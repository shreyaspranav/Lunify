import 'package:flutter/material.dart';
import 'package:lunify/audio_service_provider.dart';
import 'package:lunify/pages/settings_page.dart';
import 'package:lunify/tabs/home_tab.dart';
import 'package:lunify/pages/library_page.dart';
import 'package:lunify/tabs/player_tab.dart';
import 'package:lunify/tabs/playlist_tab.dart';

import 'package:lunify/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AudioServiceProvider([])),
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
  ];

  static const List<Tab> tabs = <Tab>[
    Tab(icon: Icon(Icons.home_filled)),
    Tab(icon: Icon(Icons.music_note)),
    Tab(icon: Icon(Icons.album)),
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
      length: 3, 
      initialIndex: 2,
      vsync: this
    );

    Provider.of<AudioServiceProvider>(context, listen: false).setTabController(_tabController);
    Provider.of<AudioServiceProvider>(context, listen: false).setPlayerTabIndex(1);
  }

  void showLoadingDialog(BuildContext context) {
    
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
      drawer: Drawer(
        child: Padding(
          padding: EdgeInsets.only(
            top: 30,
            left: 10
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset("assets/icon/icon.png"),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  "Lunify",
                  style: TextStyle(
                    fontSize: 30
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Version 0.0.1b",
                ),
              ),
              SizedBox(height: 50),
              Builder(
                builder: (context) {
                  return ListTile(
                    leading: Icon(Icons.settings),
                    title: Text("Settings"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage())
                      );
                    },
                  );
                }
              ),
              
            ]
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const PlaylistTab(),
          PlayerTab(),
          const HomeTab()
        ]
      ),
          // bottomNavigationBar: BottomAppBar(
          //   child: TabBar(tabs: tabs),
          // 
    );
  }
}
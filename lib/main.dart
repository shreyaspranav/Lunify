import 'package:flutter/material.dart';
import 'package:lunify/tabs/home_tab.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
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
  
  static const List<Widget> children_tabs = <Widget>[
    HomeTab(),
    toBeImplemented,
    toBeImplemented,
    toBeImplemented
  ];

  static const List<Tab> tabs = <Tab>[
    Tab(text: "Home",     icon: Icon(Icons.home_filled)),
    Tab(text: "Songs",    icon: Icon(Icons.music_note)),
    Tab(text: "Albums",   icon: Icon(Icons.album)),
    Tab(text: "Artists",  icon: Icon(Icons.person_2_sharp)),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: getRootPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'DMSerif', 
      )
    );
  }

  Widget getRootPage() {
      return Scaffold (
      appBar: AppBar(
        title: const Text(
            "Lunify",
            style: TextStyle(
              color: Color.fromARGB(128, 0, 0, 128),
              fontSize: 24.0
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
      body: DefaultTabController(
        length: tabs.length, 
        child: const Scaffold(
          body: TabBarView(
            children: children_tabs
          ),
          bottomNavigationBar: BottomAppBar(
            child: TabBar(tabs: tabs),
          ),
        ) 
      )
    );
  }
}

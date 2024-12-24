import 'package:flutter/material.dart';
import 'package:lunify/tabs/library_tab.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  static const num cardWidth = 175;
  static const num cardHeight = 150;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))
                ),
                prefixIcon: Icon(Icons.search),
                hintText: "Search for music",
                hintStyle: TextStyle(
                  color: Color.fromARGB(50, 0, 0, 0)
                )
              ),
            ),
          ),
          Container(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                customContainer(
                  width: 175,
                  height: 160,
                  displayText: "Most Played", 
                  gradient: const LinearGradient(
                    colors: [
                      const Color(0x22FFE1FF), const Color(0xFF7E60BF)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ), 
                  fontSize: 20.0,
                  onTap: () {
                    
                  },
                ),
                customContainer(
                  width: 175,
                  height: 160,
                  displayText: "Recently Played", 
                  gradient: const LinearGradient(
                    colors: [
                      const Color(0x22FFE1FF), const Color(0xFF7E60BF)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ), 
                  fontSize: 20.0,
                  onTap: () {} 
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: customContainer(
              width: MediaQuery.sizeOf(context).width,
              height: 100,
              displayText: "Music Library",
              fontSize: 20,
              gradient: LinearGradient(
                colors: [
                  const Color(0x22FFE1FF), const Color(0xFF7E60BF)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LibraryTab()) 
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 20), 
            child: const Text(
              "Playlists",
              style: TextStyle(
                fontSize: 25.0
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, 
        label: const Text("New Playlist"),
        icon: Icon(Icons.add),
      ),
    );
  }

  Widget customContainer({double? width, double? height, String? displayText, Gradient? gradient, double? fontSize, GestureTapCallback? onTap}) {
    return Material(
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
            gradient: gradient
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Text(
              displayText!,
              style: TextStyle(
                fontSize: fontSize
              ),
            ),
          )
        ),
      )
    );
  }
}
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lunify/audio_service_provider.dart';
import 'package:lunify/pages/library_page.dart';
import 'package:lunify/pages/playlist_page.dart';
import 'package:lunify/theme_provider.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  
  List<AudioPlaylist> _playlists = [];
  final List<int> _coverIndices = [1, 5, 6, 7, 8, 9, 10, 11];

  @override
  void initState() {
    super.initState();
    _coverIndices.shuffle();

    initPlaylists();
  }

  Future<void> initPlaylists() async {
    // In order for the deserializePlaylists() to work, the app has to load the entire library first.
    await Provider.of<AudioServiceProvider>(context, listen: false).deserializePlaylists();
    setState(() {
      _playlists = Provider.of<AudioServiceProvider>(context, listen: false).getPlaylists();
    });
  }

  void _showCreatePlaylistDialog() {
    String playlistName = "";

    showDialog(
      context: context,
      builder: (context) {
        double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

        return SizedBox(
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(color: Colors.black.withOpacity(0.0)),
              ),
              Center(
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: AnimationController(
                        vsync: this,
                        duration: Durations.medium3,
                      )..forward(),
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: SizedBox(
                    width: 400,
                    height: keyboardHeight > 0 ? 300 + keyboardHeight : 300,
                    child: AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Row(
                        children: [
                          Icon(
                            Icons.playlist_play_rounded,
                            size: 35,
                            color: colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 2 : 3],
                          ),
                          const Text("Create New Playlist"),
                        ],
                      ),
                      content: Column(
                        children: [
                          SizedBox(
                            width: 375,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 0
                              ),
                              child: TextField(
                                onChanged: (value) {
                                  playlistName = value;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(20))
                                  ),
                                  hintText: "Enter playlist name",
                                ),
                              ),
                            ),
                          ),
                          
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (playlistName.isNotEmpty) {
                                Provider.of<AudioServiceProvider>(context, listen: false).addPlaylist(AudioPlaylist(playlistName: playlistName));
                                Provider.of<AudioServiceProvider>(context, listen: false).serializePlaylists();
                              }
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text('Create'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search for music",
                  hintStyle: TextStyle(
                    color: Color.fromARGB(50, 0, 0, 0),
                  ),
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
                    showOptionsButton: false,
                    gradient: LinearGradient(
                      colors: [
                        colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 2 : 1],
                        colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 3 : 2].withOpacity(0.7),
                        colorPalette[4].withOpacity(0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter
                    ),
                    image: Image.asset("assets/covers/4.jpg", fit: BoxFit.cover),
                    fontSize: 18.0,
                    onTap: () {},
                  ),
                  customContainer(
                    width: 175,
                    height: 160,
                    displayText: "Recently Played",
                    showOptionsButton: false,
                    gradient: LinearGradient(
                      colors: [
                        colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 2 : 1],
                        colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 3 : 2].withOpacity(0.7),
                        colorPalette[4].withOpacity(0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    image: Image.asset("assets/covers/3.jpg", fit: BoxFit.cover),
                    fontSize: 18.0,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                top: 15,
                bottom: 5,
              ),
              child: customContainer(
                width: MediaQuery.sizeOf(context).width,
                height: 100,
                displayText: "Music Library",
                fontSize: 20,
                showOptionsButton: false,
                gradient: LinearGradient(
                  colors: [
                    colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 2 : 1],
                    colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 3 : 2].withOpacity(0.7),
                    colorPalette[4].withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                image: Image.asset("assets/covers/2.jpg", fit: BoxFit.cover),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LibraryTab()),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Text(
                "Playlists",
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
            ),
            SizedBox(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 5,
                  right: 5,
                ),
                itemCount: _playlists.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      top: 4,
                      bottom: 4,
                    ),
                    child: customContainer(
                      width: MediaQuery.sizeOf(context).width,
                      height: 100,
                      displayText: _playlists[index].playlistName,
                      showOptionsButton: true,
                      fontSize: 20,
                      gradient: LinearGradient(
                        colors: [
                          colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 2 : 1],
                          colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 3 : 2].withOpacity(0.7),
                          colorPalette[4].withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      image: Image.asset("assets/covers/${_coverIndices[index % _coverIndices.length]}.jpg", fit: BoxFit.cover,),
                      bottomIcon: Icon(
                        Icons.play_circle_fill, 
                        size: 35,
                        color: colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 2 : 1],
                      ),
                      onTap: () {
                        // When the user taps the card
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistPage(
                          cover: Image.asset("assets/covers/${_coverIndices[index % _coverIndices.length]}.jpg", 
                          fit: BoxFit.cover
                        ), 
                        playlist: _playlists[index])));
                      },
                      onBottomIconTap: () {
                        // When the user taps the play button on the bottom
                      },
                      onOptionsTap: () {
                        // When the user taps the options button
                        showModalBottomSheet(
                          context: context, 
                          builder: (context) {
                            return FractionallySizedBox(
                              widthFactor: 1.0,
                              heightFactor: (MediaQuery.of(context).viewInsets.bottom + 350) / MediaQuery.of(context).size.height,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 5,
                                  right: 5,
                                  top: 10,
                                  bottom: 10
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 15
                                          ),
                                          child: Text(
                                            "${_playlists[index].playlistName}",
                                            style: TextStyle(
                                              fontSize: 20
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              Provider.of<AudioServiceProvider>(context, listen: false).deletePlaylist(_playlists[index]);
                                            });
                                            Provider.of<AudioServiceProvider>(context, listen: false).serializePlaylists();
                                            // Close the sheet
                                            Navigator.pop(context);
                                          } 
                                        )
                                      ],
                                    ),
                                    const Divider(thickness: 1.0),
                                    ListView(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      children: [
                                        ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 6
                                          ),
                                          leading: Icon(
                                            Icons.play_arrow,
                                            color: colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 2 : 3],
                                            size: 40,
                                          ),
                                          title: const Text("Play"),
                                          onTap: () {
                                            
                                          },
                                        ),
                                        ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 6
                                          ),
                                          leading: Icon(
                                            Icons.playlist_add,
                                            color: colorPalette[Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? 2 : 3],
                                            size: 40,
                                          ),
                                          title: const Text("Add to the Playing Queue"),
                                          onTap: () {
                                            
                                          },
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePlaylistDialog,
        label: const Text("New Playlist"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget customContainer({
      required double width,
      required double height,
      required String displayText,
      required bool showOptionsButton,
      Gradient? gradient,
      Image? image,
      Icon? bottomIcon,
      double? fontSize,
      GestureTapCallback? onTap,
      GestureTapCallback? onOptionsTap,
      GestureTapCallback? onBottomIconTap,
    }) {
    return Material(
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              width: width,
              height: height,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                child: image ?? Container()
              ),
            ),
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  gradient: gradient
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontSize: fontSize ?? 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      showOptionsButton ? IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: colorPalette[0],
                        ),
                        onPressed: onOptionsTap,
                      ) : const SizedBox(width: 0, height: 0),
                      const SizedBox(height: 1),
                      bottomIcon != null ? IconButton(
                        onPressed: onBottomIconTap, 
                        icon: bottomIcon
                      ) : const SizedBox(width: 0, height: 0)
                    ],
                  )
                ],
              ),
            ),
          ]
        ),
      ),
    );
  }
}
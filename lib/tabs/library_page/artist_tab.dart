import 'package:flutter/material.dart';
import 'package:lunify/audio_service_provider.dart';
import 'package:lunify/models/album_model.dart';
import 'package:lunify/models/artist_model.dart';
import 'package:lunify/theme_provider.dart';
import 'package:provider/provider.dart';

class ArtistTab extends StatefulWidget {
  const ArtistTab({super.key});

  @override
  State<ArtistTab> createState() => _ArtistTabState();
}

class _ArtistTabState extends State<ArtistTab> {
  List<ArtistModel> _artists = [];

  @override
  void initState() {
    super.initState();

    setState(() {
      _artists = Provider.of<AudioServiceProvider>(context, listen: false).getArtists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _artists.length,
        itemBuilder: (context, index) {
          return ListTile(
            minVerticalPadding: 12, // Increases tile height
            contentPadding: const EdgeInsets.symmetric(horizontal: 15), // Adds space around the tile
            title: Text(
              _artists[index].name,
              style: const TextStyle(fontSize: 16), // Adjusted font size
            ),
            subtitle: Text("${_artists[index].albums.length} Album${_artists[index].albums.length != 1 ? 's' : ''}"),
            leading: ClipOval(
              child: Container(
                width: 56, 
                height: 80,
                color: Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? Colors.grey[300] : Colors.grey[850],
                child: _artists[index].coverImage != null
                    ? _artists[index].coverImage! // Display the coverImage
                    : Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(
                        "assets/artist.png",
                        color: Provider.of<ThemeProvider>(context, listen: false).currentTheme == ThemeMode.light ? Colors.black : Colors.white,
                      ),
                    )
              ),
            ),
            onTap: () {
              
            },
          );
        },
      ),
    );
  }
}

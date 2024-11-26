import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lunify/audio_service_provider.dart';
import 'package:lunify/theme_provider.dart';
import 'package:provider/provider.dart';

import 'package:filesystem_picker/filesystem_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
          settingEntry(
            settingText: const Text(
              "Dark Mode",
              style: TextStyle(
                fontSize: 18
              ),
            ), 
            settingWidget: Switch(
              value: Provider.of<ThemeProvider>(context).currentTheme == ThemeMode.dark, 
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              }
            ),
          ),
          settingEntry(
            settingText: const Text(
              "Add Music Library Folder",
              style: TextStyle(
                fontSize: 18
              ),
            ), 
            settingWidget: TextButton(
              onPressed: () async {
                String? path = await FilesystemPicker.openDialog(
                  context: context, 
                  rootDirectory: Directory("/storage/emulated/0/")
                );

                if(path != null) {
                  Provider.of<AudioServiceProvider>(context, listen: false).addAudioLibraryUrl(path);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Path $path is added to the music library.")),
                    snackBarAnimationStyle: AnimationStyle(
                      duration: Durations.medium1,
                      curve: Curves.easeInCubic
                    )
                  );
                }

                Provider.of<AudioServiceProvider>(context, listen: false).setLoadMetadataFlag();
              }, 
              child: const Text("Add...")
            )
          )
        ],
      ),
    );
  }

  Widget settingEntry({required Text settingText, required Widget settingWidget}) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: 10
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [settingText, settingWidget],
      ),
    );
  }
}
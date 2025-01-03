import 'package:flutter/material.dart';

// Color Palette used(dark to light): 0d0c1d, 161b33, 474973, a69cac, f1dac4
const List<Color> colorPalette = [
  Color(0xff0d0c1d),
  Color(0xff161b33),
  Color(0xff474973),
  Color(0xffa69cac),
  Color(0xfff1dac4),
];

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.indigo,
);

class ThemeProvider extends ChangeNotifier {
  
  ThemeMode _currentTheme = ThemeMode.light;

  ThemeMode get currentTheme => _currentTheme;

  void toggleTheme() {
    _currentTheme = _currentTheme == ThemeMode.light ? ThemeMode.dark : ThemeMode.light; 
    notifyListeners();
  }
}

import 'package:flutter/material.dart';

class LightTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
    ),
    //colorSchemeSeed: Colors.indigo,
    appBarTheme:  const AppBarTheme(
      color: Colors.indigo,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 25
      ),
        iconTheme: IconThemeData(
        color: Colors.white
      ),
        actionsIconTheme: IconThemeData(
        color: Colors.white
      ),
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: Colors.amber,
      unselectedLabelColor: Colors.white,
      indicatorColor: Colors.amber,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      showUnselectedLabels: false,
      backgroundColor: Colors.indigo,
      selectedItemColor: Colors.amber,
      unselectedItemColor: Colors.white,
    ),
    dividerTheme: const DividerThemeData(
      color: Colors.indigoAccent,
      space: 1,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: CircleBorder(
        side: BorderSide.none,
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      useIndicator: false,
      backgroundColor: Colors.indigo,
      labelType: NavigationRailLabelType.selected,
      selectedIconTheme: IconThemeData(
        color: Colors.amber,
        size: 40,
      ),
      unselectedIconTheme: IconThemeData(
        color: Colors.white,
        size: 35,
      ),
      selectedLabelTextStyle: TextStyle(
          color: Colors.amber
      ),
      unselectedLabelTextStyle: TextStyle(
          color: Colors.amber
      ),
    ),
  );
}
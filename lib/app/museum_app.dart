import 'package:flutter/material.dart';

import '../features/home/home_screen.dart';
import 'museum_theme.dart';

class MuseumApp extends StatelessWidget {
  const MuseumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Museo',
      debugShowCheckedModeBanner: false,
      theme: MuseumTheme.light(),
      home: const HomeScreen(),
    );
  }
}

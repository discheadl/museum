import 'package:flutter/material.dart';

import '../features/home/home_screen.dart';
import '../services/museum_api_service.dart';
import '../services/museum_repository.dart';
import 'museum_theme.dart';

class MuseumApp extends StatelessWidget {
  MuseumApp({super.key, MuseumRepository? repository})
    : repository = repository ?? MuseumApiService();

  final MuseumRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Museo',
      debugShowCheckedModeBanner: false,
      theme: MuseumTheme.light(),
      home: HomeScreen(repository: repository),
    );
  }
}

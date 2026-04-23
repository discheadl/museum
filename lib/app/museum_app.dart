import 'package:flutter/material.dart';

import '../features/home/home_screen.dart';
import '../services/museum_repository.dart';
import '../services/supabase_museum_service.dart';
import 'museum_theme.dart';

class MuseumApp extends StatelessWidget {
  MuseumApp({super.key, MuseumRepository? repository, this.homeOverride})
    : repository = repository ?? SupabaseMuseumService();

  final MuseumRepository repository;
  final Widget? homeOverride;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Museo',
      debugShowCheckedModeBanner: false,
      theme: MuseumTheme.light(),
      home: homeOverride ?? HomeScreen(repository: repository),
      routes: <String, WidgetBuilder>{
        HomeScreen.routeName: (_) => HomeScreen(repository: repository),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/museum_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Base: el museo se diseña en horizontal.
  await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(MuseumApp());
}

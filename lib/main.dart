import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/museum_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga las credenciales locales (Supabase, etc.) desde .env
  await dotenv.load(fileName: '.env');

  // Base: el museo se diseña en horizontal.
  await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(MuseumApp());
}

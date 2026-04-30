import 'package:flutter/material.dart';

import '../../services/museum_repository.dart';
import '../virtual_tour/virtual_tour_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.repository});

  static const String routeName = '/gallery';

  final MuseumRepository repository;

  void _startApp(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => VirtualTourScreen(repository: repository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: GestureDetector(
        onTap: () => _startApp(context),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Imagen estática de fondo (imagen provisional)
            Image.asset(
              'assets/images/museo.jpg',
              fit: BoxFit.cover,
            ),

            // Contenido centrado
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Bienvenido al\nMuseo Virtual',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Explora nuestra colección\ny recorre las salas en 360°.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withAlpha((0.85 * 255).round()),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.touch_app_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Toca cualquier parte\nde la pantalla para entrar',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withAlpha((0.75 * 255).round()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}

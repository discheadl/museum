import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/home/home_screen.dart';
import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';
import '../services/museum_repository.dart';
import '../services/supabase_museum_service.dart';
import 'museum_theme.dart';

class MuseumApp extends StatefulWidget {
  MuseumApp({super.key, MuseumRepository? repository, this.homeOverride})
    : repository = repository ?? SupabaseMuseumService();

  final MuseumRepository repository;
  final Widget? homeOverride;

  @override
  State<MuseumApp> createState() => _MuseumAppState();
}

class _MuseumAppState extends State<MuseumApp> {
  final AppLocaleController _localeController = AppLocaleController();

  @override
  void dispose() {
    _localeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLocaleScope(
      controller: _localeController,
      child: AnimatedBuilder(
        animation: _localeController,
        builder: (BuildContext context, _) {
          return MaterialApp(
            title: 'Museo',
            debugShowCheckedModeBanner: false,
            theme: MuseumTheme.light(),
            locale: _localeController.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home:
                widget.homeOverride ??
                HomeScreen(repository: widget.repository),
          );
        },
      ),
    );
  }
}

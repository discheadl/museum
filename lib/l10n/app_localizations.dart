import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale, this._translations);

  final Locale locale;
  final Map<String, dynamic> _translations;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
    Locale('fr'),
  ];

  static AppLocalizations of(BuildContext context) {
    final AppLocalizations? localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(
      localizations != null,
      'AppLocalizations no encontrado en contexto.',
    );
    return localizations!;
  }

  String text(
    String key, {
    Map<String, String> params = const <String, String>{},
  }) {
    final Object? rawValue = _lookup(key);
    final String template = rawValue is String ? rawValue : key;

    return params.entries.fold<String>(
      template,
      (String current, MapEntry<String, String> entry) =>
          current.replaceAll('{${entry.key}}', entry.value),
    );
  }

  String roomTitle(String roomId, String fallback) {
    return _localizedContent('rooms.$roomId.title') ?? fallback;
  }

  String roomSubtitle(String roomId, String fallback) {
    return _localizedContent('rooms.$roomId.subtitle') ?? fallback;
  }

  String exhibitTitle(String exhibitId, String fallback) {
    return _localizedContent('exhibits.$exhibitId.title') ?? fallback;
  }

  String exhibitSubtitle(String exhibitId, String fallback) {
    return _localizedContent('exhibits.$exhibitId.subtitle') ?? fallback;
  }

  String exhibitDescription(String exhibitId, String fallback) {
    return _localizedContent('exhibits.$exhibitId.description') ?? fallback;
  }

  String? _localizedContent(String key) {
    final Object? rawValue = _lookup(key);
    return rawValue is String && rawValue.isNotEmpty ? rawValue : null;
  }

  Object? _lookup(String key) {
    Object? current = _translations;
    for (final String part in key.split('.')) {
      if (current is! Map<String, dynamic>) return null;
      current = current[part];
    }
    return current;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (Locale supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final String languageCode = isSupported(locale)
        ? locale.languageCode
        : AppLocalizations.supportedLocales.first.languageCode;
    final String jsonString = await rootBundle.loadString(
      'assets/i18n/$languageCode.json',
    );

    return AppLocalizations(
      Locale(languageCode),
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

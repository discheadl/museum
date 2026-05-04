import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../l10n/app_localizations.dart';
import '../../models/museum_models.dart';
import '../../services/museum_cache_manager.dart';
import '../../services/museum_repository.dart';
import '../virtual_tour/virtual_tour_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final MuseumRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _audioAssets = <String>[
    'assets/audio/espanol.mp3',
    'assets/audio/ingles.mp3',
    'assets/audio/frances.mp3',
  ];

  static const List<String> _localizationsAssets = <String>[
    'assets/i18n/es.json',
    'assets/i18n/en.json',
    'assets/i18n/fr.json',
  ];

  final MuseumCacheManager _cacheManager = MuseumCacheManager.instance;

  List<MuseumRoom> _preparedRooms = const <MuseumRoom>[];
  Object? _prepareError;
  bool _isPreparing = true;
  String _statusKey = 'home.preparingData';

  @override
  void initState() {
    super.initState();
    _prepareApp();
  }

  void _startTour(BuildContext context) {
    if (_isPreparing || _prepareError != null || _preparedRooms.isEmpty) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => VirtualTourScreen(
          repository: widget.repository,
          initialRooms: _preparedRooms,
        ),
      ),
    );
  }

  Future<void> _prepareApp() async {
    try {
      _setStatus('home.preparingData');
      final List<MuseumRoom> rooms = await widget.repository.fetchRooms(
        forceRefresh: true,
      );

      _setStatus('home.preparingAssets');
      await Future.wait<void>(<Future<void>>[
        _preloadLocalizations(),
        _preloadAudio(),
        _preloadImages(rooms),
      ]);

      if (!mounted) return;
      setState(() {
        _preparedRooms = rooms;
        _prepareError = null;
        _isPreparing = false;
        _statusKey = 'home.ready';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _prepareError = error;
        _isPreparing = false;
        _statusKey = 'home.prepareError';
      });
    }
  }

  void _setStatus(String key) {
    if (!mounted) return;
    setState(() => _statusKey = key);
  }

  Future<void> _preloadImages(List<MuseumRoom> rooms) async {
    final Set<String> panoramaUrls = <String>{};
    final Set<String> exhibitUrls = <String>{};

    for (final MuseumRoom room in rooms) {
      if (room.coverUrl.isNotEmpty) {
        panoramaUrls.add(room.coverUrl);
      }
      for (final MuseumExhibit exhibit in room.exhibits) {
        if (exhibit.mediaUrl.isNotEmpty) {
          exhibitUrls.add(exhibit.mediaUrl);
        }
        if (exhibit.thumbnailUrl.isNotEmpty) {
          exhibitUrls.add(exhibit.thumbnailUrl);
        }
      }
    }

    await Future.wait<void>(
      exhibitUrls.map((String url) => _cacheManager.downloadFile(url)),
    );

    for (final String url in panoramaUrls) {
      await _cacheManager.downloadFile(url);
      if (!mounted) return;

      try {
        await precacheImage(
          CachedNetworkImageProvider(url, cacheManager: _cacheManager),
          context,
        );
      } catch (error) {
        throw Exception('Panorama inválido o no disponible: $url');
      }
    }
  }

  Future<void> _preloadLocalizations() async {
    await Future.wait<void>(_localizationsAssets.map(rootBundle.loadString));
  }

  Future<void> _preloadAudio() async {
    await Future.wait<void>(_audioAssets.map(rootBundle.load));
  }

  String _prepareErrorText(AppLocalizations localizations) {
    final Object? error = _prepareError;
    if (error == null) {
      return localizations.text('home.prepareError');
    }

    final String details = error.toString();
    if (details.isEmpty) {
      return localizations.text('home.prepareError');
    }

    return '${localizations.text('home.prepareError')}\n$details';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations localizations = AppLocalizations.of(context);
    final bool canEnter = !_isPreparing && _prepareError == null;

    return Scaffold(
      body: GestureDetector(
        onTap: canEnter ? () => _startTour(context) : null,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset('assets/images/museo.jpg', fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withAlpha(110),
                    Colors.black.withAlpha(80),
                    Colors.black.withAlpha(150),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Spacer(),
                    Text(
                      localizations.text('home.title'),
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      localizations.text('home.subtitle'),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withAlpha((0.85 * 255).round()),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_prepareError != null) ...<Widget>[
                      Text(
                        _prepareErrorText(localizations),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFFFD7D1),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            _isPreparing = true;
                            _prepareError = null;
                          });
                          _prepareApp();
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(localizations.text('actions.retry')),
                      ),
                    ] else ...<Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            canEnter
                                ? Icons.touch_app_rounded
                                : Icons.downloading_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              localizations.text(
                                canEnter ? 'home.cta' : _statusKey,
                              ),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withAlpha(
                                  (0.75 * 255).round(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

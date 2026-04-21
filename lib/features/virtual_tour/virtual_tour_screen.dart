import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/virtual_tour_demo.dart';
import '../../models/museum_models.dart';
import '../../services/museum_repository.dart';
import '../home/home_screen.dart';
import 'widgets/tour_artwork_dialog.dart';
import 'widgets/tour_menu_drawer.dart';
import 'widgets/tour_navigation_bar.dart';
import 'widgets/tour_panorama_viewer.dart';

class VirtualTourScreen extends StatefulWidget {
  const VirtualTourScreen({
    super.key,
    required this.repository,
    this.initialSceneId,
  });

  final MuseumRepository repository;
  final String? initialSceneId;

  @override
  State<VirtualTourScreen> createState() => _VirtualTourScreenState();
}

class _VirtualTourScreenState extends State<VirtualTourScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Set<String> _precachedScenes = <String>{};

  late int _sceneIndex;
  bool _gyroscopeEnabled = false;
  bool _showHotspotHints = true;

  List<VirtualTourScene> _scenes = const <VirtualTourScene>[];
  Object? _loadError;

  VirtualTourScene? get _scene =>
      _scenes.isEmpty ? null : _scenes[_sceneIndex];

  @override
  void initState() {
    super.initState();
    _sceneIndex = 0;
    _loadScenes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final scene = _scene;
      if (scene != null) {
        _precacheAround(scene);
      }
    });
  }

  Future<void> _loadScenes() async {
    try {
      final List<MuseumRoom> rooms = await widget.repository.fetchRooms();

      if (rooms.isEmpty) {
        throw Exception(
          'Supabase no devolvio salas. Revisa que existan filas en la '
          'tabla `salas` y que las RLS policies permitan SELECT al rol anon.',
        );
      }

      final List<MuseumRoom> withPanoramas = rooms
          .where((MuseumRoom r) => r.coverUrl.isNotEmpty)
          .toList(growable: false);

      if (withPanoramas.isEmpty) {
        throw Exception(
          'Las salas no tienen `imagen_url`. Sube los panoramas y guarda la '
          'URL publica en cada fila.',
        );
      }

      final scenes = _buildScenesFromRooms(withPanoramas);

      final firstUrl = scenes.first.panoramaUrl;
      if (firstUrl != null && firstUrl.isNotEmpty && mounted) {
        try {
          await precacheImage(NetworkImage(firstUrl), context);
        } catch (e) {
          debugPrint('[VirtualTour] precache fallo para $firstUrl: $e');
        }
      }

      if (!mounted) return;
      setState(() {
        _scenes = scenes;
        _sceneIndex = _findInitialIndex();
        _loadError = null;
      });
      final current = _scene;
      if (current != null) {
        _precacheAround(current);
      }
    } catch (error, stack) {
      debugPrint('[VirtualTour] error cargando escenas: $error\n$stack');
      if (!mounted) return;
      setState(() => _loadError = error);
    }
  }

  List<VirtualTourScene> _buildScenesFromRooms(List<MuseumRoom> rooms) {
    const Color exhibitTint = Color(0xFFE76F51);

    final scenes = <VirtualTourScene>[];
    for (int i = 0; i < rooms.length; i++) {
      final MuseumRoom room = rooms[i];
      final hotspots = <VirtualTourHotspot>[];

      final double navYaw = room.yaw ?? (i == 0 ? 202 : 30);
      final double navPitch = room.pitch ?? -8;
      const Color navTint = Color(0xFF2A9D8F);

      if (i < rooms.length - 1) {
        final MuseumRoom next = rooms[i + 1];
        hotspots.add(
          VirtualTourHotspot.navigation(
            id: '${room.id}_next',
            label: 'Ir a ${next.title}',
            targetSceneId: next.id,
            longitude: navYaw,
            latitude: navPitch,
            tint: navTint,
          ),
        );
      } else if (i > 0) {
        final MuseumRoom prev = rooms[i - 1];
        hotspots.add(
          VirtualTourHotspot.navigation(
            id: '${room.id}_prev',
            label: 'Ir a ${prev.title}',
            targetSceneId: prev.id,
            longitude: navYaw,
            latitude: navPitch,
            tint: navTint,
          ),
        );
      }

      for (final MuseumExhibit exhibit in room.exhibits) {
        final double? yaw = exhibit.yaw;
        final double? pitch = exhibit.pitch;
        if (yaw == null || pitch == null) continue;

        hotspots.add(
          VirtualTourHotspot.info(
            id: 'exhibit_${exhibit.id}',
            label: exhibit.title,
            artwork: VirtualTourArtwork(
              id: exhibit.id,
              title: exhibit.title,
              subtitle: exhibit.subtitle,
              description: exhibit.description,
              author: '',
              dateLabel: '',
              context: '',
              imagePath: exhibit.mediaUrl,
            ),
            longitude: yaw,
            latitude: pitch,
            tint: exhibitTint,
          ),
        );
      }

      scenes.add(
        VirtualTourScene(
          id: room.id,
          title: room.title,
          caption: room.subtitle,
          assetPath: '',
          initialLongitude: 0,
          initialLatitude: 0,
          hotspots: hotspots,
          panoramaUrl: room.coverUrl,
        ),
      );
    }
    return scenes;
  }

  void _retryLoad() {
    setState(() => _loadError = null);
    _loadScenes();
  }

  int _findInitialIndex() {
    final sceneId = widget.initialSceneId;
    if (sceneId == null) return 0;

    final index = _scenes.indexWhere(
      (VirtualTourScene scene) => scene.id == sceneId,
    );
    return index < 0 ? 0 : index;
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _goToScene(String sceneId) {
    if (_scenes.isEmpty) return;
    final nextIndex = _scenes.indexWhere(
      (VirtualTourScene scene) => scene.id == sceneId,
    );
    if (nextIndex < 0 || nextIndex == _sceneIndex) return;

    _precacheAround(_scenes[nextIndex]);
    setState(() => _sceneIndex = nextIndex);
  }

  void _goToAdjacent(int delta) {
    if (_scenes.isEmpty) return;
    final nextIndex = (_sceneIndex + delta).clamp(0, _scenes.length - 1);
    if (nextIndex == _sceneIndex) return;

    _precacheAround(_scenes[nextIndex]);
    setState(() => _sceneIndex = nextIndex);
  }

  void _restartTour() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    setState(() => _sceneIndex = 0);
  }

  Future<void> _openGallery() async {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HomeScreen(repository: widget.repository),
      ),
    );
  }

  Future<void> _showMuseumInfo() async {
    Navigator.of(context).pop();
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Informacion del museo'),
          content: const Text(
            'Recorrido virtual del museo con panoramicas 360, hotspots de '
            'navegacion y fichas de obra. Usa el menu para abrir la galeria, '
            'activar giroscopio o reiniciar el circuito.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showArtworkInfo(VirtualTourArtwork artwork) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withAlpha((0.66 * 255).round()),
      builder: (_) => TourArtworkDialog(artwork: artwork),
    );
  }

  Future<void> _handleClose() async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF11161B),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Salir del recorrido',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Puedes volver a la galeria o cerrar la aplicacion.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _openGallery();
                  },
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Ir a la galeria'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withAlpha((0.18 * 255).round()),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    SystemNavigator.pop();
                  },
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Cerrar aplicacion'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _precacheAround(VirtualTourScene scene) {
    if (_scenes.isEmpty) return;
    _precacheScene(scene);

    final currentIndex = _scenes.indexWhere(
      (VirtualTourScene item) => item.id == scene.id,
    );

    if (currentIndex > 0) {
      _precacheScene(_scenes[currentIndex - 1]);
    }

    if (currentIndex >= 0 && currentIndex < _scenes.length - 1) {
      _precacheScene(_scenes[currentIndex + 1]);
    }

    for (final VirtualTourHotspot hotspot in scene.hotspots) {
      if (hotspot.targetSceneId == null) continue;

      final int targetIndex = _scenes.indexWhere(
        (VirtualTourScene item) => item.id == hotspot.targetSceneId,
      );
      if (targetIndex >= 0) {
        _precacheScene(_scenes[targetIndex]);
      }
    }
  }

  void _precacheScene(VirtualTourScene scene) {
    if (_precachedScenes.contains(scene.id)) return;

    _precachedScenes.add(scene.id);
    final url = scene.panoramaUrl;
    if (url != null && url.isNotEmpty) {
      precacheImage(NetworkImage(url), context);
    } else {
      precacheImage(AssetImage(scene.assetPath), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scene = _scene;

    if (scene == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: _loadError != null
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.cloud_off_rounded,
                        color: Colors.white70,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No fue posible cargar el recorrido desde Supabase.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _loadError.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _retryLoad,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : const CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      drawer: TourMenuDrawer(
        gyroscopeEnabled: _gyroscopeEnabled,
        showHotspotHints: _showHotspotHints,
        onOpenGallery: _openGallery,
        onShowMuseumInfo: _showMuseumInfo,
        onToggleGyroscope: (bool value) {
          setState(() => _gyroscopeEnabled = value);
        },
        onToggleHotspotHints: (bool value) {
          setState(() => _showHotspotHints = value);
        },
        onRestartTour: _restartTour,
        onExitApp: () {
          SystemNavigator.pop();
        },
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: TourPanoramaViewer(
                key: ValueKey<String>('tour_scene_${scene.id}'),
                scene: scene,
                gyroscopeEnabled: _gyroscopeEnabled,
                showHotspotHints: _showHotspotHints,
                onNavigateToScene: _goToScene,
                onSelectArtwork: _showArtworkInfo,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.black.withAlpha((0.36 * 255).round()),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withAlpha((0.50 * 255).round()),
                    ],
                    stops: const <double>[0, 0.18, 0.66, 1],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 10, 18),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha((0.58 * 255).round()),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          key: const ValueKey<String>('tour_open_menu'),
                          onPressed: _openDrawer,
                          icon: const Icon(
                            Icons.menu_rounded,
                            color: Colors.white,
                          ),
                          tooltip: 'Abrir menu',
                        ),
                      ),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _SceneHeader(
                          key: ValueKey<String>('tour_header_${scene.id}'),
                          title: scene.title,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TourNavigationBar(
                      canGoBack: _sceneIndex > 0,
                      canGoForward: _sceneIndex < _scenes.length - 1,
                      onBack: () => _goToAdjacent(-1),
                      onForward: () => _goToAdjacent(1),
                      onClose: _handleClose,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneHeader extends StatelessWidget {
  const _SceneHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.56 * 255).round()),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha((0.12 * 255).round())),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.place_rounded, color: Color(0xFFF4A261), size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

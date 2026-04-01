import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

import '../../data/virtual_tour_demo.dart';

class VirtualTourScreen extends StatefulWidget {
  const VirtualTourScreen({super.key});

  @override
  State<VirtualTourScreen> createState() => _VirtualTourScreenState();
}

class _VirtualTourScreenState extends State<VirtualTourScreen> {
  static const double _initialZoom = 1.4;
  static const double _minZoom = 1.2;
  static const double _maxZoom = 2.6;
  static const double _minLatitude = -55;
  static const double _maxLatitude = 55;
  static const int _latSegments = 64;
  static const int _lonSegments = 128;

  int _sceneIndex = 0;
  final Set<String> _precachedScenes = <String>{};

  VirtualTourScene get _scene => demoVirtualTourScenes[_sceneIndex];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _precacheScene(_scene);
      for (final hotspot in _scene.hotspots) {
        final targetScene = demoVirtualTourScenes.firstWhere(
          (scene) => scene.id == hotspot.targetSceneId,
        );
        _precacheScene(targetScene);
      }
    });
  }

  void _goToScene(String sceneId) {
    final nextIndex = demoVirtualTourScenes.indexWhere(
      (scene) => scene.id == sceneId,
    );
    if (nextIndex < 0 || nextIndex == _sceneIndex) return;

    _precacheScene(demoVirtualTourScenes[nextIndex]);
    setState(() => _sceneIndex = nextIndex);
  }

  void _precacheScene(VirtualTourScene scene) {
    if (_precachedScenes.contains(scene.id)) return;

    _precachedScenes.add(scene.id);
    precacheImage(AssetImage(scene.assetPath), context);
  }

  @override
  Widget build(BuildContext context) {
    final scene = _scene;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: PanoramaViewer(
                key: ValueKey<String>(scene.id),
                longitude: scene.initialLongitude,
                latitude: scene.initialLatitude,
                // `flutter_cube` drops partially clipped triangles instead of
                // clipping them, so keeping the sphere denser and the camera a
                // bit away from the poles avoids black gaps in the panorama.
                minLatitude: _minLatitude,
                maxLatitude: _maxLatitude,
                zoom: _initialZoom,
                minZoom: _minZoom,
                maxZoom: _maxZoom,
                latSegments: _latSegments,
                lonSegments: _lonSegments,
                sensitivity: 1.3,
                sensorControl: SensorControl.none,
                hotspots: scene.hotspots
                    .map(
                      (hotspot) => Hotspot(
                        latitude: hotspot.latitude,
                        longitude: hotspot.longitude,
                        width: 138,
                        height: 138,
                        widget: _TourHotspot(
                          tint: hotspot.tint,
                          onTap: () => _goToScene(hotspot.targetSceneId),
                        ),
                      ),
                    )
                    .toList(growable: false),
                child: Image.asset(scene.assetPath, fit: BoxFit.cover),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: <Widget>[
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Volver'),
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

class _TourHotspot extends StatefulWidget {
  const _TourHotspot({required this.tint, required this.onTap});

  final Color tint;
  final VoidCallback onTap;

  @override
  State<_TourHotspot> createState() => _TourHotspotState();
}

class _TourHotspotState extends State<_TourHotspot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 980),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.96,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.tint.withAlpha((0.88 * 255).round()),
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: widget.tint.withAlpha((0.44 * 255).round()),
                  blurRadius: 22,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.place_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

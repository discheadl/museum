import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

import '../../../data/virtual_tour_demo.dart';

class TourPanoramaViewer extends StatelessWidget {
  const TourPanoramaViewer({
    super.key,
    required this.scene,
    required this.gyroscopeEnabled,
    required this.showHotspotHints,
    required this.onNavigateToScene,
    required this.onSelectArtwork,
  });

  static const double initialZoom = 1.4;
  static const double minZoom = 1.2;
  static const double maxZoom = 2.6;
  static const double minLatitude = -55;
  static const double maxLatitude = 55;
  static const int latSegments = 64;
  static const int lonSegments = 128;

  final VirtualTourScene scene;
  final bool gyroscopeEnabled;
  final bool showHotspotHints;
  final ValueChanged<String> onNavigateToScene;
  final ValueChanged<VirtualTourArtwork> onSelectArtwork;

  @override
  Widget build(BuildContext context) {
    return PanoramaViewer(
      key: ValueKey<String>(scene.id),
      longitude: scene.initialLongitude,
      latitude: scene.initialLatitude,
      minLatitude: minLatitude,
      maxLatitude: maxLatitude,
      zoom: initialZoom,
      minZoom: minZoom,
      maxZoom: maxZoom,
      latSegments: latSegments,
      lonSegments: lonSegments,
      sensitivity: 1.3,
      sensorControl: gyroscopeEnabled
          ? SensorControl.orientation
          : SensorControl.none,
      hotspots: scene.hotspots.map(_buildHotspot).toList(growable: false),
      child: _buildPanoramaImage(),
    );
  }

  Image _buildPanoramaImage() {
    final url = scene.panoramaUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(url, fit: BoxFit.cover, gaplessPlayback: true);
    }
    return Image.asset(scene.assetPath, fit: BoxFit.cover);
  }

  Hotspot _buildHotspot(VirtualTourHotspot hotspot) {
    return Hotspot(
      latitude: hotspot.latitude,
      longitude: hotspot.longitude,
      width: hotspot.kind == VirtualTourHotspotKind.navigation ? 170 : 200,
      height: hotspot.kind == VirtualTourHotspotKind.navigation ? 150 : 188,
      widget: _TourHotspot(
        hotspot: hotspot,
        showLabel: showHotspotHints,
        onTap: () {
          if (hotspot.kind == VirtualTourHotspotKind.navigation) {
            onNavigateToScene(hotspot.targetSceneId!);
            return;
          }

          onSelectArtwork(hotspot.artwork!);
        },
      ),
    );
  }
}

class _TourHotspot extends StatefulWidget {
  const _TourHotspot({
    required this.hotspot,
    required this.showLabel,
    required this.onTap,
  });

  final VirtualTourHotspot hotspot;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  State<_TourHotspot> createState() => _TourHotspotState();
}

class _TourHotspotState extends State<_TourHotspot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 980),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.92,
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
    final hotspot = widget.hotspot;

    return GestureDetector(
      key: ValueKey<String>('tour_hotspot_${hotspot.id}'),
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ScaleTransition(
            scale: _pulse,
            child: Container(
              width: hotspot.kind == VirtualTourHotspotKind.navigation
                  ? 54
                  : 58,
              height: hotspot.kind == VirtualTourHotspotKind.navigation
                  ? 54
                  : 58,
              decoration: BoxDecoration(
                color: hotspot.tint.withAlpha((0.92 * 255).round()),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withAlpha((0.86 * 255).round()),
                  width: 2.6,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: hotspot.tint.withAlpha((0.40 * 255).round()),
                    blurRadius: 24,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                hotspot.kind == VirtualTourHotspotKind.navigation
                    ? Icons.place_rounded
                    : Icons.info_outline_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          if (widget.showLabel) ...<Widget>[
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((0.64 * 255).round()),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Text(
                  hotspot.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

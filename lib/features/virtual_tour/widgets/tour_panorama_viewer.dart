import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

import '../../../data/virtual_tour_demo.dart';
import '../../../services/museum_cache_manager.dart';
import '../../../widgets/museum_skeleton.dart';

class TourPanoramaViewer extends StatefulWidget {
  const TourPanoramaViewer({
    super.key,
    required this.scene,
    required this.gyroscopeEnabled,
    required this.showHotspotHints,
    this.onViewportTap,
    required this.onNavigateToScene,
    required this.onSelectArtwork,
  });

  static const double initialZoom = 1.4;
  static const double minZoom = 1.2;
  static const double maxZoom = 2.6;
  static const double minLatitude = -55;
  static const double maxLatitude = 55;
  static const int latSegments = 32;
  static const int lonSegments = 64;

  static const double _infoDotSize = 14;
  static const double _navDotSize = 44;
  static const double _hotspotBoxSize = 160;

  final VirtualTourScene scene;
  final bool gyroscopeEnabled;
  final bool showHotspotHints;
  final VoidCallback? onViewportTap;
  final ValueChanged<String> onNavigateToScene;
  final ValueChanged<VirtualTourArtwork> onSelectArtwork;

  @override
  State<TourPanoramaViewer> createState() => _TourPanoramaViewerState();
}

class _TourPanoramaViewerState extends State<TourPanoramaViewer> {
  static const Duration _labelAutoDismiss = Duration(seconds: 4);

  String? _expandedHotspotId;
  Timer? _dismissTimer;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _expand(String id) {
    _dismissTimer?.cancel();
    setState(() => _expandedHotspotId = id);
    _dismissTimer = Timer(_labelAutoDismiss, _collapse);
  }

  void _collapse() {
    if (!mounted) return;
    _dismissTimer?.cancel();
    if (_expandedHotspotId == null) return;
    setState(() => _expandedHotspotId = null);
  }

  void _handleHotspotTap(VirtualTourHotspot hotspot) {
    if (hotspot.kind == VirtualTourHotspotKind.navigation) {
      widget.onNavigateToScene(hotspot.targetSceneId!);
      return;
    }

    if (_expandedHotspotId == hotspot.id) {
      _collapse();
      widget.onSelectArtwork(hotspot.artwork!);
      return;
    }

    _expand(hotspot.id);
  }

  @override
  Widget build(BuildContext context) {
    return PanoramaViewer(
      key: ValueKey<String>(widget.scene.id),
      longitude: widget.scene.initialLongitude,
      latitude: widget.scene.initialLatitude,
      minLatitude: TourPanoramaViewer.minLatitude,
      maxLatitude: TourPanoramaViewer.maxLatitude,
      zoom: TourPanoramaViewer.initialZoom,
      minZoom: TourPanoramaViewer.minZoom,
      maxZoom: TourPanoramaViewer.maxZoom,
      latSegments: TourPanoramaViewer.latSegments,
      lonSegments: TourPanoramaViewer.lonSegments,
      sensitivity: 1.3,
      sensorControl: widget.gyroscopeEnabled
          ? SensorControl.orientation
          : SensorControl.none,
      onTap: (double _, double _, double _) {
        _collapse();
        widget.onViewportTap?.call();
      },
      hotspots: widget.scene.hotspots
          .map(_buildHotspot)
          .toList(growable: false),
      child: _buildPanoramaImage(),
    );
  }

  Image _buildPanoramaImage() {
    final url = widget.scene.panoramaUrl;
    if (url != null && url.isNotEmpty) {
      return Image(
        image: CachedNetworkImageProvider(
          url,
          cacheManager: MuseumCacheManager.instance,
        ),
        fit: BoxFit.cover,
        gaplessPlayback: true,
        frameBuilder:
            (
              BuildContext context,
              Widget child,
              int? frame,
              bool wasSynchronouslyLoaded,
            ) {
              if (wasSynchronouslyLoaded || frame != null) {
                return child;
              }
              return const Center(
                child: MuseumSkeleton(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: BorderRadius.zero,
                ),
              );
            },
      );
    }
    return Image.asset(widget.scene.assetPath, fit: BoxFit.cover);
  }

  Hotspot _buildHotspot(VirtualTourHotspot hotspot) {
    final bool isInfo = hotspot.kind == VirtualTourHotspotKind.info;
    final bool labelVisible = isInfo
        ? _expandedHotspotId == hotspot.id
        : widget.showHotspotHints;

    return Hotspot(
      latitude: hotspot.latitude,
      longitude: hotspot.longitude,
      width: TourPanoramaViewer._hotspotBoxSize,
      height: TourPanoramaViewer._hotspotBoxSize,
      widget: _TourHotspot(
        hotspot: hotspot,
        labelVisible: labelVisible,
        boxSize: TourPanoramaViewer._hotspotBoxSize,
        dotSize: isInfo
            ? TourPanoramaViewer._infoDotSize
            : TourPanoramaViewer._navDotSize,
        onTap: () => _handleHotspotTap(hotspot),
      ),
    );
  }
}

class _TourHotspot extends StatelessWidget {
  const _TourHotspot({
    required this.hotspot,
    required this.labelVisible,
    required this.boxSize,
    required this.dotSize,
    required this.onTap,
  });

  final VirtualTourHotspot hotspot;
  final bool labelVisible;
  final double boxSize;
  final double dotSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isInfo = hotspot.kind == VirtualTourHotspotKind.info;

    final Widget circle = Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: hotspot.tint.withAlpha(235),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withAlpha(219),
          width: isInfo ? 2 : 2.4,
        ),
      ),
      child: isInfo
          ? null
          : Icon(
              Icons.place_rounded,
              color: Colors.white,
              size: dotSize * 0.55,
            ),
    );

    final double labelTop = boxSize / 2 + dotSize / 2 + 8;

    return GestureDetector(
      key: ValueKey<String>('tour_hotspot_${hotspot.id}'),
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(child: Center(child: circle)),
          if (labelVisible)
            Positioned(
              top: labelTop,
              left: 0,
              right: 0,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(184),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withAlpha(46)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Text(
                        hotspot.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

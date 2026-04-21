import 'package:flutter/material.dart';

enum VirtualTourHotspotKind { navigation, info }

@immutable
class VirtualTourScene {
  const VirtualTourScene({
    required this.id,
    required this.title,
    required this.caption,
    required this.assetPath,
    required this.initialLongitude,
    required this.initialLatitude,
    required this.hotspots,
    this.panoramaUrl,
  });

  final String id;
  final String title;
  final String caption;
  final String assetPath;
  final double initialLongitude;
  final double initialLatitude;
  final List<VirtualTourHotspot> hotspots;
  final String? panoramaUrl;
}

@immutable
class VirtualTourHotspot {
  const VirtualTourHotspot.navigation({
    required this.id,
    required this.label,
    required this.targetSceneId,
    required this.longitude,
    required this.latitude,
    required this.tint,
  }) : kind = VirtualTourHotspotKind.navigation,
       artwork = null;

  const VirtualTourHotspot.info({
    required this.id,
    required this.label,
    required this.artwork,
    required this.longitude,
    required this.latitude,
    required this.tint,
  }) : kind = VirtualTourHotspotKind.info,
       targetSceneId = null;

  final String id;
  final String label;
  final VirtualTourHotspotKind kind;
  final String? targetSceneId;
  final VirtualTourArtwork? artwork;
  final double longitude;
  final double latitude;
  final Color tint;
}

@immutable
class VirtualTourArtwork {
  const VirtualTourArtwork({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.author,
    required this.dateLabel,
    required this.context,
    required this.imagePath,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String author;
  final String dateLabel;
  final String context;
  final String imagePath;
}

import 'package:flutter/material.dart';

enum MuseumMediaType { image, video }

@immutable
class MuseumRoom {
  const MuseumRoom({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.coverUrl,
    required this.exhibits,
    this.yaw,
    this.pitch,
  });

  final String id;
  final String title;
  final String subtitle;
  final Color accent;
  final String coverUrl;
  final List<MuseumExhibit> exhibits;
  final double? yaw;
  final double? pitch;
}

@immutable
class MuseumExhibit {
  const MuseumExhibit({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.accent,
    required this.mediaType,
    required this.mediaUrl,
    required this.thumbnailUrl,
    this.yaw,
    this.pitch,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final Color accent;
  final MuseumMediaType mediaType;
  final String mediaUrl;
  final String thumbnailUrl;
  final double? yaw;
  final double? pitch;
}

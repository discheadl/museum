import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MuseumRoom &&
            other.id == id &&
            other.title == title &&
            other.subtitle == subtitle &&
            other.accent == accent &&
            other.coverUrl == coverUrl &&
            listEquals(other.exhibits, exhibits) &&
            other.yaw == yaw &&
            other.pitch == pitch;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    subtitle,
    accent,
    coverUrl,
    Object.hashAll(exhibits),
    yaw,
    pitch,
  );
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

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MuseumExhibit &&
            other.id == id &&
            other.title == title &&
            other.subtitle == subtitle &&
            other.description == description &&
            other.accent == accent &&
            other.mediaType == mediaType &&
            other.mediaUrl == mediaUrl &&
            other.thumbnailUrl == thumbnailUrl &&
            other.yaw == yaw &&
            other.pitch == pitch;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    subtitle,
    description,
    accent,
    mediaType,
    mediaUrl,
    thumbnailUrl,
    yaw,
    pitch,
  );
}

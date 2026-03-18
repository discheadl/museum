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
  });

  factory MuseumRoom.fromJson(Map<String, dynamic> json) {
    return MuseumRoom(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      accent: _parseColor(json['accent'] as String?),
      coverUrl: json['coverUrl'] as String? ?? '',
      exhibits: (json['exhibits'] as List<dynamic>? ?? const <dynamic>[])
          .map(
            (dynamic item) =>
                MuseumExhibit.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final Color accent;
  final String coverUrl;
  final List<MuseumExhibit> exhibits;
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
  });

  factory MuseumExhibit.fromJson(Map<String, dynamic> json) {
    return MuseumExhibit(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String,
      accent: _parseColor(json['accent'] as String?),
      mediaType: _parseMediaType(json['mediaType'] as String?),
      mediaUrl: json['mediaUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final Color accent;
  final MuseumMediaType mediaType;
  final String mediaUrl;
  final String thumbnailUrl;
}

Color _parseColor(String? hex) {
  const fallback = Color(0xFF7F5539);
  if (hex == null || hex.isEmpty) return fallback;

  final normalized = hex.replaceFirst('#', '');
  final value = normalized.length == 6 ? 'FF$normalized' : normalized;
  return Color(int.tryParse(value, radix: 16) ?? 0xFF7F5539);
}

MuseumMediaType _parseMediaType(String? value) {
  return value == 'video' ? MuseumMediaType.video : MuseumMediaType.image;
}

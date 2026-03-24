import 'package:flutter/material.dart';

@immutable
class MuseumRoom {
  const MuseumRoom({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.exhibits,
  });

  final String id;
  final String title;
  final String subtitle;
  final Color accent;
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
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final Color accent;
}

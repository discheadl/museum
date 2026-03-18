import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/museum_models.dart';
import 'museum_repository.dart';

class MuseumApiService implements MuseumRepository {
  static const String configuredBaseUrl = String.fromEnvironment(
    'MUSEUM_API_BASE_URL',
  );

  MuseumApiService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl =
          baseUrl ??
          (configuredBaseUrl.isNotEmpty ? configuredBaseUrl : _defaultBaseUrl);

  final http.Client _client;
  final String _baseUrl;

  static String get _defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:4000';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:4000';
      default:
        return 'http://localhost:4000';
    }
  }

  @override
  Future<List<MuseumRoom>> fetchRooms() async {
    final uri = Uri.parse('$_baseUrl/api/rooms');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw MuseumApiException(
        'La API respondio con estado ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const MuseumApiException('La respuesta de la API no es valida.');
    }

    final rooms = decoded['rooms'];
    if (rooms is! List<dynamic>) {
      throw const MuseumApiException('No se encontro la lista de salas.');
    }

    return rooms
        .map(
          (dynamic item) => MuseumRoom.fromJson(item as Map<String, dynamic>),
        )
        .toList(growable: false);
  }
}

class MuseumApiException implements Exception {
  const MuseumApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

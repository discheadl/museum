import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/museum_models.dart';
import 'museum_cache_manager.dart';
import 'museum_repository.dart';

class SupabaseMuseumService implements MuseumRepository {
  static const String _dartDefineUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _dartDefineKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  SupabaseMuseumService({http.Client? client, String? url, String? anonKey})
    : _client = client ?? http.Client(),
      _url = (url ?? _readConfig('SUPABASE_URL', _dartDefineUrl)).replaceFirst(
        RegExp(r'/+$'),
        '',
      ),
      _anonKey = anonKey ?? _readConfig('SUPABASE_ANON_KEY', _dartDefineKey) {
    if (_url.isEmpty || _anonKey.isEmpty) {
      throw const SupabaseConfigException(code: 'missingCredentials');
    }
  }

  static String _readConfig(String key, String fallback) {
    if (dotenv.isInitialized) {
      final value = dotenv.maybeGet(key);
      if (value != null && value.isNotEmpty) return value;
    }
    return fallback;
  }

  final http.Client _client;
  final String _url;
  final String _anonKey;
  final MuseumCacheManager _cacheManager = MuseumCacheManager.instance;

  static const Color _defaultAccent = Color(0xFF7F5539);

  @override
  Future<List<MuseumRoom>> fetchRooms({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final List<MuseumRoom> cachedRooms = await readCachedRooms();
      if (cachedRooms.isNotEmpty) {
        return cachedRooms;
      }
    }

    return _fetchRoomsFromNetwork();
  }

  @override
  Future<List<MuseumRoom>> readCachedRooms() async {
    try {
      final String? cachedJson = await _cacheManager.readJson(
        MuseumCacheManager.roomsKey,
      );
      if (cachedJson == null || cachedJson.isEmpty) {
        return const <MuseumRoom>[];
      }

      final Object? decoded = jsonDecode(cachedJson);
      if (decoded is! List<dynamic>) {
        return const <MuseumRoom>[];
      }

      return decoded
          .cast<Map<String, dynamic>>()
          .map(_mapRoom)
          .toList(growable: false);
    } catch (error) {
      debugPrint('[Supabase] cache read failed: $error');
      return const <MuseumRoom>[];
    }
  }

  Future<List<MuseumRoom>> _fetchRoomsFromNetwork() async {
    final uri = Uri.parse(
      '$_url/rest/v1/salas'
      '?select=id,nombre,descripcion,imagen_url,orden,yaw,pitch,'
      'exhibiciones(id,titulo,descripcion,imagen_url,orden,yaw,pitch)'
      '&order=orden.asc',
    );

    debugPrint('[Supabase] GET $uri');

    final response = await _client.get(
      uri,
      headers: <String, String>{
        'apikey': _anonKey,
        'Authorization': 'Bearer $_anonKey',
        'Accept': 'application/json',
      },
    );

    debugPrint('[Supabase] status ${response.statusCode}');
    debugPrint('[Supabase] body ${response.body}');

    if (response.statusCode != 200) {
      throw SupabaseConfigException(
        code: 'unexpectedStatus',
        details: '${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List<dynamic>) {
      throw const SupabaseConfigException(code: 'invalidResponse');
    }

    final rooms = decoded
        .cast<Map<String, dynamic>>()
        .map(_mapRoom)
        .toList(growable: false);

    await _cacheManager.writeJson(MuseumCacheManager.roomsKey, response.body);

    debugPrint('[Supabase] salas recibidas: ${rooms.length}');
    for (final room in rooms) {
      debugPrint('  - ${room.title} -> ${room.coverUrl}');
    }

    return rooms;
  }

  MuseumRoom _mapRoom(Map<String, dynamic> json) {
    final rawExhibits =
        (json['exhibiciones'] as List<dynamic>? ?? const <dynamic>[])
            .cast<Map<String, dynamic>>()
            .toList()
          ..sort((Map<String, dynamic> a, Map<String, dynamic> b) {
            final ordenA = (a['orden'] as num?)?.toInt() ?? 0;
            final ordenB = (b['orden'] as num?)?.toInt() ?? 0;
            return ordenA.compareTo(ordenB);
          });

    final imagen = (json['imagen_url'] as String?) ?? '';

    return MuseumRoom(
      id: json['id'].toString(),
      title: (json['nombre'] as String?) ?? 'Sin titulo',
      subtitle: (json['descripcion'] as String?) ?? '',
      accent: _defaultAccent,
      coverUrl: imagen,
      exhibits: rawExhibits.map(_mapExhibit).toList(growable: false),
      yaw: (json['yaw'] as num?)?.toDouble(),
      pitch: (json['pitch'] as num?)?.toDouble(),
    );
  }

  MuseumExhibit _mapExhibit(Map<String, dynamic> json) {
    final imagen = (json['imagen_url'] as String?) ?? '';
    return MuseumExhibit(
      id: json['id'].toString(),
      title: (json['titulo'] as String?) ?? 'Sin titulo',
      subtitle: '',
      description: (json['descripcion'] as String?) ?? '',
      accent: _defaultAccent,
      mediaType: MuseumMediaType.image,
      mediaUrl: imagen,
      thumbnailUrl: imagen,
      yaw: (json['yaw'] as num?)?.toDouble(),
      pitch: (json['pitch'] as num?)?.toDouble(),
    );
  }
}

class SupabaseConfigException implements Exception {
  const SupabaseConfigException({required this.code, this.details});

  final String code;
  final String? details;

  @override
  String toString() => details == null ? code : '$code: $details';
}

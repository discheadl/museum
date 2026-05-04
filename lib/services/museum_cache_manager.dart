import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MuseumCacheManager extends CacheManager {
  MuseumCacheManager._()
    : super(
        Config(
          _cacheKey,
          stalePeriod: const Duration(hours: 12),
          maxNrOfCacheObjects: 200,
        ),
      );

  static const String _cacheKey = 'museumAppCache';
  static const String roomsKey = 'museum_rooms_payload_v1';

  static final MuseumCacheManager instance = MuseumCacheManager._();

  Future<String?> readJson(String key) async {
    final FileInfo? fileInfo = await getFileFromCache(key);
    if (fileInfo == null) return null;
    return fileInfo.file.readAsString();
  }

  Future<void> writeJson(String key, String value) {
    return putFile(
      key,
      Uint8List.fromList(utf8.encode(value)),
      fileExtension: 'json',
    );
  }
}

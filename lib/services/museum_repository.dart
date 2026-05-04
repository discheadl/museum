import '../models/museum_models.dart';

abstract class MuseumRepository {
  Future<List<MuseumRoom>> fetchRooms({bool forceRefresh = false});
  Future<List<MuseumRoom>> readCachedRooms();
}

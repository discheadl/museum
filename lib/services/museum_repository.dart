import '../models/museum_models.dart';

abstract class MuseumRepository {
  Future<List<MuseumRoom>> fetchRooms();
}

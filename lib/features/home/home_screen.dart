import 'package:flutter/material.dart';

import '../../models/museum_models.dart';
import '../../services/museum_repository.dart';
import '../room/room_screen.dart';
import 'widgets/room_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final MuseumRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _controller;
  late Future<List<MuseumRoom>> _roomsFuture;
  List<MuseumRoom> _rooms = const <MuseumRoom>[];
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.84);
    _controller.addListener(_onScroll);
    _roomsFuture = _loadRooms();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_rooms.isEmpty) return;

    final page = _controller.page;
    if (page == null) return;
    final next = page.round().clamp(0, _rooms.length - 1);
    if (next != _index) {
      setState(() => _index = next);
    }
  }

  void _openRoom(MuseumRoom room) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => RoomScreen(room: room)));
  }

  void _retry() {
    setState(() {
      _index = 0;
      _rooms = const <MuseumRoom>[];
      _roomsFuture = _loadRooms();
    });
  }

  Future<List<MuseumRoom>> _loadRooms() async {
    final rooms = await widget.repository.fetchRooms();
    _rooms = rooms;
    return rooms;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final sidebarWidth = (size.width * 0.28).clamp(260.0, 360.0);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFFF6F1E7),
              Color(0xFFF0E7DB),
              Color(0xFFF7F3EC),
            ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<MuseumRoom>>(
            future: _roomsFuture,
            builder: (BuildContext context, AsyncSnapshot<List<MuseumRoom>> snapshot) {
              final rooms = snapshot.data ?? _rooms;

              return Row(
                children: <Widget>[
                  SizedBox(
                    width: sidebarWidth,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Museo', style: theme.textTheme.headlineMedium),
                          const SizedBox(height: 10),
                          Text(
                            'Explora por imagenes y videos reales desde tu API.',
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 18),
                          _Dots(current: _index, total: rooms.length),
                          const Spacer(),
                          Text(
                            'Configura la URL con --dart-define=MUSEUM_API_BASE_URL=http://127.0.0.1:63808',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(
                                (0.70 * 255).round(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Builder(
                      builder: (BuildContext context) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return _ErrorState(
                            message: snapshot.error.toString(),
                            onRetry: _retry,
                          );
                        }

                        if (rooms.isEmpty) {
                          return const Center(
                            child: Text('La API no devolvio salas todavia.'),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(right: 18),
                          child: PageView.builder(
                            controller: _controller,
                            itemCount: rooms.length,
                            itemBuilder: (BuildContext context, int index) {
                              final room = rooms[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                  horizontal: 10,
                                ),
                                child: RoomCard(
                                  key: ValueKey<String>('room_card_${room.id}'),
                                  room: room,
                                  onTap: () => _openRoom(room),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme.onSurface;

    return Row(
      children: List<Widget>.generate(total, (int i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.only(right: 8),
          width: active ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: ink.withAlpha(((active ? 0.70 : 0.16) * 255).round()),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.cloud_off_rounded,
                size: 44,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 14),
              Text(
                'No se pudo cargar el catalogo',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ),
        ),
      ),
    );
  }
}

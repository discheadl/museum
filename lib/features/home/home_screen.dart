import 'package:flutter/material.dart';

import '../../data/demo_museum.dart';
import '../../models/museum_models.dart';
import '../room/room_screen.dart';
import 'widgets/room_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<MuseumRoom> _rooms;
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _rooms = DemoMuseum.rooms();
    _controller = PageController(viewportFraction: 0.84);
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
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
          child: Row(
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
                        'Explora por imagenes (swipe) en horizontal.',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 18),
                      _Dots(current: _index, total: _rooms.length),
                      const Spacer(),
                      Text(
                        'Base sin menu: esto es la navegacion principal.',
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
                child: Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _rooms.length,
                    itemBuilder: (BuildContext context, int index) {
                      final room = _rooms[index];
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
                ),
              ),
            ],
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

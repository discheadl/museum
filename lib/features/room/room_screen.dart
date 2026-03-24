import 'package:flutter/material.dart';

import '../../models/museum_models.dart';
import '../../widgets/museum_art_panel.dart';
import 'widgets/exhibit_thumbnail.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key, required this.room});

  final MuseumRoom room;

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _jumpTo(int index) async {
    setState(() => _index = index);
    await _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final room = widget.room;
    final ink = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(room.title),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (int next) => setState(() => _index = next),
              itemCount: room.exhibits.length,
              itemBuilder: (BuildContext context, int index) {
                final exhibit = room.exhibits[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 6,
                        child: Hero(
                          tag: index == 0
                              ? 'room_art_${room.id}'
                              : 'ex_${exhibit.id}',
                          child: MuseumArtPanel(
                            accent: exhibit.accent,
                            label: exhibit.title,
                            mediaType: exhibit.mediaType,
                            mediaUrl: exhibit.mediaUrl,
                            thumbnailUrl: exhibit.thumbnailUrl,
                            icon: exhibit.mediaType == MuseumMediaType.video
                                ? Icons.smart_display_outlined
                                : Icons.image_outlined,
                            enableVideoPlayback: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        flex: 5,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: ink.withAlpha((0.04 * 255).round()),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: ink.withAlpha((0.08 * 255).round()),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  exhibit.title,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.6,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  exhibit.subtitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: ink.withAlpha((0.70 * 255).round()),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  exhibit.description,
                                  style: theme.textTheme.bodyLarge,
                                ),
                                const Spacer(),
                                Text(
                                  'Swipe para cambiar pieza. Toca un thumbnail para saltar.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: ink.withAlpha((0.70 * 255).round()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 96,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: room.exhibits.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(width: 12);
                },
                itemBuilder: (BuildContext context, int index) {
                  final exhibit = room.exhibits[index];
                  return ExhibitThumbnail(
                    key: ValueKey<String>('ex_thumb_${exhibit.id}'),
                    exhibit: exhibit,
                    selected: index == _index,
                    onTap: () => _jumpTo(index),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

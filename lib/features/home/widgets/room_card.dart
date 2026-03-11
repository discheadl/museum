import 'package:flutter/material.dart';

import '../../../models/museum_models.dart';
import '../../../widgets/museum_art_panel.dart';

class RoomCard extends StatelessWidget {
  const RoomCard({super.key, required this.room, required this.onTap});

  final MuseumRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Hero(
                  tag: 'room_art_${room.id}',
                  child: MuseumArtPanel(
                    accent: room.accent,
                    label: room.title,
                    icon: Icons.collections_bookmark_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                room.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                room.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(
                    (0.72 * 255).round(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.photo_library_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurface.withAlpha(
                      (0.60 * 255).round(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${room.exhibits.length} piezas',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(
                        (0.72 * 255).round(),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: theme.colorScheme.onSurface.withAlpha(
                      (0.70 * 255).round(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

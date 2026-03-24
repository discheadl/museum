import 'package:flutter/material.dart';

import '../../../models/museum_models.dart';
import '../../../widgets/museum_art_panel.dart';

class ExhibitThumbnail extends StatelessWidget {
  const ExhibitThumbnail({
    super.key,
    required this.exhibit,
    required this.selected,
    required this.onTap,
  });

  final MuseumExhibit exhibit;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onSurface;

    return AnimatedScale(
      duration: const Duration(milliseconds: 140),
      scale: selected ? 1.0 : 0.96,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 140),
        opacity: selected ? 1.0 : 0.74,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: SizedBox(
              width: 168,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: ink.withAlpha(
                      ((selected ? 0.22 : 0.10) * 255).round(),
                    ),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: MuseumArtPanel(
                    accent: exhibit.accent,
                    label: exhibit.title,
                    mediaType: exhibit.mediaType,
                    mediaUrl: exhibit.mediaUrl,
                    thumbnailUrl: exhibit.thumbnailUrl,
                    icon: Icons.photo_outlined,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

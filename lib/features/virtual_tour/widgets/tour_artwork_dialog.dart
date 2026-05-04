import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../data/virtual_tour_demo.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/museum_cache_manager.dart';
import '../../../widgets/museum_skeleton.dart';

class TourArtworkDialog extends StatelessWidget {
  const TourArtworkDialog({super.key, required this.artwork});

  final VirtualTourArtwork artwork;

  static Future<void> _openFullscreen(BuildContext context, String imagePath) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, _, _) => _FullscreenImage(imagePath: imagePath),
        transitionsBuilder: (_, Animation<double> animation, _, Widget child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  static List<Widget> _metaChipsWithLabels(
    VirtualTourArtwork artwork,
    AppLocalizations localizations,
  ) {
    final chips = <Widget>[];
    if (artwork.author.isNotEmpty) {
      chips.add(
        _MetaChip(
          label: localizations.text('artwork.authorLabel'),
          value: artwork.author,
        ),
      );
    }
    if (artwork.dateLabel.isNotEmpty) {
      chips.add(
        _MetaChip(
          label: localizations.text('artwork.dateLabel'),
          value: artwork.dateLabel,
        ),
      );
    }
    return chips;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations localizations = AppLocalizations.of(context);
    final List<Widget> metaChips = _metaChipsWithLabels(artwork, localizations);

    final double maxHeight = MediaQuery.of(context).size.height - 60;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 980, maxHeight: maxHeight),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F1E7),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: RepaintBoundary(
                    child: GestureDetector(
                      onTap: () => _openFullscreen(context, artwork.imagePath),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: _ArtworkImage(imagePath: artwork.imagePath),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              artwork.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            key: const ValueKey<String>('tour_artwork_close'),
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      if (artwork.subtitle.isNotEmpty)
                        Text(
                          artwork.subtitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF7F5539),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (metaChips.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 16),
                        Wrap(spacing: 10, runSpacing: 10, children: metaChips),
                      ],
                      const SizedBox(height: 16),
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(right: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  artwork.description,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    height: 1.4,
                                  ),
                                ),
                                if (artwork.context.isNotEmpty) ...<Widget>[
                                  const SizedBox(height: 14),
                                  Text(
                                    artwork.context,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withAlpha((0.74 * 255).round()),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArtworkImage extends StatelessWidget {
  const _ArtworkImage({required this.imagePath, this.fit = BoxFit.cover});

  final String imagePath;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        cacheManager: MuseumCacheManager.instance,
        fit: fit,
        placeholder: (BuildContext context, String url) => const MuseumSkeleton(
          width: double.infinity,
          height: double.infinity,
          borderRadius: BorderRadius.zero,
          baseColor: Color(0xFFE8DCCA),
          highlightColor: Color(0xFFF3E9DA),
        ),
        errorWidget: (BuildContext context, String url, Object error) =>
            const ColoredBox(
              color: Color(0xFFE8DCCA),
              child: Center(child: Icon(Icons.image_not_supported_outlined)),
            ),
      );
    }

    return Image.asset(imagePath, fit: fit);
  }
}

class _FullscreenImage extends StatelessWidget {
  const _FullscreenImage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: _ArtworkImage(
                    imagePath: imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(140),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    key: const ValueKey<String>('tour_fullscreen_close'),
                    color: Colors.white,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          '$label: $value',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

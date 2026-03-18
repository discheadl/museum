import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/museum_models.dart';

class MuseumArtPanel extends StatelessWidget {
  const MuseumArtPanel({
    super.key,
    required this.accent,
    required this.label,
    required this.mediaType,
    required this.mediaUrl,
    this.thumbnailUrl = '',
    this.icon = Icons.museum_outlined,
    this.enableVideoPlayback = false,
  });

  final Color accent;
  final String label;
  final MuseumMediaType mediaType;
  final String mediaUrl;
  final String thumbnailUrl;
  final IconData icon;
  final bool enableVideoPlayback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onSurface;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surface,
        border: Border.all(color: ink.withAlpha((0.10 * 255).round())),
        boxShadow: <BoxShadow>[
          BoxShadow(
            blurRadius: 22,
            spreadRadius: -10,
            color: accent.withAlpha((0.22 * 255).round()),
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _MediaSurface(
              accent: accent,
              label: label,
              mediaType: mediaType,
              mediaUrl: mediaUrl,
              thumbnailUrl: thumbnailUrl,
              enableVideoPlayback: enableVideoPlayback,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.transparent,
                    Colors.black.withAlpha((0.10 * 255).round()),
                    Colors.black.withAlpha((0.52 * 255).round()),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final showVideoBadge =
                      mediaType == MuseumMediaType.video &&
                      constraints.maxWidth >= 180;

                  return Row(
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha((0.28 * 255).round()),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (showVideoBadge) ...<Widget>[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha((0.34 * 255).round()),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Video',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaSurface extends StatelessWidget {
  const _MediaSurface({
    required this.accent,
    required this.label,
    required this.mediaType,
    required this.mediaUrl,
    required this.thumbnailUrl,
    required this.enableVideoPlayback,
  });

  final Color accent;
  final String label;
  final MuseumMediaType mediaType;
  final String mediaUrl;
  final String thumbnailUrl;
  final bool enableVideoPlayback;

  @override
  Widget build(BuildContext context) {
    if (mediaType == MuseumMediaType.video && enableVideoPlayback) {
      return _VideoSurface(
        mediaUrl: mediaUrl,
        thumbnailUrl: thumbnailUrl,
        label: label,
      );
    }

    final imageUrl = thumbnailUrl.isNotEmpty ? thumbnailUrl : mediaUrl;
    return _NetworkImageSurface(
      imageUrl: imageUrl,
      label: label,
      accent: accent,
      showPlayIcon: mediaType == MuseumMediaType.video,
    );
  }
}

class _NetworkImageSurface extends StatelessWidget {
  const _NetworkImageSurface({
    required this.imageUrl,
    required this.label,
    required this.accent,
    this.showPlayIcon = false,
  });

  final String imageUrl;
  final String label;
  final Color accent;
  final bool showPlayIcon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (imageUrl.isNotEmpty)
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
                  return _MediaFallback(accent: accent, label: label);
                },
            loadingBuilder:
                (
                  BuildContext context,
                  Widget child,
                  ImageChunkEvent? loadingProgress,
                ) {
                  if (loadingProgress == null) return child;
                  return _MediaFallback(
                    accent: accent,
                    label: label,
                    busy: true,
                  );
                },
          )
        else
          _MediaFallback(accent: accent, label: label),
        if (showPlayIcon)
          const Center(
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Color(0x8A000000),
              child: Icon(
                Icons.play_arrow_rounded,
                size: 34,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

class _VideoSurface extends StatefulWidget {
  const _VideoSurface({
    required this.mediaUrl,
    required this.thumbnailUrl,
    required this.label,
  });

  final String mediaUrl;
  final String thumbnailUrl;
  final String label;

  @override
  State<_VideoSurface> createState() => _VideoSurfaceState();
}

class _VideoSurfaceState extends State<_VideoSurface> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(covariant _VideoSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaUrl != widget.mediaUrl) {
      _disposeController();
      _initVideo();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  Future<void> _initVideo() async {
    if (widget.mediaUrl.isEmpty) {
      setState(() => _failed = true);
      return;
    }

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.mediaUrl),
    );

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _ready = true;
      });
    } catch (_) {
      await controller.dispose();
      if (mounted) {
        setState(() => _failed = true);
      }
    }
  }

  void _disposeController() {
    final controller = _controller;
    _controller = null;
    _ready = false;
    _failed = false;
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ready && _controller != null) {
      return FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      );
    }

    if (_failed) {
      return _NetworkImageSurface(
        imageUrl: widget.thumbnailUrl,
        label: widget.label,
        accent: const Color(0xFF7F5539),
        showPlayIcon: true,
      );
    }

    return _NetworkImageSurface(
      imageUrl: widget.thumbnailUrl,
      label: widget.label,
      accent: const Color(0xFF7F5539),
      showPlayIcon: true,
    );
  }
}

class _MediaFallback extends StatelessWidget {
  const _MediaFallback({
    required this.accent,
    required this.label,
    this.busy = false,
  });

  final Color accent;
  final String label;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            accent.withAlpha((0.92 * 255).round()),
            accent.withAlpha((0.70 * 255).round()),
            const Color(0xFF1F1B16),
          ],
        ),
      ),
      child: Center(
        child: busy
            ? const CircularProgressIndicator(color: Colors.white)
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
      ),
    );
  }
}

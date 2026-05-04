import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

import '../../data/virtual_tour_demo.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/locale_controller.dart';
import '../../models/museum_models.dart';
import '../../services/museum_cache_manager.dart';
import '../../services/museum_repository.dart';
import '../../services/supabase_museum_service.dart';
import '../../widgets/museum_skeleton.dart';
import 'widgets/language_selector.dart';
import 'widgets/tour_artwork_dialog.dart';
import 'widgets/tour_navigation_bar.dart';
import 'widgets/tour_panorama_viewer.dart';

class VirtualTourScreen extends StatefulWidget {
  const VirtualTourScreen({
    super.key,
    required this.repository,
    this.initialSceneId,
    this.initialRooms,
  });

  final MuseumRepository repository;
  final String? initialSceneId;
  final List<MuseumRoom>? initialRooms;

  @override
  State<VirtualTourScreen> createState() => _VirtualTourScreenState();
}

class _VirtualTourScreenState extends State<VirtualTourScreen> {
  static const Map<String, String> _audioAssets = <String, String>{
    'es': 'assets/audio/espanol.mp3',
    'en': 'assets/audio/ingles.mp3',
    'fr': 'assets/audio/frances.mp3',
  };

  final Set<String> _precachedScenes = <String>{};
  final Map<String, VideoPlayerController> _audioControllers =
      <String, VideoPlayerController>{};

  late int _sceneIndex;
  final bool _gyroscopeEnabled = false;
  final bool _showHotspotHints = true;
  bool _navigationControlsVisible = true;
  bool _languageMenuVisible = false;
  bool _isAudioSeeking = false;
  String? _audioLanguageCode;
  Future<void>? _audioSetupFuture;

  List<MuseumRoom> _rooms = const <MuseumRoom>[];
  Object? _loadError;

  MuseumRoom? get _currentRoom => _rooms.isEmpty ? null : _rooms[_sceneIndex];

  @override
  void initState() {
    super.initState();
    _sceneIndex = 0;
    _audioSetupFuture = _initializeAudioPlayers();
    if (widget.initialRooms != null && widget.initialRooms!.isNotEmpty) {
      _applyRooms(widget.initialRooms!);
      unawaited(_refreshScenes(forceRefresh: true));
    } else {
      _bootstrapScenes();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final String localeCode = AppLocaleScope.of(context).locale.languageCode;
    unawaited(_syncAudioLanguage(localeCode));
  }

  @override
  void dispose() {
    for (final VideoPlayerController controller in _audioControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _bootstrapScenes() async {
    try {
      final List<MuseumRoom> cachedRooms = await widget.repository
          .readCachedRooms();
      if (cachedRooms.isNotEmpty) {
        _applyRooms(cachedRooms);
      }

      await _refreshScenes(forceRefresh: true);
    } catch (error, stack) {
      debugPrint('[VirtualTour] error cargando escenas: $error\n$stack');
      if (!mounted || _rooms.isNotEmpty) return;
      setState(() => _loadError = error);
    }
  }

  Future<void> _refreshScenes({required bool forceRefresh}) async {
    try {
      final List<MuseumRoom> rooms = await widget.repository.fetchRooms(
        forceRefresh: forceRefresh,
      );
      _applyRooms(rooms);
    } catch (error, stack) {
      debugPrint('[VirtualTour] refresh error: $error\n$stack');
      if (!mounted || _rooms.isNotEmpty) return;
      setState(() => _loadError = error);
    }
  }

  void _applyRooms(List<MuseumRoom> rooms) {
    if (rooms.isEmpty) {
      throw const VirtualTourLoadException('roomListEmpty');
    }

    final List<MuseumRoom> withPanoramas = rooms
        .where((MuseumRoom room) => room.coverUrl.isNotEmpty)
        .toList(growable: false);

    if (withPanoramas.isEmpty) {
      throw const VirtualTourLoadException('roomPanoramaMissing');
    }

    final int nextIndex = _findInitialIndex(withPanoramas);
    final bool roomsChanged = !listEquals(_rooms, withPanoramas);
    final bool indexChanged = _sceneIndex != nextIndex;

    if (!mounted) return;
    if (roomsChanged || indexChanged || _loadError != null) {
      setState(() {
        _rooms = withPanoramas;
        _sceneIndex = nextIndex;
        _loadError = null;
      });
    }

    unawaited(_precacheAroundIndex(nextIndex));
  }

  int _findInitialIndex(List<MuseumRoom> rooms) {
    final String? sceneId = widget.initialSceneId;
    if (sceneId == null) return 0;

    final int index = rooms.indexWhere((MuseumRoom room) => room.id == sceneId);
    return index < 0 ? 0 : index;
  }

  VirtualTourScene _buildSceneForIndex(
    int index,
    AppLocalizations localizations,
  ) {
    const Color exhibitTint = Color(0xFFE76F51);
    const Color navTint = Color(0xFF2A9D8F);

    final MuseumRoom room = _rooms[index];
    final List<VirtualTourHotspot> hotspots = <VirtualTourHotspot>[];
    final double navYaw = room.yaw ?? (index == 0 ? 202 : 30);
    final double navPitch = room.pitch ?? -8;

    if (index < _rooms.length - 1) {
      final MuseumRoom next = _rooms[index + 1];
      final String nextTitle = localizations.roomTitle(next.id, next.title);
      hotspots.add(
        VirtualTourHotspot.navigation(
          id: '${room.id}_next',
          label: localizations.text(
            'tour.goToRoom',
            params: <String, String>{'title': nextTitle},
          ),
          targetSceneId: next.id,
          longitude: navYaw,
          latitude: navPitch,
          tint: navTint,
        ),
      );
    } else if (index > 0) {
      final MuseumRoom previous = _rooms[index - 1];
      final String previousTitle = localizations.roomTitle(
        previous.id,
        previous.title,
      );
      hotspots.add(
        VirtualTourHotspot.navigation(
          id: '${room.id}_prev',
          label: localizations.text(
            'tour.goToRoom',
            params: <String, String>{'title': previousTitle},
          ),
          targetSceneId: previous.id,
          longitude: navYaw,
          latitude: navPitch,
          tint: navTint,
        ),
      );
    }

    for (final MuseumExhibit exhibit in room.exhibits) {
      final double? yaw = exhibit.yaw;
      final double? pitch = exhibit.pitch;
      if (yaw == null || pitch == null) continue;

      final String exhibitTitle = localizations.exhibitTitle(
        exhibit.id,
        exhibit.title,
      );
      hotspots.add(
        VirtualTourHotspot.info(
          id: 'exhibit_${exhibit.id}',
          label: exhibitTitle,
          artwork: VirtualTourArtwork(
            id: exhibit.id,
            title: exhibitTitle,
            subtitle: localizations.exhibitSubtitle(
              exhibit.id,
              exhibit.subtitle,
            ),
            description: localizations.exhibitDescription(
              exhibit.id,
              exhibit.description,
            ),
            author: '',
            dateLabel: '',
            context: '',
            imagePath: exhibit.mediaUrl,
          ),
          longitude: yaw,
          latitude: pitch,
          tint: exhibitTint,
        ),
      );
    }

    return VirtualTourScene(
      id: room.id,
      title: localizations.roomTitle(room.id, room.title),
      caption: localizations.roomSubtitle(room.id, room.subtitle),
      assetPath: '',
      initialLongitude: 0,
      initialLatitude: 0,
      hotspots: hotspots,
      panoramaUrl: room.coverUrl,
    );
  }

  void _retryLoad() {
    setState(() => _loadError = null);
    _bootstrapScenes();
  }

  void _goToScene(String sceneId) {
    if (_rooms.isEmpty) return;
    final int nextIndex = _rooms.indexWhere(
      (MuseumRoom room) => room.id == sceneId,
    );
    if (nextIndex < 0 || nextIndex == _sceneIndex) return;

    _precacheAroundIndex(nextIndex);
    setState(() => _sceneIndex = nextIndex);
  }

  Future<void> _showArtworkInfo(VirtualTourArtwork artwork) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withAlpha((0.66 * 255).round()),
      builder: (_) => TourArtworkDialog(artwork: artwork),
    );
  }

  void _hideNavigationControls() {
    if (!_navigationControlsVisible) return;
    setState(() => _navigationControlsVisible = false);
  }

  void _showNavigationControls() {
    if (_navigationControlsVisible) return;
    setState(() => _navigationControlsVisible = true);
  }

  void _toggleLanguageMenu() {
    setState(() => _languageMenuVisible = !_languageMenuVisible);
  }

  Future<void> _initializeAudioPlayers() async {
    if (_audioControllers.isNotEmpty) return;

    for (final MapEntry<String, String> entry in _audioAssets.entries) {
      final VideoPlayerController controller = VideoPlayerController.asset(
        entry.value,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
      );
      await controller.initialize();
      await controller.setLooping(false);
      _audioControllers[entry.key] = controller;
    }
  }

  VideoPlayerController? get _activeAudioController {
    final String? languageCode = _audioLanguageCode;
    if (languageCode == null) return null;
    return _audioControllers[languageCode];
  }

  Duration _clampPosition(Duration position, Duration duration) {
    if (duration <= Duration.zero) return Duration.zero;
    if (position < Duration.zero) return Duration.zero;
    if (position > duration) return duration;
    return position;
  }

  Future<void> _syncAudioLanguage(String nextLanguageCode) async {
    final Future<void>? setupFuture = _audioSetupFuture;
    if (setupFuture != null) {
      await setupFuture;
    }

    final VideoPlayerController? target = _audioControllers[nextLanguageCode];
    if (target == null) return;

    final VideoPlayerController? current = _activeAudioController;
    final bool firstActivation = _audioLanguageCode == null;
    if (!firstActivation && _audioLanguageCode == nextLanguageCode) return;

    final Duration currentPosition = current?.value.position ?? Duration.zero;
    final bool shouldResumePlayback =
        firstActivation || (current?.value.isPlaying ?? false);

    if (current != null && current != target && current.value.isInitialized) {
      await current.pause();
    }

    await target.seekTo(_clampPosition(currentPosition, target.value.duration));

    if (!mounted) return;
    setState(() => _audioLanguageCode = nextLanguageCode);

    if (shouldResumePlayback) {
      await target.play();
    } else {
      await target.pause();
    }
  }

  Future<void> _toggleAudioPlayback() async {
    final VideoPlayerController? controller = _activeAudioController;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      if (controller.value.position >= controller.value.duration &&
          controller.value.duration > Duration.zero) {
        await controller.seekTo(Duration.zero);
      }
      await controller.play();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _seekAudio(double seconds) async {
    final VideoPlayerController? controller = _activeAudioController;
    if (controller == null || !controller.value.isInitialized) return;

    if (mounted) {
      setState(() => _isAudioSeeking = true);
    }
    await controller.seekTo(
      _clampPosition(
        Duration(milliseconds: (seconds * 1000).round()),
        controller.value.duration,
      ),
    );
    if (mounted) {
      setState(() => _isAudioSeeking = false);
    }
  }

  Future<void> _precacheAroundIndex(int index) async {
    if (_rooms.isEmpty) return;
    final List<Future<void>> pending = <Future<void>>[
      _precacheRoom(_rooms[index]),
    ];

    if (index > 0) {
      pending.add(_precacheRoom(_rooms[index - 1]));
    }

    if (index < _rooms.length - 1) {
      pending.add(_precacheRoom(_rooms[index + 1]));
    }

    await Future.wait<void>(pending);
  }

  Future<void> _precacheRoom(MuseumRoom room) async {
    if (_precachedScenes.contains(room.id) || room.coverUrl.isEmpty) return;

    _precachedScenes.add(room.id);
    try {
      await precacheImage(
        CachedNetworkImageProvider(
          room.coverUrl,
          cacheManager: MuseumCacheManager.instance,
        ),
        context,
      );
    } catch (error) {
      debugPrint('[VirtualTour] precache fallo para ${room.coverUrl}: $error');
    }
  }

  String _localizedErrorMessage(AppLocalizations localizations, Object error) {
    if (error is VirtualTourLoadException) {
      switch (error.code) {
        case 'roomListEmpty':
          return localizations.text('errors.roomListEmpty');
        case 'roomPanoramaMissing':
          return localizations.text('errors.roomPanoramaMissing');
      }
    }

    if (error is SupabaseConfigException) {
      switch (error.code) {
        case 'missingCredentials':
          return localizations.text('errors.supabaseMissingCredentials');
        case 'unexpectedStatus':
          return localizations.text('errors.supabaseUnexpectedStatus');
        case 'invalidResponse':
          return localizations.text('errors.supabaseInvalidResponse');
      }
    }

    return localizations.text('errors.genericLoadFailure');
  }

  String? _technicalErrorDetails(Object error) {
    if (error is SupabaseConfigException) {
      return error.details;
    }
    return error is VirtualTourLoadException ? null : error.toString();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final MuseumRoom? room = _currentRoom;
    final VirtualTourScene? scene = room == null
        ? null
        : _buildSceneForIndex(_sceneIndex, localizations);
    final AppLocaleController localeController = AppLocaleScope.of(context);
    final String? errorDetails = _loadError == null
        ? null
        : _technicalErrorDetails(_loadError!);
    final VideoPlayerController? activeAudioController = _activeAudioController;
    final bool isAudioReady =
        activeAudioController != null &&
        activeAudioController.value.isInitialized;

    if (scene == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: _loadError != null
              ? _TourLoadError(
                  title: localizations.text('errors.unableToLoadTour'),
                  message: _localizedErrorMessage(localizations, _loadError!),
                  details: errorDetails,
                  retryLabel: localizations.text('actions.retry'),
                  onRetry: _retryLoad,
                )
              : const _TourLoadingSkeleton(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 420),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: TourPanoramaViewer(
                  key: ValueKey<String>('tour_scene_${scene.id}'),
                  scene: scene,
                  gyroscopeEnabled: _gyroscopeEnabled,
                  showHotspotHints: _showHotspotHints,
                  onViewportTap: _showNavigationControls,
                  onNavigateToScene: _goToScene,
                  onSelectArtwork: _showArtworkInfo,
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(child: _TourGradientOverlay()),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: LanguageSelector(
                          key: ValueKey<String>(
                            'tour_language_menu_${scene.id}',
                          ),
                          controller: localeController,
                          expanded: _languageMenuVisible,
                          onToggle: _toggleLanguageMenu,
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: _CurrentLocationBadge(
                          label: localizations.text('tour.currentLocation'),
                          location: scene.title,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _navigationControlsVisible
                          ? (activeAudioController == null
                                ? TourAudioBar(
                                    key: const ValueKey<String>(
                                      'tour_audio_visible',
                                    ),
                                    isReady: isAudioReady,
                                    isPlaying: false,
                                    position: Duration.zero,
                                    duration: Duration.zero,
                                    showSlider: _isAudioSeeking,
                                    playTooltip: localizations.text(
                                      'audio.play',
                                    ),
                                    pauseTooltip: localizations.text(
                                      'audio.pause',
                                    ),
                                    closeTooltip: localizations.text(
                                      'tour.hideNavigationControls',
                                    ),
                                    onTogglePlayback: _toggleAudioPlayback,
                                    onSeekCommit: (double seconds) {
                                      unawaited(_seekAudio(seconds));
                                    },
                                    onClose: _hideNavigationControls,
                                  )
                                : AnimatedBuilder(
                                    key: const ValueKey<String>(
                                      'tour_audio_visible',
                                    ),
                                    animation: activeAudioController,
                                    builder: (BuildContext context, _) {
                                      return TourAudioBar(
                                        isReady: isAudioReady,
                                        isPlaying: activeAudioController
                                            .value
                                            .isPlaying,
                                        position: activeAudioController
                                            .value
                                            .position,
                                        duration: activeAudioController
                                            .value
                                            .duration,
                                        showSlider:
                                            activeAudioController
                                                .value
                                                .isPlaying ||
                                            _isAudioSeeking,
                                        playTooltip: localizations.text(
                                          'audio.play',
                                        ),
                                        pauseTooltip: localizations.text(
                                          'audio.pause',
                                        ),
                                        closeTooltip: localizations.text(
                                          'tour.hideNavigationControls',
                                        ),
                                        onTogglePlayback: _toggleAudioPlayback,
                                        onSeekCommit: (double seconds) {
                                          unawaited(_seekAudio(seconds));
                                        },
                                        onClose: _hideNavigationControls,
                                      );
                                    },
                                  ))
                          : Tooltip(
                              key: const ValueKey<String>('tour_nav_hidden'),
                              message: localizations.text(
                                'tour.showNavigationControls',
                              ),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(160),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withAlpha(28),
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: _showNavigationControls,
                                  icon: const Icon(
                                    Icons.chevron_left_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VirtualTourLoadException implements Exception {
  const VirtualTourLoadException(this.code);

  final String code;

  @override
  String toString() => code;
}

class _CurrentLocationBadge extends StatelessWidget {
  const _CurrentLocationBadge({required this.label, required this.location});

  final String label;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(150),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withAlpha(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.place_rounded,
                    color: Color(0xFFF4A261),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      location,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
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

class _TourGradientOverlay extends StatelessWidget {
  const _TourGradientOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0x5C000000),
            Colors.transparent,
            Colors.transparent,
            Color(0x80000000),
          ],
          stops: <double>[0, 0.18, 0.66, 1],
        ),
      ),
    );
  }
}

class _TourLoadingSkeleton extends StatelessWidget {
  const _TourLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          MuseumSkeleton(width: 280, height: 180),
          SizedBox(height: 18),
          MuseumSkeleton(width: 220, height: 18),
          SizedBox(height: 10),
          MuseumSkeleton(width: 180, height: 14),
        ],
      ),
    );
  }
}

class _TourLoadError extends StatelessWidget {
  const _TourLoadError({
    required this.title,
    required this.message,
    required this.details,
    required this.retryLabel,
    required this.onRetry,
  });

  final String title;
  final String message;
  final String? details;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.cloud_off_rounded, color: Colors.white70, size: 48),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          if (details != null && details!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              details!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(retryLabel),
          ),
        ],
      ),
    );
  }
}

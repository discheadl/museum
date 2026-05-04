import 'package:flutter/material.dart';

class TourAudioBar extends StatefulWidget {
  const TourAudioBar({
    super.key,
    required this.isReady,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.showSlider,
    required this.playTooltip,
    required this.pauseTooltip,
    required this.closeTooltip,
    required this.onTogglePlayback,
    required this.onSeekCommit,
    required this.onClose,
  });

  final bool isReady;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool showSlider;
  final String playTooltip;
  final String pauseTooltip;
  final String closeTooltip;
  final VoidCallback onTogglePlayback;
  final ValueChanged<double> onSeekCommit;
  final VoidCallback onClose;

  @override
  State<TourAudioBar> createState() => _TourAudioBarState();
}

class _TourAudioBarState extends State<TourAudioBar> {
  bool _isDragging = false;
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final double maxSeconds = widget.duration.inMilliseconds <= 0
        ? 1
        : widget.duration.inMilliseconds / 1000;
    final double livePositionSeconds = (widget.position.inMilliseconds / 1000)
        .clamp(0, maxSeconds);
    final double sliderValue =
        (_isDragging ? _dragValue : livePositionSeconds) ?? livePositionSeconds;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.62 * 255).round()),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withAlpha((0.12 * 255).round())),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withAlpha((0.28 * 255).round()),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _NavButton(
              key: const ValueKey<String>('tour_audio_toggle'),
              icon: widget.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              tooltip: widget.isPlaying
                  ? widget.pauseTooltip
                  : widget.playTooltip,
              enabled: widget.isReady,
              onPressed: widget.onTogglePlayback,
            ),
            if (widget.showSlider || _isDragging) ...<Widget>[
              const SizedBox(width: 12),
              SizedBox(
                width: 220,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                    activeTrackColor: const Color(0xFFF4A261),
                    inactiveTrackColor: Colors.white24,
                    thumbColor: const Color(0xFFF4A261),
                    overlayColor: const Color(0x33F4A261),
                  ),
                  child: Slider(
                    value: sliderValue.clamp(0, maxSeconds),
                    min: 0,
                    max: maxSeconds,
                    onChangeStart: widget.isReady
                        ? (double value) {
                            setState(() {
                              _isDragging = true;
                              _dragValue = value;
                            });
                          }
                        : null,
                    onChanged: widget.isReady
                        ? (double value) {
                            setState(() => _dragValue = value);
                          }
                        : null,
                    onChangeEnd: widget.isReady
                        ? (double value) {
                            widget.onSeekCommit(value);
                            setState(() {
                              _isDragging = false;
                              _dragValue = null;
                            });
                          }
                        : null,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 8),
            _NavButton(
              key: const ValueKey<String>('tour_audio_close'),
              icon: Icons.close_rounded,
              tooltip: widget.closeTooltip,
              enabled: true,
              onPressed: widget.onClose,
              tint: const Color(0xFFE76F51),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onPressed,
    this.tint = const Color(0xFF264653),
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onPressed;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tint.withAlpha((0.88 * 255).round()),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: enabled ? onPressed : null,
          icon: Icon(
            icon,
            color: enabled
                ? Colors.white
                : Colors.white.withAlpha((0.42 * 255).round()),
          ),
        ),
      ),
    );
  }
}

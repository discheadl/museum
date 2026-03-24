import 'dart:math' as math;

import 'package:flutter/material.dart';

class MuseumArtPanel extends StatelessWidget {
  const MuseumArtPanel({
    super.key,
    required this.accent,
    required this.label,
    this.icon = Icons.museum_outlined,
  });

  final Color accent;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surface;
    final ink = theme.colorScheme.onSurface;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.alphaBlend(accent.withAlpha((0.22 * 255).round()), base),
            Color.alphaBlend(accent.withAlpha((0.10 * 255).round()), base),
            base,
          ],
          stops: const <double>[0.0, 0.55, 1.0],
        ),
        border: Border.all(color: ink.withAlpha((0.10 * 255).round())),
        boxShadow: <BoxShadow>[
          BoxShadow(
            blurRadius: 22,
            spreadRadius: -10,
            color: accent.withAlpha((0.35 * 255).round()),
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: _NoiseOverlay(opacity: 0.04)),
            Positioned(
              right: -40,
              top: -30,
              child: _Blob(
                color: accent.withAlpha((0.16 * 255).round()),
                size: 240,
              ),
            ),
            Positioned(
              left: -60,
              bottom: -60,
              child: _Blob(
                color: accent.withAlpha((0.10 * 255).round()),
                size: 260,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: ink.withAlpha((0.06 * 255).round()),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: ink.withAlpha((0.08 * 255).round()),
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: ink.withAlpha((0.82 * 255).round()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.45,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size * 0.28),
        ),
      ),
    );
  }
}

class _NoiseOverlay extends StatelessWidget {
  const _NoiseOverlay({required this.opacity});
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _NoisePainter(opacity: opacity));
  }
}

class _NoisePainter extends CustomPainter {
  _NoisePainter({required this.opacity});
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withAlpha((opacity * 255).round());
    final rnd = math.Random(42);

    // Ruido ligero para que el panel se sienta "impreso".
    for (int i = 0; i < 650; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}

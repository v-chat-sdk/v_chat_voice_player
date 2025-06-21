// Copyright 2023, the hatemragab project author.
// All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../voice_state_model.dart';
import '../voice_message_controller.dart';

/// A widget that displays an animated voice waveform visualization
/// with interactive seeking functionality using a hidden native Flutter Slider
class VoiceVisualizer extends StatefulWidget {
  /// The controller managing the voice message playback
  final VVoiceMessageController controller;

  /// The current state of the voice player
  final VoiceStateModel state;

  /// Color of the active (played) part of the waveform
  final Color activeColor;

  /// Color of the inactive (unplayed) part of the waveform
  final Color inactiveColor;

  /// Height of the visualizer
  final double height;

  /// Number of bars in the visualization
  final int barCount;

  /// Spacing between bars
  final double barSpacing;

  /// Minimum height of bars
  final double minBarHeight;

  /// Whether to show animated bars when playing
  final bool enableAnimation;

  /// Custom bar heights for unique waveform patterns
  final List<double>? customBarHeights;

  const VoiceVisualizer({
    super.key,
    required this.controller,
    required this.state,
    required this.activeColor,
    required this.inactiveColor,
    this.height = 40.0,
    this.barCount = 50,
    this.barSpacing = 2.0,
    this.minBarHeight = 4.0,
    this.enableAnimation = true,
    this.customBarHeights,
  });

  @override
  State<VoiceVisualizer> createState() => _VoiceVisualizerState();
}

class _VoiceVisualizerState extends State<VoiceVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<double> _barHeights;
  late List<AnimationController> _barAnimationControllers;
  late List<Animation<double>> _barAnimations;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _setupAnimationControllers();
    _generateBarHeights();
    _setupBarAnimations();
  }

  void _setupAnimationControllers() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _barAnimationControllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 300 + (index % 200)),
        vsync: this,
      ),
    );
  }

  void _generateBarHeights() {
    // Use custom bar heights if provided, otherwise generate default pattern
    if (widget.customBarHeights != null &&
        widget.customBarHeights!.isNotEmpty) {
      _barHeights = List.from(widget.customBarHeights!);
      return;
    }

    final random = math.Random(42); // Fixed seed for consistent pattern
    _barHeights = List.generate(widget.barCount, (index) {
      // Create a more realistic waveform pattern
      final baseHeight = math.sin(index * 0.1) * 0.3 + 0.7;
      final randomFactor = random.nextDouble() * 0.4 + 0.6;
      final height = baseHeight * randomFactor * widget.height;
      return math.max(height, widget.minBarHeight);
    }).toList();
  }

  void _setupBarAnimations() {
    _barAnimations = _barAnimationControllers.map((controller) {
      return Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void didUpdateWidget(VoiceVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.state.isPlaying != oldWidget.state.isPlaying) {
      _handlePlayStateChange();
    }
  }

  void _handlePlayStateChange() {
    if (!mounted) return;

    if (widget.state.isPlaying && widget.enableAnimation) {
      _startAnimation();
    } else {
      _stopAnimation();
    }
  }

  void _startAnimation() {
    if (!_isAnimating) {
      _isAnimating = true;
      _animateRandomBars();
    }
  }

  void _stopAnimation() {
    if (_isAnimating) {
      _isAnimating = false;
      for (final controller in _barAnimationControllers) {
        if (mounted) {
          controller.stop();
          controller.reset();
        }
      }
    }
  }

  void _animateRandomBars() {
    if (!_isAnimating || !mounted) return;

    final random = math.Random();
    final barsToAnimate = random.nextInt(5) + 3; // 3-7 bars

    for (int i = 0; i < barsToAnimate; i++) {
      final barIndex = random.nextInt(widget.barCount);
      final controller = _barAnimationControllers[barIndex];

      if (!controller.isAnimating && mounted) {
        controller.forward().then((_) {
          if (_isAnimating && mounted) {
            controller.reverse();
          }
        });
      }
    }

    // Schedule next animation
    Future.delayed(Duration(milliseconds: random.nextInt(300) + 100), () {
      if (_isAnimating && mounted) {
        _animateRandomBars();
      }
    });
  }

  @override
  void dispose() {
    // Stop animations before disposing
    _stopAnimation();

    // Dispose all animation controllers
    _animationController.dispose();
    for (final controller in _barAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create a custom slider theme with transparent appearance
    final hiddenSliderTheme = SliderTheme.of(context).copyWith(
      activeTrackColor: Colors.transparent,
      inactiveTrackColor: Colors.transparent,
      thumbColor: Colors.transparent,
      overlayColor: Colors.transparent,
      trackHeight: widget.height,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0.0),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 0.0),
      trackShape: const RoundedRectSliderTrackShape(),
    );

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Hidden Flutter Slider for native touch handling
          Positioned.fill(
            child: SliderTheme(
              data: hiddenSliderTheme,
              child: Opacity(
                opacity: 0.0, // Completely hidden
                child: Slider(
                  value: widget.state.currentMillSeconds
                      .clamp(0.0, widget.state.maxMillSeconds),
                  min: 0.0,
                  max: widget.state.maxMillSeconds,
                  onChangeStart: widget.controller.onChangeSliderStart,
                  onChanged: widget.controller.onChanging,
                  onChangeEnd: (value) {
                    widget.controller
                        .onSeek(Duration(milliseconds: value.toInt()));
                  },
                ),
              ),
            ),
          ),

          // Visual bars (non-interactive)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                size: Size(double.infinity, widget.height),
                painter: _VoiceVisualizerPainter(
                  barHeights: _barHeights,
                  progress: widget.state.progress,
                  activeColor: widget.activeColor,
                  inactiveColor: widget.inactiveColor,
                  barSpacing: widget.barSpacing,
                  barAnimations: _barAnimations,
                  isPlaying: widget.state.isPlaying && widget.enableAnimation,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for drawing the voice waveform visualization
class _VoiceVisualizerPainter extends CustomPainter {
  final List<double> barHeights;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final double barSpacing;
  final List<Animation<double>> barAnimations;
  final bool isPlaying;

  _VoiceVisualizerPainter({
    required this.barHeights,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    required this.barSpacing,
    required this.barAnimations,
    required this.isPlaying,
  }) : super(repaint: isPlaying ? Listenable.merge(barAnimations) : null);

  @override
  void paint(Canvas canvas, Size size) {
    if (barHeights.isEmpty) return;

    final barWidth =
        (size.width - (barHeights.length - 1) * barSpacing) / barHeights.length;
    final progressPosition = progress * size.width;

    for (int i = 0; i < barHeights.length; i++) {
      final x = i * (barWidth + barSpacing);
      final baseHeight = barHeights[i];

      // Apply animation if playing
      final animationScale = isPlaying ? barAnimations[i].value : 1.0;
      final height = baseHeight * animationScale;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          (size.height - height) / 2,
          barWidth,
          height,
        ),
        const Radius.circular(1.5),
      );

      // Determine color based on progress
      final color = x <= progressPosition ? activeColor : inactiveColor;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VoiceVisualizerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.isPlaying != isPlaying;
  }
}

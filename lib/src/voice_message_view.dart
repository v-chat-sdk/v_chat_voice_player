// Copyright 2023, the hatemragab project author.
// All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:v_chat_voice_player/src/voice_message_controller.dart';
import 'package:v_chat_voice_player/src/voice_state_model.dart';

/// A widget that displays a voice message player with play/pause controls,
/// a seek bar, and speed control.
///
/// The seek bar visualizes the playback progress and allows users to seek
/// within the audio. It also includes an optional noise visualization.
///
/// This widget follows ValueNotifier best practices by using ValueListenableBuilder
/// for efficient UI updates only when the state actually changes.
class VVoiceMessageView extends StatelessWidget {
  /// The controller managing the voice message playback.
  final VVoiceMessageController controller;

  /// The color of the active part of the seek bar.
  final Color activeSliderColor;

  /// The color of the inactive part of the seek bar.
  final Color? notActiveSliderColor;

  /// The background color of the player container.
  final Color? backgroundColor;

  /// The text style for the remaining time counter.
  final TextStyle counterTextStyle;

  /// Custom widget for the play icon.
  final Widget? playIcon;

  /// Custom widget for the pause icon.
  final Widget? pauseIcon;

  /// Custom widget for the error icon.
  final Widget? errorIcon;

  /// Builder function for customizing the speed display widget.
  final Widget Function(String speed)? speedBuilder;

  /// The corner radius for the container
  final double borderRadius;

  /// The padding inside the container
  final EdgeInsets containerPadding;

  /// Whether to show the speed control button
  final bool showSpeedControl;

  /// Creates a [VVoiceMessageView].
  ///
  /// [controller] is required and manages the playback state.
  /// Other parameters are optional and allow customization of the UI.
  const VVoiceMessageView({
    super.key,
    required this.controller,
    this.activeSliderColor = Colors.red,
    this.notActiveSliderColor,
    this.backgroundColor,
    this.playIcon,
    this.pauseIcon,
    this.errorIcon,
    this.speedBuilder,
    this.counterTextStyle = const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      height: 1.2,
    ),
    this.borderRadius = 13.0,
    this.containerPadding = const EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 10.0,
    ),
    this.showSpeedControl = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
      ),
      padding: containerPadding,
      child: ValueListenableBuilder<VoiceStateModel>(
        valueListenable: controller,
        builder: (context, state, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Play/Pause/Error Button
              _PlayPauseButton(
                state: state,
                controller: controller,
                playIcon: playIcon,
                pauseIcon: pauseIcon,
                errorIcon: errorIcon,
              ),
              const SizedBox(width: 12),

              // Seek Bar and Time Display
              Expanded(
                child: _SeekBarSection(
                  controller: controller,
                  state: state,
                  activeSliderColor: activeSliderColor,
                  notActiveSliderColor: notActiveSliderColor,
                  counterTextStyle: counterTextStyle,
                ),
              ),

              // Speed Control Button
              if (showSpeedControl) ...[
                const SizedBox(width: 12),
                _SpeedControlButton(
                  controller: controller,
                  state: state,
                  speedBuilder: speedBuilder,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Widget for the Play/Pause/Error button
/// This widget efficiently rebuilds only when the playback state changes
class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.state,
    required this.controller,
    this.playIcon,
    this.pauseIcon,
    this.errorIcon,
  });

  final VoiceStateModel state;
  final VVoiceMessageController controller;
  final Widget? playIcon;
  final Widget? pauseIcon;
  final Widget? errorIcon;

  @override
  Widget build(BuildContext context) {
    // Show loading indicator when downloading
    if (state.isDownloading) {
      return const SizedBox(
        height: 40,
        width: 40,
        child: CupertinoActivityIndicator(),
      );
    }

    // Determine icon and action based on current state
    Widget iconWidget;
    VoidCallback? onTap;

    if (state.isPlaying) {
      iconWidget = pauseIcon ?? _DefaultIcons.pause;
      onTap = controller.pausePlaying;
    } else if (state.isDownloadError) {
      iconWidget = errorIcon ?? _DefaultIcons.error;
      onTap = controller.initAndPlay;
    } else {
      iconWidget = playIcon ?? _DefaultIcons.play;
      onTap = controller.initAndPlay;
    }

    return GestureDetector(
      onTap: onTap,
      child: iconWidget,
    );
  }
}

/// Widget for the seek bar and time display section
/// This widget optimizes performance by only rebuilding when necessary
class _SeekBarSection extends StatelessWidget {
  const _SeekBarSection({
    required this.controller,
    required this.state,
    required this.activeSliderColor,
    required this.notActiveSliderColor,
    required this.counterTextStyle,
  });

  final VVoiceMessageController controller;
  final VoiceStateModel state;
  final Color activeSliderColor;
  final Color? notActiveSliderColor;
  final TextStyle counterTextStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Seek Bar
        _CustomSlider(
          controller: controller,
          state: state,
          activeColor: activeSliderColor,
          inactiveColor:
              notActiveSliderColor ?? activeSliderColor.withValues(alpha: 0.3),
        ),

        const SizedBox(height: 2),

        // Time Display - Using state value for consistency
        Text(
          state.remainingTimeText,
          style: counterTextStyle,
        ),
      ],
    );
  }
}

/// Custom slider widget for seeking
/// This widget uses the state model directly for better performance
class _CustomSlider extends StatelessWidget {
  const _CustomSlider({
    required this.controller,
    required this.state,
    required this.activeColor,
    required this.inactiveColor,
  });

  final VVoiceMessageController controller;
  final VoiceStateModel state;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final customSliderTheme = SliderTheme.of(context).copyWith(
      activeTrackColor: activeColor,
      inactiveTrackColor: inactiveColor,
      thumbColor: activeColor,
      overlayColor: activeColor.withValues(alpha: 0.15),
      trackHeight: 3.0,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
      trackShape: const RoundedRectSliderTrackShape(),
    );

    return SliderTheme(
      data: customSliderTheme,
      child: Slider(
        value: state.currentMillSeconds.clamp(0.0, state.maxMillSeconds),
        min: 0.0,
        max: state.maxMillSeconds,
        onChangeStart: controller.onChangeSliderStart,
        onChanged: controller.onChanging,
        onChangeEnd: (value) {
          controller.onSeek(Duration(milliseconds: value.toInt()));
        },
      ),
    );
  }
}

/// Widget for the speed control button
/// This widget uses the state model for better performance and consistency
class _SpeedControlButton extends StatelessWidget {
  const _SpeedControlButton({
    required this.controller,
    required this.state,
    this.speedBuilder,
  });

  final VVoiceMessageController controller;
  final VoiceStateModel state;
  final Widget Function(String speed)? speedBuilder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: state.canPlay ? controller.changeSpeed : null,
      child: AnimatedOpacity(
        opacity: state.canPlay ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: speedBuilder?.call(state.speedDisplayText) ??
            _DefaultSpeedButton(speed: state.speedDisplayText),
      ),
    );
  }
}

/// Default speed button widget with improved styling
class _DefaultSpeedButton extends StatelessWidget {
  const _DefaultSpeedButton({required this.speed});

  final String speed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        speed,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Default icon widgets with consistent styling
class _DefaultIcons {
  /// Play icon for starting playback
  static Widget get play => _buildIcon(Icons.play_arrow_rounded);

  /// Pause icon for pausing playback
  static Widget get pause => _buildIcon(Icons.pause_rounded);

  /// Error icon for retry action
  static Widget get error => _buildIcon(Icons.refresh_rounded);

  /// Builds a consistent icon widget with circular background
  static Widget _buildIcon(IconData iconData) {
    return Container(
      height: 40,
      width: 40,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}

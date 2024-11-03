// Copyright 2023, the hatemragab project author.
// All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:v_chat_voice_player/src/voice_message_controller.dart';

/// A widget that displays a voice message player with play/pause controls,
/// a seek bar, and speed control.
///
/// The seek bar visualizes the playback progress and allows users to seek
/// within the audio. It also includes an optional noise visualization.
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
    this.counterTextStyle =
        const TextStyle(fontSize: 10, fontWeight: FontWeight.w400, height: .5),
  });

  @override
  Widget build(BuildContext context) {
    // Customize the Slider theme to match the desired appearance.
    final SliderThemeData customSliderTheme = SliderTheme.of(context).copyWith(
      activeTrackColor: activeSliderColor,
      inactiveTrackColor:
          notActiveSliderColor ?? activeSliderColor.withOpacity(0.4),
      thumbColor: activeSliderColor,
      overlayColor: activeSliderColor.withOpacity(0.2),
      trackHeight: 2.0,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
      trackShape: const RoundedRectSliderTrackShape(),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: backgroundColor ?? Colors.grey.shade200,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Play/Pause/Error Button
              _buildPlayPauseErrorButton(),
              const SizedBox(width: 8),
              // Seek Bar and Remaining Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seek Bar with Optional Noise Visualization
                    _buildSeekBar(customSliderTheme),

                    // Remaining Time
                    Text(
                      controller.remindingTime,
                      style: counterTextStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Speed Control Button
              _buildSpeedControl(),
            ],
          );
        },
      ),
    );
  }

  /// Builds the Play/Pause/Error button based on the current playback state.
  Widget _buildPlayPauseErrorButton() {
    if (controller.isDownloading) {
      return const SizedBox(
        height: 38,
        width: 38,
        child: CupertinoActivityIndicator(),
      );
    } else if (controller.isPlaying) {
      return InkWell(
        onTap: controller.pausePlaying,
        child: pauseIcon ?? _defaultPauseIcon,
      );
    } else if (controller.isDownloadError) {
      return InkWell(
        onTap: controller.initAndPlay,
        child: errorIcon ?? _defaultErrorIcon,
      );
    } else {
      return InkWell(
        onTap: controller.initAndPlay,
        child: playIcon ?? _defaultPlayIcon,
      );
    }
  }

  /// Builds the seek bar with optional noise visualization.
  ///
  /// [sliderTheme] customizes the appearance of the Slider.
  Widget _buildSeekBar(SliderThemeData sliderTheme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // // Optional Noise Visualization
        // if (controller.randoms.isNotEmpty)
        //   Noises(
        //     rList: controller.randoms,
        //     activeSliderColor: activeSliderColor,
        //   ),
        // Slider Positioned on Top
        SliderTheme(
          data: sliderTheme,
          child: Slider(
            value: controller.currentMillSeconds,
            min: 0.0,
            max: controller.maxMillSeconds,
            onChangeStart: controller.onChangeSliderStart,
            onChanged: controller.onChanging,
            onChangeEnd: (value) {
              controller.onSeek(
                Duration(milliseconds: value.toInt()),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the speed control button.
  Widget _buildSpeedControl() {
    return InkWell(
      onTap: controller.changeSpeed,
      child: speedBuilder != null
          ? speedBuilder!(controller.playSpeedStr)
          : _defaultSpeedButton(),
    );
  }

  /// Default Pause Icon Widget.
  Widget get _defaultPauseIcon => Container(
        height: 38,
        width: 38,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.pause_rounded,
          color: Colors.white,
        ),
      );

  /// Default Play Icon Widget.
  Widget get _defaultPlayIcon => Container(
        height: 38,
        width: 38,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Colors.white,
        ),
      );

  /// Default Error Icon Widget.
  Widget get _defaultErrorIcon => Container(
        height: 38,
        width: 38,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      );

  /// Default Speed Control Button Widget.
  Widget _defaultSpeedButton() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          controller.playSpeedStr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}

/// A custom track shape for the Slider to remove padding and align it properly.
class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 2.0;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

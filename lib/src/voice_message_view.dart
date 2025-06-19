// Copyright 2023, the hatemragab project author.
// All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:v_chat_voice_player/src/voice_message_controller.dart';
import 'package:v_chat_voice_player/src/voice_state_model.dart';
import 'package:v_chat_voice_player/src/voice_message_config.dart';
import 'widgets/voice_visualizer.dart';
import 'helpers/voice_ui_randomizer.dart';

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

  /// Configuration for colors used throughout the voice player
  final VoiceColorConfig? colorConfig;

  /// Configuration for container styling
  final VoiceContainerConfig? containerConfig;

  /// Configuration for text styling in the voice player
  final VoiceTextConfig? textConfig;

  /// Configuration for button appearance and behavior
  final VoiceButtonConfig? buttonConfig;

  /// Configuration for speed control button appearance
  final VoiceSpeedConfig? speedConfig;

  /// Configuration for user avatar with mic icon
  final VoiceAvatarConfig? avatarConfig;

  /// Configuration for the voice visualizer appearance and behavior
  final VoiceVisualizerConfig? visualizerConfig;

  /// Creates a [VVoiceMessageView].
  ///
  /// [controller] is required and manages the playback state.
  /// Configuration objects are optional and allow customization of the UI.
  const VVoiceMessageView({
    super.key,
    required this.controller,
    this.colorConfig,
    this.containerConfig,
    this.textConfig,
    this.buttonConfig,
    this.speedConfig,
    this.avatarConfig,
    this.visualizerConfig,
  });

  @override
  Widget build(BuildContext context) {
    // Create effective configurations with defaults
    final effectiveColorConfig = colorConfig ?? const VoiceColorConfig();
    final effectiveContainerConfig =
        containerConfig ?? const VoiceContainerConfig();
    final effectiveTextConfig = textConfig ?? const VoiceTextConfig();
    final effectiveButtonConfig = buttonConfig ?? const VoiceButtonConfig();
    final effectiveSpeedConfig = speedConfig ?? const VoiceSpeedConfig();
    final effectiveAvatarConfig = avatarConfig ?? const VoiceAvatarConfig();
    final effectiveVisualizerConfig =
        visualizerConfig ?? const VoiceVisualizerConfig();

    // Use provided colors or smart defaults
    final effectiveActiveColor = effectiveColorConfig.activeSliderColor;
    final effectiveInactiveColor = effectiveColorConfig.notActiveSliderColor ??
        effectiveColorConfig.activeSliderColor.withValues(alpha: 0.3);
    final effectiveBackgroundColor =
        effectiveContainerConfig.backgroundColor ?? Theme.of(context).cardColor;
    final effectiveBorderRadius = effectiveContainerConfig.borderRadius;
    final effectivePadding = effectiveContainerConfig.containerPadding;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        color: effectiveBackgroundColor,
      ),
      padding: effectivePadding,
      child: ValueListenableBuilder<VoiceStateModel>(
        valueListenable: controller,
        builder: (context, state, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // User Avatar with Mic Icon (optional)
              if (effectiveAvatarConfig.userAvatar != null) ...[
                _UserAvatarWithMic(
                  avatar: effectiveAvatarConfig.userAvatar!,
                  micIcon: effectiveAvatarConfig.micIcon,
                  isListened: state.isListened,
                  avatarSize: effectiveAvatarConfig.avatarSize,
                  micIconSize: effectiveAvatarConfig.micIconSize,
                  activeColor: effectiveActiveColor,
                  inactiveColor: effectiveInactiveColor,
                ),
                const SizedBox(width: 12),
              ],

              // Play/Pause/Error Button
              _PlayPauseButton(
                state: state,
                controller: controller,
                playIcon: effectiveButtonConfig.playIcon,
                pauseIcon: effectiveButtonConfig.pauseIcon,
                errorIcon: effectiveButtonConfig.errorIcon,
                buttonColor: effectiveButtonConfig.buttonColor,
                buttonIconColor: effectiveButtonConfig.buttonIconColor,
                buttonSize: effectiveButtonConfig.buttonSize,
                activeColor: effectiveActiveColor,
                useSimpleIcon: effectiveButtonConfig.useSimplePlayIcon,
                inactiveColor: effectiveInactiveColor,
                simpleIconSize: effectiveButtonConfig.simpleIconSize,
              ),
              const SizedBox(width: 12),

              // Seek Bar and Time Display
              Expanded(
                child: _SeekBarSection(
                  controller: controller,
                  state: state,
                  activeSliderColor: effectiveActiveColor,
                  notActiveSliderColor: effectiveInactiveColor,
                  counterTextStyle: effectiveTextConfig.counterTextStyle,
                  timerTextTheme: effectiveTextConfig.timerTextTheme,
                  showVisualizer: effectiveVisualizerConfig.showVisualizer,
                  visualizerHeight: effectiveVisualizerConfig.height,
                  visualizerBarCount: effectiveVisualizerConfig.barCount,
                  visualizerBarSpacing: effectiveVisualizerConfig.barSpacing,
                  visualizerMinBarHeight:
                      effectiveVisualizerConfig.minBarHeight,
                  useRandomHeights: effectiveVisualizerConfig.useRandomHeights,
                  customBarHeights: effectiveVisualizerConfig.customBarHeights,
                  enableBarAnimations:
                      effectiveVisualizerConfig.enableBarAnimations,
                ),
              ),

              // Speed Control Button
              if (effectiveSpeedConfig.showSpeedControl) ...[
                const SizedBox(width: 12),
                _SpeedControlButton(
                  controller: controller,
                  state: state,
                  speedBuilder: effectiveSpeedConfig.speedBuilder,
                  speedButtonColor: effectiveSpeedConfig.speedButtonColor,
                  speedButtonTextColor:
                      effectiveSpeedConfig.speedButtonTextColor,
                  speedButtonBorderRadius:
                      effectiveSpeedConfig.speedButtonBorderRadius,
                  speedButtonPadding: effectiveSpeedConfig.speedButtonPadding,
                  activeColor: effectiveActiveColor,
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
    this.buttonColor,
    this.buttonIconColor,
    this.buttonSize = 40.0,
    this.activeColor = Colors.red,
    this.useSimpleIcon = false,
    this.inactiveColor,
    this.simpleIconSize = 24.0,
  });

  final VoiceStateModel state;
  final VVoiceMessageController controller;
  final Widget? playIcon;
  final Widget? pauseIcon;
  final Widget? errorIcon;
  final Color? buttonColor;
  final Color? buttonIconColor;
  final double buttonSize;
  final Color activeColor;
  final bool useSimpleIcon;
  final Color? inactiveColor;
  final double simpleIconSize;

  @override
  Widget build(BuildContext context) {
    // Show loading indicator when downloading
    if (state.isDownloading) {
      return SizedBox(
        height: buttonSize,
        width: buttonSize,
        child: const CupertinoActivityIndicator(),
      );
    }

    // Determine icon and action based on current state
    Widget iconWidget;
    VoidCallback? onTap;

    final effectiveButtonColor = buttonColor ??
        (useSimpleIcon
            ? (inactiveColor ?? activeColor.withValues(alpha: 0.3))
            : activeColor);
    final effectiveIconColor = buttonIconColor ??
        (useSimpleIcon ? effectiveButtonColor : Colors.white);

    if (state.isPlaying) {
      iconWidget = pauseIcon ??
          (useSimpleIcon
              ? _DefaultIcons.pauseSimple(effectiveIconColor, simpleIconSize)
              : _DefaultIcons.pause(
                  effectiveButtonColor, effectiveIconColor, buttonSize));
      onTap = controller.pausePlaying;
    } else if (state.isDownloadError) {
      iconWidget = errorIcon ??
          (useSimpleIcon
              ? _DefaultIcons.errorSimple(effectiveIconColor, simpleIconSize)
              : _DefaultIcons.error(
                  effectiveButtonColor, effectiveIconColor, buttonSize));
      onTap = controller.initAndPlay;
    } else {
      iconWidget = playIcon ??
          (useSimpleIcon
              ? _DefaultIcons.playSimple(effectiveIconColor, simpleIconSize)
              : _DefaultIcons.play(
                  effectiveButtonColor, effectiveIconColor, buttonSize));
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
    this.timerTextTheme,
    required this.showVisualizer,
    required this.visualizerHeight,
    required this.visualizerBarCount,
    required this.visualizerBarSpacing,
    required this.visualizerMinBarHeight,
    required this.useRandomHeights,
    this.customBarHeights,
    required this.enableBarAnimations,
  });

  final VVoiceMessageController controller;
  final VoiceStateModel state;
  final Color activeSliderColor;
  final Color? notActiveSliderColor;
  final TextStyle counterTextStyle;
  final TextTheme? timerTextTheme;
  final bool showVisualizer;
  final double visualizerHeight;
  final int visualizerBarCount;
  final double visualizerBarSpacing;
  final double visualizerMinBarHeight;
  final bool useRandomHeights;
  final List<double>? customBarHeights;
  final bool enableBarAnimations;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Seek Bar or Voice Visualizer
        if (showVisualizer)
          VoiceVisualizer(
            controller: controller,
            state: state,
            activeColor: activeSliderColor,
            inactiveColor: notActiveSliderColor ??
                activeSliderColor.withValues(alpha: 0.3),
            height: visualizerHeight,
            barCount: visualizerBarCount,
            barSpacing: visualizerBarSpacing,
            minBarHeight: visualizerMinBarHeight,
            enableAnimation: enableBarAnimations,
            customBarHeights: customBarHeights ??
                (useRandomHeights
                    ? VoiceUIRandomizer(
                        messageId: controller.id,
                        barCount: visualizerBarCount,
                      ).customBarHeights
                    : null),
          )
        else
          _CustomSlider(
            controller: controller,
            state: state,
            activeColor: activeSliderColor,
            inactiveColor: notActiveSliderColor ??
                activeSliderColor.withValues(alpha: 0.3),
          ),

        const SizedBox(height: 2),

        // Time Display - Using state value for consistency
        Text(
          state.remainingTimeText,
          style: timerTextTheme?.bodySmall ?? counterTextStyle,
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
    this.speedButtonColor,
    this.speedButtonTextColor,
    this.speedButtonBorderRadius = 6.0,
    this.speedButtonPadding =
        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    this.activeColor = Colors.red,
  });

  final VVoiceMessageController controller;
  final VoiceStateModel state;
  final Widget Function(String speed)? speedBuilder;
  final Color? speedButtonColor;
  final Color? speedButtonTextColor;
  final double speedButtonBorderRadius;
  final EdgeInsets speedButtonPadding;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: state.canPlay ? controller.changeSpeed : null,
      child: AnimatedOpacity(
        opacity: state.canPlay ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: speedBuilder?.call(state.speedDisplayText) ??
            _DefaultSpeedButton(
              speed: state.speedDisplayText,
              backgroundColor: speedButtonColor ?? activeColor,
              textColor: speedButtonTextColor ?? Colors.white,
              borderRadius: speedButtonBorderRadius,
              padding: speedButtonPadding,
            ),
      ),
    );
  }
}

/// Default speed button widget with improved styling
class _DefaultSpeedButton extends StatelessWidget {
  const _DefaultSpeedButton({
    required this.speed,
    this.backgroundColor = Colors.red,
    this.textColor = Colors.white,
    this.borderRadius = 6.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
  });

  final String speed;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        speed,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Widget for displaying user avatar with mic icon
/// Shows a circular avatar with a mic icon that changes color based on listened status
class _UserAvatarWithMic extends StatelessWidget {
  const _UserAvatarWithMic({
    required this.avatar,
    required this.isListened,
    required this.activeColor,
    required this.inactiveColor,
    this.micIcon,
    this.avatarSize = 45.0,
    this.micIconSize = 16.0,
  });

  final Widget avatar;
  final Widget? micIcon;
  final bool isListened;
  final double avatarSize;
  final double micIconSize;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: avatarSize,
      height: avatarSize,
      child: Stack(
        children: [
          // User Avatar
          ClipOval(
            child: SizedBox(
              width: avatarSize,
              height: avatarSize,
              child: avatar,
            ),
          ),
          // Mic Icon at bottom right
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: micIconSize + 4,
              height: micIconSize + 4,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 1,
                ),
              ),
              child: Center(
                child: micIcon ??
                    Icon(
                      Icons.mic,
                      size: micIconSize,
                      color: isListened ? activeColor : inactiveColor,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Default icon widgets with consistent styling
class _DefaultIcons {
  /// Play icon for starting playback
  static Widget play(Color backgroundColor, Color iconColor, double size) =>
      _buildIcon(Icons.play_arrow_rounded, backgroundColor, iconColor, size);

  /// Pause icon for pausing playback
  static Widget pause(Color backgroundColor, Color iconColor, double size) =>
      _buildIcon(Icons.pause_rounded, backgroundColor, iconColor, size);

  /// Error icon for retry action
  static Widget error(Color backgroundColor, Color iconColor, double size) =>
      _buildIcon(Icons.refresh_rounded, backgroundColor, iconColor, size);

  /// Simple play icon without background
  static Widget playSimple(Color iconColor, double size) =>
      _buildSimpleIcon(Icons.play_arrow_rounded, iconColor, size);

  /// Simple pause icon without background
  static Widget pauseSimple(Color iconColor, double size) =>
      _buildSimpleIcon(Icons.pause_rounded, iconColor, size);

  /// Simple error icon without background
  static Widget errorSimple(Color iconColor, double size) =>
      _buildSimpleIcon(Icons.refresh_rounded, iconColor, size);

  /// Builds a consistent icon widget with circular background
  static Widget _buildIcon(
      IconData iconData, Color backgroundColor, Color iconColor, double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: size * 0.55, // Proportional icon size
      ),
    );
  }

  /// Builds a simple icon widget without background
  static Widget _buildSimpleIcon(
      IconData iconData, Color iconColor, double size) {
    return Icon(
      iconData,
      color: iconColor,
      size: size, // Use actual size for simple icons
    );
  }
}

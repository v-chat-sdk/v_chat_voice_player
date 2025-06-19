// Copyright 2023, the hatemragab project author.
// All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// Configuration for the voice visualizer appearance and behavior
class VoiceVisualizerConfig {
  /// Whether to show voice visualizer instead of slider
  final bool showVisualizer;

  /// Height of the voice visualizer
  final double height;

  /// Number of bars in the voice visualizer
  final int barCount;

  /// Spacing between visualizer bars
  final double barSpacing;

  /// Minimum height for visualizer bars
  final double minBarHeight;

  /// Whether to use random bar heights for each voice message
  final bool useRandomHeights;

  /// Custom bar heights for the visualizer (overrides random heights)
  final List<double>? customBarHeights;

  /// Whether to enable bar animations when playing
  final bool enableBarAnimations;

  const VoiceVisualizerConfig({
    this.showVisualizer = true,
    this.height = 40.0,
    this.barCount = 50,
    this.barSpacing = 2.0,
    this.minBarHeight = 4.0,
    this.useRandomHeights = true,
    this.customBarHeights,
    this.enableBarAnimations = true,
  });

  VoiceVisualizerConfig copyWith({
    bool? showVisualizer,
    double? height,
    int? barCount,
    double? barSpacing,
    double? minBarHeight,
    bool? useRandomHeights,
    List<double>? customBarHeights,
    bool? enableBarAnimations,
  }) {
    return VoiceVisualizerConfig(
      showVisualizer: showVisualizer ?? this.showVisualizer,
      height: height ?? this.height,
      barCount: barCount ?? this.barCount,
      barSpacing: barSpacing ?? this.barSpacing,
      minBarHeight: minBarHeight ?? this.minBarHeight,
      useRandomHeights: useRandomHeights ?? this.useRandomHeights,
      customBarHeights: customBarHeights ?? this.customBarHeights,
      enableBarAnimations: enableBarAnimations ?? this.enableBarAnimations,
    );
  }
}

/// Configuration for button appearance and behavior
class VoiceButtonConfig {
  /// Custom widget for the play icon
  final Widget? playIcon;

  /// Custom widget for the pause icon
  final Widget? pauseIcon;

  /// Custom widget for the error icon
  final Widget? errorIcon;

  /// Color for play/pause/error button backgrounds
  final Color? buttonColor;

  /// Color for button icons
  final Color? buttonIconColor;

  /// Size of the play/pause/error buttons
  final double buttonSize;

  /// Whether to show the play icon without circular background
  final bool useSimplePlayIcon;

  /// Size of the simple play icon (only used when useSimplePlayIcon is true)
  final double simpleIconSize;

  const VoiceButtonConfig({
    this.playIcon,
    this.pauseIcon,
    this.errorIcon,
    this.buttonColor,
    this.buttonIconColor,
    this.buttonSize = 40.0,
    this.useSimplePlayIcon = false,
    this.simpleIconSize = 24.0,
  });

  VoiceButtonConfig copyWith({
    Widget? playIcon,
    Widget? pauseIcon,
    Widget? errorIcon,
    Color? buttonColor,
    Color? buttonIconColor,
    double? buttonSize,
    bool? useSimplePlayIcon,
    double? simpleIconSize,
  }) {
    return VoiceButtonConfig(
      playIcon: playIcon ?? this.playIcon,
      pauseIcon: pauseIcon ?? this.pauseIcon,
      errorIcon: errorIcon ?? this.errorIcon,
      buttonColor: buttonColor ?? this.buttonColor,
      buttonIconColor: buttonIconColor ?? this.buttonIconColor,
      buttonSize: buttonSize ?? this.buttonSize,
      useSimplePlayIcon: useSimplePlayIcon ?? this.useSimplePlayIcon,
      simpleIconSize: simpleIconSize ?? this.simpleIconSize,
    );
  }
}

/// Configuration for speed control button appearance
class VoiceSpeedConfig {
  /// Whether to show the speed control button
  final bool showSpeedControl;

  /// Builder function for customizing the speed display widget
  final Widget Function(String speed)? speedBuilder;

  /// Color for the speed control button
  final Color? speedButtonColor;

  /// Text color for the speed control button
  final Color? speedButtonTextColor;

  /// Border radius for the speed control button
  final double speedButtonBorderRadius;

  /// Padding for the speed control button
  final EdgeInsets speedButtonPadding;

  const VoiceSpeedConfig({
    this.showSpeedControl = true,
    this.speedBuilder,
    this.speedButtonColor,
    this.speedButtonTextColor,
    this.speedButtonBorderRadius = 6.0,
    this.speedButtonPadding =
        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
  });

  VoiceSpeedConfig copyWith({
    bool? showSpeedControl,
    Widget Function(String speed)? speedBuilder,
    Color? speedButtonColor,
    Color? speedButtonTextColor,
    double? speedButtonBorderRadius,
    EdgeInsets? speedButtonPadding,
  }) {
    return VoiceSpeedConfig(
      showSpeedControl: showSpeedControl ?? this.showSpeedControl,
      speedBuilder: speedBuilder ?? this.speedBuilder,
      speedButtonColor: speedButtonColor ?? this.speedButtonColor,
      speedButtonTextColor: speedButtonTextColor ?? this.speedButtonTextColor,
      speedButtonBorderRadius:
          speedButtonBorderRadius ?? this.speedButtonBorderRadius,
      speedButtonPadding: speedButtonPadding ?? this.speedButtonPadding,
    );
  }
}

/// Configuration for user avatar with mic icon
class VoiceAvatarConfig {
  /// User avatar image widget (optional)
  final Widget? userAvatar;

  /// Custom mic icon widget
  final Widget? micIcon;

  /// Size of the user avatar
  final double avatarSize;

  /// Size of the mic icon
  final double micIconSize;

  const VoiceAvatarConfig({
    this.userAvatar,
    this.micIcon,
    this.avatarSize = 45.0,
    this.micIconSize = 16.0,
  });

  VoiceAvatarConfig copyWith({
    Widget? userAvatar,
    Widget? micIcon,
    double? avatarSize,
    double? micIconSize,
  }) {
    return VoiceAvatarConfig(
      userAvatar: userAvatar ?? this.userAvatar,
      micIcon: micIcon ?? this.micIcon,
      avatarSize: avatarSize ?? this.avatarSize,
      micIconSize: micIconSize ?? this.micIconSize,
    );
  }
}

/// Configuration for container styling
class VoiceContainerConfig {
  /// The background color of the player container
  final Color? backgroundColor;

  /// The corner radius for the container
  final double borderRadius;

  /// The padding inside the container
  final EdgeInsets containerPadding;

  const VoiceContainerConfig({
    this.backgroundColor,
    this.borderRadius = 13.0,
    this.containerPadding = const EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 10.0,
    ),
  });

  VoiceContainerConfig copyWith({
    Color? backgroundColor,
    double? borderRadius,
    EdgeInsets? containerPadding,
  }) {
    return VoiceContainerConfig(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      containerPadding: containerPadding ?? this.containerPadding,
    );
  }
}

/// Configuration for colors used throughout the voice player
class VoiceColorConfig {
  /// The color of the active part of the seek bar
  final Color activeSliderColor;

  /// The color of the inactive part of the seek bar
  final Color? notActiveSliderColor;

  const VoiceColorConfig({
    this.activeSliderColor = Colors.red,
    this.notActiveSliderColor,
  });

  VoiceColorConfig copyWith({
    Color? activeSliderColor,
    Color? notActiveSliderColor,
  }) {
    return VoiceColorConfig(
      activeSliderColor: activeSliderColor ?? this.activeSliderColor,
      notActiveSliderColor: notActiveSliderColor ?? this.notActiveSliderColor,
    );
  }
}

/// Configuration for text styling in the voice player
class VoiceTextConfig {
  /// The text style for the remaining time counter
  final TextStyle counterTextStyle;

  /// The text theme for the timer display
  final TextTheme? timerTextTheme;

  const VoiceTextConfig({
    this.counterTextStyle = const TextStyle(
      fontSize: 8,
      fontWeight: FontWeight.w400,
      height: .3,
    ),
    this.timerTextTheme,
  });

  VoiceTextConfig copyWith({
    TextStyle? counterTextStyle,
    TextTheme? timerTextTheme,
  }) {
    return VoiceTextConfig(
      counterTextStyle: counterTextStyle ?? this.counterTextStyle,
      timerTextTheme: timerTextTheme ?? this.timerTextTheme,
    );
  }
}

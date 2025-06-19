// Copyright 2023, the hatemragab project author.
// All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

/// Enum representing the current playback status of the voice message
enum PlayStatus {
  /// Initial state before any playback
  init,

  /// Currently playing audio
  playing,

  /// Playback is paused
  pause,

  /// Playback is stopped
  stop,

  /// Audio is being downloaded
  downloading,

  /// Error occurred during download
  downloadError
}

/// Enum representing different playback speeds
enum PlaySpeed {
  /// Normal playback speed (1.0x)
  x1,

  /// 1.25x playback speed
  x1_25,

  /// 1.5x playback speed
  x1_5,

  /// 1.75x playback speed
  x1_75,

  /// 2.0x playback speed
  x2
}

/// Extension to get the numeric speed value from PlaySpeed enum
extension GetSpeed on PlaySpeed {
  /// Returns the numeric speed multiplier
  double get getSpeed {
    switch (this) {
      case PlaySpeed.x1:
        return 1.0;
      case PlaySpeed.x1_25:
        return 1.25;
      case PlaySpeed.x1_5:
        return 1.50;
      case PlaySpeed.x1_75:
        return 1.75;
      case PlaySpeed.x2:
        return 2.00;
    }
  }

  /// Returns the display string for the speed
  String get displayString {
    switch (this) {
      case PlaySpeed.x1:
        return '1.00x';
      case PlaySpeed.x1_25:
        return '1.25x';
      case PlaySpeed.x1_5:
        return '1.50x';
      case PlaySpeed.x1_75:
        return '1.75x';
      case PlaySpeed.x2:
        return '2.00x';
    }
  }

  /// Returns the next speed in the sequence
  PlaySpeed get next {
    switch (this) {
      case PlaySpeed.x1:
        return PlaySpeed.x1_25;
      case PlaySpeed.x1_25:
        return PlaySpeed.x1_5;
      case PlaySpeed.x1_5:
        return PlaySpeed.x1_75;
      case PlaySpeed.x1_75:
        return PlaySpeed.x2;
      case PlaySpeed.x2:
        return PlaySpeed.x1;
    }
  }
}

/// Extension to add utility methods to PlayStatus
extension PlayStatusExtension on PlayStatus {
  /// Whether the player is in an active state (playing or paused)
  bool get isActive => this == PlayStatus.playing || this == PlayStatus.pause;

  /// Whether the player is in an error state
  bool get isError => this == PlayStatus.downloadError;

  /// Whether the player is busy (downloading)
  bool get isBusy => this == PlayStatus.downloading;

  /// Whether the player can be played (not downloading or in error)
  bool get canPlay => !isBusy && !isError;
}

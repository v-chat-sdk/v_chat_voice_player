// Copyright 2023, the hatemragab project author.
// All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

import 'helpers/play_status.dart';

/// Model representing the current state of voice message playback
/// This model holds all the data needed for the voice player UI
class VoiceStateModel {
  /// Current playback status
  final PlayStatus playStatus;

  /// Current playback speed
  final PlaySpeed speed;

  /// Whether the user is currently seeking
  final bool isSeeking;

  /// Current playback position
  final Duration currentDuration;

  /// Total duration of the audio
  final Duration maxDuration;

  /// Current position in milliseconds for UI display
  final double currentMillSeconds;

  /// Maximum duration in milliseconds for UI display
  final double maxMillSeconds;

  /// Formatted remaining time string
  final String remainingTimeText;

  /// Current speed display string
  final String speedDisplayText;

  /// Whether the animation is currently running
  final bool isAnimating;

  /// Whether the voice message has been listened to (played at least once)
  final bool isListened;

  /// Creates a new [VoiceStateModel]
  const VoiceStateModel({
    required this.playStatus,
    required this.speed,
    required this.isSeeking,
    required this.currentDuration,
    required this.maxDuration,
    required this.currentMillSeconds,
    required this.maxMillSeconds,
    required this.remainingTimeText,
    required this.speedDisplayText,
    required this.isAnimating,
    required this.isListened,
  });

  /// Creates an initial state for the voice player
  factory VoiceStateModel.initial({
    Duration? maxDuration,
    String? id,
    bool isListened = false,
  }) {
    final initialMaxDuration = maxDuration ?? const Duration(days: 1);
    return VoiceStateModel(
      playStatus: PlayStatus.init,
      speed: PlaySpeed.x1,
      isSeeking: false,
      currentDuration: Duration.zero,
      maxDuration: initialMaxDuration,
      currentMillSeconds: 0.0,
      maxMillSeconds: initialMaxDuration.inMilliseconds.toDouble(),
      remainingTimeText: _formatDuration(initialMaxDuration),
      speedDisplayText: PlaySpeed.x1.displayString,
      isAnimating: false,
      isListened: isListened,
    );
  }

  /// Whether the audio is currently playing
  bool get isPlaying => playStatus == PlayStatus.playing;

  /// Whether the audio player is in initial state
  bool get isInit => playStatus == PlayStatus.init;

  /// Whether the audio is currently downloading
  bool get isDownloading => playStatus == PlayStatus.downloading;

  /// Whether there was an error downloading the audio
  bool get isDownloadError => playStatus == PlayStatus.downloadError;

  /// Whether the audio playback is stopped
  bool get isStop => playStatus == PlayStatus.stop;

  /// Whether the audio playback is paused
  bool get isPause => playStatus == PlayStatus.pause;

  /// Returns progress as a value between 0.0 and 1.0
  double get progress {
    if (maxMillSeconds == 0) return 0.0;
    return (currentMillSeconds / maxMillSeconds).clamp(0.0, 1.0);
  }

  /// Returns remaining duration
  Duration get remainingDuration {
    return maxDuration - currentDuration;
  }

  /// Whether the player can be played (not downloading or in error)
  bool get canPlay =>
      playStatus != PlayStatus.downloading &&
      playStatus != PlayStatus.downloadError;

  /// Whether the player is in an active playback state
  bool get isActive => isPlaying || isPause;

  /// Whether the player is in a loading state
  bool get isLoading => isDownloading;

  /// Whether the player has an error
  bool get hasError => isDownloadError;

  /// Creates a copy of this model with updated values
  VoiceStateModel copyWith({
    PlayStatus? playStatus,
    PlaySpeed? speed,
    bool? isSeeking,
    Duration? currentDuration,
    Duration? maxDuration,
    double? currentMillSeconds,
    double? maxMillSeconds,
    String? remainingTimeText,
    String? speedDisplayText,
    bool? isAnimating,
    double? animationValue,
    bool? isListened,
  }) {
    return VoiceStateModel(
      playStatus: playStatus ?? this.playStatus,
      speed: speed ?? this.speed,
      isSeeking: isSeeking ?? this.isSeeking,
      currentDuration: currentDuration ?? this.currentDuration,
      maxDuration: maxDuration ?? this.maxDuration,
      currentMillSeconds: currentMillSeconds ?? this.currentMillSeconds,
      maxMillSeconds: maxMillSeconds ?? this.maxMillSeconds,
      remainingTimeText: remainingTimeText ?? this.remainingTimeText,
      speedDisplayText: speedDisplayText ?? this.speedDisplayText,
      isAnimating: isAnimating ?? this.isAnimating,
      isListened: isListened ?? this.isListened,
    );
  }

  @override
  String toString() {
    return 'VoiceStateModel{playStatus: $playStatus, speed: $speed, '
        'isSeeking: $isSeeking, currentDuration: $currentDuration, '
        'maxDuration: $maxDuration, progress: ${progress.toStringAsFixed(2)}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VoiceStateModel &&
        other.playStatus == playStatus &&
        other.speed == speed &&
        other.isSeeking == isSeeking &&
        other.currentDuration == currentDuration &&
        other.maxDuration == maxDuration &&
        other.currentMillSeconds == currentMillSeconds &&
        other.maxMillSeconds == maxMillSeconds &&
        other.remainingTimeText == remainingTimeText &&
        other.speedDisplayText == speedDisplayText &&
        other.isAnimating == isAnimating &&
        other.isListened == isListened;
  }

  @override
  int get hashCode {
    return Object.hash(
      playStatus,
      speed,
      isSeeking,
      currentDuration,
      maxDuration,
      currentMillSeconds,
      maxMillSeconds,
      remainingTimeText,
      speedDisplayText,
      isAnimating,
      isListened,
    );
  }
}

/// Helper function to format duration
String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return '$twoDigitMinutes:$twoDigitSeconds';
}

// Copyright 2023, the hatemragab project author.
// All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

import '../helpers/play_status.dart';
import '../helpers/utils.dart';
import '../voice_state_model.dart';

/// Helper class for managing voice state transitions and calculations
/// This follows the separation of concerns principle by extracting
/// state management logic from the controller
class VoiceStateManager {
  /// Calculates the current position in milliseconds with proper bounds
  static double calculateCurrentMillSeconds(Duration current, Duration max) {
    final currentMs = current.inMilliseconds.toDouble();
    final maxMs = max.inMilliseconds.toDouble();
    return currentMs.clamp(0.0, maxMs);
  }

  /// Calculates the animation value based on current position
  static double calculateAnimationValue(
    Duration current,
    Duration max,
    double noiseWidth,
  ) {
    final currentMs = current.inMilliseconds.toDouble();
    final maxMs = max.inMilliseconds.toDouble();
    if (maxMs <= 0) return 0.0;
    return ((noiseWidth * currentMs) / maxMs).clamp(0.0, noiseWidth);
  }

  /// Formats the remaining time based on current state
  static String formatRemainingTime(
    Duration current,
    Duration max,
    PlayStatus status,
    bool isSeeking,
  ) {
    if (current == Duration.zero) {
      return max.getStringTime;
    }
    if (isSeeking) {
      return current.getStringTime;
    }
    if (status == PlayStatus.pause || status == PlayStatus.init) {
      return max.getStringTime;
    }
    return current.getStringTime;
  }

  /// Creates a new state with updated values
  static VoiceStateModel createUpdatedState({
    required PlayStatus playStatus,
    required PlaySpeed speed,
    required bool isSeeking,
    required Duration currentDuration,
    required Duration maxDuration,
  }) {
    final currentMs = calculateCurrentMillSeconds(currentDuration, maxDuration);
    final maxMs = maxDuration.inMilliseconds.toDouble();

    return VoiceStateModel(
      playStatus: playStatus,
      speed: speed,
      isSeeking: isSeeking,
      currentDuration: currentDuration,
      maxDuration: maxDuration,
      currentMillSeconds: currentMs,
      maxMillSeconds: maxMs,
      remainingTimeText: formatRemainingTime(
        currentDuration,
        maxDuration,
        playStatus,
        isSeeking,
      ),
      speedDisplayText: speed.displayString,
      isAnimating: playStatus == PlayStatus.playing,
    );
  }

  /// Validates if a state transition is allowed
  static bool canTransitionTo(PlayStatus from, PlayStatus to) {
    // Define allowed transitions
    switch (from) {
      case PlayStatus.init:
        return to == PlayStatus.downloading || to == PlayStatus.downloadError;
      case PlayStatus.downloading:
        return to == PlayStatus.playing ||
            to == PlayStatus.downloadError ||
            to == PlayStatus.init;
      case PlayStatus.playing:
        return to == PlayStatus.pause ||
            to == PlayStatus.stop ||
            to == PlayStatus.init;
      case PlayStatus.pause:
        return to == PlayStatus.playing ||
            to == PlayStatus.stop ||
            to == PlayStatus.init;
      case PlayStatus.stop:
        return to == PlayStatus.init || to == PlayStatus.playing;
      case PlayStatus.downloadError:
        return to == PlayStatus.downloading || to == PlayStatus.init;
    }
  }

  /// Checks if the player is in a stable state (not transitioning)
  static bool isStableState(PlayStatus status) {
    return status != PlayStatus.downloading;
  }

  /// Checks if the player can accept user input
  static bool canAcceptInput(PlayStatus status) {
    return status != PlayStatus.downloading &&
        status != PlayStatus.downloadError;
  }
}

// Copyright 2023, the hatemragab project author.
// All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

import 'dart:math' as math;

/// Simple configuration for randomized bar heights only
class VoiceUIRandomConfig {
  final List<double> heightList;

  const VoiceUIRandomConfig({
    this.heightList = const [35.0, 40.0, 45.0, 50.0],
  });
}

/// A simple helper class that generates random bar heights for voice messages
/// Uses the message ID as seed to ensure consistency for the same message
class VoiceUIRandomizer {
  final String messageId;
  final VoiceUIRandomConfig config;
  late final math.Random _random;
  late final List<double> _customBarHeights;

  VoiceUIRandomizer({
    required this.messageId,
    this.config = const VoiceUIRandomConfig(),
    required int barCount,
  }) {
    // Use message ID hash as seed for consistent randomization
    final seed = messageId.hashCode.abs();
    _random = math.Random(seed);

    // Generate custom bar heights for unique waveform pattern
    _customBarHeights = _generateCustomBarHeights(barCount);
  }

  List<double> _generateCustomBarHeights(int barCount) {
    // Get a random height from the config for this message
    final baseHeight =
        config.heightList[_random.nextInt(config.heightList.length)];

    return List.generate(barCount, (index) {
      // Create unique waveform patterns for each message
      final wave1 = math.sin(index * 0.1 + _random.nextDouble() * 2 * math.pi);
      final wave2 = math.sin(index * 0.15 + _random.nextDouble() * 2 * math.pi);
      final wave3 = math.sin(index * 0.05 + _random.nextDouble() * 2 * math.pi);

      final combined = (wave1 + wave2 * 0.5 + wave3 * 0.3) / 1.8;
      final normalized = (combined + 1) / 2; // Normalize to 0-1
      final randomFactor = _random.nextDouble() * 0.4 + 0.6; // 0.6-1.0

      final height = normalized * randomFactor * baseHeight;
      return math.max(height, 4.0); // Minimum height
    });
  }

  /// Get the custom bar heights for this message
  List<double> get customBarHeights => _customBarHeights;
}

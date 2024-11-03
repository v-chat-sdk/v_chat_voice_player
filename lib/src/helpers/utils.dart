// Copyright 2023, the hatemragab project author.
// All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

// Global media query data
// final MediaQueryData media =
// MediaQueryData.fromView(WidgetsBinding.instance.window);

/// This extension helps to make widgets responsive.
extension NumberParsing on num {
  double w() => this * 20;

  double h() => this * 40;
}

extension DurationFormatting on Duration {
  /// Formats the duration into a string representation.
  String get getStringTime => _formatDuration(this);
}

String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return '$twoDigitMinutes:$twoDigitSeconds';
}

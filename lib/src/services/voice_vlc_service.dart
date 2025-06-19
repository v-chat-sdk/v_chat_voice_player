// Copyright 2023, the hatemragab project author.
// All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

import 'dart:io';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:v_platform/v_platform.dart';

/// Service class for handling VLC player operations
/// This service manages VLC-specific functionality for iOS WebM/Opus files
class VoiceVlcService {
  VlcPlayerController? _vlcController;

  /// Whether VLC is required for the given audio source
  bool isVlcRequired(VPlatformFile audioSrc) {
    return VPlatforms.isIOS &&
        (audioSrc.extension == ".webm" || audioSrc.extension == ".opus");
  }

  /// Initializes and starts VLC player with the given file path
  Future<VlcPlayerController> initializeAndPlay(String filePath) async {
    await _disposeCurrentController();

    _vlcController = VlcPlayerController.file(
      File(filePath),
      hwAcc: HwAcc.full,
      options: _createVlcOptions(),
      autoInitialize: true,
    );

    // Small delay to ensure initialization
    await Future.delayed(const Duration(milliseconds: 500));

    return _vlcController!;
  }

  /// Creates VLC player options with optimized settings
  VlcPlayerOptions _createVlcOptions() {
    return VlcPlayerOptions(
      advanced: VlcAdvancedOptions([
        VlcAdvancedOptions.networkCaching(2000),
      ]),
      subtitle: VlcSubtitleOptions([
        VlcSubtitleOptions.boldStyle(true),
        VlcSubtitleOptions.fontSize(30),
        VlcSubtitleOptions.outlineColor(VlcSubtitleColor.yellow),
        VlcSubtitleOptions.outlineThickness(VlcSubtitleThickness.normal),
        VlcSubtitleOptions.color(VlcSubtitleColor.navy),
      ]),
      http: VlcHttpOptions([
        VlcHttpOptions.httpReconnect(true),
      ]),
      rtp: VlcRtpOptions([
        VlcRtpOptions.rtpOverRtsp(true),
      ]),
    );
  }

  /// Plays the current VLC controller
  Future<void> play() async {
    await _vlcController?.play();
  }

  /// Pauses the current VLC controller
  Future<void> pause() async {
    await _vlcController?.pause();
  }

  /// Stops the current VLC controller
  Future<void> stop() async {
    await _vlcController?.stop();
  }

  /// Seeks to the specified duration
  Future<void> seekTo(Duration duration) async {
    await _vlcController?.seekTo(duration);
  }

  /// Gets the current VLC controller
  VlcPlayerController? get controller => _vlcController;

  /// Checks if VLC controller is initialized
  bool get isInitialized => _vlcController != null;

  /// Disposes the current VLC controller
  Future<void> _disposeCurrentController() async {
    if (_vlcController != null) {
      try {
        await _vlcController!.dispose();
      } catch (e) {
        // Ignore disposal errors
      } finally {
        _vlcController = null;
      }
    }
  }

  /// Disposes all resources
  Future<void> dispose() async {
    await _disposeCurrentController();
  }
}

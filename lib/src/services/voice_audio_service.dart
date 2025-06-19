// Copyright 2023, the hatemragab project author.
// All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:v_chat_voice_player/src/services/voice_cache_service.dart';
import 'package:v_platform/v_platform.dart';

/// Service class for handling AudioPlayer operations
/// This service manages audio playback functionality for standard audio formats
class VoiceAudioService {
  late final AudioPlayer _audioPlayer;

  // Stream subscriptions for proper cleanup
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  final _cacheService = VoiceCacheService();

  // Callback functions
  final Function(Duration)? onPositionChanged;
  final Function(PlayerState)? onStateChanged;
  final Function(Duration)? onDurationChanged;
  final Function(String, dynamic)? onError;

  VoiceAudioService({
    this.onPositionChanged,
    this.onStateChanged,
    this.onDurationChanged,
    this.onError,
  }) {
    _initializeAudioPlayer();
  }

  /// Initializes the audio player and sets up listeners
  void _initializeAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    _setupListeners();
  }

  /// Sets up stream listeners for audio player events
  void _setupListeners() {
    if (onPositionChanged != null) {
      _positionSubscription = _audioPlayer.onPositionChanged.listen(
        onPositionChanged!,
        onError: (error) => _handleError('Position stream error', error),
      );
    }

    if (onStateChanged != null) {
      _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen(
        onStateChanged!,
        onError: (error) => _handleError('Player state stream error', error),
      );
    }

    if (onDurationChanged != null) {
      _durationSubscription = _audioPlayer.onDurationChanged.listen(
        onDurationChanged!,
        onError: (error) => _handleError('Duration stream error', error),
      );
    }
  }

  /// Creates audio source from VPlatformFile
  Future<Source> createAudioSource(VPlatformFile audioSrc) async {
    if (audioSrc.isFromPath) {
      return DeviceFileSource(audioSrc.fileLocalPath!);
    } else if (audioSrc.isFromBytes) {
      return BytesSource(Uint8List.fromList(audioSrc.bytes!));
    } else if (audioSrc.isFromUrl) {
      final path = await _cacheService.getFileFromCache(audioSrc);
      return DeviceFileSource(path);
    } else {
      throw Exception('Unsupported audio source type');
    }
  }

  /// Initializes audio source and prepares for playback
  Future<void> setSource(VPlatformFile audioSrc) async {
    try {
      final path = await _cacheService.getFileFromCache(audioSrc);
      final source = await createAudioSource(audioSrc);
      await _audioPlayer.setSource(source);
    } catch (error) {
      _handleError("Error setting audio source", error);
      rethrow;
    }
  }

  /// Starts audio playback
  Future<void> play() async {
    try {
      await _audioPlayer.resume();
    } catch (error) {
      _handleError("Error starting playback", error);
      rethrow;
    }
  }

  /// Pauses audio playback
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (error) {
      _handleError("Error pausing playback", error);
      rethrow;
    }
  }

  /// Stops audio playback
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (error) {
      _handleError("Error stopping playback", error);
      rethrow;
    }
  }

  /// Seeks to specific position
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (error) {
      _handleError("Error seeking", error);
      rethrow;
    }
  }

  /// Sets playback rate/speed
  Future<void> setPlaybackRate(double rate) async {
    try {
      await _audioPlayer.setPlaybackRate(rate);
    } catch (error) {
      _handleError("Error setting playback rate", error);
      rethrow;
    }
  }

  /// Gets current player state
  PlayerState get state => _audioPlayer.state;

  /// Handles errors with optional logging
  void _handleError(String message, dynamic error) {
    if (kDebugMode) {
      print('$message: $error');
    }
    onError?.call(message, error);
  }

  /// Disposes all resources
  Future<void> dispose() async {
    await _positionSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _audioPlayer.dispose();
  }
}

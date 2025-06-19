// Copyright 2023, the hatemragab project author.
// All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:v_platform/v_platform.dart';

import 'helpers/play_status.dart';
import 'helpers/voice_state_manager.dart';
import 'voice_state_model.dart';
import 'services/voice_cache_service.dart';
import 'services/voice_vlc_service.dart';
import 'services/voice_audio_service.dart';

/// A controller for handling voice message playback following ValueNotifier best practices.
/// This controller manages all voice player state and provides a clean API for the UI.
///
/// The controller has been refactored to use separate service classes for better separation
/// of concerns and improved readability.
class VVoiceMessageController extends ValueNotifier<VoiceStateModel>
    implements TickerProvider {
  /// The source of the audio file.
  final VPlatformFile audioSrc;

  /// Callback function when playback completes.
  final Function(String id)? onComplete;

  /// Callback function when playback starts.
  final Function(String id)? onPlaying;

  /// Callback function when playback is paused.
  final Function(String id)? onPause;

  /// The unique identifier for the voice message.
  final String id;

  // Service dependencies
  final _cacheService = VoiceCacheService();
  final _vlcService = VoiceVlcService();
  late final VoiceAudioService _audioService;

  // Internal state tracking
  Duration _currentDuration = Duration.zero;
  Duration _maxDuration = const Duration(minutes: 25);
  PlayStatus _playStatus = PlayStatus.init;
  PlaySpeed _speed = PlaySpeed.x1;
  bool _isSeeking = false;
  bool _wasPlayingBeforeSeek = false;
  bool _isListened = false;

  /// Creates a new [VVoiceMessageController] with proper initialization
  VVoiceMessageController({
    required this.id,
    required this.audioSrc,
    Duration? maxDuration,
    this.onComplete,
    this.onPause,
    this.onPlaying,
  }) : super(VoiceStateModel.initial(maxDuration: maxDuration, id: id)) {
    _maxDuration = maxDuration ?? const Duration(minutes: 25);
    _initializeController();
  }

  /// Initializes the controller and services
  void _initializeController() {
    _setupAudioService();
    _updateState(); // Initial state update
  }

  /// Sets up the audio service with event callbacks
  void _setupAudioService() {
    _audioService = VoiceAudioService(
      onPositionChanged: _handlePositionChanged,
      onStateChanged: _handlePlayerStateChanged,
      onDurationChanged: _handleDurationChanged,
      onError: _handleError,
    );
  }

  /// Initializes and starts audio playback
  Future<void> initAndPlay() async {
    await _setPlaybackState(PlayStatus.downloading);

    try {
      if (_vlcService.isVlcRequired(audioSrc)) {
        await _initAndPlayVlc();
      } else {
        await _initAndPlayAudio();
      }
    } catch (error) {
      await _setPlaybackState(PlayStatus.downloadError);
      _handleError('Error initializing and playing audio', error);
    }
  }

  /// Pauses the audio playback
  void pausePlaying() {
    if (_vlcService.isVlcRequired(audioSrc)) {
      _vlcService.pause();
    } else {
      _audioService.pause();
    }
    _setPlaybackState(PlayStatus.pause);
    onPause?.call(id);
  }

  /// Resumes the audio playback from current position
  Future<void> _resumePlayback() async {
    try {
      if (_vlcService.isVlcRequired(audioSrc)) {
        await _vlcService.play();
      } else {
        await _audioService.play();
      }
      _isListened = true;
      await _setPlaybackState(PlayStatus.playing);
      onPlaying?.call(id);
    } catch (error) {
      _handleError('Error resuming playback', error);
      await _setPlaybackState(PlayStatus.pause);
    }
  }

  /// Seeks the audio playback to the specified duration
  /// Restores the previous playback state after seeking
  Future<void> onSeek(Duration duration) async {
    final wasPlayingBeforeSeeking = _wasPlayingBeforeSeek;

    _isSeeking = false;
    _currentDuration = duration;
    _updateState();

    try {
      if (_vlcService.isVlcRequired(audioSrc)) {
        await _vlcService.seekTo(duration);
      } else {
        await _audioService.seek(duration);
      }

      // Add a small delay to ensure seek operation is completed
      await Future.delayed(const Duration(milliseconds: 100));

      // Restore the previous playback state
      if (wasPlayingBeforeSeeking && !value.isPlaying) {
        await _resumePlayback();
      }
    } catch (error) {
      _handleError('Error during seek operation', error);
    } finally {
      // Reset the seeking state flag
      _wasPlayingBeforeSeek = false;
    }
  }

  /// Called when the user starts interacting with the playback slider
  /// Remembers the current playback state and pauses if playing
  void onChangeSliderStart(double x) {
    _isSeeking = true;
    // Remember if we were playing before seeking
    _wasPlayingBeforeSeek = value.isPlaying;

    // Only pause if currently playing
    if (value.isPlaying) {
      pausePlaying();
    }
  }

  /// Updates the current playback position while the user is interacting with the slider
  void onChanging(double value) {
    _currentDuration = Duration(milliseconds: value.toInt());
    _updateState();
  }

  /// Changes the playback speed to the next available speed option
  Future<void> changeSpeed() async {
    _speed = _speed.next;

    if (!_vlcService.isVlcRequired(audioSrc)) {
      await _audioService.setPlaybackRate(_speed.getSpeed);
    }
    _updateState();
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  // Private audio playback methods
  Future<void> _initAndPlayAudio() async {
    await _audioService.setSource(audioSrc);

    if (_currentDuration != Duration.zero) {
      await _audioService.seek(_currentDuration);
    }

    await _audioService.play();
    await _audioService.setPlaybackRate(_speed.getSpeed);
    _isListened = true;
    await _setPlaybackState(PlayStatus.playing);
    onPlaying?.call(id);
  }

  // Private VLC methods
  Future<void> _initAndPlayVlc() async {
    final path = await _cacheService.getFileFromCache(audioSrc);
    await _vlcService.initializeAndPlay(path);
    _isListened = true;
    await _setPlaybackState(PlayStatus.playing);
    onPlaying?.call(id);
  }

  // Private event handlers
  Future<void> _handlePositionChanged(Duration position) async {
    if (!_isSeeking) {
      _currentDuration = position;
      _updateState();

      if (position >= _maxDuration) {
        await _handlePlaybackCompletion();
      }
    }
  }

  Future<void> _handlePlayerStateChanged(PlayerState state) async {
    switch (state) {
      case PlayerState.playing:
        if (_playStatus != PlayStatus.playing) {
          await _setPlaybackState(PlayStatus.playing);
        }
        break;
      case PlayerState.paused:
        if (_playStatus != PlayStatus.pause) {
          await _setPlaybackState(PlayStatus.pause);
        }
        break;
      case PlayerState.stopped:
        if (_playStatus != PlayStatus.stop) {
          await _setPlaybackState(PlayStatus.stop);
        }
        break;
      case PlayerState.completed:
        await _handlePlaybackCompletion();
        break;
      case PlayerState.disposed:
        break;
    }
  }

  Future<void> _handleDurationChanged(Duration duration) async {
    if (duration != Duration.zero) {
      _maxDuration = duration;
      _updateState();
    }
  }

  Future<void> _handlePlaybackCompletion() async {
    if (_vlcService.isVlcRequired(audioSrc)) {
      await _vlcService.stop();
      await _vlcService.seekTo(Duration.zero);
    } else {
      await _audioService.stop();
    }

    _currentDuration = Duration.zero;
    await _setPlaybackState(PlayStatus.init);
    onComplete?.call(id);
  }

  Future<void> _setPlaybackState(PlayStatus status) async {
    _playStatus = status;
    _updateState();
  }

  void _updateState() {
    value = VoiceStateManager.createUpdatedState(
      playStatus: _playStatus,
      speed: _speed,
      isSeeking: _isSeeking,
      currentDuration: _currentDuration,
      maxDuration: _maxDuration,
      isListened: _isListened,
    );
  }

  void _handleError(String message, dynamic error) {
    if (kDebugMode) {
      print('$message: $error');
    }
  }

  Future<void> _cleanupResources() async {
    await _audioService.dispose();
    await _vlcService.dispose();
  }

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

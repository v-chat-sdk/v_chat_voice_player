// Copyright 2023, the hatemragab project author.
// All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart' as cache;
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:v_platform/v_platform.dart';

import 'helpers/play_status.dart';
import 'helpers/voice_state_manager.dart';
import 'voice_state_model.dart';

/// A controller for handling voice message playback following ValueNotifier best practices.
/// This controller manages all voice player state and provides a clean API for the UI.
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

  late final AudioPlayer _audioPlayer;
  VlcPlayerController? _vlcPlayerController;

  // Stream subscriptions for proper cleanup
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _durationSubscription;

  // Internal state tracking
  Duration _currentDuration = Duration.zero;
  Duration _maxDuration = const Duration(days: 1);
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
    _maxDuration = maxDuration ?? const Duration(days: 1);
    _initializeController();
  }

  // Public getters for backward compatibility
  /// Whether the audio is currently playing
  bool get isPlaying => value.isPlaying;

  /// Whether the audio player is initialized
  bool get isInit => value.isInit;

  /// Whether the audio is currently downloading
  bool get isDownloading => value.isDownloading;

  /// Whether there was an error downloading the audio
  bool get isDownloadError => value.isDownloadError;

  /// Whether the audio playback is stopped
  bool get isStop => value.isStop;

  /// Whether the audio playback is paused
  bool get isPause => value.isPause;

  /// Gets the current playback position in milliseconds
  double get currentMillSeconds => value.currentMillSeconds;

  /// Gets the maximum duration of the audio in milliseconds
  double get maxMillSeconds => value.maxMillSeconds;

  /// Gets the current playback speed as a string
  String get playSpeedStr => value.speedDisplayText;

  /// Gets the formatted remaining time of the audio playback
  String get remindingTime => value.remainingTimeText;

  /// Initializes the audio player and starts playback
  Future<void> initAndPlay() async {
    await _setPlaybackState(PlayStatus.downloading);

    try {
      if (_isIosWebm) {
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
    _audioPlayer.pause();
    _vlcPlayerController?.pause();
    _setPlaybackState(PlayStatus.pause);
    onPause?.call(id);
  }

  /// Resumes the audio playback from current position
  Future<void> _resumePlayback() async {
    try {
      if (_isIosWebm && _vlcPlayerController != null) {
        await _vlcPlayerController!.play();
      } else {
        await _audioPlayer.resume();
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
      if (_isIosWebm && _vlcPlayerController != null) {
        await _vlcPlayerController!.seekTo(duration);
      } else {
        await _audioPlayer.seek(duration);
      }

      // Add a small delay to ensure seek operation is completed
      await Future.delayed(const Duration(milliseconds: 100));

      // Restore the previous playback state
      if (wasPlayingBeforeSeeking && !isPlaying) {
        // Resume playing if we were playing before seeking
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
  void onChangeSliderStart(double value) {
    _isSeeking = true;
    // Remember if we were playing before seeking
    _wasPlayingBeforeSeek = isPlaying;

    // Only pause if currently playing
    if (isPlaying) {
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

    if (!_isIosWebm) {
      await _audioPlayer.setPlaybackRate(_speed.getSpeed);
    }
    _updateState();
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  // Private initialization methods
  void _initializeController() {
    _setupAudioPlayer();
    _updateState(); // Initial state update
  }

  void _setupAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    _setupAudioListeners();
  }

  void _setupAudioListeners() {
    _listenToPositionStream();
    _listenToPlayerStateStream();
    _listenToDurationStream();
  }

  // Private audio playback methods
  Future<void> _initAndPlayAudio() async {
    await _initializeAudioSource();
    await _audioPlayer.resume();
    await _audioPlayer.setPlaybackRate(_speed.getSpeed);
    _isListened = true;
    await _setPlaybackState(PlayStatus.playing);
    onPlaying?.call(id);
  }

  Future<void> _initializeAudioSource() async {
    try {
      final source = await _createAudioSource();
      await _audioPlayer.setSource(source);

      if (_currentDuration != Duration.zero) {
        await _audioPlayer.seek(_currentDuration);
      }
    } catch (error) {
      _handleError("Error initializing audio source", error);
      rethrow;
    }
  }

  Future<Source> _createAudioSource() async {
    if (_isFile) {
      return DeviceFileSource(audioSrc.fileLocalPath!);
    } else if (_isUrl) {
      return UrlSource(audioSrc.fullNetworkUrl!);
    } else if (_isBytes) {
      return BytesSource(Uint8List.fromList(audioSrc.bytes!));
    } else {
      throw Exception('Unsupported audio source type');
    }
  }

  // Private VLC methods
  Future<void> _initAndPlayVlc() async {
    final path = await _getFileFromCache();
    await _setupVlcPlayer(path);
    await Future.delayed(const Duration(milliseconds: 500));
    _isListened = true;
    await _setPlaybackState(PlayStatus.playing);
    onPlaying?.call(id);
  }

  Future<void> _setupVlcPlayer(String path) async {
    await _disposeVlcPlayer();

    _vlcPlayerController = VlcPlayerController.file(
      File(path),
      hwAcc: HwAcc.full,
      options: _createVlcOptions(),
      autoInitialize: true,
    );
  }

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

  Future<void> _disposeVlcPlayer() async {
    if (_vlcPlayerController != null) {
      await _vlcPlayerController!.dispose();
      _vlcPlayerController = null;
    }
  }

  // Private stream listeners
  void _listenToPositionStream() {
    _positionSubscription = _audioPlayer.onPositionChanged.listen(
      _handlePositionChanged,
      onError: (error) => _handleError('Position stream error', error),
    );
  }

  void _listenToPlayerStateStream() {
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen(
      _handlePlayerStateChanged,
      onError: (error) => _handleError('Player state stream error', error),
    );
  }

  void _listenToDurationStream() {
    _durationSubscription = _audioPlayer.onDurationChanged.listen(
      _handleDurationChanged,
      onError: (error) => _handleError('Duration stream error', error),
    );
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
    await _audioPlayer.stop();
    _vlcPlayerController?.stop();
    _vlcPlayerController?.seekTo(Duration.zero);
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

  Future<String> _getFileFromCache() async {
    if (_isFile) {
      return audioSrc.fileLocalPath!;
    }
    if (_isBytes) {
      throw Exception('Bytes audio source not supported for cached playback');
    }
    final file = await cache.DefaultCacheManager().getSingleFile(
      audioSrc.fullNetworkUrl!,
      key: audioSrc.getCachedUrlKey,
    );
    return file.path;
  }

  void _handleError(String message, dynamic error) {
    if (kDebugMode) {
      print('$message: $error');
    }
  }

  Future<void> _cleanupResources() async {
    await _positionSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _audioPlayer.dispose();
    await _disposeVlcPlayer();
  }

  // Private getters for audio source type
  bool get _isFile => audioSrc.isFromPath;

  bool get _isBytes => audioSrc.isFromBytes;

  bool get _isUrl => audioSrc.isFromUrl;

  bool get _isIosWebm =>
      VPlatforms.isIOS &&
      (audioSrc.extension == ".webm" || audioSrc.extension == ".opus");

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

// Copyright 2023, the hatemragab project author.
// All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart' as cache;
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart';
import 'package:v_chat_voice_player/src/helpers/utils.dart';
import 'package:v_platform/v_platform.dart';

import 'helpers/bytes_custom_source.dart';
import 'helpers/play_status.dart';

/// A controller for handling voice message playback, including play, pause,
/// seek, and speed control. It manages the audio player, animation controller,
/// and playback status.
class VVoiceMessageController extends ValueNotifier implements TickerProvider {
  /// The source of the audio file.
  final VPlatformFile audioSrc;

  /// The maximum duration of the audio.
  late Duration maxDuration;
  VlcPlayerController? vlcPlayerController;
  Duration _currentDuration = Duration.zero;

  /// Callback function when playback completes.
  final Function(String id)? onComplete;

  /// Callback function when playback starts.
  final Function(String id)? onPlaying;

  /// Callback function when playback is paused.
  final Function(String id)? onPause;

  /// The unique identifier for the voice message.
  final String id;

  /// The width used for noise visualization.
  final double noiseWidth = 50.5.w();

  /// Animation controller for visualizing audio waves.
  late AnimationController animController;

  final AudioPlayer _player = AudioPlayer();
  PlayStatus _playStatus = PlayStatus.init;
  PlaySpeed _speed = PlaySpeed.x1;
  final List<double> randoms = [];

  StreamSubscription<Duration>? _positionStream;
  StreamSubscription<PlayerState>? _playerStateStream;

  bool _isSeeking = false;

  /// Indicates whether the audio is currently playing.
  bool get isPlaying => _playStatus == PlayStatus.playing;

  /// Indicates whether the audio player is initialized.
  bool get isInit => _playStatus == PlayStatus.init;

  /// Indicates whether the audio is currently downloading.
  bool get isDownloading => _playStatus == PlayStatus.downloading;

  /// Indicates whether there was an error downloading the audio.
  bool get isDownloadError => _playStatus == PlayStatus.downloadError;

  /// Indicates whether the audio playback is stopped.
  bool get isStop => _playStatus == PlayStatus.stop;

  /// Indicates whether the audio playback is paused.
  bool get isPause => _playStatus == PlayStatus.pause;

  /// Gets the current playback position in milliseconds.
  double get currentMillSeconds {
    final c = _currentDuration.inMilliseconds.toDouble();
    return c >= maxMillSeconds ? maxMillSeconds : c;
  }

  /// Gets the maximum duration of the audio in milliseconds.
  double get maxMillSeconds => maxDuration.inMilliseconds.toDouble();

  /// Creates a new [VVoiceMessageController].
  ///
  /// [id] is the unique identifier for the voice message.
  /// [audioSrc] is the source of the audio file.
  /// [maxDuration] is the maximum duration of the audio.
  /// [onComplete] is a callback function when playback completes.
  /// [onPause] is a callback function when playback is paused.
  /// [onPlaying] is a callback function when playback starts.
  VVoiceMessageController({
    required this.id,
    required this.audioSrc,
    this.maxDuration = const Duration(days: 1),
    this.onComplete,
    this.onPause,
    this.onPlaying,
  }) : super(null) {
    _setRandoms();
    animController = AnimationController(
      vsync: this,
      upperBound: noiseWidth,
      duration: maxDuration,
    );
    _listenToPositionStream();
    _listenToPlayerState();
  }

  /// Initializes the audio player and starts playback.
  /// Downloads the audio if necessary and begins playback from the current position.
  Future<void> initAndPlay() async {
    _playStatus = PlayStatus.downloading;
    _updateUi();
    try {
      if (kIsWeb) {
        await _setMaxDurationForJs();
      } else {
        final path = await _getFileFromCache();
        if (_isIosWebm) {
          await _initAndPlayForIosWebm(path);
        } else {
          await _setMaxDurationForIo(path);
        }
      }
      _player.play();
      await _player.setSpeed(_speed.getSpeed);
      _playStatus = PlayStatus.playing;
      _updateUi();
      onPlaying?.call(id);
    } catch (err) {
      _playStatus = PlayStatus.downloadError;
      _updateUi();
      if (kDebugMode) {
        print('Error initializing and playing audio: $err');
      }
    }
  }

  /// Pauses the audio playback and notifies listeners.
  void pausePlaying() {
    _player.pause();
    _playStatus = PlayStatus.pause;
    _updateUi();
    vlcPlayerController?.pause();
    onPause?.call(id);
  }

  /// Seeks the audio playback to the specified [duration].
  /// [duration] is the position to seek to.
  void onSeek(Duration duration) {
    _isSeeking = false;
    _currentDuration = duration;
    _updateUi();
    _player.seek(duration);
  }

  Future _initAndPlayForIosWebm(String path) async {
    if (vlcPlayerController != null) {
      await vlcPlayerController!.dispose();
      //await videoPlayerController!.stopRendererScanning();
      vlcPlayerController = null;
    }
    vlcPlayerController ??= VlcPlayerController.file(
      File(path),
      hwAcc: HwAcc.full,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(2000),
        ]),
        subtitle: VlcSubtitleOptions([
          VlcSubtitleOptions.boldStyle(true),
          VlcSubtitleOptions.fontSize(30),
          VlcSubtitleOptions.outlineColor(VlcSubtitleColor.yellow),
          VlcSubtitleOptions.outlineThickness(VlcSubtitleThickness.normal),
          // works only on externally added subtitles
          VlcSubtitleOptions.color(VlcSubtitleColor.navy),
        ]),
        http: VlcHttpOptions([
          VlcHttpOptions.httpReconnect(true),
        ]),
        rtp: VlcRtpOptions([
          VlcRtpOptions.rtpOverRtsp(true),
        ]),
      ),
      autoInitialize: true,
    );
    //await videoPlayerController!.initialize();
    _updateUi();
    await Future.delayed(const Duration(milliseconds: 500));
    //await videoPlayerController!.initialize();
    _playStatus = PlayStatus.playing;
    _updateUi();
  }
  bool get _isIosWebm =>
      VPlatforms.isIOS &&
      (audioSrc.extension == ".webm" || audioSrc.extension == ".opus");

  /// Called when the user starts interacting with the playback slider.
  /// Pauses the audio and prepares for seeking.
  void onChangeSliderStart(double value) {
    _isSeeking = true;
    pausePlaying();
  }

  /// Updates the current playback position while the user is interacting with the slider.
  /// [value] is the new position in milliseconds.
  void onChanging(double value) {
    _currentDuration = Duration(milliseconds: value.toInt());
    final animValue = (noiseWidth * value) / maxMillSeconds;
    animController.value = animValue;
    _updateUi();
  }

  /// Changes the playback speed to the next available speed option.
  Future<void> changeSpeed() async {
    switch (_speed) {
      case PlaySpeed.x1:
        _speed = PlaySpeed.x1_25;
        break;
      case PlaySpeed.x1_25:
        _speed = PlaySpeed.x1_5;
        break;
      case PlaySpeed.x1_5:
        _speed = PlaySpeed.x1_75;
        break;
      case PlaySpeed.x1_75:
        _speed = PlaySpeed.x2;
        break;
      case PlaySpeed.x2:
        _speed = PlaySpeed.x1;
        break;
    }
    await _player.setSpeed(_speed.getSpeed);
    _updateUi();
  }

  /// Gets the current playback speed as a string.
  String get playSpeedStr {
    switch (_speed) {
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

  /// Gets the formatted remaining time of the audio playback.
  String get remindingTime {
    if (_currentDuration == Duration.zero) {
      return maxDuration.getStringTime;
    }
    if (_isSeeking) {
      return _currentDuration.getStringTime;
    }
    if (isPause || isInit) {
      return maxDuration.getStringTime;
    }
    return _currentDuration.getStringTime;
  }

  @override
  void dispose()async {
    _player.dispose();
    _positionStream?.cancel();
    _playerStateStream?.cancel();

    animController.dispose();
    await vlcPlayerController?.stop();
    await vlcPlayerController?.dispose();
    super.dispose();
  }

  // Private methods and utilities

  bool get _isFile => audioSrc.isFromPath;

  bool get _isBytes => audioSrc.isFromBytes;

  bool get _isUrl => audioSrc.isFromUrl;

  Future<String> _getFileFromCache() async {
    if (_isFile) {
      return audioSrc.fileLocalPath!;
    }
    if (_isBytes) {
      throw 'Bytes file not supported for play voice';
    }
    final file = await cache.DefaultCacheManager().getSingleFile(
      audioSrc.fullNetworkUrl!,
      key: audioSrc.getCachedUrlKey,
    );
    return file.path;
  }

  void _listenToPositionStream() {
    _positionStream = _player.positionStream.listen((Duration position) async {
      _currentDuration = position;
      final value = (noiseWidth * currentMillSeconds) / maxMillSeconds;
      animController.value = value;
      _updateUi();
      if (position.inMilliseconds >= maxMillSeconds) {
        await _player.stop();
        vlcPlayerController?.stop();
        vlcPlayerController?.seekTo(Duration.zero);
        _currentDuration = Duration.zero;
        _playStatus = PlayStatus.init;
        animController.reset();
        _updateUi();
        onComplete?.call(id);
      }
    });
  }

  void _updateUi() {
    notifyListeners();
  }

  void _listenToPlayerState() {
    _playerStateStream = _player.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        // Handle completion if necessary
      } else if (event.playing) {
        _playStatus = PlayStatus.playing;
        _updateUi();
      }
    });
  }

  void _setRandoms() {
    for (var i = 0; i < 40; i++) {
      randoms.add(5.74.w() * Random().nextDouble() + .26.w());
    }
  }

  Future<void> _setMaxDurationForIo(String path) async {
    try {
      final maxDuration = await _player.setFilePath(
        path,
        initialPosition: _currentDuration,
      );
      if (maxDuration != null) {
        this.maxDuration = maxDuration;
        animController.duration = maxDuration;
      }
    } catch (err) {
      if (kDebugMode) {
        print("Can't get the max duration from the path $path");
      }
    }
  }

  Future<void> _setMaxDurationForJs() async {
    try {
      if (_isUrl) {
        final maxDuration = await _player.setUrl(
          audioSrc.fullNetworkUrl!,
          initialPosition: _currentDuration,
        );
        if (maxDuration != null) {
          this.maxDuration = maxDuration;
          animController.duration = maxDuration;
        }
      } else if (_isBytes) {
        final maxDuration = await _player.setAudioSource(
          BytesCustomSource(audioSrc.bytes!),
          initialPosition: _currentDuration,
        );
        if (maxDuration != null) {
          this.maxDuration = maxDuration;
          animController.duration = maxDuration;
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print("Can't get the max duration from the audio source!");
      }
    }
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}

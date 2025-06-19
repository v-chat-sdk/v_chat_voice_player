// Copyright 2023, the hatemragab project author.
// All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:v_platform/v_platform.dart';

/// Service class for handling voice file caching operations
/// This class provides a clean interface for cache management
/// and uses flutter_cache_manager to determine file existence
class VoiceCacheService {
  static final VoiceCacheService _instance = VoiceCacheService._internal();
  factory VoiceCacheService() => _instance;
  VoiceCacheService._internal();

  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  /// Checks if a file exists in cache
  /// Uses flutter_cache_manager's FileInfo to determine existence
  Future<bool> isFileInCache(VPlatformFile audioSrc) async {
    if (!audioSrc.isFromUrl) return false;

    try {
      final fileInfo = await _cacheManager.getFileFromCache(
        audioSrc.getCachedUrlKey,
      );
      return fileInfo != null && fileInfo.file.existsSync();
    } catch (e) {
      return false;
    }
  }

  /// Gets file from cache or downloads it if not cached
  /// Returns the local file path
  Future<String> getFileFromCache(VPlatformFile audioSrc) async {
    if (audioSrc.isFromPath) {
      return audioSrc.fileLocalPath!;
    }

    if (audioSrc.isFromBytes) {
      throw Exception('Bytes audio source not supported for cached playback');
    }

    if (!audioSrc.isFromUrl) {
      throw Exception('Unsupported audio source type for caching');
    }

    try {
      final file = await _cacheManager.getSingleFile(
        audioSrc.fullNetworkUrl!,
        key: audioSrc.getCachedUrlKey,
      );
      return file.path;
    } catch (e) {
      throw Exception('Failed to get file from cache: $e');
    }
  }

  /// Removes a file from cache
  Future<void> removeFromCache(VPlatformFile audioSrc) async {
    if (!audioSrc.isFromUrl) return;

    try {
      await _cacheManager.removeFile(audioSrc.getCachedUrlKey);
    } catch (e) {
      // Ignore removal failures silently
    }
  }

  /// Gets file info from cache
  Future<FileInfo?> getFileInfo(VPlatformFile audioSrc) async {
    if (!audioSrc.isFromUrl) return null;

    try {
      return await _cacheManager.getFileFromCache(audioSrc.getCachedUrlKey);
    } catch (e) {
      return null;
    }
  }

  /// Clears all cached voice files
  Future<void> clearCache() async {
    try {
      await _cacheManager.emptyCache();
    } catch (e) {
      // Ignore clear failures silently
    }
  }

  /// Gets cache size information
  /// Note: This is an approximation as flutter_cache_manager doesn't provide direct cache size access
  Future<int> getCacheSize() async {
    try {
      // Since flutter_cache_manager doesn't provide direct access to calculate total cache size,
      // we return 0 as a placeholder. In practice, you might need to maintain your own size tracking
      // or use platform-specific directory access methods
      return 0;
    } catch (e) {
      return 0;
    }
  }
}

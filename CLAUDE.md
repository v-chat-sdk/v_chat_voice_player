# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

V Chat Voice Player is a Flutter package providing customizable voice message playback for chat applications. It's part of the V Chat SDK ecosystem and can be used as a standalone package. The package supports multiple audio sources (URLs, local files, bytes) across all major platforms (Android, iOS, Web, Windows, macOS, Linux).

**Key Architecture**: ValueNotifier-based state management with separate service classes for audio playback, VLC handling (iOS WebM), and caching.

## Development Commands

### Testing & Validation
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Analyze code for issues
flutter analyze

# Format code
dart format lib/ test/

# Check for outdated dependencies
flutter pub outdated
```

### Building & Running
```bash
# Get dependencies
flutter pub get

# Run example app (from example directory)
cd example && flutter run

# Build for specific platforms (compile-only, don't run on device)
flutter build apk --debug           # Android
flutter build ios --no-codesign     # iOS
flutter build web                   # Web
flutter build windows               # Windows
flutter build macos                 # macOS
flutter build linux                 # Linux
```

### Package Management
```bash
# Publish dry-run (validate before publishing)
flutter pub publish --dry-run

# Update dependencies
flutter pub upgrade

# Clean build artifacts
flutter clean
```

## Architecture & Code Structure

### Core Components

**lib/src/voice_message_controller.dart** (`VVoiceMessageController`)
- Extends `ValueNotifier<VoiceStateModel>` for reactive state management
- Coordinates three service classes: `VoiceAudioService`, `VoiceVlcService`, `VoiceCacheService`
- Manages audio lifecycle: initialization, play/pause, seek, speed control, disposal
- Smart seek behavior: preserves playback state during user interaction via `_wasPlayingBeforeSeek` flag
- Platform detection: automatically switches between standard audio and VLC for iOS WebM files

**lib/src/voice_state_model.dart** (`VoiceStateModel`)
- Immutable state model containing all player state
- Properties: `playStatus`, `speed`, `currentDuration`, `maxDuration`, `isListened`, etc.
- Computed getters: `isPlaying`, `progress`, `remainingDuration`, `canPlay`
- Always use `copyWith()` for state updates to maintain immutability

**lib/src/voice_message_view.dart** (`VVoiceMessageView`)
- Main UI widget using configuration classes for customization
- Uses `ValueListenableBuilder` to rebuild efficiently on state changes
- Renders play/pause button, visualizer/slider, speed control, avatar, timer
- Touch handling: Hidden native Flutter Slider behind visualizer for superior gesture recognition

**lib/src/voice_message_config.dart** (Configuration Classes)
- `VoiceVisualizerConfig`: Waveform visualization (bar count, heights, animations)
- `VoiceButtonConfig`: Play/pause button styling and behavior
- `VoiceSpeedConfig`: Speed control appearance
- `VoiceAvatarConfig`: User avatar and mic icon settings
- `VoiceColorConfig`: Active/inactive slider colors
- `VoiceContainerConfig`: Background, padding, border radius
- `VoiceTextConfig`: Text styling with TextTheme support

### Service Architecture (Refactored in v3.1.1)

**lib/src/services/voice_audio_service.dart**
- Wraps `audioplayers` package for standard audio playback
- Manages streams: position, state, duration, errors
- Methods: `setSource()`, `play()`, `pause()`, `stop()`, `seek()`, `setPlaybackRate()`
- Used for most audio sources (MP3, WAV, AAC, etc.)

**lib/src/services/voice_vlc_service.dart**
- Wraps `flutter_vlc_player` for iOS WebM/Opus file support
- Required when `audioSrc.ext == 'webm'` on iOS platform
- Methods: `initializeAndPlay()`, `pause()`, `play()`, `seekTo()`, `stop()`
- Auto-cleanup: disposes VLC controller when done

**lib/src/services/voice_cache_service.dart**
- Wraps `flutter_cache_manager` for audio file caching
- Used by VLC service to get local file paths for network URLs
- Web platform: Returns URL directly (no caching needed)

### Helper Classes

**lib/src/helpers/play_status.dart**
- Enum: `init`, `downloading`, `playing`, `pause`, `stop`, `downloadError`
- `PlaySpeed` enum: `x1`, `x125`, `x15`, `x2` with display strings

**lib/src/helpers/voice_state_manager.dart**
- Factory for creating updated `VoiceStateModel` instances
- Handles duration formatting and time calculations
- Centralizes state creation logic

**lib/src/helpers/voice_ui_randomizer.dart**
- Generates unique random bar heights for visualizer per message ID
- Seeded random generator ensures consistent patterns per message

**lib/src/helpers/utils.dart**
- Utility functions for time formatting and conversions

### Widget Components

**lib/src/widgets/voice_visualizer.dart**
- Animated waveform visualization using bars
- Implements hidden native Slider for touch handling (v3.1.2 improvement)
- Supports custom bar heights or random generation
- Bar animations during playback

**lib/src/widgets/noises.dart**
- Individual visualizer bar rendering
- Handles active/inactive coloring based on progress

## Important Implementation Details

### State Management Pattern
Always update state through `VoiceStateManager.createUpdatedState()` which is called by `_updateState()` in the controller. Never directly modify state properties.

### Seek Behavior (Critical Logic)
```dart
// When user starts seeking
onChangeSliderStart() {
  _isSeeking = true;
  _wasPlayingBeforeSeek = value.isPlaying;  // Remember state
  if (value.isPlaying) pausePlaying();       // Pause if playing
}

// When user finishes seeking
onSeek(duration) {
  _isSeeking = false;
  await seek(duration);
  if (_wasPlayingBeforeSeek && !value.isPlaying) {
    await _resumePlayback();  // Auto-resume if was playing before
  }
  _wasPlayingBeforeSeek = false;  // Reset flag
}
```

### Platform-Specific Audio Handling
```dart
// VLC required for iOS WebM files only
if (_vlcService.isVlcRequired(audioSrc)) {
  await _initAndPlayVlc();  // Use VLC player
} else {
  await _initAndPlayAudio();  // Use standard audioplayers
}
```

### Web Platform Special Handling
- Web uses `UrlSource` directly (no caching)
- Check in `voice_audio_service.dart:_createAudioSource()`
- Web detection via `kIsWeb` constant

### Resource Cleanup
Always call `controller.dispose()` in widget's `dispose()` method. Controller handles cleanup of both audio service and VLC service.

## Configuration System (v3.1.0+)

The package uses configuration classes instead of individual parameters for better organization and maintainability. When adding new customization options:

1. Add property to appropriate config class (or create new config class)
2. Update `copyWith()` method
3. Pass config to `VVoiceMessageView` constructor
4. Use config in widget build method

Example pattern:
```dart
VVoiceMessageView(
  controller: controller,
  colorConfig: const VoiceColorConfig(
    activeSliderColor: Colors.blue,
  ),
  visualizerConfig: const VoiceVisualizerConfig(
    showVisualizer: true,
    barCount: 50,
  ),
)
```

## Testing Strategy

- **Unit Tests**: Test state model, helpers, service classes independently
- **Widget Tests**: Test UI components and interactions
- **Integration Tests**: Test full playback scenarios with mock audio
- Test files location: `test/` directory

## Dependencies Overview

**Core Audio**:
- `audioplayers: ^6.5.0` - Standard audio playback (migrated from just_audio in v3.0.0)
- `flutter_vlc_player: ^7.4.3` - iOS WebM support

**Visualization**:
- `audio_waveforms: ^1.3.0` - Waveform generation

**Utilities**:
- `flutter_cache_manager: ^3.4.1` - Audio file caching
- `v_platform: ^2.1.4` - Platform abstraction for audio sources
- `intl: ^0.20.2` - Internationalization support
- `path: ^1.9.0` - Path manipulation

## Breaking Changes History

### v3.1.0
Individual styling parameters replaced with configuration classes. Migration required for all styling parameters.

### v3.0.0
Migrated from `just_audio` to `audioplayers`. API changes in some method signatures.

## Common Development Tasks

### Adding New Configuration Option
1. Identify appropriate config class in `voice_message_config.dart`
2. Add property with default value
3. Update `copyWith()` method
4. Use in `voice_message_view.dart`

### Adding New Playback Feature
1. Update `VoiceStateModel` if new state needed
2. Add method to `VVoiceMessageController`
3. Update service classes (`VoiceAudioService` or `VoiceVlcService`)
4. Update UI in `VVoiceMessageView` if visual changes needed

### Debugging Audio Issues
- Check `_handleError()` output in debug mode (`kDebugMode` flag)
- Verify platform-specific logic in service selection
- Ensure proper disposal to prevent resource leaks
- Check `PlayStatus` state transitions

## Version Requirements

- Dart SDK: `>=2.17.0 <4.0.0`
- Flutter: `>=1.17.0`
- Platforms: Android, iOS, Web, Windows, macOS, Linux

## Links

- Documentation: https://v-chat-sdk.github.io/vchat-v2-docs/docs/intro
- Issues: https://github.com/v-chat-sdk/v_chat_voice_player/issues
- Repository: https://github.com/v-chat-sdk/v_chat_voice_player

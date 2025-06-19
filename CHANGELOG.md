## 0.0.1

- initial release.

## 0.0.3

- update v_chat_utils to v 0.0.3
- ## 0.3.0
- add web support

## 0.4.0

- full localization support

## 1.0.0

- Support Dart 3

## 2.0.0

- Support Flutter V3.22
-

## 2.1.0

- Fix slider
- Upgrade packages

## 2.2.0

- Add flutter_audio_waveforms
- Upgrade packages

## 2.2.1

- update packages

## 2.2.2

- update packages

## 3.0.0

- **BREAKING CHANGE**: Migrated from `just_audio` to `audioplayers` package
- Improved code structure and performance
- Better state management with VoiceStateModel
- Enhanced error handling and stream management
- Kept VLC player support for iOS WebM files
- Added better documentation and utility methods
- Improved UI responsiveness and animations
- Fixed deprecated `withOpacity` usage
- Better memory management and resource cleanup
- Enhanced play speed controls with cleaner API

## 3.0.1

- **FEATURE**: Improved seek functionality - now preserves playback state during seeking
- When seeking while playing, audio resumes automatically after seek completes
- When seeking while paused, audio remains paused after seek completes
- Better user experience with intelligent seek state management

## 3.1.0

- **FEATURE**: Added user avatar support with mic icon indicating listened status
- **FEATURE**: Added `userAvatar` parameter to display user profile image
- **FEATURE**: Added `micIcon` parameter for custom mic icon widget
- **FEATURE**: Added `avatarSize` and `micIconSize` parameters for size customization
- **FEATURE**: Added `useSimplePlayIcon` parameter for play icon without circular background
- **FEATURE**: Added `simpleIconSize` parameter to control simple icon size (default: 24.0)
- **FEATURE**: Added automatic listen status tracking - mic icon changes color when voice is played
- **ENHANCEMENT**: Play icons now support both circular background and simple icon styles
- **ENHANCEMENT**: Enhanced state model to track if voice message has been listened to
- **ENHANCEMENT**: Simple icons now use actual size instead of proportional sizing for better visibility
- **UI**: Mic icon displays in active color when listened, inactive color when not listened
- **UI**: Play icon takes inactive slider color when using simple icon style

## 3.2.1

- **ENHANCEMENT**: Improved seek functionality to ensure playback resumes if it was playing before seeking
- **ENHANCEMENT**: Added error handling for seek operations and playback resumption
- **ENHANCEMENT**: Improved visualizer gesture handling for better seek behavior
- **ENHANCEMENT**: Added small delay after seek operation to ensure stability
- **FIX**: Seek behavior now correctly preserves playing state across seek operations
- **FIX**: Better state management during seek operations in both slider and visualizer

## 3.2.0

- **BREAKING CHANGE**: Reorganized parameters into configuration classes for better maintainability
- **FEATURE**: Added `VoiceColorConfig` for color-related settings
- **FEATURE**: Added `VoiceContainerConfig` for container styling
- **FEATURE**: Added `VoiceTextConfig` for text styling with theme support
- **FEATURE**: Added `VoiceButtonConfig` for button appearance and behavior
- **FEATURE**: Added `VoiceSpeedConfig` for speed control customization
- **FEATURE**: Added `VoiceAvatarConfig` for avatar and mic icon settings
- **FEATURE**: Added `VoiceVisualizerConfig` for visualizer appearance and behavior
- **FEATURE**: Added `timerTextTheme` support for timer text styling using Flutter's TextTheme
- **ENHANCEMENT**: Improved code organization and maintainability
- **ENHANCEMENT**: Better parameter grouping for easier customization
- **ENHANCEMENT**: All configuration classes include `copyWith` methods for easy modifications
- **MIGRATION**: Old individual parameters are replaced with configuration objects (see documentation)

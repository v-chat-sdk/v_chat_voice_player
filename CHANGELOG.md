# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.1.0] - 2024-12-19

### 🚨 Breaking Changes

- **Configuration Classes**: Reorganized parameters into configuration classes for better maintainability
- **Parameter Migration**: Individual styling parameters replaced with organized config objects
- **API Changes**: Old individual parameters are no longer supported (see migration guide in README)

### ✨ New Features

- **VoiceColorConfig**: Centralized color management for active/inactive states
- **VoiceContainerConfig**: Container styling with background, padding, border radius
- **VoiceTextConfig**: Text styling with Flutter TextTheme support
- **VoiceButtonConfig**: Complete button appearance and behavior control
- **VoiceSpeedConfig**: Speed control button customization
- **VoiceAvatarConfig**: User avatar and mic icon configuration
- **VoiceVisualizerConfig**: Comprehensive visualizer appearance and behavior settings
- **User Avatar Support**: Display user profile images with listen status indicators
- **Listen Status Tracking**: Automatic visual indicators for played/unplayed messages
- **Simple Play Icons**: Choice between circular background or simple icon styles
- **Icon Size Control**: Independent sizing for simple icons and avatar elements
- **Timer Theme Support**: Integration with Flutter's TextTheme for consistent styling

### 🔧 Enhancements

- **Improved Code Organization**: Better parameter grouping and class structure
- **Enhanced State Management**: More robust state tracking during seek operations
- **Better Error Handling**: Improved error handling for seek and playback operations
- **Visualizer Gestures**: Enhanced gesture handling for smoother interactions
- **Seek Stability**: Added delay after seek operations for better reliability
- **Memory Management**: Optimized resource cleanup and disposal
- **Performance**: Better state updates and reduced unnecessary rebuilds

### 🐛 Bug Fixes

- **Seek Behavior**: Correctly preserves playing state across seek operations
- **State Synchronization**: Better state management during slider and visualizer interactions
- **Icon Rendering**: Fixed icon sizing issues in different configurations
- **Animation Timing**: Improved animation stability during state transitions

### 📖 Documentation

- **Migration Guide**: Comprehensive guide for upgrading from v3.0.x
- **Configuration Examples**: Detailed examples for all configuration classes
- **API Reference**: Updated documentation with new class structures
- **Usage Examples**: Enhanced examples showing different customization approaches

### 🔄 Migration Notes

See the migration section in README.md for detailed upgrade instructions from v3.0.x to v3.1.0.

## [3.0.1] - 2024-11-15

### 🔧 Enhancements

- **Smart Seek Functionality**: Improved seek behavior that preserves playback state
- **Auto-Resume**: When seeking while playing, audio automatically resumes from new position
- **Pause Preservation**: When seeking while paused, audio remains paused at new position
- **User Experience**: Eliminated need for manual resume after seeking operations

## [3.0.0] - 2024-10-20

### 🚨 Breaking Changes

- **Audio Engine**: Migrated from `just_audio` to `audioplayers` package for better stability
- **API Changes**: Some method signatures updated for consistency

### ✨ New Features

- **VoiceStateModel**: Comprehensive state management system
- **Enhanced Error Handling**: Robust error handling and recovery mechanisms
- **Stream Management**: Improved audio stream handling and cleanup
- **VLC Support**: Maintained VLC player support for iOS WebM files
- **Speed Controls**: Enhanced playback speed controls with cleaner API
- **Animation System**: Improved UI responsiveness and smooth animations

### 🔧 Enhancements

- **Performance**: Significant performance improvements and optimization
- **Memory Management**: Better resource cleanup and memory usage
- **Code Structure**: Improved code organization and maintainability
- **Documentation**: Enhanced documentation and utility methods
- **Deprecation Fixes**: Removed deprecated `withOpacity` usage

### 🐛 Bug Fixes

- **State Consistency**: Fixed various state synchronization issues
- **Resource Leaks**: Resolved memory leaks in audio player cleanup
- **Platform Compatibility**: Enhanced cross-platform compatibility

## [2.2.2] - 2024-08-15

### 🔧 Enhancements

- **Dependencies**: Updated all package dependencies to latest versions
- **Compatibility**: Improved compatibility with latest Flutter SDK versions

## [2.2.1] - 2024-07-10

### 🔧 Enhancements

- **Dependencies**: Updated package dependencies for better stability
- **Performance**: Minor performance optimizations

## [2.2.0] - 2024-06-20

### ✨ New Features

- **Audio Waveforms**: Added `flutter_audio_waveforms` integration
- **Visual Enhancement**: Improved audio visualization capabilities

### 🔧 Enhancements

- **Dependencies**: Upgraded core packages to latest stable versions
- **Compatibility**: Enhanced Flutter version compatibility

## [2.1.0] - 2024-05-15

### 🐛 Bug Fixes

- **Slider Issues**: Fixed various slider interaction and rendering issues
- **UI Consistency**: Improved UI consistency across different platforms

### 🔧 Enhancements

- **Package Updates**: Upgraded dependencies for better performance and security

## [2.0.0] - 2024-04-10

### 🚨 Breaking Changes

- **Flutter Support**: Updated minimum Flutter version to 3.22
- **Dart Requirements**: Updated Dart SDK requirements

### 🔧 Enhancements

- **Compatibility**: Full compatibility with Flutter 3.22 and latest features
- **Performance**: Leveraged new Flutter optimizations for better performance

## [1.0.0] - 2024-02-20

### 🚨 Breaking Changes

- **Dart 3 Support**: Updated to support Dart 3 with null safety improvements
- **API Stability**: Marked API as stable with semantic versioning

### 🔧 Enhancements

- **Type Safety**: Enhanced type safety with Dart 3 features
- **Performance**: Improved performance with latest Dart optimizations

## [0.4.0] - 2023-12-15

### ✨ New Features

- **Internationalization**: Full localization support with multiple languages
- **Accessibility**: Enhanced accessibility features for screen readers
- **RTL Support**: Right-to-left language support

## [0.3.0] - 2023-11-10

### ✨ New Features

- **Web Support**: Added comprehensive web platform support
- **Cross-Platform**: Enhanced cross-platform compatibility

### 🔧 Enhancements

- **V Chat Utils**: Updated v_chat_utils dependency to v0.0.3
- **Web Optimization**: Optimized performance for web platforms

## [0.0.3] - 2023-10-05

### 🔧 Enhancements

- **Dependencies**: Updated v_chat_utils to version 0.0.3
- **Stability**: Improved overall package stability

## [0.0.1] - 2023-09-20

### 🎉 Initial Release

- **Basic Playback**: Core audio playback functionality
- **Simple UI**: Basic voice message player interface
- **Flutter Integration**: Initial Flutter package implementation

---

## Legend

- 🚨 **Breaking Changes**: Changes that require code modifications
- ✨ **New Features**: New functionality and capabilities
- 🔧 **Enhancements**: Improvements to existing features
- 🐛 **Bug Fixes**: Fixed issues and problems
- 📖 **Documentation**: Documentation improvements
- 🔄 **Migration Notes**: Information for upgrading versions

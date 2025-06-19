# V Chat Voice Player

![Pub Version](https://img.shields.io/pub/v/v_chat_voice_player) ![License](https://img.shields.io/badge/license-MIT-blue.svg) ![Platform](https://img.shields.io/badge/platform-flutter-blue.svg)

V Chat Voice Player is a powerful and highly customizable Flutter package for voice message playback in chat applications. Built with performance and flexibility in mind, it offers seamless audio playback with beautiful visualizations and extensive customization options.

## ✨ Features

- **🎵 Audio Playback**: Play/pause controls with intelligent state management
- **🎚️ Interactive Seek Bar**: Navigate through audio with real-time progress updates
- **⚡ Speed Control**: Adjustable playback speed (1x, 1.25x, 1.5x, 2x)
- **🌊 Voice Visualization**: Beautiful animated waveform with interactive seeking
- **👤 User Avatar Support**: Display user profile with listen status indicator
- **🎨 Highly Customizable**: Extensive styling options through configuration classes
- **📱 Cross-Platform**: Works seamlessly on Android, iOS, Web, Windows, macOS, and Linux
- **🔄 Smart State Management**: Built with ValueNotifier for optimal performance
- **🎯 Listen Tracking**: Visual indicators for played/unplayed messages
- **📦 Multiple Audio Sources**: Support for URLs, local files, and byte arrays

## 🚀 Quick Start

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  v_chat_voice_player: ^3.1.0
  v_platform: ^2.1.4 # Required for audio source handling
```

Run:

```bash
flutter pub get
```

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:v_chat_voice_player/v_chat_voice_player.dart';
import 'package:v_platform/v_platform.dart';

class MyVoiceMessage extends StatefulWidget {
  @override
  _MyVoiceMessageState createState() => _MyVoiceMessageState();
}

class _MyVoiceMessageState extends State<MyVoiceMessage> {
  late VVoiceMessageController controller;

  @override
  void initState() {
    super.initState();
    controller = VVoiceMessageController(
      id: 'voice_001',
      audioSrc: VPlatformFile.fromUrl(
        networkUrl: 'https://example.com/voice.mp3',
      ),
      onComplete: (id) => print('Playback completed: $id'),
      onPlaying: (id) => print('Started playing: $id'),
      onPause: (id) => print('Paused: $id'),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VVoiceMessageView(
      controller: controller,
    );
  }
}
```

## 🎨 Customization

### Configuration Classes (Recommended)

The package uses configuration classes for better organization and maintainability:

```dart
VVoiceMessageView(
  controller: controller,

  // Color configuration
  colorConfig: const VoiceColorConfig(
    activeSliderColor: Colors.blue,
    notActiveSliderColor: Colors.grey,
  ),

  // Container styling
  containerConfig: VoiceContainerConfig(
    backgroundColor: Colors.blue.shade50,
    borderRadius: 15,
    containerPadding: const EdgeInsets.all(12),
  ),

  // Button configuration
  buttonConfig: const VoiceButtonConfig(
    buttonColor: Colors.blue,
    buttonIconColor: Colors.white,
    buttonSize: 45,
    useSimplePlayIcon: true,
    simpleIconSize: 28,
  ),

  // Visualizer configuration
  visualizerConfig: const VoiceVisualizerConfig(
    showVisualizer: true,
    height: 50,
    barCount: 40,
    barSpacing: 2,
    minBarHeight: 6,
    useRandomHeights: true,
    enableBarAnimations: true,
  ),

  // Speed control configuration
  speedConfig: const VoiceSpeedConfig(
    showSpeedControl: true,
    speedButtonColor: Colors.blue,
    speedButtonTextColor: Colors.white,
  ),

  // Avatar configuration
  avatarConfig: VoiceAvatarConfig(
    userAvatar: const CircleAvatar(
      child: Icon(Icons.person),
    ),
    avatarSize: 45,
    micIconSize: 16,
  ),

  // Text styling
  textConfig: const VoiceTextConfig(
    counterTextStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  ),
)
```

### Audio Sources

#### From URL

```dart
VPlatformFile.fromUrl(
  networkUrl: 'https://example.com/audio.mp3',
)
```

#### From Local File

```dart
VPlatformFile.fromPath(
  fileLocalPath: '/path/to/audio.mp3',
)
```

#### From Bytes

```dart
VPlatformFile.fromBytes(
  bytes: audioBytes,
  name: 'audio.mp3',
)
```

> **Note**: Seeking is not supported for byte sources.

## 🌊 Visualizer Options

### Animated Waveform (Default)

```dart
visualizerConfig: const VoiceVisualizerConfig(
  showVisualizer: true,
  useRandomHeights: true, // Unique pattern per message
  height: 50,
  barCount: 50,
  enableBarAnimations: true,
)
```

### Custom Bar Pattern

```dart
visualizerConfig: const VoiceVisualizerConfig(
  showVisualizer: true,
  useRandomHeights: false,
  customBarHeights: [8, 16, 12, 20, 10, 18, 14, 22],
  enableBarAnimations: true,
)
```

### Traditional Slider

```dart
visualizerConfig: const VoiceVisualizerConfig(
  showVisualizer: false,
)
```

## 👤 Avatar & Listen Status

Display user avatars with automatic listen status tracking:

```dart
avatarConfig: VoiceAvatarConfig(
  userAvatar: CircleAvatar(
    backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
    child: const Text('JD'),
  ),
  avatarSize: 45,
  micIconSize: 16,
),
```

The mic icon automatically changes color:

- **Active color**: When message has been played
- **Inactive color**: When message is unplayed

## 🎯 Advanced Examples

### Chat Bubble Style

```dart
VVoiceMessageView(
  controller: controller,
  containerConfig: const VoiceContainerConfig(
    backgroundColor: Colors.transparent,
    containerPadding: EdgeInsets.zero,
    borderRadius: 0,
  ),
  buttonConfig: const VoiceButtonConfig(
    buttonSize: 32,
    useSimplePlayIcon: true,
  ),
  visualizerConfig: const VoiceVisualizerConfig(
    height: 28,
    showVisualizer: true,
  ),
  speedConfig: const VoiceSpeedConfig(
    showSpeedControl: false,
  ),
)
```

### Compact Player

```dart
VVoiceMessageView(
  controller: controller,
  visualizerConfig: const VoiceVisualizerConfig(
    showVisualizer: false,
  ),
  containerConfig: const VoiceContainerConfig(
    borderRadius: 20,
  ),
  buttonConfig: const VoiceButtonConfig(
    buttonSize: 35,
  ),
)
```

### Highly Customized

```dart
VVoiceMessageView(
  controller: controller,
  colorConfig: const VoiceColorConfig(
    activeSliderColor: Colors.deepPurple,
    notActiveSliderColor: Colors.grey,
  ),
  containerConfig: VoiceContainerConfig(
    backgroundColor: Colors.purple.shade50,
    borderRadius: 25,
    containerPadding: const EdgeInsets.all(16),
  ),
  buttonConfig: const VoiceButtonConfig(
    buttonColor: Colors.deepPurple,
    buttonIconColor: Colors.white,
    buttonSize: 50,
  ),
  visualizerConfig: const VoiceVisualizerConfig(
    height: 60,
    barCount: 60,
    barSpacing: 3,
    minBarHeight: 8,
    useRandomHeights: false,
    customBarHeights: [10, 20, 15, 25, 12, 18, 22, 14],
    enableBarAnimations: true,
  ),
  speedConfig: const VoiceSpeedConfig(
    speedButtonColor: Colors.purple,
    speedButtonTextColor: Colors.white,
    speedButtonBorderRadius: 10,
    speedButtonPadding: EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 5,
    ),
  ),
  avatarConfig: VoiceAvatarConfig(
    userAvatar: Container(
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 30,
      ),
    ),
    avatarSize: 50,
    micIconSize: 18,
  ),
)
```

## 📋 API Reference

### VVoiceMessageController

Main controller for voice message playback.

**Constructor:**

```dart
VVoiceMessageController({
  required String id,
  required VPlatformFile audioSrc,
  Duration? maxDuration,
  Function(String id)? onComplete,
  Function(String id)? onPlaying,
  Function(String id)? onPause,
})
```

**Properties:**

- `isPlaying` → `bool`: Whether audio is currently playing
- `isInit` → `bool`: Whether player is initialized
- `isDownloading` → `bool`: Whether audio is downloading
- `isDownloadError` → `bool`: Whether download failed
- `isStop` → `bool`: Whether playback is stopped
- `isPause` → `bool`: Whether playback is paused
- `currentMillSeconds` → `double`: Current position in milliseconds
- `maxMillSeconds` → `double`: Total duration in milliseconds
- `playSpeedStr` → `String`: Current speed (e.g., "1.00x")
- `remindingTime` → `String`: Remaining time (MM:SS format)

**Methods:**

- `initAndPlay()` → `Future<void>`: Initialize and start playback
- `pausePlaying()` → `void`: Pause playback
- `onSeek(Duration duration)` → `Future<void>`: Seek to position
- `changeSpeed()` → `Future<void>`: Change playback speed
- `dispose()` → `void`: Clean up resources

### Configuration Classes

All configuration classes support `copyWith()` for easy modification:

- **VoiceColorConfig**: Colors for active/inactive states
- **VoiceContainerConfig**: Background, padding, border radius
- **VoiceButtonConfig**: Play/pause button styling
- **VoiceVisualizerConfig**: Waveform visualization settings
- **VoiceSpeedConfig**: Speed control appearance
- **VoiceAvatarConfig**: User avatar and mic icon
- **VoiceTextConfig**: Text styling and theme support

## 🔄 Migration from v3.0.x

### Breaking Changes in v3.1.0

Individual parameters have been replaced with configuration classes for better organization:

**Before (v3.0.x):**

```dart
VVoiceMessageView(
  controller: controller,
  activeSliderColor: Colors.blue,
  backgroundColor: Colors.white,
  buttonSize: 45,
  showVisualizer: true,
  // ... many individual parameters
)
```

**After (v3.1.0):**

```dart
VVoiceMessageView(
  controller: controller,
  colorConfig: const VoiceColorConfig(
    activeSliderColor: Colors.blue,
  ),
  containerConfig: const VoiceContainerConfig(
    backgroundColor: Colors.white,
  ),
  buttonConfig: const VoiceButtonConfig(
    buttonSize: 45,
  ),
  visualizerConfig: const VoiceVisualizerConfig(
    showVisualizer: true,
  ),
)
```

### Migration Tool

Use this mapping to convert your existing code:

| Old Parameter          | New Location                       |
| ---------------------- | ---------------------------------- |
| `activeSliderColor`    | `colorConfig.activeSliderColor`    |
| `notActiveSliderColor` | `colorConfig.notActiveSliderColor` |
| `backgroundColor`      | `containerConfig.backgroundColor`  |
| `borderRadius`         | `containerConfig.borderRadius`     |
| `containerPadding`     | `containerConfig.containerPadding` |
| `buttonSize`           | `buttonConfig.buttonSize`          |
| `buttonColor`          | `buttonConfig.buttonColor`         |
| `showVisualizer`       | `visualizerConfig.showVisualizer`  |
| `visualizerHeight`     | `visualizerConfig.height`          |
| `userAvatar`           | `avatarConfig.userAvatar`          |
| `counterTextStyle`     | `textConfig.counterTextStyle`      |

## 🛠️ Platform Support

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- ✅ **Web** (Chrome, Firefox, Safari, Edge)
- ✅ **Windows** (Windows 10+)
- ✅ **macOS** (macOS 10.14+)
- ✅ **Linux** (Ubuntu 18.04+)

## 🎯 Smart Seek Functionality

The player includes intelligent seek behavior:

- **Playing + Seek**: Automatically resumes from new position
- **Paused + Seek**: Remains paused at new position
- **Smooth interaction**: No manual resume needed

## 🤝 Contributing

Contributions are welcome! Please read our [contributing guidelines](https://github.com/v-chat-sdk/v_chat_voice_player/blob/main/CONTRIBUTING.md) and submit pull requests to the main repository.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- **Documentation**: [V Chat SDK Docs](https://v-chat-sdk.github.io/vchat-v2-docs/docs/intro)
- **Issues**: [GitHub Issues](https://github.com/v-chat-sdk/v_chat_voice_player/issues)
- **Repository**: [GitHub](https://github.com/v-chat-sdk/v_chat_voice_player)
- **Pub.dev**: [Package Page](https://pub.dev/packages/v_chat_voice_player)

---

Made with ❤️ by the [V Chat SDK](https://github.com/v-chat-sdk) team

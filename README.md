# V Chat Voice Player

![Pub Version](https://img.shields.io/pub/v/v_chat_voice_player) ![License](https://img.shields.io/badge/license-MIT-blue.svg)

V Chat Voice Player is a Flutter package designed to provide a seamless and customizable voice message playback experience within your chat applications. It offers intuitive playback controls, a responsive seek bar, speed adjustment, and optional noise visualization to enhance user interaction.

## 📦 Features

- **Play/Pause Controls:** Easily integrate play and pause functionality for voice messages.
- **Seek Bar:** Intuitive seek bar to navigate through the audio with real-time progress updates.
- **Speed Control:** Adjust playback speed with customizable speed options.
- **Voice Visualization:** Beautiful animated waveform visualization with interactive seeking.
- **Noise Visualization:** Optional noise-based visualization to represent audio playback dynamically.
- **User Avatar Support:** Display user avatar with mic icon indicating listened status.
- **Listen Status Tracking:** Visual indicator showing if voice message has been played.
- **Flexible Icon Styles:** Choice between circular background or simple icon styles.
- **Customizable UI:** Tailor the player's appearance to match your app's design with customizable icons and colors.
- **Cross-Platform Support:** Works seamlessly on both Android and iOS platforms.

## 🔧 Installation

Add `v_chat_voice_player` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  v_chat_voice_player: ^3.0.0
```

Then, run `flutter pub get` to install the package.

## 📖 Usage

### 1. Import the Package

```dart
import 'package:v_chat_voice_player/v_chat_voice_player.dart';
```

### 2. Initialize the Controller

Create an instance of `VVoiceMessageController` by providing the necessary parameters such as the audio source and callbacks.

```dart
import 'package:flutter/material.dart';
import 'package:v_chat_voice_player/v_chat_voice_player.dart';
import 'package:v_platform/v_platform.dart';

class VoiceMessageExample extends StatefulWidget {
  @override
  _VoiceMessageExampleState createState() => _VoiceMessageExampleState();
}

class _VoiceMessageExampleState extends State<VoiceMessageExample> {
  late VVoiceMessageController _voiceController;

  @override
  void initState() {
    super.initState();
    _voiceController = VVoiceMessageController(
      id: 'unique_voice_message_id',
      audioSrc: VPlatformFile(
        // Provide your audio source here
        url: 'https://example.com/path/to/your/audio/file.mp3',
      ),
      onComplete: (id) {
        print('Playback completed for message: $id');
      },
      onPlaying: (id) {
        print('Playback started for message: $id');
      },
      onPause: (id) {
        print('Playback paused for message: $id');
      },
    );
  }

  @override
  void dispose() {
    _voiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VVoiceMessageView(
      controller: _voiceController,
      activeSliderColor: Colors.blue,
      notActiveSliderColor: Colors.grey,
      backgroundColor: Colors.white,
      playIcon: Icon(Icons.play_arrow, color: Colors.white),
      pauseIcon: Icon(Icons.pause, color: Colors.white),
      errorIcon: Icon(Icons.error, color: Colors.white),
      speedBuilder: (speed) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            speed,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
      counterTextStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      noiseWidthPercentage: 50.5, // Adjust as needed
    );
  }
}
```

### 3. Provide Audio Source

The `VVoiceMessageController` accepts a `VPlatformFile` which can be sourced from a URL, file path, or bytes. Here's how you can provide different audio sources:

#### From a URL

```dart
VPlatformFile(
  url: 'https://example.com/path/to/your/audio/file.mp3',
)
```

#### From a Local File Path

```dart
VPlatformFile(
  fileLocalPath: '/path/to/your/local/audio/file.mp3',
)
```

#### From Bytes

```dart
VPlatformFile(
  bytes: yourAudioBytes,
)
```

**Note:** Seeking with bytes source is not supported.

## 🔧 Seek Functionality

The voice player includes intelligent seek functionality that preserves playback state:

- **Playing + Seek**: When you seek while audio is playing, it automatically resumes playing from the new position
- **Paused + Seek**: When you seek while audio is paused, it remains paused at the new position
- **Smooth UX**: No need to manually resume playback after seeking

```dart
// The seek functionality works automatically with the slider
VVoiceMessageView(
  controller: _voiceController,
  // Seek behavior is handled internally - no additional setup needed
)
```

## 🚧 Customization

### 1. Customize Icons

You can provide custom widgets for play, pause, and error icons to match your app's design.

```dart
VVoiceMessageView(
  controller: _voiceController,
  playIcon: YourCustomPlayIcon(),
  pauseIcon: YourCustomPauseIcon(),
  errorIcon: YourCustomErrorIcon(),
  // Other parameters...
)
```

### 2. Customize Colors

Adjust the colors of the active and inactive parts of the seek bar, as well as the background.

```dart
VVoiceMessageView(
  controller: _voiceController,
  activeSliderColor: Colors.blue,
  notActiveSliderColor: Colors.grey,
  backgroundColor: Colors.white,
  // Other parameters...
)
```

### 3. Customize Speed Control

Provide a custom widget for the speed control display.

```dart
VVoiceMessageView(
  controller: _voiceController,
  speedBuilder: (speed) {
    return YourCustomSpeedWidget(speed);
  },
  // Other parameters...
)
```

### 4. Extensive Customization Options

The widget is highly customizable through its constructor parameters:

```dart
// Highly customized voice visualizer
VVoiceMessageView(
  controller: _voiceController,
  // Visualizer customization
  showVisualizer: true,
  useRandomHeights: false,
  visualizerHeight: 50,
  visualizerBarCount: 40,
  visualizerBarSpacing: 3.0,
  visualizerMinBarHeight: 6.0,
  enableBarAnimations: true,
  customBarHeights: [10, 20, 15, 25, 18], // Custom pattern

  // Colors
  activeSliderColor: Colors.deepPurple,
  notActiveSliderColor: Colors.purple.shade100,
  backgroundColor: Colors.purple.shade50,

  // Container styling
  borderRadius: 25,
  containerPadding: EdgeInsets.all(16),

  // Button customization
  buttonColor: Colors.deepPurple,
  buttonIconColor: Colors.white,
  buttonSize: 45,

  // Speed button customization
  speedButtonColor: Colors.purple,
  speedButtonTextColor: Colors.white,
  speedButtonBorderRadius: 10,
  speedButtonPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
)
```

### 5. User Avatar with Mic Icon

Display a user avatar with a mic icon that indicates if the voice message has been listened to:

```dart
VVoiceMessageView(
  controller: _voiceController,
  userAvatar: CircleAvatar(
    backgroundImage: NetworkImage('https://example.com/user-avatar.jpg'),
    child: Text('JD'), // Fallback if image fails to load
  ),
  avatarSize: 45.0,
  micIconSize: 16.0,
  useSimplePlayIcon: true, // Use simple play icon without circular background
  simpleIconSize: 28.0, // Control the size of simple icons for better visibility
)
```

The mic icon automatically changes color based on whether the voice message has been listened to:

- **Green/Active Color**: When the voice message has been played
- **Grey/Inactive Color**: When the voice message hasn't been played yet

#### Simple Icon Sizing

When using `useSimplePlayIcon: true`, you can control the icon size independently:

```dart
VVoiceMessageView(
  controller: _voiceController,
  useSimplePlayIcon: true,
  simpleIconSize: 28.0, // Default is 24.0 - increase for better visibility
  // Other parameters...
)
```

### 6. Voice Visualizer Options

Choose between different visualization modes:

```dart
// Default voice visualizer with random heights
VVoiceMessageView(
  controller: _voiceController,
  showVisualizer: true,
  useRandomHeights: true, // Each message gets unique bar pattern
)

// Fixed pattern visualizer
VVoiceMessageView(
  controller: _voiceController,
  showVisualizer: true,
  useRandomHeights: false, // Consistent pattern for all messages
  visualizerHeight: 45.0,
  visualizerBarCount: 60,
)

// Traditional slider
VVoiceMessageView(
  controller: _voiceController,
  showVisualizer: false,
)
```

### 7. Configuration-Based Approach

The voice player now uses a configuration-based approach for better organization and maintainability:

```dart
// Minimal setup
VVoiceMessageView(
  controller: controller,
)

// Organized configuration approach
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
    buttonSize: 45,
    useSimplePlayIcon: true,
    simpleIconSize: 28,
  ),
  // Visualizer configuration
  visualizerConfig: const VoiceVisualizerConfig(
    showVisualizer: true,
    height: 50,
    barCount: 40,
    useRandomHeights: false,
    customBarHeights: [8, 16, 12, 20, 10, 18, 14, 22, 16, 24],
  ),
  // Speed control configuration
  speedConfig: const VoiceSpeedConfig(
    showSpeedControl: true,
    speedButtonColor: Colors.blue,
  ),
  // Avatar configuration
  avatarConfig: VoiceAvatarConfig(
    userAvatar: CircleAvatar(child: Text('JD')),
    avatarSize: 45,
  ),
  // Text configuration with theme support
  textConfig: VoiceTextConfig(
    counterTextStyle: TextStyle(fontSize: 12),
    timerTextTheme: Theme.of(context).textTheme,
  ),
)
```

### 8. Advanced Usage Examples

Examples of different customization approaches:

```dart
// Chat bubble style
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
  ),
  speedConfig: const VoiceSpeedConfig(
    showSpeedControl: false,
  ),
)

// Compact player
VVoiceMessageView(
  controller: controller,
  visualizerConfig: const VoiceVisualizerConfig(
    showVisualizer: false, // Use traditional slider
  ),
  containerConfig: const VoiceContainerConfig(
    borderRadius: 25,
  ),
)
```

## 📋 API Reference

### VVoiceMessageController

A controller for handling voice message playback, including play, pause, seek, and speed control. It manages the audio player, animation controller, and playback status.

#### Constructor

```dart
VVoiceMessageController({
  required String id,
  required VPlatformFile audioSrc,
  Duration maxDuration = const Duration(days: 1),
  Function(String id)? onComplete,
  Function(String id)? onPlaying,
  Function(String id)? onPause,
})
```

- **id:** Unique identifier for the voice message.
- **audioSrc:** Source of the audio file (`VPlatformFile`).
- **maxDuration:** Maximum duration of the audio (default is 1 day).
- **onComplete:** Callback when playback completes.
- **onPlaying:** Callback when playback starts.
- **onPause:** Callback when playback is paused.

#### Properties

- **isPlaying:** `bool` indicating if the audio is currently playing.
- **isInit:** `bool` indicating if the player is initialized.
- **isDownloading:** `bool` indicating if the audio is downloading.
- **isDownloadError:** `bool` indicating if there was an error downloading.
- **isStop:** `bool` indicating if playback is stopped.
- **isPause:** `bool` indicating if playback is paused.
- **currentMillSeconds:** `double` representing current playback position in milliseconds.
- **maxMillSeconds:** `double` representing maximum duration in milliseconds.
- **playSpeedStr:** `String` representing current playback speed (e.g., "1.00x").
- **remindingTime:** `String` representing remaining time in MM:SS format.

#### Methods

- **initAndPlay():** Initializes the audio player and starts playback.
- **pausePlaying():** Pauses the audio playback.
- **onSeek(Duration duration):** Seeks to a specific position in the audio.
- **onChangeSliderStart(double value):** Called when user starts interacting with the seek bar.
- **onChanging(double value):** Updates playback position while interacting with the seek bar.
- **changeSpeed():** Changes the playback speed to the next option.
- **dispose():** Disposes the controller and associated resources.

### VVoiceMessageView

A widget that displays a voice message player with play/pause controls, a seek bar, and speed control.

#### Constructor

```dart
VVoiceMessageView({
  Key? key,
  required VVoiceMessageController controller,

  // Basic styling
  Color activeSliderColor = Colors.red,
  Color? notActiveSliderColor,
  Color? backgroundColor,
  TextStyle counterTextStyle = const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
  double borderRadius = 13.0,
  EdgeInsets containerPadding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),

  // Custom icons
  Widget? playIcon,
  Widget? pauseIcon,
  Widget? errorIcon,
  Widget Function(String speed)? speedBuilder,

  // Controls
  bool showSpeedControl = true,
  bool showVisualizer = true,

  // Visualizer customization
  double visualizerHeight = 40.0,
  int visualizerBarCount = 50,
  double visualizerBarSpacing = 2.0,
  double visualizerMinBarHeight = 4.0,
  bool useRandomHeights = true,
  List<double>? customBarHeights,
  bool enableBarAnimations = true,

  // Button customization
  Color? buttonColor,
  Color? buttonIconColor,
  double buttonSize = 40.0,

  // Speed button customization
  Color? speedButtonColor,
  Color? speedButtonTextColor,
  double speedButtonBorderRadius = 6.0,
  EdgeInsets speedButtonPadding = const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
})
```

**Key Features:**

- **Highly Customizable**: Every aspect can be customized through constructor parameters
- **No Theme Dependencies**: All styling is done through constructor parameters
- **Random Heights**: Generate unique bar patterns for each message ID
- **Custom Bar Heights**: Provide your own bar height patterns
- **Button Styling**: Full control over play/pause/speed button appearance
- **Container Styling**: Customize background, padding, border radius

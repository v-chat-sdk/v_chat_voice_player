# V Chat Voice Player

![Pub Version](https://img.shields.io/pub/v/v_chat_voice_player) ![License](https://img.shields.io/badge/license-MIT-blue.svg)

V Chat Voice Player is a Flutter package designed to provide a seamless and customizable voice message playback experience within your chat applications. It offers intuitive playback controls, a responsive seek bar, speed adjustment, and optional noise visualization to enhance user interaction.

## 📦 Features

- **Play/Pause Controls:** Easily integrate play and pause functionality for voice messages.
- **Seek Bar:** Intuitive seek bar to navigate through the audio with real-time progress updates.
- **Speed Control:** Adjust playback speed with customizable speed options.
- **Noise Visualization:** Optional noise-based visualization to represent audio playback dynamically.
- **Customizable UI:** Tailor the player’s appearance to match your app’s design with customizable icons and colors.
- **Cross-Platform Support:** Works seamlessly on both Android and iOS platforms.

## 🔧 Installation

Add `v_chat_voice_player` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  v_chat_voice_player: ^1.0.0
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

### 4. Adjust Noise Visualization Width

Control the width of the noise visualization relative to the screen width.

```dart
VVoiceMessageView(
  controller: _voiceController,
  noiseWidthPercentage: 60.0, // 60% of screen width
  // Other parameters...
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
  Color activeSliderColor = Colors.red,
  Color? notActiveSliderColor,
  Color? backgroundColor,
  TextStyle counterTextStyle = const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
  Widget? playIcon,
  Widget? pauseIcon,
  Widget? errorIcon,
  Widget Function(String speed)? speedBuilder,
  double noiseWidthPercentage = 50.5,
})
```

- **controller:** Instance of `VVoiceMessageController`.
- **activeSliderColor:** Color of the active part of the seek bar.
- **notActiveSliderColor:** Color of the inactive part of the seek bar.
- **backgroundColor:** Background color of the player container.
- **counterTextStyle:** Text style for the remaining time counter.
- **playIcon:** Custom widget for the play icon.
- **pauseIcon:** Custom widget for the pause icon.
- **errorIcon:** Custom widget for the error icon.
- **speedBuilder:** Function to build a custom speed display widget.
- **noiseWidthPercentage:** Width of the noise visualization as a percentage of screen width.

## 🖼️ Example

Here's a complete example integrating the `VChatVoicePlayer` into a Flutter application:

```dart
import 'package:flutter/material.dart';
import 'package:v_chat_voice_player/v_chat_voice_player.dart';
import 'package:v_platform/v_platform.dart';

void main() {
  runApp
    (
        MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: Text('Voice Message Player')),
            body: VoiceMessageExample(),
        ),
        ),
    );
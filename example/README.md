# V Chat Voice Player Example

This example demonstrates how to use the **V Chat Voice Player** package in a Flutter application. It showcases various customization options and configuration approaches available in the package.

## 🚀 Features Demonstrated

### ✨ Multiple Voice Player Styles

- **Default Configuration**: Simple, out-of-the-box voice player
- **Animated Waveform**: Voice player with random height visualizer
- **Highly Customized**: Extensively customized player with purple theme
- **User Avatar Integration**: Voice player with user avatar and mic icon
- **Traditional Slider**: Classic slider-based voice player
- **Compact Player**: Minimalist voice player design

### 🎨 Customization Examples

- **Configuration Classes**: Demonstrates the new config-based approach
- **Color Theming**: Various color schemes and styling options
- **Visualizer Options**: Different waveform visualization patterns
- **Button Styling**: Custom play/pause button configurations
- **Container Styling**: Background, padding, and border customizations
- **Text Styling**: Custom typography and text themes

## 📱 Running the Example

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK 2.17.0 or higher
- A device or emulator to run the app

### Installation & Setup

1. **Clone or download** the v_chat_voice_player package
2. **Navigate** to the example directory:
   ```bash
   cd example
   ```
3. **Install dependencies**:
   ```bash
   flutter pub get
   ```
4. **Run the example**:
   ```bash
   flutter run
   ```

### Project Structure

```
example/
├── lib/
│   ├── app/
│   │   ├── modules/
│   │   │   └── home/
│   │   │       ├── controllers/
│   │   │       │   └── home_controller.dart
│   │   │       └── views/
│   │   │           ├── home_view.dart       # Main demo page
│   │   │           ├── voice_player.dart    # Voice player widget
│   │   │           └── widgets/
│   │   │               └── bubble.dart      # Chat bubble UI
│   │   └── routes/
│   │       ├── app_pages.dart
│   │       └── app_routes.dart
│   └── main.dart                            # App entry point
├── pubspec.yaml                             # Dependencies
└── README.md                                # This file
```

## 🎯 Key Example Features

### 1. Basic Implementation

The example shows how to create a simple voice message player:

```dart
VVoiceMessageController(
  id: 'voice_001',
  audioSrc: VPlatformFile.fromUrl(
    networkUrl: 'https://example.com/audio.mp3',
  ),
  onComplete: (id) => print('Completed: $id'),
  onPlaying: (id) => print('Playing: $id'),
  onPause: (id) => print('Paused: $id'),
)
```

### 2. Configuration Classes

Demonstrates the new organized approach using configuration classes:

```dart
VVoiceMessageView(
  controller: controller,
  colorConfig: const VoiceColorConfig(
    activeSliderColor: Colors.blue,
    notActiveSliderColor: Colors.grey,
  ),
  containerConfig: VoiceContainerConfig(
    backgroundColor: Colors.blue.shade50,
    borderRadius: 15,
  ),
  // ... other configurations
)
```

### 3. Advanced Customization

Shows extensive customization possibilities:

- Custom visualizer patterns
- User avatar integration
- Multiple button styles
- Different container themes
- Speed control customization

### 4. Audio Sources

Examples of different audio source types:

- **Network URLs**: Remote audio files
- **Local Files**: Cached or local audio files
- **Byte Arrays**: In-memory audio data

## 🔧 Configuration Examples

The example includes several pre-configured voice players:

| Style                 | Description                           | Key Features                         |
| --------------------- | ------------------------------------- | ------------------------------------ |
| **Default**           | Simple, minimal configuration         | Basic functionality, default styling |
| **Random Visualizer** | Animated waveform with random heights | Unique patterns per message          |
| **Highly Customized** | Purple-themed, extensively styled     | Custom colors, sizes, animations     |
| **With Avatar**       | User profile integration              | Avatar display, listen status        |
| **Traditional**       | Classic slider approach               | No visualizer, simple progress bar   |
| **Compact**           | Minimalist design                     | Smaller size, clean appearance       |

## 📖 Learning Resources

### Official Documentation

- [Package Documentation](https://pub.dev/packages/v_chat_voice_player)
- [V Chat SDK Docs](https://v-chat-sdk.github.io/vchat-v2-docs/docs/intro)
- [GitHub Repository](https://github.com/v-chat-sdk/v_chat_voice_player)

### Key Concepts

- **ValueNotifier Pattern**: Efficient state management
- **Configuration Classes**: Organized parameter structure
- **Audio Source Handling**: Multiple input types
- **Cross-Platform Support**: Works on all Flutter platforms

## 🤝 Contributing

If you find issues or have suggestions for improving this example:

1. **Report Issues**: [GitHub Issues](https://github.com/v-chat-sdk/v_chat_voice_player/issues)
2. **Submit PRs**: Contributions welcome for example improvements
3. **Documentation**: Help improve examples and documentation

## 📄 License

This example is part of the V Chat Voice Player package and is licensed under the MIT License.

---

**Happy Coding!** 🎉

For more information, visit the [V Chat SDK documentation](https://v-chat-sdk.github.io/vchat-v2-docs/docs/intro).

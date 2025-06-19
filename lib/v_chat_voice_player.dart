// Copyright 2023, the hatemragab project author.
// All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

/// V Chat Voice Player - A powerful and customizable voice message player for Flutter
///
/// This package provides:
/// - Efficient state management using ValueNotifier best practices
/// - Support for multiple audio sources (files, URLs, bytes)
/// - Cross-platform compatibility (including VLC for iOS WebM)
/// - Customizable UI components
/// - Performance optimized with proper resource management
library v_chat_voice_player;

// Core Components
export 'src/voice_message_controller.dart';
export 'src/voice_message_view.dart';
export 'src/voice_state_model.dart';
export 'src/voice_message_config.dart';

// Helpers
export 'src/helpers/play_status.dart';
export 'src/helpers/utils.dart';
export 'src/helpers/v_voice_language.dart';
export 'src/helpers/voice_state_manager.dart';
export 'src/helpers/voice_ui_randomizer.dart';

// Widgets
export 'src/widgets/noises.dart';
export 'src/widgets/voice_visualizer.dart';

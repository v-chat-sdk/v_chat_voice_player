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
/// - Modular architecture with separate service classes for better maintainability
library v_chat_voice_player;

// Core Components
export 'src/voice_message_controller.dart';
export 'src/voice_message_view.dart';
export 'src/voice_state_model.dart';
export 'src/voice_message_config.dart';

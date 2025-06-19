// Copyright 2023, the hatemragab project author.
// All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:v_chat_voice_player/v_chat_voice_player.dart';
import 'package:v_platform/v_platform.dart';

class VoicePlayer extends StatefulWidget {
  final String url;
  final Duration duration;

  const VoicePlayer({required this.url, required this.duration, super.key});

  @override
  VoicePlayerState createState() => VoicePlayerState();
}

class VoicePlayerState extends State<VoicePlayer> {
  bool isLoading = true;
  late String path;
  late final VVoiceMessageController messageController;
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    return PopScope(
      onPopInvoked: (bool value) {
        messageController.dispose();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  if (isLoading)
                    const CircularProgressIndicator.adaptive()
                  else
                    Column(
                      children: [
                        // Default Voice Visualizer
                        Container(
                          margin: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Default Voice Visualizer:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              VVoiceMessageView(
                                controller: messageController,
                                visualizerConfig: const VoiceVisualizerConfig(
                                  useRandomHeights: true,
                                  showVisualizer: true,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Highly Customized Voice Visualizer
                        Container(
                          margin: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Highly Customized Voice Visualizer:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              VVoiceMessageView(
                                controller: messageController,
                                // Visualizer customization
                                visualizerConfig: const VoiceVisualizerConfig(
                                  useRandomHeights: false,
                                  showVisualizer: true,
                                  height: 50,
                                  barCount: 40,
                                  barSpacing: 3.0,
                                  minBarHeight: 6.0,
                                  enableBarAnimations: true,
                                ),
                                // Colors
                                colorConfig: VoiceColorConfig(
                                  activeSliderColor: Colors.deepPurple,
                                  notActiveSliderColor: Colors.purple.shade100,
                                ),
                                // Container styling
                                containerConfig: VoiceContainerConfig(
                                  backgroundColor: Colors.purple.shade50,
                                  borderRadius: 25,
                                  containerPadding: const EdgeInsets.all(16),
                                ),
                                // Button customization
                                buttonConfig: const VoiceButtonConfig(
                                  buttonColor: Colors.deepPurple,
                                  buttonIconColor: Colors.white,
                                  buttonSize: 45,
                                ),
                                // Speed button customization
                                speedConfig: const VoiceSpeedConfig(
                                  speedButtonColor: Colors.purple,
                                  speedButtonTextColor: Colors.white,
                                  speedButtonBorderRadius: 10,
                                  speedButtonPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Voice Player with User Avatar and Mic Icon
                        Container(
                          margin: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'With User Avatar & Mic Icon:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              VVoiceMessageView(
                                controller: messageController,
                                visualizerConfig: const VoiceVisualizerConfig(
                                  showVisualizer: true,
                                ),
                                colorConfig: const VoiceColorConfig(
                                  activeSliderColor: Colors.blue,
                                ),
                                containerConfig: VoiceContainerConfig(
                                  backgroundColor: Colors.blue.shade50,
                                  borderRadius: 20,
                                ),
                                buttonConfig: const VoiceButtonConfig(
                                  useSimplePlayIcon: true,
                                  simpleIconSize:
                                      39.0, // Larger icon size for better visibility
                                ),
                                avatarConfig: VoiceAvatarConfig(
                                  userAvatar: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.blueAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  avatarSize: 45,
                                  micIconSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Traditional Slider Version
                        Container(
                          margin: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Traditional Slider:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              VVoiceMessageView(
                                controller: messageController,
                                visualizerConfig: const VoiceVisualizerConfig(
                                  showVisualizer: false,
                                ),
                                colorConfig: const VoiceColorConfig(
                                  activeSliderColor: Colors.green,
                                ),
                                containerConfig: VoiceContainerConfig(
                                  backgroundColor: Colors.green.shade50,
                                  borderRadius: 15,
                                ),
                                buttonConfig: const VoiceButtonConfig(
                                  buttonColor: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future download() async {
    try {
      final file = await DefaultCacheManager().getSingleFile(
        widget.url,
      );
      path = file.path;
    } catch (err) {
      //
      rethrow;
    }
  }

  void init() async {
    await download();
    messageController = VVoiceMessageController(
      audioSrc: VPlatformFile.fromPath(fileLocalPath: path),
      maxDuration: widget.duration,
      id: "1",
      onPlaying: (id) {},
      onComplete: (id) {
        if (kDebugMode) {
          print("On onComplete called ! $id");
        }
      },
      onPause: (id) {},
    );
    setState(() {
      isLoading = false;
    });
  }
}

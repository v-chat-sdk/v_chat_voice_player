// Copyright 2023, the hatemragab project author.
// All rights reserved. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

import 'package:example_2/app/modules/home/views/voice_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:v_chat_voice_player/v_chat_voice_player.dart';
import 'package:v_platform/v_platform.dart';

import '../controllers/home_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  final controller = Get.find<HomeController>();
  final voicesList = <VoiceMessageModel>[];
  final url = "https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.mp3";

  @override
  void initState() {
    super.initState();
    voicesList.addAll(List.generate(
      100,
      (i) => VoiceMessageModel(
        id: "$i",
        dataSource: VPlatformFile.fromUrl(
          networkUrl: url,
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Example"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(30),
              reverse: true,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, i) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: MediaQuery.of(context).size.width *
                        0.25, // 1/4 of screen width
                    child: SwipeTo(
                      key: UniqueKey(),
                      iconOnLeftSwipe: Icons.arrow_forward,
                      iconOnRightSwipe: Icons.arrow_back,
                      onLeftSwipe: (details) {
                        // Handle left swipe action
                        print(
                            'Left swipe on voice message ${voicesList[i].id}');
                      },
                      onRightSwipe: (details) {
                        // Handle right swipe action
                        print(
                            'Right swipe on voice message ${voicesList[i].id}');
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: VVoiceMessageView(
                          controller:
                              controller.getVoiceController(voicesList[i]),
                          key: ValueKey(voicesList[i].id),
                          colorConfig: const VoiceColorConfig(
                            activeSliderColor: Colors.red,
                            notActiveSliderColor: Colors.grey,
                          ),
                          visualizerConfig: const VoiceVisualizerConfig(
                            useRandomHeights: true,
                            enableBarAnimations: false,
                          ),
                          containerConfig: const VoiceContainerConfig(
                            borderRadius: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: voicesList.length,
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            elevation: 0,
            heroTag: "cc",
            onPressed: () {
              voicesList.insert(
                0,
                VoiceMessageModel(
                  id: "${DateTime.now().millisecond}",
                  dataSource: VPlatformFile.fromUrl(
                    networkUrl:
                        "https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.mp3",
                  ),
                ),
              );
              setState(() {});
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            elevation: 0,
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) {
                  return const VoicePlayer(
                    duration: Duration(seconds: 7, minutes: 3),
                    url:
                        "https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.mp3",
                  );
                },
              );
            },
            child: const Icon(Icons.music_note),
          ),
        ],
      ),
    );
  }
}

class VoiceMessageModel {
  final String id;
  final VPlatformFile dataSource;
  final int? maxDuration;

  VoiceMessageModel({
    required this.id,
    required this.dataSource,
    this.maxDuration,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceMessageModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
// void onComplete(String id) {
//   final cIndex = list.indexWhere((e) => e.id == id);
//   if (cIndex == -1) {
//     return;
//   }
//   if (cIndex == list.length - 1) {
//     return;
//   }
//   if (list.length - 1 != cIndex) {
//     list[cIndex + 1].controller.initAndPlay();
//   }
// }
//
// void onPlaying(String id) {
//   for (var e in list) {
//     if (e.id != id) {
//       if (e.controller.isPlaying) {
//         e.controller.pausePlaying();
//       }
//     }
//   }
// }

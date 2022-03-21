import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DisplayVideoScreen extends StatelessWidget {
  final VideoPlayerController videoPath;

  const DisplayVideoScreen({Key? key, required this.videoPath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Display the Videos')),
        body: VideoPlayer(videoPath));
  }
}

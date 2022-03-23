import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DisplayVideoScreen extends StatelessWidget {
  final VideoPlayerController videoPath;

  const DisplayVideoScreen({Key? key, required this.videoPath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: const Text('Display the Videos')),
        body: Hero(tag: 'galley', child: VideoPlayer(videoPath)));
  }
}

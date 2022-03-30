import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DisplayVideoScreen extends StatefulWidget {
  final VideoPlayerController? videoCtrl;

  const DisplayVideoScreen({Key? key, this.videoCtrl}) : super(key: key);

  @override
  State<DisplayVideoScreen> createState() => _DisplayVideoScreenState();
}

class _DisplayVideoScreenState extends State<DisplayVideoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: const Text('Display the Videos'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.save_alt),
            )
          ],
        ),
        floatingActionButton: Center(
          child: FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.white,
            onPressed: () {
              setState(() {
                if (widget.videoCtrl!.value.isPlaying) {
                  widget.videoCtrl!.pause();
                } else {
                  widget.videoCtrl!.play();
                }
              });
            },
            child: Icon(
              widget.videoCtrl!.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              color: Colors.black,
            ),
          ),
        ),
        body: Hero(tag: 'galley', child: VideoPlayer(widget.videoCtrl!)));
  }
}

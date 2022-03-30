import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../views/display_image.dart';
import '../../views/display_video.dart';

class Thumbnail extends StatefulWidget {
  const Thumbnail({
    Key? key,
    required this.file,
  }) : super(key: key);

  final XFile file;

  @override
  State<Thumbnail> createState() => _ThumbnailState();
}

class _ThumbnailState extends State<Thumbnail> {
  VideoPlayerController? videoPlayerController;
  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Thumbnail oldWidget) {
    if (oldWidget.file.path != widget.file.path) {
      videoPlayerController?.dispose();
      videoPlayerController = null;
      _init();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    super.dispose();
  }

  void _init() {
    if (widget.file.path.contains('.mp4')) {
      videoPlayerController =
          VideoPlayerController.file(File(widget.file.path));
    }
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      videoPlayerController?.initialize().whenComplete(
        () async {
          await videoPlayerController?.setLooping(true);
          if (mounted) {
            setState(() {
              videoPlayerController?.play();
            });
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'galley',
      child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => videoPlayerController == null
                    ? DisplayPictureScreen(
                        imagePath: widget.file.path,
                      )
                    : DisplayVideoScreen(
                        videoCtrl: videoPlayerController,
                      ),
              ),
            );
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(color: Colors.white, width: 2),
              image: videoPlayerController == null
                  ? DecorationImage(
                      image: FileImage(File(widget.file.path)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: videoPlayerController != null
                ? CircleAvatar(
                    radius: 30,
                    child: ClipOval(child: VideoPlayer(videoPlayerController!)),
                  )
                : null,
          )),
    );
  }
}

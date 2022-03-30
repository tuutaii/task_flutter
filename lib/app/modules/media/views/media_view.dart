import 'package:flutter/material.dart';

import '../packages/media_picker.dart';

class MediaView extends StatefulWidget {
  const MediaView({
    Key? key,
  }) : super(key: key);

  @override
  MediaViewState createState() => MediaViewState();
}

class MediaViewState extends State<MediaView> {
  List<dynamic>? mediaPaths;

  void _getImages() async {
    mediaPaths = await MediaPicker.pickImages(
      quantity: 7,
      maxWidth: 1024,
      maxHeight: 1024,
      quality: 85,
    );

    if (!mounted) return;
    setState(() {});
  }

  void _getVideos() async {
    mediaPaths = await MediaPicker.pickVideos(quantity: 7);

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextButton(
                child: const Text('Get images'),
                onPressed: _getImages,
              ),
              TextButton(
                child: const Text('Get videos'),
                onPressed: _getVideos,
              ),
              if (mediaPaths != null) Text(mediaPaths!.join('\n'))
            ],
          ),
        ),
      ),
    );
  }
}

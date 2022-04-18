import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';

import '../packages/tamp/media_picker.dart';

class MediaView extends StatefulWidget {
  const MediaView({
    Key? key,
  }) : super(key: key);

  @override
  MediaViewState createState() => MediaViewState();
}

class MediaViewState extends State<MediaView> {
  bool isReview = false, isMulti = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Review"),
                Switch(
                  value: isReview,
                  onChanged: (newValue) {
                    setState(() => isReview = newValue);
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Multi Mode"),
                Switch(
                  value: isMulti,
                  onChanged: (newValue) {
                    setState(() => isMulti = newValue);
                  },
                ),
              ],
            ),
            MaterialButton(
              child: const Text(
                'All Image Picker',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                picker(RequestType.image);
              },
            ),
            MaterialButton(
              child: const Text(
                'All Video Picker',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                picker(RequestType.video);
              },
            ),
          ],
        ),
      ),
    );
  }

  void picker(RequestType type) {
    PackageMediaPicker.picker(context,
        isMulti: isMulti,
        type: type,
        isReview: isReview,
        maxDuration: const Duration(minutes: 1));
  }
}

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({Key? key, required this.entity}) : super(key: key);
  final AssetEntity entity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child: Center(
          child: AssetEntityImage(
            entity,
            isOriginal: true,
            filterQuality: FilterQuality.none,
            fit: BoxFit.fill,
          ),
        )));
  }
}

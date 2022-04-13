import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({Key? key, required this.entity}) : super(key: key);
  final AssetEntity entity;

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              minScale: 0.2,
              child: Center(
                child: AssetEntityImage(
                  widget.entity,
                  isOriginal: true,
                  filterQuality: FilterQuality.none,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Positioned(
              top: 5,
              left: 10,
              child: GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        )));
  }
}

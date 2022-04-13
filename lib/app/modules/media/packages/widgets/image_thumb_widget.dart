import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageItemWidget extends StatefulWidget {
  const ImageItemWidget({
    Key? key,
    required this.entity,
    required this.thumbnailOption,
    required this.isMulti,
    required this.isLimit,
    this.onTap,
  }) : super(key: key);

  final AssetEntity entity;
  final ThumbnailOption thumbnailOption;
  final GestureTapCallback? onTap;
  final bool isMulti;
  final int isLimit;

  @override
  State<ImageItemWidget> createState() => _ImageItemWidgetState();
}

class _ImageItemWidgetState extends State<ImageItemWidget> {
  var isSelected = false;
  Widget buildContent(BuildContext context) {
    if (widget.entity.type == AssetType.audio) {
      return const Center(
        child: Icon(Icons.audiotrack, size: 30),
      );
    }
    return _buildImageWidget(widget.entity, widget.thumbnailOption);
  }

  Widget _buildImageWidget(AssetEntity entity, ThumbnailOption option) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AssetEntityImage(
          entity,
          isOriginal: false,
          thumbnailSize: option.size,
          thumbnailFormat: option.format,
          fit: BoxFit.cover,
        ),
        widget.entity.type == AssetType.video
            ? const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              isSelected = !isSelected;
            });
            widget.onTap?.call();
          },
          child: buildContent(context),
        ),
        if (isSelected && widget.isMulti && widget.isLimit < 10)
          const Positioned(
            top: 5,
            right: 5,
            child: Icon(
              Icons.check_circle,
              color: Colors.blue,
            ),
          )
      ],
    );
  }
}

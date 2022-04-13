import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:math' as math;

class GalleryItemWidget extends StatefulWidget {
  const GalleryItemWidget({
    Key? key,
    required this.path,
    this.onTap,
    this.isSwitchPath = false,
  }) : super(key: key);

  final AssetPathEntity path;
  final VoidCallback? onTap;
  final bool isSwitchPath;

  @override
  State<GalleryItemWidget> createState() => _GalleryItemWidgetState();
}

class _GalleryItemWidgetState extends State<GalleryItemWidget> {
  Widget buildGalleryItemWidget(AssetPathEntity item, BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 32,
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
        padding: const EdgeInsets.only(left: 12.0, right: 6.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.grey[200],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Text(
                widget.path.name,
                style: const TextStyle(fontSize: 14, color: Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Transform.rotate(
                      angle: math.pi,
                      alignment: Alignment.center,
                      child: widget.isSwitchPath
                          ? const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                            )
                          : const Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.white,
                            ))),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildGalleryItemWidget(widget.path, context);
  }
}

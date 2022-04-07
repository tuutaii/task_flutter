import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryItemWidget extends StatelessWidget {
  const GalleryItemWidget({
    Key? key,
    required this.path,
  }) : super(key: key);

  final AssetPathEntity path;

  Widget buildGalleryItemWidget(AssetPathEntity item, BuildContext context) {
    return GestureDetector(
      child: ListTile(
        title: Text(item.name),
        subtitle: Text('count : ${item.assetCount}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildGalleryItemWidget(path, context);
  }
}

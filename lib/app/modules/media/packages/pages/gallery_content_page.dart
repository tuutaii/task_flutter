import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../widgets/gallery_item.dart';

class GalleryContentListPage extends StatefulWidget {
  GalleryContentListPage({
    Key? key,
  }) : super(key: key);

  final List<AssetPathEntity> pathList = <AssetPathEntity>[];

  @override
  _GalleryContentListPageState createState() => _GalleryContentListPageState();
}

class _GalleryContentListPageState extends State<GalleryContentListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery list'),
      ),
      body: Scrollbar(
        child: ListView.builder(
          itemBuilder: _buildItem,
          itemCount: widget.pathList.length,
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final AssetPathEntity item = widget.pathList[index];
    return GalleryItemWidget(
      path: item,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class SelectedImageList extends StatelessWidget {
  const SelectedImageList({
    Key? key,
    required this.itemsSelected,
  }) : super(key: key);
  final List<AssetEntity> itemsSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('List Selected Image'),
        centerTitle: true,
      ),
      body: SizedBox(
        child: GridView.builder(
          cacheExtent: 16 / 9,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            crossAxisCount: 4,
          ),
          itemCount: itemsSelected.length,
          itemBuilder: (BuildContext context, int index) {
            final AssetEntity entity = itemsSelected[index];
            return AssetEntityImage(
              entity,
              key: UniqueKey(),
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }
}

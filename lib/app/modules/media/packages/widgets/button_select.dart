import 'package:basesource/app/modules/media/packages/pages/list_selected_image_page.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class SelectButton extends StatelessWidget {
  const SelectButton({
    Key? key,
    required this.items,
    required this.isMulti,
    required this.limit,
  }) : super(key: key);

  final List<AssetEntity> items;
  final bool isMulti;
  final int limit;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: items.isNotEmpty ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: MaterialButton(
        height: 32,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        color: Colors.blue,
        child: Text(
          isMulti ? 'Select (${items.length}/$limit)' : 'Select',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          items.isNotEmpty
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SelectedImageList(
                            itemsSelected: items,
                          )),
                )
              : {};
        },
      ),
    );
  }
}

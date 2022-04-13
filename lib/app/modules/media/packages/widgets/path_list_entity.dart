import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class PathListEntity extends StatefulWidget {
  PathListEntity({
    Key? key,
    required this.pathEntityList,
    this.currentPath,
    this.changePath,
  }) : super(key: key);
  var pathEntityList = <AssetPathEntity?, Uint8List?>{};
  AssetPathEntity? currentPath;
  final Function(AssetPathEntity)? changePath;

  @override
  State<PathListEntity> createState() => _PathListEntityState();
}

class _PathListEntityState extends State<PathListEntity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.only(top: 1.0),
        itemCount: widget.pathEntityList.length,
        itemBuilder: (BuildContext _, int index) {
          return PathEntityWidget(
            onTap: () {
              setState(() {
                widget.currentPath =
                    widget.pathEntityList.keys.elementAt(index);
                widget.changePath!(widget.currentPath!);
              });
            },
            path: widget.pathEntityList.keys.elementAt(index)!,
          );
        },
        separatorBuilder: (_, int __) {
          return const Divider(thickness: 1);
        },
      ),
    );
  }
}

class PathEntityWidget extends StatelessWidget {
  PathEntityWidget({
    Key? key,
    required this.path,
    this.type = RequestType.video,
    this.onTap,
    this.currentPath,
  }) : super(key: key);
  final AssetPathEntity path;
  final RequestType type;
  final pathEntityList = <AssetPathEntity?, Uint8List?>{};
  final VoidCallback? onTap;
  final AssetPathEntity? currentPath;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        splashFactory: InkSplash.splashFactory,
        child: SizedBox(
          height: 52.0,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 20.0),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Text(
                            path.name,
                            style: const TextStyle(fontSize: 15.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Text(
                        '(${path.assetCount})',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              if (currentPath == path)
                const AspectRatio(
                  aspectRatio: 1.0,
                  child: Icon(
                    Icons.check,
                    size: 26.0,
                    color: Colors.blue,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

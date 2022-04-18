part of media;

class PathListEntity extends StatefulWidget {
  const PathListEntity({
    Key? key,
  }) : super(key: key);

  @override
  State<PathListEntity> createState() => _PathListEntityState();
}

class _PathListEntityState extends State<PathListEntity> {
  @override
  Widget build(BuildContext context) {
    final height =
        context.height - context.padding.bottom - context.padding.top;
    return Selector<MediaProvider, bool>(
        selector: (BuildContext _, MediaProvider e) => e.isSwitchingPath,
        builder: (context, bool isSwitchingPath, child) {
          return AnimatedPositioned(
            // hide backdrop
            duration: switchingPathDuration,
            curve: switchingPathCurve,
            top: !isSwitchingPath ? height : 1.0,
            child: AnimatedOpacity(
              duration: switchingPathDuration,
              curve: switchingPathCurve,
              opacity: isSwitchingPath ? 1.0 : 0.0,
              child: Container(
                width: context.width,
                height: height,
                decoration: BoxDecoration(
                  color: context.colorScheme.background,
                ),
                child:
                    Selector<MediaProvider, Map<AssetPathEntity?, Uint8List?>>(
                  selector: (BuildContext _, MediaProvider provider) =>
                      provider.pathEntityList,
                  builder: (_, pathEntityList, child) {
                    return ListView.separated(
                      padding: const EdgeInsets.only(top: 1.0),
                      itemCount: pathEntityList.length,
                      itemBuilder: (BuildContext _, int index) {
                        return PathEntityWidget(
                          path: pathEntityList.keys.elementAt(index)!,
                        );
                      },
                      separatorBuilder: (_, int __) {
                        return const Divider(thickness: 1);
                      },
                    );
                  },
                ),
              ),
            ),
          );
        });
  }
}

class PathEntityWidget extends StatelessWidget {
  const PathEntityWidget({
    Key? key,
    required this.path,
  }) : super(key: key);
  final AssetPathEntity path;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MediaProvider>(context, listen: false);
    Widget builder() {
      if (provider.type == RequestType.audio) {
        return ColoredBox(
          color: Colors.white.withOpacity(0.12),
          child: const Center(
            child: Icon(Icons.audiotrack_rounded),
          ),
        );
      }

      final thumbData = provider.pathEntityList[path];
      if (thumbData != null) {
        return Image.memory(thumbData, fit: BoxFit.cover);
      } else {
        return ColoredBox(
          color: context.colorScheme.primary.withOpacity(0.12),
        );
      }
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => provider.getAssetFormEntity(path),
        splashFactory: InkSplash.splashFactory,
        child: SizedBox(
          height: 52.0,
          child: Row(
            children: <Widget>[
              RepaintBoundary(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: builder(),
                ),
              ),
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
              if (provider.currentPath == path)
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

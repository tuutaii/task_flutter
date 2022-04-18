part of media;

class GalleryTitleWidget extends StatelessWidget {
  const GalleryTitleWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MediaProvider>(context, listen: false);
    return GestureDetector(
      onTap: provider.switchingPath,
      child: Container(
        height: 32,
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
        padding: const EdgeInsets.only(left: 12.0, right: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Selector<MediaProvider, AssetPathEntity?>(
                selector: (_, p) => p.currentPath,
                builder: (_, currentPath, __) {
                  return Text(
                    currentPath?.name ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Selector<MediaProvider, bool>(
                selector: (_, p) => p.isSwitchingPath,
                builder: (_, bool isSwitchingPath, __) {
                  return Transform.rotate(
                    angle: isSwitchingPath ? math.pi : 0.0,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

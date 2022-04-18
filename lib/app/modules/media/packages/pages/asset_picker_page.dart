part of media;

Duration get switchingPathDuration => kThemeAnimationDuration * 1.5;
Curve get switchingPathCurve => Curves.easeInBack;

class AssetPicker extends StatelessWidget {
  const AssetPicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _AppBarCustom(),
      body: SafeArea(
        child: Selector<MediaProvider, bool>(
          selector: (_, provider) => provider.hasAssetsToDisplay,
          builder: (_, bool hasAssetsToDisplay, child) {
            return hasAssetsToDisplay
                ? Stack(
                    children: const [
                      ListBuilder(),
                      BackDropList(),
                      PathListEntity(),
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  );
          },
        ),
      ),
    );
  }
}

class ListBuilder extends StatelessWidget {
  const ListBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MediaProvider>(context, listen: false);
    return Selector<MediaProvider, List<AssetEntity>>(
      selector: (_, MediaProvider e) => e.assets,
      builder: (_, assets, child) {
        return GridView.builder(
            controller: provider.scroll,
            cacheExtent: 16 / 9,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.gridCount,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemCount: assets.length,
            itemBuilder: (_, int index) {
              final asset = provider.assets[index];
              return _ItemBuilder(asset: asset, index: index);
            });
      },
    );
  }
}

class _ItemBuilder extends StatelessWidget {
  const _ItemBuilder({
    Key? key,
    required this.asset,
    required this.index,
  }) : super(key: key);
  final AssetEntity asset;
  final int index;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MediaProvider>(context, listen: false);
    final size = context.width / context.gridCount;
    final scale = math.min(1, size / 100);
    final _size = ThumbnailSize(size ~/ scale, size ~/ scale);
    return Stack(
      children: [
        Positioned.fill(
          child: AssetEntityImage(
            asset,
            thumbnailSize: _size,
            isOriginal: false,
            fit: BoxFit.cover,
          ),
        ),
        Selector<MediaProvider, List<AssetEntity>>(
          selector: (_, MediaProvider e) => e.selects,
          builder: (_, selects, child) {
            return SelectedBackdrop(
              selected: selects.contains(asset),
              onReview: () {
                if (provider.isPreview) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MediaBuilderPreview(
                        assets: context.watch<MediaProvider>().assets,
                        index: index,
                      ),
                    ),
                  );
                } else {
                  provider.onSelectItem(asset);
                }
              },
            );
          },
        ),
        Selector<MediaProvider, List<AssetEntity>>(
          selector: (_, MediaProvider e) => e.selects,
          builder: (_, selects, child) {
            return SelectIndicator(
              selected: selects.contains(asset),
              onTap: () {
                provider.onSelectItem(asset);
              },
              isMulti: provider.isMulti,
              gridCount: context.gridCount,
              selectText: (selects.indexOf(asset) + 1).toString(),
            );
          },
        ),
      ],
    );
  }
}

class _AppBarCustom extends StatelessWidget with PreferredSizeWidget {
  const _AppBarCustom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MediaProvider>(context, listen: false);
    return AppBar(
      elevation: 0.2,
      leading: CloseButton(color: context.colorScheme.onBackground),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: const GalleryTitleWidget(),
      centerTitle: true,
      actions: <Widget>[
        Center(
          child: Selector<MediaProvider, List<AssetEntity>>(
            selector: (_, MediaProvider e) => e.selects,
            builder: (_, List<AssetEntity> selects, __) {
              return SelectButton(
                items: selects,
                isMulti: provider.isMulti,
                limit: provider.limit,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  ui.Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

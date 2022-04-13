part of media;

const _pageSize = 80;

class MediaProvider extends ChangeNotifier {
  MediaProvider(
      {this.limit = 10,
      this.type = RequestType.common,
      required this.routeDuration,
      this.filterOptionGroup,
      this.isMulti = true,
      this.isPreview = true,
      this.maxDuration = const Duration(hours: 1),
      this.minDuration = Duration.zero}) {
    Future<void>.delayed(routeDuration).then((_) {
      getAssetPathList().whenComplete(() {
        getAssetList();
      });
    });
    scroll.addListener(loadMoreAsset);
  }
  final FilterOptionGroup? filterOptionGroup;
  final int limit;
  final RequestType type;
  final Duration routeDuration, minDuration, maxDuration;
  final bool isMulti, isPreview;
  final pathEntityList = <AssetPathEntity?, Uint8List?>{};
  final scroll = ScrollController();

  var selects = ValueNotifier(<AssetEntity>[]);
  var isLoadingMore = ValueNotifier(false);

  List<AssetEntity> assets = <AssetEntity>[];
  List<AssetPathEntity> list = <AssetPathEntity>[];
  List<AssetEntity>? _entities;

  AssetPathEntity? currentPath;
  bool isSwitchingPath = false, isAssetsEmpty = false;
  int totalEntitiesCount = 0, sizePerPage = 50, page = 0;

  int get currentPage => (math.max(1, assets.length) / _pageSize).ceil();
  double get position => scroll.position.pixels;
  double get maxScroll => scroll.position.maxScrollExtent;

  void loadMoreAsset() {
    isLoadingMore.value = true;
    currentPath!
        .getAssetListPaged(
      page: page + 1,
      size: sizePerPage,
    )
        .then((value) {
      _entities!.addAll(value);
      page++;
      notifyListeners();
    }).whenComplete(() {
      isLoadingMore.value = false;
    });
  }

  Future<void> getAssetPathList() async {
    FilterOptionGroup option = customOption();
    if (filterOptionGroup != null) {
      option.merge(filterOptionGroup!);
    }
    final _list = await PhotoManager.getAssetPathList(
      filterOption: option,
      type: type,
    );
    _list.sort(
      (path1, path2) {
        if (path1.isAll) {
          return -1;
        }
        if (path2.isAll) {
          return 1;
        }
        return path1.name.toUpperCase().compareTo(path2.name.toUpperCase());
      },
    );
    for (var pathEntities in _list) {
      pathEntityList[pathEntities] = null;
      if (type != RequestType.audio) {
        getFirstThumbFromPathEntity(pathEntities).then((Uint8List? data) {
          pathEntityList[pathEntities] = data;
        });
      }
    }
    if (pathEntityList.isEmpty) {
      isAssetsEmpty = true;
      notifyListeners();
    }
  }

  Future<void> getAssetList() async {
    if (pathEntityList.isNotEmpty) {
      await getAssetFormEntity(pathEntityList.keys.elementAt(0)!);
    } else {
      assets = [];
      isAssetsEmpty = true;
    }
  }

  Future<void> getAssetFormEntity(AssetPathEntity pathEntity) async {
    isSwitchingPath = false;
    selects.value = [];
    if (currentPath == pathEntity) {
      return;
    }
    currentPath = pathEntity;
    totalEntitiesCount = pathEntity.assetCount;
    final items = await pathEntity.getAssetListPaged(
      page: 0,
      size: _pageSize,
    );
    assets = items;
    notifyListeners();
  }

  FilterOptionGroup customOption() {
    final FilterOption option = FilterOption(
      sizeConstraint: const SizeConstraint(
        ignoreSize: true,
      ),
      durationConstraint: DurationConstraint(
        min: minDuration,
        max: maxDuration,
      ),
      needTitle: true,
    );
    return FilterOptionGroup()
      ..setOption(AssetType.image, option)
      ..setOption(AssetType.video, option)
      ..setOption(AssetType.audio, option);
  }

  Future<Uint8List?> getFirstThumbFromPathEntity(pathEntity) async {
    final AssetEntity asset = (await pathEntity.getAssetListRange(
      start: 0,
      end: 1,
    ))
        .elementAt(0);
    if (asset.type == AssetType.image || asset.type == AssetType.video) {
      final assetData =
          await asset.thumbnailDataWithSize(const ThumbnailSize.square(80));
      return assetData;
    } else {
      return null;
    }
  }

  void onSelectItem(AssetEntity asset) {
    final _selected = selects.value.toList();
    if (isMulti) {
      if (_selected.length < limit) {
        if (!_selected.contains(asset)) {
          _selected.add(asset);
        } else {
          _selected.remove(asset);
        }
      }
    } else {
      _selected.clear();
    }
    selects.value = _selected.toList();
  }

  @override
  void dispose() {
    scroll.addListener(() {
      if (scroll.position.pixels != 0 &&
          scroll.position.atEdge &&
          !isLoadingMore.value) {
        loadMoreAsset();
      }
    });
    super.dispose();
  }
}

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
        registerObserve(_onLimitedAssetsUpdated);
      });
    });
    scroll.addListener(_listenerLoadMore);
  }
  final FilterOptionGroup? filterOptionGroup;
  final RequestType type;
  final int limit;
  final Duration routeDuration, minDuration, maxDuration;
  final bool isMulti, isPreview;
  final scroll = ScrollController();

  List<AssetEntity> selects = <AssetEntity>[];
  List<AssetEntity> assets = <AssetEntity>[];
  final pathEntityList = <AssetPathEntity?, Uint8List?>{};

  AssetPathEntity? currentPath;
  bool isSwitchingPath = false, isAssetsEmpty = false;
  int totalEntitiesCount = 0;

  bool get hasMoreToLoad => assets.length < totalEntitiesCount;
  int get currentPage => (math.max(1, assets.length) / _pageSize).ceil();

  double get position => scroll.position.pixels;
  double get maxScroll => scroll.position.maxScrollExtent;
  bool get _loadMore => position / maxScroll > 0.33;
  bool isLoadMore = true;
  bool _hasAssetsToDisplay = false;

  bool get hasAssetsToDisplay => _hasAssetsToDisplay;

  set hasAssetsToDisplay(bool value) {
    if (value == _hasAssetsToDisplay) {
      return;
    }
    _hasAssetsToDisplay = value;
    notifyListeners();
  }

  void _listenerLoadMore() {
    if (isLoadMore && _loadMore) {
      isLoadMore = false;
      onLoadMore().then((value) => isLoadMore = true);
    }
  }

  Future<void> onLoadMore() async {
    if (hasMoreToLoad) {
      final items = await currentPath!.getAssetListPaged(
        page: currentPage,
        size: _pageSize,
      );
      final List<AssetEntity> moreItems = <AssetEntity>[];
      moreItems.addAll(assets);
      moreItems.addAll(items);
      assets = moreItems;
      notifyListeners();
    }
  }

  void registerObserve([ValueChanged<MethodCall>? callback]) {
    if (callback == null) {
      return;
    }
    try {
      PhotoManager.addChangeCallback(callback);
      PhotoManager.startChangeNotify();
    } catch (e) {
      print('Error when registering assets callback: $e');
    }
  }

  void _onLimitedAssetsUpdated(MethodCall methodCall) async {
    if (currentPath != null) {
      await currentPath?.fetchPathProperties();
      getAssetFormEntity(currentPath!);
    }
  }

  void switchingPath() {
    isSwitchingPath = !isSwitchingPath;
    notifyListeners();
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
    selects = [];
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
    _hasAssetsToDisplay = assets.isNotEmpty;

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
    final _selected = selects.toList();
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
    selects = _selected.toList();

    notifyListeners();
  }

  @override
  void dispose() {
    registerObserve(_onLimitedAssetsUpdated);
    scroll.removeListener(_listenerLoadMore);
    super.dispose();
  }
}

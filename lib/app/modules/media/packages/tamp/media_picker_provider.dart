part of media;

const _pageSize = 80;

class MediaProvider extends ChangeNotifier {
  MediaProvider(
      {this.limit = 9,
      this.leadingBuilder,
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
    scrollController.addListener(_listenerLoadMore);
  }
  final WidgetBuilder? leadingBuilder;
  final FilterOptionGroup? filterOptionGroup;
  final int limit;
  final RequestType type;
  final Duration routeDuration, minDuration, maxDuration;
  final bool isMulti, isPreview;

  final scrollController = ScrollController();

  List<AssetEntity> selects = <AssetEntity>[];
  List<AssetEntity> assets = <AssetEntity>[];

  List<AssetPathEntity> list = <AssetPathEntity>[];
  final pathEntityList = <AssetPathEntity?, Uint8List?>{};
  AssetPathEntity? currentPath;
  bool isSwitchingPath = false;
  int _totalAssetsCount = 0;
  bool isAssetsEmpty = false;

  bool get hasMoreToLoad => assets.length < _totalAssetsCount;
  int get currentPage => (math.max(1, assets.length) / _pageSize).ceil();

  double get position => scrollController.position.pixels;
  double get maxScroll => scrollController.position.maxScrollExtent;
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
    }
  }

  Future<void> loadingmore() async {
    if (hasMoreToLoad) {
      final items = await currentPath!
          .getAssetListPaged(page: currentPage, size: _pageSize);
      final List<AssetEntity> itemList = <AssetEntity>[];
      itemList.addAll(assets);
      itemList.addAll(items);
      assets = itemList;
      notifyListeners();
    }
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
    for (var pathEntites in _list) {
      pathEntityList[pathEntites] = null;
      if (type != RequestType.audio) {
        getFirstThumbFromPathEntity(pathEntites).then((Uint8List? data) {
          pathEntityList[pathEntites] = data;
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
      await getAsssetFormEntity(pathEntityList.keys.elementAt(0)!);
    } else {
      assets = [];
      isAssetsEmpty = true;
    }
  }

  Future<void> getAsssetFormEntity(AssetPathEntity pathEntity) async {
    isSwitchingPath = false;
    selects = [];
    if (currentPath == pathEntity) {
      return;
    }
    currentPath = pathEntity;
    _totalAssetsCount = pathEntity.assetCount;
    final items = await pathEntity.getAssetListPaged(
      page: 0,
      size: _pageSize,
    );
    assets = items;
    _hasAssetsToDisplay = assets.isNotEmpty;
    notifyListeners();
  }

  void registerObserve([ValueChanged<MethodCall>? callback]) {
    if (callback == null) {
      return;
    }
    try {
      PhotoManager.addChangeCallback(callback);
      PhotoManager.startChangeNotify();
    } catch (e) {
      TailtMediaPicker.log('Erro $e');
    }
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

  void _onLimitedAssetsUpdated(MethodCall methodCall) async {
    if (currentPath != null) {
      await currentPath?.fetchPathProperties();
      getAsssetFormEntity(currentPath!);
    }
  }

  void onSelectItem(AssetEntity asset) {
    if (!isMulti) {
      if (!selects.contains(asset)) {
        selects = List.from([asset]);
      }
    } else {
      // ignore: iterable_contains_unrelated_type
      if (selects.contains(assets)) {
        selects = selects.where((e) => e != asset).toList();
      } else {
        if (selects.length < limit) {
          selects = [...selects, asset];
        }
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    registerObserve(_onLimitedAssetsUpdated);
    scrollController.removeListener(_listenerLoadMore);
    super.dispose();
  }
}

import 'dart:developer';
import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';
import '../packages/pages/image_preview_page.dart';
import '../packages/widgets/gallery_item.dart';
import '../packages/widgets/image_thumb_widget.dart';
import '../packages/pages/video_page.dart';

class MediaView extends StatefulWidget {
  const MediaView({
    Key? key,
  }) : super(key: key);

  @override
  MediaViewState createState() => MediaViewState();
}

class MediaViewState extends State<MediaView> {
  final FilterOptionGroup _filterOptionGroup = FilterOptionGroup(
    imageOption: const FilterOption(
      sizeConstraint: SizeConstraint(ignoreSize: true),
    ),
  );
  bool isReview = false;
  bool isMulti = false;
  AssetPathEntity? _path;
  AssetEntity? _assetEntity;
  List<AssetEntity>? _entities;
  final pathEntityList = <AssetPathEntity?, Uint8List?>{};
  RequestType type = RequestType.common;
  int totalEntitesCount = 0;
  int sizePerPage = 50;

  Duration maxDuration = const Duration(hours: 1);
  Duration minDuration = Duration.zero;

  int _page = 0;
  bool _isLoading = false;
  bool _isVideo = false;
  final _isLoadingMore = ValueNotifier(false);

  final _isSwitchPath = ValueNotifier(false);

  final scroll = ScrollController();
  @override
  void initState() {
    scroll.addListener(() {
      if (scroll.position.pixels != 0 &&
          scroll.position.atEdge &&
          !_isLoadingMore.value) {
        _loadMoreAsset();
      }
    });
    super.initState();
  }

  void switchinPath() {
    if (_assetEntity != null) {
      _isSwitchPath.value = !_isSwitchPath.value;
    }
  }

  Future<void> _requestAssets(RequestType type) async {
    setState(() {
      _isLoading = true;
    });
    // Request permissions.
    final PermissionState _ps = await PhotoManager.requestPermissionExtend();
    if (!mounted) {
      return;
    } else if (_ps != PermissionState.authorized &&
        _ps != PermissionState.limited) {
      setState(() {
        _isLoading = false;
      });
      log('Permission is not granted.');
    } else {
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: type,
        filterOption: _filterOptionGroup,
      );
      if (!mounted) {
        return;
      }
      if (paths.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        log('No paths found.');
        return;
      }
      setState(() {
        _path = paths.first;
      });
      totalEntitesCount = _path!.assetCount;
      final List<AssetEntity> entities = await _path!.getAssetListPaged(
        page: 0,
        size: sizePerPage,
      );
      if (mounted) {
        setState(() {
          _entities = entities;
          _isLoading = false;
        });
      }
    }
  }

  void _loadMoreAsset() {
    _isLoadingMore.value = true;
    _path!
        .getAssetListPaged(
      page: _page + 1,
      size: sizePerPage,
    )
        .then((value) {
      setState(() {
        _entities!.addAll(value);
        _page++;
      });
    }).whenComplete(() {
      _isLoadingMore.value = false;
    });
  }

  Future<void> getAssetPathList() async {
    FilterOptionGroup option = customOption();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          const Text("Review"),
                          Switch(
                            value: isReview,
                            onChanged: (newValue) {
                              setState(() => isReview = newValue);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text("Multi Mode"),
                          Switch(
                            value: isMulti,
                            onChanged: (newValue) {
                              setState(() => isMulti = newValue);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      MaterialButton(
                        child: const Text(
                          'Image picker',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          _requestAssets(RequestType.image);
                          _isVideo = false;
                        },
                      ),
                      MaterialButton(
                        child: const Text(
                          'Video picker',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          _requestAssets(RequestType.video);
                          _isVideo = true;
                        },
                      ),
                    ],
                  ),
                ],
              ),
              _path != null
                  ? GalleryItemWidget(
                      path: _path!,
                    )
                  : const SizedBox(),
              Expanded(child: buildBody(context)),
              ValueListenableBuilder(
                  valueListenable: _isLoadingMore,
                  child: Column(
                    children: const [
                      SizedBox(height: 10),
                      CircularProgressIndicator()
                    ],
                  ),
                  builder: (_, bool isLoadMore, child) {
                    if (!isLoadMore) return const SizedBox();
                    return child!;
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    } else if (_path == null) {
      return const Center(child: Text('Request paths first.'));
    }
    return GridView.builder(
      controller: scroll,
      cacheExtent: 16 / 9,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        crossAxisCount: 4,
      ),
      itemCount: _entities!.length,
      itemBuilder: (BuildContext context, int index) {
        final AssetEntity entity = _entities![index];

        return ImageItemWidget(
          key: UniqueKey(),
          entity: entity,
          thumbnailOption:
              const ThumbnailOption(size: ThumbnailSize.square(200)),
          onTap: () {
            if (isReview) {
              _isVideo
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VideoPageBuilder(
                                asset: entity,
                              )),
                    )
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ImagePreview(
                                entity: entity,
                              )),
                    );
            } else {
              log('Nothing to show');
            }
          },
        );
      },
    );
  }
}

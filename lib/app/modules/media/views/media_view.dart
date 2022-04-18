import 'dart:developer';
import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/material.dart';
import '../packages/pages/image_preview_page.dart';
import '../packages/widgets/button_select.dart';
import '../packages/widgets/gallery_item.dart';
import '../packages/widgets/image_thumb_widget.dart';
import '../packages/pages/video_page.dart';
import '../packages/widgets/path_list_entity.dart';

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
  bool isReview = false, isMulti = false, _isLoading = false;
  AssetPathEntity? _currentPath;
  List<AssetEntity>? _entities;
  RequestType type = RequestType.common;
  int totalAssetCount = 0, sizePerPage = 50, limit = 10, _page = 0;

  Duration maxDuration = const Duration(hours: 1);
  Duration minDuration = Duration.zero;

  final selects = ValueNotifier(<AssetEntity>[]);
  final assets = ValueNotifier(<AssetEntity>[]);
  final pathEntityList = <AssetPathEntity?, Uint8List?>{};
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
    getAssetPathList();
    super.initState();
  }

  void switchingPath() {
    _isSwitchPath.value = !_isSwitchPath.value;
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
      setState(() {
        _selected.clear();
      });
    }
    selects.value = _selected.toList();
  }

  void _loadMoreAsset() {
    _isLoadingMore.value = true;
    _currentPath!
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
        _currentPath = paths.first;
      });
      totalAssetCount = _currentPath!.assetCount;
      final List<AssetEntity> entities = await _currentPath!.getAssetListPaged(
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
    for (var pathEntities in _list) {
      pathEntityList[pathEntities] = null;
      if (type != RequestType.audio) {
        getFirstThumbFromPathEntity(pathEntities).then((Uint8List? data) {
          pathEntityList[pathEntities] = data;
        });
      }
    }
  }

  Future<void> getAssetsFromEntity(AssetPathEntity pathEntity) async {
    _isSwitchPath.value = false;
    if (_currentPath == pathEntity) {
      return;
    }
    _currentPath = pathEntity;
    totalAssetCount = pathEntity.assetCount;

    final List<AssetEntity> entities = await _currentPath!.getAssetListPaged(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              if (!newValue) {
                                selects.value.clear();
                              }
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
                          'All Image Picker',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          _requestAssets(RequestType.image);
                        },
                      ),
                      MaterialButton(
                        child: const Text(
                          'All Video Picker',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          _requestAssets(RequestType.video);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              ValueListenableBuilder(
                  valueListenable: _isSwitchPath,
                  builder: (_, bool isSwitchPath, __) {
                    return _currentPath != null
                        ? GalleryItemWidget(
                            isSwitchPath: isSwitchPath,
                            onTap: () {
                              switchingPath();
                              getAssetPathList();
                            },
                            path: _currentPath!,
                          )
                        : const SizedBox.shrink();
                  }),
              ValueListenableBuilder(
                  valueListenable: _isSwitchPath,
                  builder: (_, bool isSwitchPath, __) {
                    if (isSwitchPath) {
                      log(_currentPath.toString());
                      return SizedBox(
                        height: 200,
                        width: MediaQuery.of(context).size.width * .5,
                        child: PathListEntity(
                          pathEntityList: pathEntityList,
                          changePath: (_currentPath) {
                            getAssetsFromEntity(_currentPath);
                          },
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
              ValueListenableBuilder(
                valueListenable: selects,
                builder: (_, List<AssetEntity> selects, __) {
                  return SelectButton(isMulti: true, limit: 10, items: selects);
                },
              ),
              Expanded(
                child: buildBody(context),
              ),
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
    } else if (_currentPath == null) {
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
          isLimit: selects.value.length,
          isMulti: isMulti,
          entity: entity,
          thumbnailOption:
              const ThumbnailOption(size: ThumbnailSize.square(200)),
          onTap: () {
            if (isReview && !isMulti) {
              if (entity.type == AssetType.video) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VideoPageBuilder(
                            asset: entity,
                          )),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ImagePreview(
                            entity: entity,
                          )),
                );
              }
            } else {
              onSelectItem(entity);
            }
          },
        );
      },
    );
  }
}

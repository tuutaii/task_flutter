library media;

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
part 'media_picker_provider.dart';

class ZoomImageItem {
  ZoomImageItem({this.path, this.isVideo = false, this.thumbnail});
  final String? path;
  final bool isVideo;
  final String? thumbnail;
}

typedef MulCallback = void Function(List<AssetEntity>);
typedef SingleCallback = void Function(AssetEntity);

class PackageMediaPicker {
  factory PackageMediaPicker() => _instance;
  PackageMediaPicker._internal();
  static final PackageMediaPicker _instance = PackageMediaPicker._internal();

  static String formatDuration(Duration duration) {
    return <int>[duration.inMinutes, duration.inSeconds]
        .map((int e) => e.remainder(60).toString().padLeft(2, "0"))
        .join(':');
  }

  static void picker(
    BuildContext context, {
    RequestType type = RequestType.common,
    int limit = 10,
    MulCallback? mulCallback,
    SingleCallback? singleCallback,
    Duration routeDuration = const Duration(milliseconds: 300),
    Duration minDuration = Duration.zero,
    Duration maxDuration = const Duration(hours: 1),
    bool isMulti = false,
    bool isReview = false,
    WidgetBuilder? leadingBuilder,
    FilterOptionGroup? filterOptions,
  }) async {
    final isPermission = await PhotoManager.requestPermissionExtend();
    if (isPermission.isAuth) {
      final MediaProvider provider = MediaProvider(
        routeDuration: routeDuration,
        type: type,
        isMulti: isMulti,
        limit: limit,
        filterOptionGroup: filterOptions,
        isPreview: isReview,
        minDuration: minDuration,
        maxDuration: maxDuration,
      );
    } else {
      PhotoManager.openSetting();
    }
  }

  static Size sizeImage(
    double currentWidth,
    double currentHeight, {
    required double targetWidth,
    required double targetHeight,
  }) {
    double w = currentWidth;
    double h = currentHeight;
    final double wd = w / targetWidth;
    final double hd = h / targetHeight;
    final double be = math.max(1, math.max(wd, hd));
    w = w / be;
    h = h / be;
    return Size(w, h);
  }
}

library media;

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:extended_image/extended_image.dart';

part 'media_picker_provider.dart';

part '../widgets/button_select.dart';
part '../widgets/gallery_title.dart';
part '../widgets/list_path_entity.dart';
part '../widgets/select_indicator.dart';
part '../widgets/list_backdrop.dart';
part '../pages/image_preview_page.dart';
part '../pages/list_selected_image_page.dart';
part '../pages/video_page.dart';
part '../pages/video_progress.dart';
part '../pages/asset_picker_page.dart';
part '../pages/media_preview_page.dart';

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
    VoidCallback? onCancel,
    Duration routeDuration = const Duration(milliseconds: 300),
    Duration minDuration = Duration.zero,
    Duration maxDuration = const Duration(hours: 1),
    bool isMulti = false,
    bool isReview = false,
    FilterOptionGroup? filterOptions,
    WidgetBuilder? leadingBuilder,
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
      final Widget picker = ChangeNotifierProvider(
        create: (context) => provider,
        child: const AssetPicker(),
      );
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => picker))
          .then(
        (data) {
          if (data != null) {
            if (mulCallback != null && isMulti) {
              mulCallback(data as List<AssetEntity>);
            } else if (singleCallback != null && !isMulti) {
              singleCallback.call(data.first as AssetEntity);
            }
          } else {
            onCancel?.call();
          }
        },
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

extension ContextExt on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  Color get primary => colorScheme.primary;
  Size get size => mediaQuery.size;
  double get width => size.width;
  double get height => size.height;
  int get gridCount => (width / 100) ~/ math.min(1, (width / 100) / 4);
  EdgeInsets get padding => mediaQuery.padding;
}

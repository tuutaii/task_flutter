library media;

import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';
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

class TailtMediaPicker {
  factory TailtMediaPicker() => _instance;
  TailtMediaPicker._internal();
  static final TailtMediaPicker _instance = TailtMediaPicker._internal();

  static String formatDuration(Duration duration) {
    return <int>[duration.inMinutes, duration.inSeconds]
        .map((int e) => e.remainder(60).toString().padLeft(2, "0"))
        .join(':');
  }

  static void picker(
    BuildContext context, {
    RequestType type = RequestType.common,
    int limited = 10,
    MulCallback? mulCallback,
    SingleCallback? singleCallback,
    Duration routeDuration = const Duration(milliseconds: 300),
    bool isMulti = false,
    bool isReview = false,
    WidgetBuilder? leadingBuilder,
    FilterOptionGroup? filterOptions,
  }) {}

  static customDuration(Duration duration) {
    return <int>[duration.inMinutes, duration.inSeconds]
        .map((int e) => e.remainder(60).toString().padLeft(2, '0'))
        .join(':');
  }

  static log(dynamic message, {String tag = ''}) {
    dev.log(message.toString(), name: tag);
  }

  static Size sizeImgae(
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

class LoadingCircle extends StatelessWidget {
  const LoadingCircle({
    Key? key,
    this.width = 30.0,
    this.padding,
    this.color,
  }) : super(key: key);

  final double width;
  final Color? color;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(8.0),
        child: SizedBox(
          width: width,
          height: width,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}

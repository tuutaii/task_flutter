import 'dart:ui';

import 'package:flutter/material.dart';
import '../widgets/jumping_button.dart';
import 'package:photo_manager/photo_manager.dart';

import '../media_picker_widget.dart';

class MediaTile extends StatefulWidget {
  const MediaTile({
    Key? key,
    required this.media,
    required this.onSelected,
    this.isSelected = false,
    this.decoration,
  }) : super(key: key);

  final AssetEntity media;
  final Function(bool, Media) onSelected;
  final bool isSelected;
  final PickerDecoration? decoration;

  @override
  _MediaTileState createState() => _MediaTileState();
}

class _MediaTileState extends State<MediaTile>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  bool? selected;

  Media? media;

  final Duration _duration = const Duration(milliseconds: 100);
  AnimationController? _animationController;
  Animation? _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: _duration);
    _animation =
        Tween<double>(begin: 1.0, end: 1.3).animate(_animationController!);
    selected = widget.isSelected;
    if (selected!) _animationController!.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (media != null) {
      return Padding(
        padding: const EdgeInsets.all(0.5),
        child: Stack(
          children: [
            Positioned.fill(
              child: media!.thumbnail != null
                  ? JumpingButton(
                      onTap: () {
                        setState(() => selected = !selected!);
                        if (selected!) {
                          _animationController!.forward();
                        } else {
                          _animationController!.reverse();
                        }
                        widget.onSelected(selected!, media!);
                      },
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRect(
                              child: AnimatedBuilder(
                                  animation: _animation!,
                                  builder: (context, child) {
                                    double amount =
                                        (_animation!.value - 1) * 3.33;

                                    return ImageFiltered(
                                      imageFilter: ImageFilter.blur(
                                        sigmaX:
                                            widget.decoration!.blurStrength *
                                                amount,
                                        sigmaY:
                                            widget.decoration!.blurStrength *
                                                amount,
                                      ),
                                      child: Transform.scale(
                                        scale: _animation!.value,
                                        child: Image.memory(
                                          media!.thumbnail!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                          Positioned.fill(
                            child: AnimatedOpacity(
                              opacity: selected! ? 1 : 0,
                              curve: Curves.easeOut,
                              duration: _duration,
                              child: ClipRect(
                                child: Container(
                                  color: Colors.black26,
                                ),
                              ),
                            ),
                          ),
                          if (widget.media.type == AssetType.video)
                            const Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: EdgeInsets.only(right: 5, bottom: 5),
                                child: Icon(
                                  Icons.videocam,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.grey.shade400,
                        size: 40,
                      ),
                    ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedOpacity(
                  curve: Curves.easeOut,
                  duration: _duration,
                  opacity: selected! ? 1 : 0,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle),
                    padding: const EdgeInsets.all(5),
                    child: const Icon(
                      Icons.done,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      convertToMedia(media: widget.media)
          .then((_media) => setState(() => media = _media));
      return const SizedBox();
    }
  }

  @override
  bool get wantKeepAlive => true;
}

Future<Media> convertToMedia({required AssetEntity media}) async {
  Media convertedMedia = Media();
  convertedMedia.file = await media.file;
  convertedMedia.mediaByte = await media.originBytes;
  convertedMedia.thumbnail =
      await media.thumbnailDataWithSize(const ThumbnailSize(200, 200));
  convertedMedia.id = media.id;
  convertedMedia.size = media.size;
  convertedMedia.title = media.title;
  convertedMedia.creationTime = media.createDateTime;

  MediaType mediaType = MediaType.all;
  if (media.type == AssetType.video) mediaType = MediaType.video;
  if (media.type == AssetType.image) mediaType = MediaType.image;
  convertedMedia.mediaType = mediaType;

  return convertedMedia;
}

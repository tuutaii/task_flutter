import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'media_picker_widget.dart';
import 'header_controller.dart';
import 'widgets/jumping_button.dart';

class Header extends StatefulWidget {
  const Header({
    Key? key,
    required this.selectedAlbum,
    required this.onBack,
    required this.onDone,
    required this.albumController,
    required this.controller,
    this.mediaCount,
    this.decoration,
  }) : super(key: key);

  final AssetPathEntity selectedAlbum;
  final VoidCallback onBack;
  final PanelController albumController;
  final ValueChanged<List<Media>> onDone;
  final HeaderController controller;
  final MediaCount? mediaCount;
  final PickerDecoration? decoration;

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> with TickerProviderStateMixin {
  List<Media> selectedMedia = [];

  var _arrowAnimation;
  AnimationController? _arrowAnimController;

  @override
  void initState() {
    _arrowAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _arrowAnimation =
        Tween<double>(begin: 0, end: 1).animate(_arrowAnimController!);

    widget.controller.updateSelection = (selectedMediaList) {
      if (widget.mediaCount == MediaCount.multiple) {
        setState(() => selectedMedia = selectedMediaList.cast<Media>());
      } else if (selectedMediaList.length == 1) {
        widget.onDone(selectedMediaList);
      }
    };

    widget.controller.closeAlbumDrawer = () {
      widget.albumController.close();
      _arrowAnimController!.reverse();
    };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: IconButton(
              icon: widget.decoration!.cancelIcon ??
                  const Icon(Icons.arrow_back_outlined),
              onPressed: () {
                if (_arrowAnimation.value == 1) _arrowAnimController!.reverse();
                widget.onBack();
              }),
        ),
        Expanded(
          flex: 3,
          child: Center(
            child: JumpingButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        child: child,
                        position: Tween<Offset>(
                                begin: const Offset(0.0, -0.5),
                                end: const Offset(0.0, 0.0))
                            .animate(animation),
                      );
                    },
                    child: Text(
                      widget.selectedAlbum.name,
                      style: widget.decoration!.albumTitleStyle,
                      key: ValueKey<String>(widget.selectedAlbum.id),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _arrowAnimation,
                    builder: (context, child) => Transform.rotate(
                      angle: _arrowAnimation.value * pi,
                      child: Icon(
                        Icons.keyboard_arrow_up_outlined,
                        size: (widget.decoration!.albumTitleStyle?.fontSize) !=
                                null
                            ? widget.decoration!.albumTitleStyle!.fontSize! *
                                1.5
                            : 20,
                        color: widget.decoration!.albumTitleStyle?.color ??
                            Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                if (widget.albumController.isPanelOpen) {
                  widget.albumController.close();
                  _arrowAnimController!.reverse();
                }
                if (widget.albumController.isPanelClosed) {
                  widget.albumController.open();
                  _arrowAnimController!.forward();
                }
              },
            ),
          ),
        ),
        if (widget.mediaCount == MediaCount.multiple)
          Expanded(
            flex: 1,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  child: child,
                  position: Tween<Offset>(
                          begin: const Offset(1, 0.0),
                          end: const Offset(0.0, 0.0))
                      .animate(animation),
                );
              },
              child: (selectedMedia.isNotEmpty)
                  ? TextButton(
                      key: const Key('button'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.decoration!.completeText,
                            style: widget.decoration!.completeTextStyle ??
                                const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                          ),
                          Text(
                            ' (${selectedMedia.length})',
                            style: TextStyle(
                              color:
                                  widget.decoration!.completeTextStyle?.color ??
                                      Colors.white,
                              fontSize: widget.decoration!.completeTextStyle
                                          ?.fontSize !=
                                      null
                                  ? widget.decoration!.completeTextStyle!
                                          .fontSize! *
                                      0.77
                                  : 11,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      onPressed: selectedMedia.isNotEmpty
                          ? () => widget.onDone(selectedMedia)
                          : null,
                      style: widget.decoration!.completeButtonStyle ??
                          ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3))),
                          ),
                    )
                  : Container(
                      key: const Key('blank'),
                    ),
            ),
          ),
      ],
    );
  }
}

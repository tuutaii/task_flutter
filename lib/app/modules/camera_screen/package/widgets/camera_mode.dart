import 'package:flutter/material.dart';

class CameraMode extends StatefulWidget {
  const CameraMode({
    Key? key,
    required this.tabController,
    required this.isVideoCameraSelected,
  }) : super(key: key);

  final TabController tabController;
  final bool isVideoCameraSelected;

  @override
  State<CameraMode> createState() => _CameraModeState();
}

class _CameraModeState extends State<CameraMode> {
  late bool isVideoCameraSelected;
  @override
  void initState() {
    isVideoCameraSelected = widget.isVideoCameraSelected;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CameraMode oldWidget) {
    if (oldWidget.isVideoCameraSelected != widget.isVideoCameraSelected) {
      setState(() {
        isVideoCameraSelected = widget.isVideoCameraSelected;
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TabBar(
            indicator: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(50),
              color: Colors.transparent,
            ),
            isScrollable: true,
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.white,
            labelStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            tabs: const [
              Tab(
                child: Text('Camera'),
              ),
              Tab(
                child: Text('Video'),
              ),
            ],
            controller: widget.tabController,
            indicatorColor: Colors.white,
            onTap: (index) {
              index == 0
                  ? isVideoCameraSelected = false
                  : isVideoCameraSelected = true;
            },
          ),
        ),
      ),
    );
  }
}

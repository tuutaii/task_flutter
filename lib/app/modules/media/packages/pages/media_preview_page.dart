part of media;

class MediaBuilderPreview extends StatefulWidget {
  const MediaBuilderPreview({
    Key? key,
    required this.assets,
    this.index = 0,
  }) : super(key: key);

  final List<AssetEntity> assets;
  final int index;

  @override
  State<MediaBuilderPreview> createState() => _MediaBuilderPreviewState();
}

class _MediaBuilderPreviewState extends State<MediaBuilderPreview>
    with SingleTickerProviderStateMixin {
  ExtendedPageController get pageController => _pageController;

  late final ExtendedPageController _pageController = ExtendedPageController(
    initialPage: currentIndex,
  );

  final _pageStreamController = StreamController<int>.broadcast();
  final _showAppBar = ValueNotifier<bool>(true);
  late int _currentIndex;
  int get currentIndex => _currentIndex;
  int get total => widget.assets.length;

  set currentIndex(int value) {
    if (_currentIndex == value) {
      return;
    }
    _currentIndex = value;
  }

  @override
  void initState() {
    _currentIndex = widget.index;
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    _showAppBar.dispose();
    _pageStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ExtendedImageGesturePageView.builder(
              canScrollPage: (val) {
                return val?.totalScale == 1.0 || val?.totalScale == null;
              },
              physics: const AlwaysScrollableScrollPhysics(),
              controller: pageController,
              itemCount: total,
              scrollDirection: Axis.horizontal,
              itemBuilder: assetPageBuilder,
              onPageChanged: (int index) {
                currentIndex = index;
                _pageStreamController.add(index);
                _showAppBar.value = true;
              },
            ),
          ),
          appBar(context),
        ],
      ),
    );
  }

  Widget appBar(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _showAppBar,
      builder: (_, bool value, Widget? child) {
        return AnimatedPositioned(
          duration: kThemeAnimationDuration,
          curve: Curves.easeInOut,
          top: value ? 0.0 : -(context.padding.top + kToolbarHeight),
          left: 0.0,
          right: 0.0,
          height: context.padding.top + kToolbarHeight,
          child: child!,
        );
      },
      child: Container(
        padding: EdgeInsets.only(top: context.padding.top, right: 12.0),
        child: Row(
          children: <Widget>[
            const CloseButton(color: Colors.white),
            StreamBuilder<int>(
              initialData: currentIndex,
              stream: _pageStreamController.stream,
              builder: (_, AsyncSnapshot<int> snapshot) {
                return Text(
                  '${snapshot.data! + 1}/$total',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget assetPageBuilder(BuildContext context, int index) {
    final AssetEntity asset = widget.assets.elementAt(index);
    switch (asset.type) {
      case AssetType.image:
        return ImagePreview(
          entity: asset,
        );
      case AssetType.video:
        return VideoPageBuilder(
          asset: asset,
          toggleShowAppBar: (bool value) {
            _showAppBar.value = value;
          },
        );
      default:
        return const Center(child: Text('Not support type'));
    }
  }
}

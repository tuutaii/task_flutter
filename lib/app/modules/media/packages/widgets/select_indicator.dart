part of media;

class SelectedBackdrop extends StatelessWidget {
  const SelectedBackdrop({
    Key? key,
    required this.selected,
    required this.onReview,
  }) : super(key: key);
  final bool selected;
  final VoidCallback onReview;
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        child: AnimatedContainer(
          duration: const Duration(seconds: 1),
          color: selected
              ? Colors.black.withOpacity(0.5)
              : Colors.black.withOpacity(0.1),
        ),
        onTap: onReview,
      ),
    );
  }
}

class SelectIndicator extends StatelessWidget {
  const SelectIndicator({
    Key? key,
    required this.selected,
    required this.onTap,
    required this.isMulti,
    required this.gridCount,
    required this.selectText,
  }) : super(key: key);
  final bool selected;
  final VoidCallback onTap;
  final bool isMulti;
  final int gridCount;
  final String selectText;

  @override
  Widget build(BuildContext context) {
    final double indicatorSize = context.width / gridCount / 4;
    return Positioned(
      top: 0.0,
      right: 0.0,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: indicatorSize,
          height: indicatorSize,
          margin: EdgeInsets.all(
            context.width / gridCount / 15.0,
          ),
          child: AnimatedContainer(
            duration: const Duration(microseconds: 100),
            width: indicatorSize / 1.5,
            height: indicatorSize / 1.5,
            decoration: BoxDecoration(
              border: !selected && isMulti
                  ? Border.all(color: Colors.white, width: 2.0)
                  : null,
              color: selected ? context.primary : null,
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(microseconds: 100),
              reverseDuration: const Duration(microseconds: 100),
              child: selected
                  ? isMulti
                      ? Text(
                          selectText,
                          style: TextStyle(
                            color: selected ? Colors.white : null,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Icon(Icons.check, size: 18.0, color: Colors.white)
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}

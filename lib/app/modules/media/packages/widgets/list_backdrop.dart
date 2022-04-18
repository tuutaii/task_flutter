part of media;

class BackDropList extends StatelessWidget {
  const BackDropList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<MediaProvider, bool>(
      selector: (BuildContext _, MediaProvider e) => e.isSwitchingPath,
      builder: (context, bool isSwitchingPath, child) {
        return IgnorePointer(
          ignoring: !isSwitchingPath,
          child: GestureDetector(
            onTap: Provider.of<MediaProvider>(context, listen: false)
                .switchingPath,
            child: AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: isSwitchingPath ? 1.0 : 0.0,
              child: child,
            ),
          ),
        );
      },
      child: Container(color: Colors.white.withOpacity(0.75)),
    );
  }
}

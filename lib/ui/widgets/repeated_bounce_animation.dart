import 'package:flutter/material.dart';

class RepeatedBounceAnimation extends StatefulWidget {
  final Widget child;
  final double cellSize;
  const RepeatedBounceAnimation({
    Key? key,
    required this.child,
    required this.cellSize,
  }) : super(key: key);

  @override
  _RepeatedBounceAnimationState createState() =>
      _RepeatedBounceAnimationState();
}

class _RepeatedBounceAnimationState extends State<RepeatedBounceAnimation>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 600);
  double scale = 1;

  @override
  void initState() {
    super.initState();
    // _changeScale();
  }

  void _changeScale() async {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        scale = scale == 1 ? 0.8 : 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.cellSize,
      height: widget.cellSize,
      child: Center(
        child: AnimatedContainer(
          duration: _duration,
          height: widget.cellSize * scale,
          width: widget.cellSize * scale,
          onEnd: _changeScale,
          child: FittedBox(fit:BoxFit.cover,child: widget.child),
        ),
      ),
    );
  }
}

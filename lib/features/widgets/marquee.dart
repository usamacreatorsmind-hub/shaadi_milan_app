
import 'package:flutter/material.dart';

/// =======================
/// MARQUEE WIDGET
/// =======================
class Marquee extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration pauseDuration;
  final double velocity;

  const Marquee(
    this.text, {
    super.key,
    required this.style,
    this.pauseDuration = const Duration(seconds: 2),
    this.velocity = 30.0, // pixels per second
  });

  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> {
  final ScrollController _scrollController = ScrollController();
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scroll());
  }

  @override
  void didUpdateWidget(Marquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      // When text changes, reset and the loop will restart with new dimensions.
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    super.dispose();
  }

  void _scroll() async {
    while (!_isDisposed) {
      // Wait for controller to be attached
      if (!_scrollController.hasClients) {
        await Future.delayed(const Duration(milliseconds: 100));
        continue;
      }

      // Only scroll if there's overflow
      if (_scrollController.position.maxScrollExtent > 0) {
        final scrollDuration = Duration(
          milliseconds:
              (_scrollController.position.maxScrollExtent /
                      widget.velocity *
                      1000)
                  .toInt(),
        );

        await Future.delayed(widget.pauseDuration);
        if (_isDisposed) break;

        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: scrollDuration,
          curve: Curves.linear,
        );
        if (_isDisposed) break;

        await Future.delayed(widget.pauseDuration);
        if (_isDisposed) break;

        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      } else {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        widget.text,
        style: widget.style,
        softWrap: false,
        maxLines: 1,
      ),
    );
  }
}

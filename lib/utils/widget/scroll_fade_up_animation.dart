import 'package:flutter/material.dart';

class ScrollFadeUpAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offset;

  const ScrollFadeUpAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.offset = 30.0,
  });

  @override
  State<ScrollFadeUpAnimation> createState() => _ScrollFadeUpAnimationState();
}

class _ScrollFadeUpAnimationState extends State<ScrollFadeUpAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  final GlobalKey _widgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.offset / 100),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Cek posisi widget setelah layout selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  void _checkVisibility() {
    final RenderBox? renderBox =
        _widgetKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final screenHeight = MediaQuery.of(context).size.height;

      // Jika widget sudah terlihat di screen
      if (position.dy < screenHeight * 0.8) {
        _controller.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        _checkVisibility();
        return false;
      },
      child: FadeTransition(
        key: _widgetKey,
        opacity: _opacityAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
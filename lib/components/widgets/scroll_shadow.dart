// Flutter imports:
import 'package:flutter/material.dart';

class ScrollShadow extends StatefulWidget {
  const ScrollShadow({
    super.key,
    this.size = 6.0,
    this.color = Colors.black12,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.fadeInCurve = Curves.easeIn,
    this.fadeOutCurve = Curves.easeOut,
    this.ignoreInteraction = true,
    this.enableStartShadow = true,
    this.enableEndShadow = false,
  });

  final bool enableStartShadow;
  final bool enableEndShadow;
  final Color color;
  final double size;
  final Widget child;
  final Duration duration;
  final Curve fadeInCurve;
  final Curve fadeOutCurve;
  final bool ignoreInteraction;

  @override
  State<ScrollShadow> createState() => _ScrollShadowState();
}

class _ScrollShadowState extends State<ScrollShadow> {
  bool _isMetricsReady = false;
  Axis? _axis;
  bool _reachedStart = true;
  bool _reachedEnd = true;
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    // Ensure metrics are available after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isMetricsReady = true;
      });
    });
  }

  bool get reachedStart => _reachedStart;

  set reachedStart(final bool value) {
    if (_reachedStart == value) return;
    setState(() => _reachedStart = value);
  }

  bool get reachedEnd => _reachedEnd;

  set reachedEnd(final bool value) {
    if (_reachedEnd == value) return;
    setState(() => _reachedEnd = value);
  }

  @override
  Widget build(final BuildContext context) {
    if (!_isMetricsReady) {
      return const SizedBox.shrink();
    }

    LinearGradient? startGradient, endGradient;

    switch (_axis) {
      case Axis.horizontal:
        startGradient = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [widget.color.withAlpha(0), widget.color],
        );
        endGradient = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [widget.color, widget.color.withAlpha(0)],
        );
        break;
      case Axis.vertical:
        startGradient = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [widget.color.withAlpha(0), widget.color],
        );
        endGradient = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [widget.color, widget.color.withAlpha(0)],
        );
        break;
      default:
        break;
    }

    var startShadow = _getShadow(startGradient);
    var endShadow = _getShadow(endGradient);

    if (_animate) {
      startShadow = _getAnimatedShadow(startShadow, reachedStart);
      endShadow = _getAnimatedShadow(endShadow, reachedEnd);
    }

    if (widget.ignoreInteraction) {
      startShadow = _getNoninteractive(startShadow);
      endShadow = _getNoninteractive(endShadow);
    }

    startShadow = _getPositioned(startShadow, true);
    endShadow = _getPositioned(endShadow, false);

    return Stack(
      children: [
        NotificationListener<ScrollMetricsNotification>(
          onNotification: (notification) =>
              _handleNewMetrics(notification.metrics),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) =>
                _handleNewMetrics(notification.metrics),
            child: widget.child,
          ),
        ),
        if (widget.enableStartShadow && startShadow != null) startShadow,
        if (widget.enableEndShadow && endShadow != null) endShadow,
      ],
    );
  }

  Widget? _getShadow(final LinearGradient? gradient) => gradient == null
      ? null
      : Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(gradient: gradient),
        );

  Widget? _getAnimatedShadow(final Widget? shadow, final bool reachedEdge) =>
      shadow == null
      ? null
      : AnimatedOpacity(
          opacity: reachedEdge ? 0.0 : 1.0,
          duration: widget.duration,
          curve: reachedEdge ? widget.fadeOutCurve : widget.fadeInCurve,
          child: shadow,
        );

  Widget? _getNoninteractive(final Widget? shadow) =>
      shadow == null ? null : IgnorePointer(ignoring: true, child: shadow);

  Widget? _getPositioned(final Widget? shadow, final bool start) {
    if (shadow == null) return null;
    switch (_axis) {
      case Axis.horizontal:
        return Positioned(
          left: start ? 0.0 : null,
          right: start ? null : 0.0,
          top: 0.0,
          bottom: 0.0,
          child: shadow,
        );
      case Axis.vertical:
        return Positioned(
          top: start ? 0.0 : null,
          bottom: start ? null : 0.0,
          left: 0.0,
          right: 0.0,
          child: shadow,
        );
      default:
        return null;
    }
  }

  bool _handleNewMetrics(final ScrollMetrics metrics) {
    // Update scroll metrics only when valid
    if (_axis == null) {
      setState(() {
        _axis = metrics.axis;
      });
    }

    // If the content is smaller than the available screen size, make sure metrics are available
    if (metrics.maxScrollExtent == 0.0) {
      reachedStart = true;
      reachedEnd = true;
    } else {
      final isReverse =
          metrics.axisDirection == AxisDirection.left ||
          metrics.axisDirection == AxisDirection.up;
      reachedStart = isReverse
          ? metrics.pixels >= metrics.maxScrollExtent
          : metrics.pixels <= metrics.minScrollExtent;
      reachedEnd = isReverse
          ? metrics.pixels <= metrics.minScrollExtent
          : metrics.pixels >= metrics.maxScrollExtent;
    }

    _animate = true;

    return true;
  }
}

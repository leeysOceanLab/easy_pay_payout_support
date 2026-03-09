// Project imports:
import '../../imports.dart';

class InkWellWrapper extends StatefulWidget {
  final Widget child;
  final Function()? onTap;
  final Function()? onLongPress;
  final bool checkLogin;
  final Duration cooldownDuration;
  final bool keyboardCheckingEnabled;

  const InkWellWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.checkLogin = false,
    this.keyboardCheckingEnabled = false,
    this.cooldownDuration = const Duration(milliseconds: 0),
  });

  @override
  State<InkWellWrapper> createState() => _InkWellWrapperState();
}

class _InkWellWrapperState extends State<InkWellWrapper> {
  bool _isTapped = false;

  void _handleTap() async {
    if (_isTapped) return;

    // Check if keyboard is open, then unfocus
    if (widget.keyboardCheckingEnabled) {
      final bool isKeyboardVisible =
          KeyboardVisibilityProvider.isKeyboardVisible(context);
      if (isKeyboardVisible) {
        unfocusKeyboard();
        return;
      }
    }

    setState(() => _isTapped = true);

    if (widget.onTap != null) {
      widget.onTap!();
    }

    // Prevent tapping again
    await Future.delayed(widget.cooldownDuration);
    if (mounted) setState(() => _isTapped = false);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      onLongPress: widget.onLongPress,
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: widget.child,
    );
  }
}

// Project imports:
import '../../imports.dart';

class UnfocusWrapper extends StatelessWidget {
  final Widget child;
  final Function()? onTap;

  const UnfocusWrapper({required this.child, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: (event) {
        final currentFocus = FocusManager.instance.primaryFocus;

        if (currentFocus != null && !currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }

        if (onTap != null) {
          onTap!();
        }
      },
      child: child,
    );
  }
}

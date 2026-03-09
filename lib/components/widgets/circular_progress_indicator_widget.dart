// Package imports:
import 'package:lottie/lottie.dart';

// Project imports:
import '../../imports.dart';

class CircularProgressIndicatorWidget extends StatelessWidget {
  // final double? strokeWidth;
  // final Color? color;

  const CircularProgressIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double loaderSize = 56.0;

    return RepaintBoundary(
      child: SizedBox(
        width: loaderSize.h,
        height: loaderSize.h,
        child: Lottie.asset('assets/lotties/loading.json'),
        // CircularProgressIndicator(
        //   strokeWidth: strokeWidth?.fw ?? loaderSize.fw * 0.1,
        //   valueColor: AlwaysStoppedAnimation<Color?>(
        //     color ?? AppColors.of(context).refreshColor(),
        //   ),
        // ),
      ),
    );
  }
}

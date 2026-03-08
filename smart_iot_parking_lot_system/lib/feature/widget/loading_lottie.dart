import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingLottie extends StatelessWidget {
  const LoadingLottie({super.key});

  @override
  Widget build(BuildContext context) {
    return LottieBuilder.asset(
      "assets/lottie/loading.json",
      width: 200,
      height: 200,
      alignment: Alignment.center,
      repeat: true,
    );
  }
}

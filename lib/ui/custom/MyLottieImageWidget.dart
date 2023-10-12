import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MyLottieImageWidget extends StatelessWidget {
  final String imageAsset;
  final String lottieAsset;

  MyLottieImageWidget({
    required this.imageAsset,
    required this.lottieAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          imageAsset,
          width: 35,
          height: 35,
        ),
        Positioned(
          top: 0,
          left: 0,
          width: 35,
          height: 35,
          child: Lottie.asset(
            lottieAsset,
            // Other options like repeat, reverse, etc. can be added here
          ),
        ),
      ],
    );
  }
}

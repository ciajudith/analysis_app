import 'package:analysis_app/constants/colors.dart';
import 'package:analysis_app/views/welcome_view.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return AnimatedSplashScreen(
      duration: 5000,
      splash: SvgPicture.asset(
        "assets/images/logo.svg",
        height: size.height * 0.08,
      ),
      nextScreen: const WelcomeScreen(),
      splashTransition: SplashTransition.fadeTransition,
      animationDuration: const Duration(
        milliseconds: 1000,
      ),
      backgroundColor: AppColors.primaryColor,
      pageTransitionType: PageTransitionType.fade,
    );
  }
}

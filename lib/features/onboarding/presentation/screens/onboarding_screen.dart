import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../../../../app/router/app_router.dart';
import 'page_view_model.dart';

@RoutePage()
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onDone(BuildContext context) {
    // When done button is press
    context.router.replace(const LoginRoute());
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: pageViewModelList,
      onDone: () => _onDone(context),
      onSkip: () => _onDone(context), // You can also override onSkip behavior

      next: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.arrow_forward_ios,
          size: 20,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),

      curve: Curves.bounceOut,
      

      // need icon
      done: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.check,
          size: 20,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),

      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Theme.of(context).colorScheme.secondary,
        // theme color
        color: Colors.black26,

        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}

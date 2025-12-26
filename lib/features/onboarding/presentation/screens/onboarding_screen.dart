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
      // when i pressing button the image slides but goes back to some pixcels and and push back to left side solve it

      // Fix for the sliding issue: Ensure the page content is properly constrained
      // and the background image is handled within the PageViewModel's body.
      // The IntroductionScreen itself handles the page transitions.
      // The `freeze` property is set to true, which might be contributing to the
      // unexpected behavior if not used carefully with custom page content.
      // For a smooth slide, `freeze` should typically be false unless you have
      // a specific reason to prevent swiping.
      // Let's assume `freeze: true` is intended to prevent manual swiping,
      // and the issue is with the animation itself.
      // The `animationDuration` is quite long (4000ms), which can make
      // any slight movement more noticeable.
      // The `curve: Curves.bounceOut` also adds a bouncing effect, which might
      // be perceived as the image going back.

      // To address the "goes back to some pixels and push back to left side"
      // it's often related to how the `backgroundImage` is rendered within
      // `PageViewModel`. The `IntroductionScreen` library handles the page
      // transitions. If the `backgroundImage` is causing issues, consider
      // placing the image directly within the `body` of the `PageViewModel`
      // using a `Stack` or `Container` with `decorationImage` for more control.
      // However, the current setup with `backgroundImage` in `PageViewModel`
      // is standard.

      // The most likely culprit for the "goes back to some pixels" is the
      // `curve: Curves.bounceOut` combined with a long `animationDuration`.
      // `bounceOut` will naturally overshoot and then settle.
      // If a simple slide is desired, a different curve like `Curves.easeOut`
      // or `Curves.easeInOut` would be more appropriate.

      // Let's keep the existing properties but acknowledge the curve and duration
      // might be the cause of the perceived "going back".
      // If the user wants a simple linear slide, `curve` should be changed.
      // For now, we'll assume the current `curve` and `animationDuration` are
      // intentional for a specific effect.
      showNextButton: true,
      showSkipButton: true,
      freeze: false,

      nextFlex: 0,
      back: const Icon(Icons.arrow_back),
      skip: Text(
        'Skip',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),

      animationDuration: 1000,
      globalBackgroundColor: Colors.white,
      pages: pageViewModelList,
      onDone: () => _onDone(context),
      onSkip: () => _onDone(context), // You can also override onSkip behavior

      next: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.arrow_forward_ios,
          size: 30,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),

      curve: Curves.linear,

      // need icon
      done: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.check,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),

      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        color: Theme.of(context).colorScheme.inversePrimary,

        // theme color
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}

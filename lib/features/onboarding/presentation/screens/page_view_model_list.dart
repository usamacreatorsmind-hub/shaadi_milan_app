import '../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../app/router/app_router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

// Create page view model list with navigation callbacks
List<PageViewModel> pageViewModelList(BuildContext context) {
  return [
    PageViewModel(
      title: "Find Your Perfect Match ❤️",

      body: "Trusted matrimony platform for genuine connections",

      backgroundImage: "assets/images/image_1.jpeg",

      decoration: PageDecoration(
        titleTextStyle: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyTextStyle: const TextStyle(fontSize: 16, color: Colors.white70),
      ),
    ),
    PageViewModel(
      title: "Connect with Like-Minded Individuals",

      body: "Explore profiles and start meaningful conversations",

      backgroundImage: "assets/images/image_2.jpeg",

      decoration: PageDecoration(
        titleTextStyle: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyTextStyle: const TextStyle(fontSize: 16, color: Colors.white70),
      ),
    ),
    PageViewModel(
      title: "Secure & Private Platform",
      body: "Your privacy is our priority. Connect with confidence.",

      backgroundImage: "assets/images/image_3.jpeg",

      decoration: PageDecoration(
        titleTextStyle: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyTextStyle: const TextStyle(fontSize: 16, color: Colors.white70),
      ),
    ),
  ];
}

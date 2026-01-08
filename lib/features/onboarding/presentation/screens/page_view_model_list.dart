import 'package:arvika_marriage_bureau/app/custom/custom_widgets/widgets.dart';
import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/app/router/app_router.dart';
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
      footer: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Navigate to Agent Registration/Login
                  // context.router.replace(const AgentLoginRoute());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: Duration(seconds: 2),

                      // appread from top
                      content: const Text('Agent login coming soon!'),
                    ),
                  );
                },
                child: const Text(
                  "Continue as Agent",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Navigate to User Login/Signup
                  context.router.replace(const LoginRoute());
                },
                child: const Text(
                  "Continue as User",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

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

import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

List<PageViewModel> pageViewModelList = [
  PageViewModel(
    title: "Find Your Perfect Match 💍",
    body:
        "Join thousands of verified profiles and discover your life partner with trust and confidence.",
    image: const Center(
      child: Icon(Icons.favorite, size: 120, color: Colors.pink),
    ),
    decoration: const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      bodyTextStyle: TextStyle(fontSize: 16),
    ),
  ),
  PageViewModel(
    title: "Verified & Secure Profiles 🔐",
    body:
        "All profiles are manually verified to ensure safety, privacy, and genuine connections.",
    image: const Center(
      child: Icon(Icons.verified_user, size: 120, color: Colors.green),
    ),
    decoration: const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      bodyTextStyle: TextStyle(fontSize: 16),
    ),
  ),
  PageViewModel(
    title: "Start Your Journey Today ✨",
    body:
        "Create your profile, connect with matches, and take the first step towards a happy marriage.",
    image: const Center(
      child: Icon(Icons.celebration, size: 120, color: Colors.deepPurple),
    ),
  ),
];

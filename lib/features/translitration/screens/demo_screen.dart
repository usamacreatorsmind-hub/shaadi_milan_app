import 'dart:async';

import 'package:flutter/material.dart';

import '../services/transliteration_service.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final englishController = TextEditingController();
  final hindiController = TextEditingController();

  bool loading = false;

  Future<void> transliterate() async {
    if (englishController.text.isEmpty) return;

    setState(() {
      loading = true;
    });

    try {
      final result = await TransliterationService.transliterate(
        englishController.text,
      );

      hindiController.text = result.result;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Timer? _debounce;
    return Scaffold(
      appBar: AppBar(title: const Text("Transliteration")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              controller: englishController,
              onChanged: (value) {
                _debounce?.cancel();

                _debounce = Timer(
                  const Duration(milliseconds: 600),
                  transliterate,
                );
              },
              decoration: const InputDecoration(labelText: "English"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : transliterate,
              child: const Text("Convert"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: hindiController,
              decoration: const InputDecoration(labelText: "Hindi"),
            ),
          ],
        ),
      ),
    );
  }
}

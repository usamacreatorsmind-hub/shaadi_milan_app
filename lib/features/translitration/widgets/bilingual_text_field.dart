import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/app/custom/custom_widgets/widgets.dart';
import 'package:shadi_milan/features/l10n/app_localizations.dart';

import '../providers/transliteration_provider.dart';

class BilingualTextField extends ConsumerStatefulWidget {
  /// The controller for the Hindi field (or primary field)
  final TextEditingController controller;

  /// Optional controller for the English field. If not provided, an internal one is used.
  final TextEditingController? englishController;

  final String label;
  final String hint;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType keyboardType;

  const BilingualTextField({
    super.key,
    required this.controller,
    this.englishController,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.validator,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  ConsumerState<BilingualTextField> createState() => _BilingualTextFieldState();
}

class _BilingualTextFieldState extends ConsumerState<BilingualTextField> {
  late TextEditingController _englishController;
  Timer? _debounce;
  bool _isTransliterating = false;

  @override
  void initState() {
    super.initState();
    _englishController = widget.englishController ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.englishController == null) {
      _englishController.dispose();
    }
    _debounce?.cancel();
    super.dispose();
  }

  void _onFieldChanged(String value, bool isEnglishInput) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    if (value.isEmpty) {
      if (isEnglishInput) {
        if (widget.controller.text.isNotEmpty) {
          widget.controller.text = "";
        }
      } else {
        if (_englishController.text.isNotEmpty) {
          _englishController.text = "";
        }
      }
      return;
    }

    setState(() => _isTransliterating = true);
    _debounce = Timer(const Duration(milliseconds: 1200), () async {
      try {
        final targetLanguage = isEnglishInput ? 'hi' : 'en';
        final result = await ref
            .read(transliterationProvider)
            .convert(value, targetLanguage: targetLanguage);

        if (mounted) {
          if (isEnglishInput) {
            // Only update if the result is different to avoid cursor jumping and loops
            if (widget.controller.text != result) {
              widget.controller.text = result;
            }
          } else {
            if (_englishController.text != result) {
              _englishController.text = result;
            }
          }
        }
      } catch (e) {
        debugPrint("Transliteration error: $e");
        // We don't show snackbar here anymore to avoid annoying the user if bidirectional isn't 100% supported
      } finally {
        if (mounted) setState(() => _isTransliterating = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // English Field
        AppTextField(
          controller: _englishController,
          label:
              "${widget.label} ${AppLocalizations.of(context)!.englishSuffix}",
          hint: AppLocalizations.of(context)!.transliterateHint,
          prefixIcon: Icons.abc,
          iconColor: Theme.of(context).primaryColor,
          obscureText: false,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          validator: (v) => null,
          onChanged: (v) => _onFieldChanged(v, true),
        ),

        if (_isTransliterating)
          const Padding(
            padding: EdgeInsets.only(left: 20.0, top: 4),
            child: SizedBox(
              height: 2,
              width: 100,
              child: LinearProgressIndicator(),
            ),
          ),

        const SizedBox(height: 12),

        // Hindi Field
        AppTextField(
          controller: widget.controller,
          label: "${widget.label} (हिन्दी)",
          hint: widget.hint,
          prefixIcon: widget.prefixIcon,
          iconColor: Theme.of(context).primaryColor,
          obscureText: false,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          validator: widget.validator,
          onChanged: (v) => _onFieldChanged(v, false),
        ),
      ],
    );
  }
}

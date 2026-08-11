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
  final bool showHindi;

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
    this.showHindi = true,
  });

  @override
  ConsumerState<BilingualTextField> createState() => _BilingualTextFieldState();
}

class _BilingualTextFieldState extends ConsumerState<BilingualTextField> {
  late TextEditingController _englishController;
  Timer? _debounce;
  bool _isTransliterating = false;
  bool _isHindiManuallyEdited = false;

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

    // If user is typing in Hindi, mark it as manually edited to prevent overwrite
    if (!isEnglishInput) {
      _isHindiManuallyEdited = true;
    } else {
      _isHindiManuallyEdited = false;
    }

    setState(() => _isTransliterating = true);
    _debounce = Timer(const Duration(milliseconds: 800), () async {
      try {
        final targetLanguage = isEnglishInput ? 'hi' : 'en';

        // Skip auto-syncing Hindi if user just manually typed in Hindi box
        if (isEnglishInput && _isHindiManuallyEdited) {
          setState(() => _isTransliterating = false);
          return;
        }

        // Clean up the text
        final cleanValue = value.trim().replaceAll(RegExp(r'\s+'), ' ');
        if (cleanValue.isEmpty) {
          setState(() => _isTransliterating = false);
          return;
        }

        final result = await ref.read(transliterationProvider).convert(cleanValue, targetLanguage: targetLanguage);

        if (mounted) {
          if (isEnglishInput) {
            // Only update Hindi if user isn't actively fixing it
            if (widget.controller.text.trim() != result.trim() && !_isHindiManuallyEdited) {
              widget.controller.text = result;
            }
          } else {
            if (_englishController.text.trim() != result.trim()) {
              _englishController.text = result;
            }
          }
        }
      } catch (e) {
        debugPrint("Transliteration error: $e");
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
          label: widget.showHindi ? "${widget.label} ${AppLocalizations.of(context)!.englishSuffix}" : widget.label,
          hint: widget.showHindi ? AppLocalizations.of(context)!.transliterateHint : widget.hint,
          prefixIcon: widget.showHindi ? Icons.abc : widget.prefixIcon,
          iconColor: Theme.of(context).primaryColor,
          obscureText: false,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          validator: (v) => widget.showHindi ? null : widget.validator?.call(v),
          onChanged: (v) => _onFieldChanged(v, true),
        ),

        if (widget.showHindi && _isTransliterating)
          const Padding(
            padding: EdgeInsets.only(left: 20.0, top: 4),
            child: SizedBox(height: 2, width: 100, child: LinearProgressIndicator()),
          ),

        if (widget.showHindi) ...[
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
      ],
    );
  }
}

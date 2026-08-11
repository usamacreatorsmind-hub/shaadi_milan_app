import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';

enum CounterType { words, characters }

class WordLengthFormatter extends TextInputFormatter {
  final int maxWords;

  WordLengthFormatter({required this.maxWords});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final words = newValue.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    if (words.length > maxWords) {
      return oldValue; // 🚫 stop typing
    }
    return newValue; // ✅ allow input
  }
}

class MaxLengthFormatter extends TextInputFormatter {
  final int max;

  MaxLengthFormatter({required this.max});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > max) {
      return oldValue; // 🚫 stop typing
    }
    return newValue; // ✅ allow input
  }
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          padding: padding,
          textStyle: textStyle,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),

          elevation: 0,

          // Add this line to remove the default shadow
          shadowColor: Colors.transparent,

          // Add this line to remove the default shadow
        ),
        child: Text(text),
      ),
    );
  }
}

class AppSwitch extends StatelessWidget {
  final String title;
  final bool value;
  final void Function(bool) onChanged;

  const AppSwitch({super.key, required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Theme.of(context).colorScheme.primary,
      inactiveThumbColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: Theme.of(context).cardColor,

      // secondary: Icon(Icons.lightbulb_outline), // Optional: Add a secondary icon
    );
  }
}

class AppTextField extends ConsumerStatefulWidget {
  final CounterType counterType;

  final TextEditingController? controller;
  final IconData prefixIcon;
  final Color iconColor;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final VoidCallback? ontap;
  final String? Function(String?)? validator;
  final List<String>? autofillHints;

  // 🔹 Word count options
  final bool showWordCount;
  final int? maxLimit; // Unified max limit for words or characters
  final int maxLines;
  final void Function(String)? onChanged;

  final List<TextInputFormatter>? inputFormatters;

  const AppTextField({
    this.counterType = CounterType.words,
    super.key,
    this.controller,
    required this.prefixIcon,
    this.inputFormatters,
    required this.iconColor,
    required this.label,
    required this.hint,
    required this.obscureText,
    this.ontap,
    required this.keyboardType,
    this.validator,
    this.showWordCount = false,
    this.maxLimit, // Unified max limit
    this.maxLines = 1,
    this.onChanged,
    this.autofillHints = const [],
  });

  @override
  ConsumerState<AppTextField> createState() => _TextFormWidgetState();
}

class _TextFormWidgetState extends ConsumerState<AppTextField> {
  int _currentCount = 0;
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
    widget.controller?.addListener(_updateCount);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_updateCount);
    super.dispose();
  }

  void _updateCount() {
    final value = widget.controller?.text ?? '';
    int count;

    if (widget.counterType == CounterType.characters) {
      count = value.length;
    } else {
      final text = value.trim();
      count = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    }

    if (count != _currentCount && mounted) {
      setState(() => _currentCount = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<TextInputFormatter> formatters = [
      ...?widget.inputFormatters,
      if (widget.counterType == CounterType.words && widget.maxLimit != null) WordLengthFormatter(maxWords: widget.maxLimit!),
      if (widget.counterType == CounterType.characters && widget.maxLimit != null) MaxLengthFormatter(max: widget.maxLimit!),
    ];

    String? counterText;
    if (widget.showWordCount) {
      if (widget.counterType == CounterType.words) {
        if (widget.maxLimit != null) {
          counterText = '$_currentCount / ${widget.maxLimit} ${AppLabels.words(context)}';
        } else {
          counterText = '$_currentCount ${AppLabels.words(context)}';
        }
      } else {
        if (widget.maxLimit != null) {
          counterText = '$_currentCount / ${widget.maxLimit} ${AppLabels.characters(context)}';
        } else {
          counterText = '$_currentCount ${AppLabels.characters(context)}';
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: widget.controller,
        onTap: widget.ontap,
        readOnly: widget.ontap != null,
        obscureText: _isObscured,
        inputFormatters: formatters,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        maxLength: widget.counterType == CounterType.characters ? widget.maxLimit : null,
        autofillHints: widget.autofillHints,
        cursorColor: Theme.of(context).colorScheme.primary,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        onChanged: (value) {
          if (widget.showWordCount) {
            _updateCount();
          }
          widget.onChanged?.call(value);
        },
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(_isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
          counterText: counterText,
          counterStyle: TextStyle(
            fontSize: 12,
            color: (widget.maxLimit != null && _currentCount > widget.maxLimit!) ? Colors.red : Colors.grey,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: widget.iconColor.withOpacity(0.15),
              child: Icon(widget.prefixIcon, color: widget.iconColor, size: 20),
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
          ),
        ),
        validator: widget.validator,
      ),
    );
  }
}

class SearchWidget extends ConsumerStatefulWidget {
  const SearchWidget({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends ConsumerState<SearchWidget> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: AppLabels.searchLabel(context),
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }
}

class AppDropDown<T> extends ConsumerStatefulWidget {
  final String label;
  final List<T> items;
  final T? value;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;

  const AppDropDown({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.itemLabel,
    required this.onChanged,
    this.validator,
  });

  @override
  ConsumerState<AppDropDown<T>> createState() => _AppDropDownWidgetState<T>();
}

class _AppDropDownWidgetState<T> extends ConsumerState<AppDropDown<T>> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<T>(
        isExpanded: true,
        value: widget.items.contains(widget.value) ? widget.value : null,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: '${AppLabels.select(context)} ${widget.label.toLowerCase()}',
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              child: Icon(Icons.arrow_drop_down_circle_outlined, color: Theme.of(context).colorScheme.primary, size: 30),
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
          ),
        ),
        items: widget.items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(widget.itemLabel(item), style: const TextStyle(fontSize: 14)),
              ),
            )
            .toList(),
        onChanged: widget.onChanged,
        validator: widget.validator,
      ),
    );
  }
}

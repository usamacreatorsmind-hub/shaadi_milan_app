import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CounterType { words, characters }

class WordLengthFormatter extends TextInputFormatter {
  final int maxWords;

  WordLengthFormatter({required this.maxWords});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final words = newValue.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

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
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),

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

  const AppSwitch({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Theme.of(context).colorScheme.primary,
      inactiveThumbColor: Theme.of(
        context,
      ).colorScheme.onSurface.withOpacity(0.6),
      inactiveTrackColor: Theme.of(
        context,
      ).colorScheme.onSurface.withOpacity(0.3),
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

  // 🔹 Word count options
  final bool showWordCount;
  final int? maxLimit; // Unified max limit for words or characters
  final int maxLines;

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
  });

  @override
  ConsumerState<AppTextField> createState() => _TextFormWidgetState();
}

class _TextFormWidgetState extends ConsumerState<AppTextField> {
  int _currentCount = 0;

  @override
  void initState() {
    super.initState();
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
      if (widget.counterType == CounterType.words && widget.maxLimit != null)
        WordLengthFormatter(maxWords: widget.maxLimit!),
      if (widget.counterType == CounterType.characters &&
          widget.maxLimit != null)
        MaxLengthFormatter(max: widget.maxLimit!),
    ];

    return Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.8,
        child: TextFormField(
          controller: widget.controller,
          onTap: widget.ontap,
          readOnly: widget.ontap != null,
          obscureText: widget.obscureText,
          inputFormatters: formatters,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          maxLength: widget.counterType == CounterType.characters
              ? widget.maxLimit
              : null, // Pass maxLength only for character count
          cursorColor: Theme.of(context).colorScheme.primary,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          onChanged: (value) {
            if (widget.showWordCount) {
              _updateCount();
            }
          },
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            counterText: widget.showWordCount
                ? widget.counterType == CounterType.words
                      ? widget.maxLimit != null
                            ? '$_currentCount / ${widget.maxLimit} words'
                            : '$_currentCount words'
                      : widget.maxLimit != null
                      ? '$_currentCount / ${widget.maxLimit} characters'
                      : '$_currentCount characters'
                : null,
            counterStyle: TextStyle(
              fontSize: 12,
              color:
                  (widget.maxLimit != null && _currentCount > widget.maxLimit!)
                  ? Colors.red
                  : Colors.grey,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: widget.iconColor.withOpacity(0.15),
                child: Icon(
                  widget.prefixIcon,
                  color: widget.iconColor,
                  size: 20,
                ),
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
          ),
          validator:
              widget.validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter ${widget.label.toLowerCase()}';
                }
                return null;
              },
        ),
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
        hintText: "Search",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }
}

class AppDropDown extends ConsumerStatefulWidget {
  final String label;
  final List<String> items;
  final String? value;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;

  const AppDropDown({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  @override
  ConsumerState<AppDropDown> createState() => _AppDropDownWidgetState();
}

class _AppDropDownWidgetState extends ConsumerState<AppDropDown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<String>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: 'Select ${widget.label.toLowerCase()}',
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.15),
            child: Icon(
              Icons.arrow_drop_down_circle_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
      ),
      value: widget.value,

      dropdownStyleData: DropdownStyleData(
        isOverButton: true,
        maxHeight: 200,

        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      ),
      items: widget.items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            ),
          )
          .toList(),
      onChanged: widget.onChanged,
      validator:
          widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please select ${widget.label.toLowerCase()}';
            }
            return null;
          },
    );
  }
}

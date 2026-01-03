import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      activeColor: Theme.of(context).colorScheme.primary,
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
  final TextEditingController? controller;
  final IconData prefixIcon;
  final Color iconColor;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final VoidCallback? ontap;

  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    this.controller,
    required this.prefixIcon,
    required this.iconColor,
    required this.label,
    required this.hint,
    required this.obscureText,
    this.ontap,

    required this.keyboardType,
    this.validator,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TextFormWidgetState();
}

class _TextFormWidgetState extends ConsumerState<AppTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.8,
        child: TextFormField(
          onTap: widget.ontap,

          readOnly: widget.ontap != null,
          cursorColor: Theme.of(context).colorScheme.primary,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
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

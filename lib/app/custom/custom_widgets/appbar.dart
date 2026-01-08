import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Builder(
        builder: (context) {
          final baseTextStyle =
              Theme.of(context).appBarTheme.titleTextStyle ??
              Theme.of(context).textTheme.titleMedium;
          final style = (baseTextStyle ?? const TextStyle()).copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          );
          return Text(title, style: style);
        },
      ),
    );
  }
}

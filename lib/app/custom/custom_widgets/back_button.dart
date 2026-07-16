import 'package:flutter/material.dart';
import 'package:shadi_milan/core/constants/app_constants.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';

class BackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const BackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Text(AppLabels.back(context)),
      ),
    );
  }
}

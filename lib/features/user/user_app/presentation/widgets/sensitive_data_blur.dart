import 'dart:ui';

import 'package:flutter/material.dart';

import 'complete_profile_bottom_sheet.dart';

/// Displays [child] when [isUnlocked] is `true`.
/// When [isUnlocked] is `false` (incomplete profile / View Profiles mode),
/// replaces the sensitive value with a blurred placeholder and lock indicator
/// so private data (Father's name, Mobile, Address, etc.) is never exposed.
class SensitiveDataBlur extends StatelessWidget {
  final bool isUnlocked;
  final Widget child;
  final String maskedPlaceholder;
  final TextStyle? placeholderStyle;
  final VoidCallback? onLockedTap;
  final bool showLockIcon;

  const SensitiveDataBlur({
    super.key,
    required this.isUnlocked,
    required this.child,
    this.maskedPlaceholder = 'Hidden Details',
    this.placeholderStyle,
    this.onLockedTap,
    this.showLockIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isUnlocked) return child;

    final isHindi = Localizations.localeOf(context).languageCode == 'hi';

    return InkWell(
      onTap: onLockedTap ??
          () => CompleteProfileBottomSheet.show(
                context,
                title: isHindi
                    ? 'पूरी जानकारी देखने के लिए प्रोफाइल पूरी करें'
                    : 'Complete Profile to View Details',
                subtitle: isHindi
                    ? 'पिता का नाम, मोबाइल नंबर, पता और अन्य व्यक्तिगत जानकारी देखने के लिए पहले अपनी प्रोफाइल पूरी करें।'
                    : 'Father\'s name, mobile number, address, and personal details are hidden until you complete your profile.',
                showPremiumStep: false,
              ),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 5.5, sigmaY: 5.5),
                child: Text(
                  maskedPlaceholder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: placeholderStyle ??
                      TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                ),
              ),
            ),
          ),
          if (showLockIcon) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.lock_outline_rounded,
              size: 14,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.75),
            ),
          ],
        ],
      ),
    );
  }
}

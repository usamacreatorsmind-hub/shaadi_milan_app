import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/features/l10n/app_localizations.dart';
import 'package:shadi_milan/features/l10n/app_translation_service.dart';

class BilingualValue {
  final String hi;
  final String en;

  BilingualValue({required this.hi, required this.en});

  Map<String, dynamic> toMap() {
    return {'hi': hi, 'en': en};
  }

  factory BilingualValue.fromMap(Map<String, dynamic> map) {
    return BilingualValue(
      hi: map['hi'] as String? ?? '',
      en: map['en'] as String? ?? '',
    );
  }

  factory BilingualValue.empty() => BilingualValue(hi: '', en: '');

  bool get isEmpty => hi.isEmpty && en.isEmpty;
  bool get isNotEmpty => hi.isNotEmpty || en.isNotEmpty;

  @override
  String toString() => 'BilingualValue(hi: $hi, en: $en)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BilingualValue && other.hi == hi && other.en == en;
  }

  @override
  int get hashCode => hi.hashCode ^ en.hashCode;
}


class BilingualParser extends ConsumerWidget {
  const BilingualParser({
    super.key,
    required this.value,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.localeOverride,
    this.softWrap,
    this.overflow,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  final BilingualValue value;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? localeOverride;
  final bool? softWrap;
  final TextOverflow? overflow;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  Widget _buildText(String text) {
    return Text(
      text,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: localeOverride,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    // handle null values by fallback to english
    if (value.hi.isEmpty && value.en.isNotEmpty) {
      return _buildText(value.en);
    }
    if (value.en.isEmpty && value.hi.isNotEmpty) {
      return _buildText(value.hi);
    }
    if (value.hi.isEmpty && value.en.isEmpty) {
      return _buildText('Required');
    }

    return _buildText(locale.languageCode == 'hi' ? value.hi : value.en);
  }
}
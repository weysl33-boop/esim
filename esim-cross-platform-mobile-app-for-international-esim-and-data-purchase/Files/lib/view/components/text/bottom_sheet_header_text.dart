import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/core/utils/style.dart';

class BottomSheetHeaderText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final TextStyle? style;

  const BottomSheetHeaderText({super.key, required this.text, this.textAlign, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.tr,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      style: style ?? regularLarge.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

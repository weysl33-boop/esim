import 'package:esim/view/components/text-form-field/otp_text_field.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/dimensions.dart';

class OTPFieldWidget extends StatelessWidget {
  const OTPFieldWidget({super.key, required this.onChanged});

  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final boxSize = screenSize.width < 400
        ? const Size(42, 42)
        : screenSize.width < 600
            ? const Size(50, 50)
            : const Size(55, 55);
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10),
      child: OtpInputField(
        length: 6,
        fieldSize: boxSize.width, // or 40 for the enable section
        onChanged: (value) => onChanged?.call(value),
        onCompleted: (value) => onChanged?.call(value),
      ),
    );
  }
}

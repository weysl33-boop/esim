import 'package:flutter/material.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/data/model/global/kyc/global_kyc_form_data.dart';
import 'package:esim/view/components/custom_drop_down_button_with_text_field.dart';
import 'package:esim/view/components/text/label_text_with_instructions.dart';

class KycSelectSection extends StatelessWidget {
  GlobalFormModel model;
  Function onChanged;
  KycSelectSection({
    super.key,
    required this.model,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelTextInstruction(
          text: model.name ?? '',
          isRequired: model.isRequired == 'optional' ? false : true,
          instructions: model.instruction,
        ),
        const SizedBox(height: Dimensions.textToTextSpace),
        CustomDropDownWithTextField(
//          borderWidth: .5,
          list: model.options ?? [],
          onChanged: (value) => onChanged(value),
          selectedValue: model.selectedValue,
        ),
        const SizedBox(height: Dimensions.space10)
      ],
    );
  }
}

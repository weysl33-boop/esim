import 'package:flutter/material.dart';
import 'package:esim/data/model/global/kyc/global_kyc_form_data.dart';
import 'package:esim/view/components/custom_radio_button.dart';
import 'package:esim/view/components/text/label_text_with_instructions.dart';

class KycRadioSection extends StatelessWidget {
  GlobalFormModel model;
  Function onChanged;
  int selectedIndex;
  KycRadioSection({
    super.key,
    required this.model,
    required this.onChanged,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelTextInstruction(text: model.name ?? '', isRequired: model.isRequired == 'optional' ? false : true, instructions: model.instruction),
        CustomRadioButton(
          title: model.name,
          selectedIndex: selectedIndex,
          list: model.options ?? [],
          onChanged: (index) => onChanged(index),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:esim/data/model/global/kyc/global_kyc_form_data.dart';
import 'package:esim/view/components/checkbox/custom_check_box.dart';
import 'package:esim/view/components/text/label_text_with_instructions.dart';

class KycCheckBoxSection extends StatelessWidget {
  GlobalFormModel model;
  Function onChanged;
  List<String>? selectedValue;
  KycCheckBoxSection({
    super.key,
    required this.model,
    required this.onChanged,
    required this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelTextInstruction(text: model.name ?? '', isRequired: model.isRequired == 'optional' ? false : true, instructions: model.instruction),
        CustomCheckBox(
          selectedValue: selectedValue,
          list: model.options ?? [],
          onChanged: (value) => onChanged(value),
        ),
      ],
    );
  }
}

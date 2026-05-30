import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/util.dart';
import 'package:esim/data/model/global/kyc/global_kyc_form_data.dart';
import 'package:esim/view/components/text-form-field/custom_text_field.dart';

class KycTextAnEmailSection extends StatelessWidget {
  GlobalFormModel model;
  Function onChanged;

  KycTextAnEmailSection({
    super.key,
    required this.onChanged,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          isRequired: model.isRequired == 'optional' ? false : true,
          instructions: model.instruction,
          hintText: model.selectedValue,
          needOutlineBorder: true,
          labelText: model.name ?? '',
          controller: model.textEditingController,
          // controller: TextEditingController(text: model.selectedValue),
          textInputType: MyUtils.getInputTextFieldType(model.type ?? 'text'),
          validator: (value) {
            if (model.isRequired != 'optional' && value.toString().isEmpty) {
              return '${model.name.toString().capitalizeFirst} ${MyStrings.isRequired}';
            } else {
              return null;
            }
          },
          onChanged: (value) => onChanged(value),
          maxLines: model.type == "textarea" ? 5 : 1,
        ),
        const SizedBox(height: Dimensions.space10),
      ],
    );
  }
}

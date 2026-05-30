import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/data/model/global/kyc/global_kyc_form_data.dart';
import 'package:esim/view/components/text-form-field/custom_text_field.dart';

import '../../../core/helper/string_format_helper.dart' show printX;

class KycDateTimeSection extends StatelessWidget {
  GlobalFormModel model;
  Function onChanged;
  Function onTap;
  TextEditingController? controller;
  KycDateTimeSection({
    super.key,
    required this.model,
    required this.onTap,
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      instructions: model.instruction,
      isRequired: model.isRequired == 'optional' ? false : true,
      hintText: (model.name ?? '').toString().capitalizeFirst,
      needOutlineBorder: true,
      labelText: model.name ?? '',
      controller: controller,
      textInputType: TextInputType.datetime,
      readOnly: true,
      validator: (value) {
        printX(model.isRequired);
        if (model.isRequired != 'optional' && value.toString().isEmpty) {
          return '${model.name.toString().capitalizeFirst} ${MyStrings.isRequired}';
        } else {
          return null;
        }
      },
      onTap: () {
        onTap();
      },
      onChanged: (value) => onChanged(value),
    );
  }
}

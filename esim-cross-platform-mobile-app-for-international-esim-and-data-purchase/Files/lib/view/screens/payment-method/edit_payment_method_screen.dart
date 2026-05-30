import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/style.dart';
import 'package:esim/core/utils/util.dart';
import 'package:esim/data/controller/payment_method/payment_method_controller.dart';
import 'package:esim/data/model/payment_method/payment_method_create_response.dart';
import 'package:esim/data/repo/payment_method/payment_method_repo.dart';
import 'package:esim/data/services/api_service.dart';
import 'package:esim/view/components/app-bar/app_main_appbar.dart';
import 'package:esim/view/components/buttons/rounded_button.dart';
import 'package:esim/view/components/divider/custom_spacer.dart';
import 'package:esim/view/components/dropdown/generic_drop_down.dart';
import 'package:esim/view/components/form_row.dart';
import 'package:esim/view/components/kyc_section/kyc_checkbox_section.dart';
import 'package:esim/view/components/kyc_section/kyc_date_time_section.dart';
import 'package:esim/view/components/kyc_section/kyc_radio_section.dart';
import 'package:esim/view/components/kyc_section/kyc_select_section.dart';
import 'package:esim/view/components/kyc_section/kyc_text_section.dart';
import 'package:esim/view/components/shimmer/history_list_data_shimmer.dart';
import 'package:esim/view/components/text-form-field/custom_text_field.dart';
import 'package:esim/view/screens/auth/kyc/widget/widget/choose_file_list_item.dart';

class EditPaymentMethodScreen extends StatefulWidget {
  const EditPaymentMethodScreen({super.key});

  @override
  State<EditPaymentMethodScreen> createState() => _EditPaymentMethodScreenState();
}

class _EditPaymentMethodScreenState extends State<EditPaymentMethodScreen> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(PaymentMethodRepo());
    final controller = Get.put(PaymentMethodController());
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      controller.editMethod(Get.arguments);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: AppMainAppBar(
        isTitleCenter: true,
        isProfileCompleted: true,
        title: MyStrings.editPaymentMethod,
        bgColor: MyColor.transparentColor,
        titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
        actions: [
          horizontalSpace(Dimensions.space10),
        ],
      ),
      body: GetBuilder<PaymentMethodController>(
        builder: (controller) {
          return controller.isLoading
              ? const HistoryListDataShimmer(length: 10)
              : SingleChildScrollView(
                  padding: Dimensions.screenPaddingHV,
                  child: Column(
                    children: [
                      GenericDropdown<CreatePaymentMethodData>(
                        displayItem: (t) => (t.name ?? '').toLowerCase(),
                        list: controller.paymentMethods,
                        bgColor: MyColor.getScreenBgSecondaryColor(),
                        title: MyStrings.editPaymentMethod,
                        titleStyle: regularLarge.copyWith(color: MyColor.getLabelTextColor()),
                        selectedValue: controller.selectedPaymentMethod.id != "-1" ? controller.selectedPaymentMethod : null,
                        onChanged: (value) {
                          if (value != null && value.id != "-1") {
                            controller.selectPaymentMethod(value);
                          }
                        },
                      ),
                      Visibility(
                        visible: controller.formList.isNotEmpty,
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: List.generate(
                              controller.formList.length,
                              (index) {
                                final model = controller.formList[index];
                                return Column(
                                  children: [
                                    const SizedBox(height: Dimensions.space15),
                                    if (MyUtils.getInputType(model.type ?? 'text')) ...[
                                      KycTextAnEmailSection(
                                        onChanged: (value) {
                                          controller.changeSelectedValue(value, index);
                                        },
                                        model: model,
                                      )
                                    ] else if (model.type == "select") ...[
                                      KycSelectSection(
                                        onChanged: (value) {
                                          controller.changeSelectedValue(value, index);
                                        },
                                        model: model,
                                      )
                                    ] else if (model.type == 'radio') ...[
                                      KycRadioSection(
                                        model: model,
                                        onChanged: (selectedIndex) {
                                          controller.changeSelectedRadioBtnValue(index, selectedIndex);
                                        },
                                        selectedIndex: controller.formList[index].options?.indexOf(model.selectedValue ?? '') ?? 0,
                                      )
                                    ] else if (model.type == "checkbox") ...[
                                      KycCheckBoxSection(
                                        model: model,
                                        onChanged: (value) {
                                          controller.changeSelectedCheckBoxValue(index, value);
                                        },
                                        selectedValue: controller.formList[index].cbSelected,
                                      )
                                    ] else if (model.type == "datetime" || model.type == "date" || model.type == "time") ...[
                                      KycDateTimeSection(
                                        model: model,
                                        onChanged: (value) {
                                          controller.changeSelectedValue(value, index);
                                        },
                                        onTap: () {
                                          printX(model.type);
                                          if (model.type == "time") {
                                            controller.changeSelectedTimeOnlyValue(index, context);
                                          } else if (model.type == "date") {
                                            controller.changeSelectedDateOnlyValue(index, context);
                                          } else {
                                            controller.changeSelectedDateTimeValue(index, context);
                                          }
                                        },
                                        controller: controller.formList[index].textEditingController!,
                                      )
                                    ],
                                    model.type == 'file'
                                        ? Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormRow(label: (model.name ?? '').tr, isRequired: model.isRequired == 'optional' ? false : true),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: Dimensions.textToTextSpace),
                                                child: InkWell(
                                                  borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                                                  onTap: () {
                                                    controller.pickFile(index);
                                                  },
                                                  child: ChooseFileItem(fileName: model.selectedValue ?? MyStrings.chooseFile),
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox(),
                                    const SizedBox(height: Dimensions.space10),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.space15),
                      CustomTextField(
                        animatedLabel: false,
                        needOutlineBorder: true,
                        labelText: MyStrings.remark.tr,
                        hintText: "${MyStrings.remark.tr} (Optional)",
                        onChanged: (value) {},
                        textInputType: TextInputType.text,
                        inputAction: TextInputAction.next,
                        maxLines: 4,
                        controller: controller.remarkController,
                        validator: (value) {
                          return null;
                        },
                      ),
                      const SizedBox(height: Dimensions.space50),
                      RoundedButton(
                        text: "Submit",
                        isLoading: controller.isSubmitLoading,
                        onPress: () {
                          if (formKey.currentState!.validate()) {
                            controller.submitEditMethod();
                          }
                        },
                      )
                    ],
                  ),
                );
        },
      ),
    );
  }
}

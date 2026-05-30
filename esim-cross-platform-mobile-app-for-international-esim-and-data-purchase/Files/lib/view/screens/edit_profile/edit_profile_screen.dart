import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/style.dart';
import '../../../data/controller/account/profile_controller.dart';
import '../../../data/repo/account/profile_repo.dart';
import '../../../data/services/api_service.dart';
import '../../components/app-bar/app_main_appbar.dart';
import '../../components/buttons/rounded_button.dart';
import '../../components/card/app_body_card.dart';
import '../../components/divider/custom_spacer.dart';
import '../../components/text-form-field/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProfileRepo(apiClient: Get.find()));
    final controller = Get.put(ProfileController(profileRepo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadProfileInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) => Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppMainAppBar(
          isTitleCenter: true,
          isProfileCompleted: true,
          title: MyStrings.editProfile.tr,
          bgColor: MyColor.transparentColor,
          titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
          actions: [horizontalSpace(Dimensions.space10)],
        ),
        body: SingleChildScrollView(
          padding: Dimensions.screenPaddingHV,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Edit Details Section
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: Dimensions.space10),
                      child: AppBodyWidgetCard(
                        child: Form(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: Dimensions.space5,
                                    height: Dimensions.space25,
                                    decoration: BoxDecoration(color: MyColor.getPrimaryColor(), borderRadius: BorderRadius.circular(Dimensions.radiusMax)),
                                  ),
                                  horizontalSpace(Dimensions.space10),
                                  Text(MyStrings.profileInformation, style: boldExtraLarge.copyWith(color: MyColor.getPrimaryTextColor())),
                                ],
                              ),
                              verticalSpace(Dimensions.space20),
                              CustomTextField(
                                animatedLabel: false,
                                needOutlineBorder: true,
                                controller: controller.firstNameController,
                                labelText: MyStrings.firstName.tr,
                                onChanged: (value) {},
                                focusNode: controller.firstNameFocusNode,
                                nextFocus: controller.lastNameFocusNode,
                                textInputType: TextInputType.text,
                                inputAction: TextInputAction.next,
                                fillColor: MyColor.getScreenBgColor().withValues(alpha: 0.7),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return MyStrings.fieldErrorMsg.tr;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              verticalSpace(Dimensions.space20),
                              CustomTextField(
                                animatedLabel: false,
                                needOutlineBorder: true,
                                controller: controller.lastNameController,
                                labelText: MyStrings.lastName.tr,
                                onChanged: (value) {},
                                focusNode: controller.lastNameFocusNode,
                                nextFocus: controller.stateFocusNode,
                                textInputType: TextInputType.text,
                                fillColor: MyColor.getScreenBgColor().withValues(alpha: 0.7),
                                inputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return MyStrings.fieldErrorMsg.tr;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              verticalSpace(Dimensions.space20),
                              CustomTextField(
                                readOnly: true,
                                animatedLabel: false,
                                needOutlineBorder: true,
                                controller: controller.emailController,
                                labelText: MyStrings.email.tr,
                                onChanged: (value) {},
                                fillColor: MyColor.getScreenBgColor().withValues(alpha: 0.7),
                                focusNode: controller.emailFocusNode,
                                // nextFocus: controller.passwordFocusNode,
                                textInputType: TextInputType.emailAddress,
                                inputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return MyStrings.fieldErrorMsg.tr;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              verticalSpace(Dimensions.space20),
                              CustomTextField(
                                readOnly: true,
                                animatedLabel: false,
                                needOutlineBorder: true,
                                controller: controller.mobileNoController,
                                labelText: MyStrings.phone.tr,
                                onChanged: (value) {},
                                focusNode: controller.mobileNoFocusNode,
                                // nextFocus: controller.stateFocusNode,
                                textInputType: TextInputType.phone,
                                fillColor: MyColor.getScreenBgColor().withValues(alpha: 0.7),
                                inputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return MyStrings.fieldErrorMsg.tr;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              verticalSpace(Dimensions.space40),
                              Row(
                                children: [
                                  Container(
                                    width: Dimensions.space5,
                                    height: Dimensions.space25,
                                    decoration: BoxDecoration(color: MyColor.getPrimaryColor(), borderRadius: BorderRadius.circular(Dimensions.radiusMax)),
                                  ),
                                  horizontalSpace(Dimensions.space10),
                                  Text(MyStrings.addressInformation.tr, style: boldExtraLarge.copyWith(color: MyColor.getPrimaryTextColor())),
                                ],
                              ),
                              verticalSpace(Dimensions.space20),
                              CustomTextField(
                                animatedLabel: false,
                                needOutlineBorder: true,
                                controller: controller.stateController,
                                labelText: MyStrings.state.tr,
                                onChanged: (value) {},
                                focusNode: controller.stateFocusNode,
                                nextFocus: controller.cityFocusNode,
                                textInputType: TextInputType.text,
                                fillColor: MyColor.getScreenBgColor().withValues(alpha: 0.7),
                                inputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return MyStrings.fieldErrorMsg.tr;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              verticalSpace(Dimensions.space20),
                              CustomTextField(
                                animatedLabel: false,
                                needOutlineBorder: true,
                                controller: controller.cityController,
                                labelText: MyStrings.city.tr,
                                onChanged: (value) {},
                                focusNode: controller.cityFocusNode,
                                nextFocus: controller.zipCodeFocusNode,
                                textInputType: TextInputType.text,
                                fillColor: MyColor.getScreenBgColor().withValues(alpha: 0.7),
                                inputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return MyStrings.fieldErrorMsg.tr;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              verticalSpace(Dimensions.space20),
                              CustomTextField(
                                animatedLabel: false,
                                needOutlineBorder: true,
                                controller: controller.zipCodeController,
                                labelText: MyStrings.zipCode.tr,
                                onChanged: (value) {},
                                focusNode: controller.zipCodeFocusNode,
                                nextFocus: controller.addressFocusNode,
                                textInputType: TextInputType.text,
                                fillColor: MyColor.getScreenBgColor().withValues(alpha: 0.7),
                                inputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return MyStrings.fieldErrorMsg.tr;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              verticalSpace(Dimensions.space20),
                              CustomTextField(
                                animatedLabel: false,
                                needOutlineBorder: true,
                                controller: controller.addressController,
                                labelText: MyStrings.address.tr,
                                onChanged: (value) {},
                                focusNode: controller.addressFocusNode,
                                // nextFocus: controller.lastNameFocusNode,
                                textInputType: TextInputType.text,
                                fillColor: MyColor.getScreenBgColor().withValues(alpha: 0.7),
                                inputAction: TextInputAction.done,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return MyStrings.fieldErrorMsg.tr;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              verticalSpace(Dimensions.space20),
                              RoundedButton(
                                isLoading: controller.isSubmitLoading,
                                horizontalPadding: Dimensions.space10,
                                verticalPadding: Dimensions.space20,
                                text: MyStrings.updateProfile.tr,
                                onPress: () {
                                  controller.updateProfile();
                                },
                                cornerRadius: 8,
                                isOutlined: false,
                                color: MyColor.getPrimaryButtonColor(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

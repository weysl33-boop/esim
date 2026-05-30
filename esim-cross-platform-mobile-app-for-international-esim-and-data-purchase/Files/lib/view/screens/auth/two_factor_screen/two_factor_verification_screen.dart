import 'package:esim/view/components/text-form-field/otp_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/core/route/route.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/style.dart';
import 'package:esim/data/controller/auth/auth/two_factor_controller.dart';
import 'package:esim/data/repo/auth/two_factor_repo.dart';
import 'package:esim/data/services/api_service.dart';
import 'package:esim/view/components/buttons/rounded_button.dart';
import 'package:esim/view/components/will_pop_widget.dart';

import '../../../components/app-bar/app_main_appbar.dart';
import '../../../components/divider/custom_spacer.dart';
import '../../../components/text/default_text.dart';
import '../../../components/text/header_text.dart';

class TwoFactorVerificationScreen extends StatefulWidget {
  const TwoFactorVerificationScreen({super.key});

  @override
  State<TwoFactorVerificationScreen> createState() => _TwoFactorVerificationScreenState();
}

class _TwoFactorVerificationScreenState extends State<TwoFactorVerificationScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(TwoFactorRepo(apiClient: Get.find()));
    final controller = Get.put(TwoFactorController(repo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.isProfileCompleteEnable = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopWidget(
      nextRoute: RouteHelper.authenticationScreen,
      child: Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppMainAppBar(
          showCrossIconInBackBtn: true,
          isTitleCenter: true,
          fromAuth: true,
          isProfileCompleted: true,
          bgColor: MyColor.transparentColor,
          titleStyle: boldOverLarge.copyWith(fontSize: Dimensions.fontOverLarge, color: MyColor.getPrimaryTextColor()),
          actions: [
            horizontalSpace(Dimensions.space10),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space20),
          child: GetBuilder<TwoFactorController>(
              builder: (controller) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: Dimensions.space30),
                        HeaderText(
                          text: MyStrings.twoFactorAuth.tr,
                          textStyle: semiBoldOverLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                        ),
                        const SizedBox(height: Dimensions.space15),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 25), child: DefaultText(text: MyStrings.twoFactorMsg.tr, textAlign: TextAlign.center, textStyle: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()))),
                        const SizedBox(height: Dimensions.space25),
                        OtpInputField(
                          length: 6,
                          onChanged: (value) => controller.updateText(value),
                          onCompleted: (value) => controller.updateText(value),
                        ),
                        const SizedBox(height: Dimensions.space30),
                        RoundedButton(
                          isLoading: controller.submitLoading,
                          text: MyStrings.verify.tr,
                          isDisabled: controller.currentText.trim().length == 6 ? false : true,
                          onPress: () {
                            controller.verifyYourSms(controller.currentText);
                          },
                        ),
                        const SizedBox(height: Dimensions.space30),
                      ],
                    ),
                  )),
        ),
      ),
    );
  }
}

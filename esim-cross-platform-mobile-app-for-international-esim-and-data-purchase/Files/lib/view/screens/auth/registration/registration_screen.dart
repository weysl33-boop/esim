import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/core/route/route.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/data/controller/auth/auth/registration_controller.dart';
import 'package:esim/data/repo/auth/general_setting_repo.dart';
import 'package:esim/data/repo/auth/signup_repo.dart';
import 'package:esim/data/services/api_service.dart';
import 'package:esim/view/components/will_pop_widget.dart';
import 'package:esim/view/screens/auth/registration/widget/registration_form.dart';

import '../../../../core/utils/my_icons.dart';
import '../../../components/divider/custom_divider_with_center_text.dart';
import '../../../components/divider/custom_spacer.dart';
import '../../../components/no_data.dart';
import '../../../components/shimmer/text_field_loading_shimmer.dart';
import '../social_auth/widgets/social_auth_button_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(GeneralSettingRepo(apiClient: Get.find()));
    Get.put(RegistrationRepo(apiClient: Get.find()));
    Get.put(RegistrationController(registrationRepo: Get.find(), generalSettingRepo: Get.find()));

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<RegistrationController>().initData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegistrationController>(
      builder: (controller) => WillPopWidget(
        nextRoute: RouteHelper.authenticationScreen,
        child: Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          body: controller.noInternet
              ? const Center(
                  child: NoDataWidget(
                  text: MyStrings.noInternet,
                ))
              : controller.isLoading
                  ? const TextFieldLoadingShimmer()
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          verticalSpace(Dimensions.space25),
                          //Social Auth
                          Padding(
                            padding: const EdgeInsets.all(Dimensions.space3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //   if (controller.registrationRepo.apiClient.getSocialCredentialsConfigData().google?.status == '1') ...[
                                horizontalSpace(Dimensions.space5),
                                Expanded(
                                  child: SocialAuthButtonWidget(
                                    isLoading: controller.isSocialSubmitLoading && controller.isGoogle,
                                    assetImage: MyIcons.googleIcon,
                                    text: MyStrings.google.tr,
                                    showText: !controller.registrationRepo.apiClient.getSocialCredentialsEnabledAll(),
                                    onPressed: () {
                                      controller.signInWithGoogle();
                                    },
                                  ),
                                ),
                                // ],
                                // if (controller.registrationRepo.apiClient.getSocialCredentialsConfigData().linkedin?.status == '1') ...[
                                horizontalSpace(Dimensions.space5),
                                Expanded(
                                  child: SocialAuthButtonWidget(
                                    isLoading: controller.isSocialSubmitLoading && controller.isLinkedin,
                                    assetImage: MyIcons.linkeDinIcon,
                                    text: MyStrings.linkedin.tr,
                                    showText: !controller.registrationRepo.apiClient.getSocialCredentialsEnabledAll(),
                                    onPressed: () {
                                      controller.signInWithLinkeDin(context);
                                    },
                                  ),
                                )
                              ],
                              // ],
                            ),
                          ),
                          if (controller.registrationRepo.apiClient.isAnySocialLoginEnabled()) ...[
                            CustomDividerWithCenterText(
                              text: MyStrings.orSignInWith.tr,
                              height: 2,
                            ),
                          ],
                          const SizedBox(height: Dimensions.space20),
                          //General Auth
                          const RegistrationForm(),
                          const SizedBox(height: Dimensions.space30),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}

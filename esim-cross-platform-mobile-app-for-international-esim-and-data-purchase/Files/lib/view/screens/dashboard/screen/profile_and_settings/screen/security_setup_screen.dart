import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/core/utils/my_icons.dart';
import 'package:esim/view/components/annotated_region/annotated_region.dart';
import 'package:esim/view/components/bottom-sheet/custom_bottom_sheet_plus.dart';
import 'package:esim/view/screens/dashboard/screen/profile_and_settings/widgets/delete_account_bottom_sheet.dart';

import '../../../../../../core/route/route.dart';
import '../../../../../../core/utils/dimensions.dart';
import '../../../../../../core/utils/my_color.dart';
import '../../../../../../core/utils/my_strings.dart';
import '../../../../../../core/utils/style.dart';
import '../../../../../../data/controller/account/profile_controller.dart';
import '../../../../../../data/controller/profile_and_settings/profile_and_settings_controller.dart';
import '../../../../../../data/repo/account/profile_repo.dart';
import '../../../../../../data/repo/auth/general_setting_repo.dart';
import '../../../../../../data/repo/menu_repo/menu_repo.dart';
import '../../../../../../data/services/api_service.dart';
import '../../../../../components/app-bar/app_main_appbar.dart';
import '../../../../../components/custom_loader/custom_loader.dart';
import '../../../../../components/divider/custom_divider.dart';
import '../../../../../components/divider/custom_spacer.dart';
import '../../../../../components/text/header_text.dart';
import '../widgets/menu_row_widget.dart';

class SecuritySetupScreen extends StatefulWidget {
  const SecuritySetupScreen({super.key});

  @override
  State<SecuritySetupScreen> createState() => _SecuritySetupScreenState();
}

class _SecuritySetupScreenState extends State<SecuritySetupScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));

    Get.put(GeneralSettingRepo(apiClient: Get.find()));

    Get.put(MenuRepo(apiClient: Get.find()));
    Get.put(ProfileRepo(apiClient: Get.find()));
    final profileController = Get.put(ProfileController(profileRepo: Get.find()));
    final controller = Get.put(ProfileAndSettingsController(menuRepo: Get.find(), repo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //profile info

      profileController.loadProfileInfo();
      //load Configure
      controller.loadMenuConfigData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) {
        return AnnotatedRegionWidget(
          statusBarColor: MyColor.colorWhite,
          systemNavigationBarColor: MyColor.colorWhite,
          useDarkTheme: false,
          statusBarBrightness: Brightness.light,
          child: Scaffold(
            backgroundColor: MyColor.getScreenBgColor(),
            appBar: AppMainAppBar(
              bgColor: MyColor.getScreenBgColor(),
              isTitleCenter: true,
              isProfileCompleted: true,
              title: MyStrings.security.tr,
              titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
              actions: [
                horizontalSpace(Dimensions.space10),
              ],
            ),
            body: controller.isLoading
                ? const CustomLoader()
                : SingleChildScrollView(
                    padding: Dimensions.screenPaddingHV,
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      width: double.infinity,
                      // color: Colors.orange,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Details Section

                          verticalSpace(Dimensions.space20),
                          HeaderText(text: MyStrings.security.tr.toUpperCase(), textStyle: regularLarge.copyWith(color: MyColor.getSecondaryTextColor(isReverse: true))),
                          const SizedBox(height: Dimensions.space10),

                          Container(
                            padding: const EdgeInsets.all(Dimensions.space15),
                            decoration: BoxDecoration(
                              color: MyColor.colorWhite,
                              borderRadius: BorderRadius.circular(Dimensions.space12),
                              // boxShadow: MyUtils.getCardShadow(),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                verticalSpace(Dimensions.space10),
                                MenuRowWidget(
                                  image: MyIcons.menuChangePassword,
                                  label: MyStrings.changePassword,
                                  onPressed: () => Get.toNamed(RouteHelper.changePasswordScreen),
                                ),
                                CustomDivider(
                                  space: Dimensions.space15,
                                  color: MyColor.getBorderColor(),
                                ),
                                MenuRowWidget(
                                  image: MyIcons.menuSecurity,
                                  label: MyStrings.twoFactorAuth,
                                  onPressed: () => Get.toNamed(RouteHelper.twoFactorSetupScreen),
                                ),
                                CustomDivider(
                                  space: Dimensions.space15,
                                  color: MyColor.getBorderColor(),
                                ),
                                verticalSpace(Dimensions.space10),
                                MenuRowWidget(
                                  image: MyIcons.block,
                                  iconColor: MyColor.colorRed,
                                  imageSize: 28,
                                  label: MyStrings.deleteAccount,
                                  onPressed: () {
                                    CustomBottomSheetPlus(
                                      isNeedPadding: false,
                                      bgColor: MyColor.transparentColor,
                                      child: const DeleteAccountBottomsheetBody(),
                                    ).show(context);
                                  },
                                ),
                                verticalSpace(Dimensions.space10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/style.dart';
import 'package:esim/data/controller/localization/localization_controller.dart';
import 'package:esim/data/controller/my_language_controller/my_language_controller.dart';
import 'package:esim/data/repo/auth/general_setting_repo.dart';
import 'package:esim/data/services/api_service.dart';
import 'package:esim/view/components/annotated_region/annotated_region.dart';
import 'package:esim/view/components/app-bar/app_main_appbar.dart';
import 'package:esim/view/components/buttons/rounded_button.dart';
import 'package:esim/view/components/custom_loader/custom_loader.dart';
import 'package:esim/view/components/no_data.dart';
import 'package:esim/view/screens/language/widget/language_card.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String comeFrom = '';

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(GeneralSettingRepo(apiClient: Get.find()));
    Get.put(LocalizationController(sharedPreferences: Get.find()));
    final controller = Get.put(MyLanguageController(repo: Get.find(), localizationController: Get.find()));

    comeFrom = Get.arguments ?? '';

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadLanguage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyLanguageController>(
      builder: (controller) => AnnotatedRegionWidget(
        statusBarColor: MyColor.colorWhite,
        systemNavigationBarColor: MyColor.colorWhite,
        useDarkTheme: false,
        statusBarBrightness: Brightness.light,
        child: Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          appBar: AppMainAppBar(
            title: MyStrings.language.tr,
            isTitleCenter: true,
            isProfileCompleted: true,
            titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
          ),
          body: controller.isLoading
              ? const CustomLoader()
              : controller.langList.isEmpty
                  ? const NoDataWidget()
                  : SingleChildScrollView(
                      padding: Dimensions.screenPaddingHV,
                      child: GridView.builder(
                        shrinkWrap: true,
                        addAutomaticKeepAlives: true,
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.vertical,
                        itemCount: controller.langList.length,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: MediaQuery.of(context).size.width > 200 ? 2 : 1, crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: 150),
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () {
                            controller.changeSelectedIndex(index);
                          },
                          child: LanguageCard(
                            index: index,
                            selectedIndex: controller.selectedIndex,
                            langeName: controller.langList[index].languageName,
                            isShowTopRight: true,
                            imagePath: "${controller.languageImagePath}/${controller.langList[index].imageUrl}",
                          ),
                        ),
                      ),
                    ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: Dimensions.space15, horizontal: Dimensions.space15),
            child: RoundedButton(
              text: MyStrings.confirm.tr,
              isLoading: controller.isChangeLangLoading,
              onPress: () {
                controller.changeLanguage(controller.selectedIndex);
              },
            ),
          ),
        ),
      ),
    );
  }
}

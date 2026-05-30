import 'package:esim/core/utils/my_color.dart';
import 'package:esim/core/utils/my_images.dart';
import 'package:esim/core/utils/util.dart';
import 'package:esim/data/controller/localization/localization_controller.dart';
import 'package:esim/data/controller/splash/splash_controller.dart';
import 'package:esim/data/repo/auth/general_setting_repo.dart';
import 'package:esim/data/services/api_service.dart';
import 'package:esim/view/components/annotated_region/annotated_region.dart';
import 'package:esim/view/components/will_pop_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    MyUtils.splashScreen();
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(GeneralSettingRepo(apiClient: Get.find()));
    Get.put(LocalizationController(sharedPreferences: Get.find()));
    final controller = Get.put(SplashController(repo: Get.find(), localizationController: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.gotoNextPage();
    });
  }

  @override
  void dispose() {
    MyUtils.allScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      builder: (controller) => WillPopWidget(
        child: AnnotatedRegionWidget(
          systemNavigationBarColor: MyColor.primaryColor,
          statusBarColor: MyColor.primaryColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          padding: EdgeInsets.zero,
          child: Scaffold(
            backgroundColor: MyColor.primaryColor,
            body: Stack(
              children: [
                Positioned.fill(
                    child: Image.asset(
                  MyImages.backgroundImage,
                  fit: BoxFit.cover,
                )),
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    MyImages.appLogoLight,
                    width: 125,
                    height: 123,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

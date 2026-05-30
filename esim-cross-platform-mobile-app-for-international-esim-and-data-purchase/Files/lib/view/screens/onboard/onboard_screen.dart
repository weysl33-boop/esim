import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_images.dart';
import 'package:esim/core/utils/style.dart';
import 'package:esim/view/components/annotated_region/annotated_region.dart';
import 'package:esim/view/components/buttons/rounded_button.dart';
import 'package:esim/view/components/image/custom_svg_picture.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../../../core/helper/shared_preference_helper.dart';
import '../../../core/route/route.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../data/controller/onbaord/onboard_controller.dart';
import '../../../data/repo/onboard/onboard_repo.dart';
import '../../../data/services/api_service.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({super.key});

  @override
  State<OnBoardScreen> createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  Future<void> _onIntroEnd() async {
    bool isFirstTime = Get.find<ApiClient>().sharedPreferences.getBool(SharedPreferenceHelper.firstTimeOnAppKey) ?? true;

    if (isFirstTime == false) {
      Get.find<ApiClient>().sharedPreferences.setBool(SharedPreferenceHelper.onBoardIsOnKey, false).whenComplete(() {
        Get.offAllNamed(RouteHelper.dashboardScreen, arguments: true);
      });
    } else {
      Get.find<ApiClient>().sharedPreferences.setBool(SharedPreferenceHelper.onBoardIsOnKey, false).whenComplete(() {
        Get.offAllNamed(RouteHelper.authenticationScreen, arguments: false);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(OnboardRepo(apiClient: Get.find()));
    Get.put(OnboardController(onboardRepo: Get.find()));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GetBuilder<OnboardController>(
      builder: (controller) {
        return AnnotatedRegionWidget(
          systemNavigationBarColor: MyColor.screenBgColor,
          statusBarColor: MyColor.transparentColor,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.dark,
          padding: EdgeInsets.zero,
          child: Scaffold(
              backgroundColor: MyColor.transparentColor,
              body: Stack(
                children: [
                  ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [Colors.black, Colors.transparent],
                      ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                    },
                    blendMode: BlendMode.darken,
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            scrollBehavior: const CupertinoScrollBehavior(),
                            controller: controller.pageController,
                            itemCount: controller.onboardList.length,
                            onPageChanged: (int index) {
                              controller.setCurrentIndex(index);
                            },
                            itemBuilder: (_, index) {
                              final item = controller.onboardList[index];

                              return Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(item.image ?? ""),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.space50, horizontal: 20),
                      child: TextButton(
                          onPressed: () {
                            controller.pageController?.animateToPage(
                              controller.onboardList.length - 1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: controller.onboardList.length - 1 == controller.currentIndex
                              ? const SizedBox.shrink()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      MyStrings.skip.tr,
                                      style: semiBoldMediumLarge.copyWith(color: MyColor.colorWhite, fontSize: 15),
                                    ),
                                    CustomSvgPicture(
                                      image: MyImages.doubleArrow,
                                      color: MyColor.colorWhite,
                                    )
                                  ],
                                )),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              controller.onboardList.length,
                              (index) => Container(
                                height: controller.currentIndex == index ? 10 : 8,
                                width: controller.currentIndex == index ? 10 : 8,
                                margin: const EdgeInsets.only(right: Dimensions.space8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: controller.currentIndex == index ? MyColor.colorWhite : MyColor.borderColor.withValues(alpha: .50),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * .04),
                          Text(controller.onboardList[controller.currentIndex].title?.tr ?? "", textAlign: TextAlign.center, style: boldOverLarge.copyWith(fontSize: 24, color: MyColor.colorWhite)),
                          SizedBox(height: size.height * .015),
                          Text(controller.onboardList[controller.currentIndex].value?.tr.toCapitalized() ?? "", textAlign: TextAlign.center, style: regularDefault.copyWith(fontSize: 15, color: MyColor.colorWhite)),
                          SizedBox(height: size.height * .04),
                          RoundedButton(
                            text: MyStrings.continue_,
                            onPress: () {
                              if (controller.currentIndex < controller.onboardList.length - 1) {
                                controller.pageController?.animateToPage(
                                  controller.currentIndex + 1,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                _onIntroEnd(); // last page → navigate
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  MyStrings.continue_,
                                  style: regularDefault.copyWith(fontSize: Dimensions.space17, color: MyColor.colorWhite),
                                ),
                                CustomSvgPicture(
                                  image: MyImages.arrowForward,
                                  color: MyColor.colorWhite,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height * .08,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        );
      },
    );
  }
}

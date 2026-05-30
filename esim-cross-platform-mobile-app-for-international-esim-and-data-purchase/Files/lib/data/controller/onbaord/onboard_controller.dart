import 'package:esim/core/utils/my_images.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/onboard/onboard_model.dart';
import '../../repo/onboard/onboard_repo.dart';

class OnboardController extends GetxController {
  OnboardRepo onboardRepo;

  OnboardController({required this.onboardRepo});

  int currentIndex = 0;
  PageController? pageController = PageController();

  void setCurrentIndex(int index) {
    currentIndex = index;
    update();
  }

  bool isLoading = false;
  List<OnBoard> onboardList = [
    OnBoard(id: "1", title: MyStrings.onboardTitle1, value: MyStrings.onboardDescription1, image: MyImages.onboard1),
    OnBoard(id: "2", title: MyStrings.onboardTitle2, value: MyStrings.onboardDescription2, image: MyImages.onboard2),
    OnBoard(id: "3", title: MyStrings.onboardTitle3, value: MyStrings.onboardDescription3, image: MyImages.onboard3),
  ];
  String onboardImagePath = "";

  int currentIntroScreen = 0;
}

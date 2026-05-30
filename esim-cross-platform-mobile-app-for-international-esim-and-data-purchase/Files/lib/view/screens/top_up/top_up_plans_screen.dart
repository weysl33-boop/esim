import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/core/utils/my_icons.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/style.dart';
import 'package:esim/data/controller/top_up/top_up_controller.dart';
import 'package:esim/data/repo/top_up/top_up_repo.dart';
import 'package:esim/view/components/buttons/rounded_button.dart';
import 'package:esim/view/components/card/custom_app_card.dart';
import 'package:esim/view/components/image/my_local_image_widget.dart';

import '../../../data/model/top_up/top_up_plans_response_model.dart';

class TopUpPlansScreen extends StatefulWidget {
  const TopUpPlansScreen({super.key});

  @override
  State<TopUpPlansScreen> createState() => _TopUpPlansScreenState();
}

class _TopUpPlansScreenState extends State<TopUpPlansScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.put(TopupRepo(apiClient: Get.find()));
    var controller = Get.put(TopUpController(topupRepo: Get.find()));
    controller.selectedPlanId = Get.arguments[0];
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadStoreData();
    });

    // Add scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        // Load more plans when near bottom
        final controller = Get.find<TopUpController>();
        if (controller.hasNextPlan() && !controller.isCountryLoading) {
          controller.getStoreDetails();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TopUpController>(builder: (controller) {
      return Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  toolbarHeight: 50,
                  expandedHeight: 50,
                  pinned: true,
                  backgroundColor: MyColor.colorWhite,
                  leading: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: MyColor.colorBlack,
                      size: 18,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  titleSpacing: 0,
                  title: Text(
                    MyStrings.topUpPlans.tr,
                    style: semiBoldLarge.copyWith(color: MyColor.colorBlack),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: MyColor.getScreenBgColor(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.screenPaddingH),
                          child: Column(
                            children: [
                              ...List.generate(controller.planData.length, (index) {
                                return planCard(
                                  index: index,
                                  planData: controller.planData,
                                  isSelected: controller.selectedIndex == index,
                                  days: controller.planData[index].name ?? '',
                                  price: controller.planData[index].price ?? '',
                                  currency: controller.planData[index].currency ?? 'USD',
                                  isRecommended: index == 3,
                                  onTap: () {
                                    controller.selectedIndex = index;
                                    controller.planId = controller.planData[index].uid.toString();

                                    controller.resetValidCountries();

                                    // Load valid countries for the selected plan
                                    controller.getValidCountries();

                                    controller.update();
                                  },
                                );
                              }),

                              // Loading indicator for pagination
                              if (controller.isCountryLoading && controller.countryPage > 1)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: MyColor.getPrimaryColor(),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.space100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: controller.selectedIndex != -1
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space5),
                child: RoundedButton(
                  isLoading: controller.planLoading,
                  text: MyStrings.continue_,
                  onPress: () {
                    controller.getPlan();
                  },
                  textStyle: semiBoldMediumLarge.copyWith(color: MyColor.colorWhite),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    });
  }
}

Widget planCard({
  required bool isSelected,
  required List<Plan> planData,
  required String days,
  required int index,
  required String price,
  required String currency,
  bool isRecommended = false,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isSelected
            ? const LinearGradient(
                colors: [
                  Color(0xFF2FA965),
                  Color(0xFF28A15F),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isSelected ? null : Colors.white,
        boxShadow: [
          BoxShadow(
            color: MyColor.colorBlack.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// RADIO
          Container(
            height: 22,
            width: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? MyColor.colorWhite : MyColor.bodyTextColor,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      height: 10,
                      width: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: MyColor.colorWhite,
                      ),
                    ),
                  )
                : null,
          ),

          const SizedBox(width: 14),

          /// LEFT INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  days,
                  style: semiBoldMediumLarge.copyWith(fontSize: Dimensions.space17, color: isSelected ? MyColor.colorWhite : MyColor.colorBlack),
                ),
                const SizedBox(height: Dimensions.space4),
                Row(
                  children: [
                    if (planData[index].dataVolume != null && planData[index].dataVolume != "-1") ...[
                      MyLocalImageWidget(imagePath: MyIcons.time, height: Dimensions.space14, width: Dimensions.space14, imageOverlayColor: isSelected ? MyColor.colorWhite.withValues(alpha: .9) : Colors.grey),
                      SizedBox(width: Dimensions.space5),
                      Text(
                        '${StringConverter.dataVolume(planData[index].dataVolume.toString(), isString: true)}',
                        style: regularDefault.copyWith(
                          fontSize: Dimensions.space14,
                          color: isSelected ? MyColor.colorWhite.withValues(alpha: .9) : MyColor.getTextFieldHintColor().withValues(alpha: .6),
                        ),
                      ),
                      Spacer(),
                    ],
                    AppCard(
                      enableShadow: false,
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.space8, vertical: Dimensions.space3),
                      backgroundColor: isSelected ? MyColor.colorWhite : MyColor.getPrimaryColor().withValues(alpha: .1),
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          '${StringConverter.formatNumber(planData[index].price.toString(), precision: 2)} ${planData[index].currency ?? ''}',
                          style: semiBoldLarge.copyWith(
                            color: isSelected ? MyColor.colorBlack.withValues(alpha: .9) : MyColor.getTextFieldHintColor(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (planData[index].voiceQuantity != null && planData[index].voiceQuantity != "0.00") ...[
                  const SizedBox(height: Dimensions.space4),
                  Row(
                    children: [
                      MyLocalImageWidget(imagePath: MyIcons.phoneCall, height: 14, width: 14, imageOverlayColor: isSelected ? MyColor.colorWhite.withValues(alpha: .9) : Colors.grey),
                      SizedBox(width: Dimensions.space5),
                      Text(
                        '${StringConverter.voiceInMinutes(
                          double.tryParse(planData[index].voiceQuantity.toString()) ?? 0.0,
                        )}${planData[index].voiceQuantity != null ? ' ${planData[index].voiceQuantity}' : ''}',
                        style: regularDefault.copyWith(
                          fontSize: Dimensions.space14,
                          color: isSelected ? MyColor.colorWhite.withValues(alpha: .9) : MyColor.getTextFieldHintColor().withValues(alpha: .6),
                        ),
                      ),
                      SizedBox(width: Dimensions.space8),
                      MyLocalImageWidget(imagePath: MyIcons.sms, height: 14, width: 14, imageOverlayColor: isSelected ? MyColor.colorWhite.withValues(alpha: .9) : Colors.grey),
                      SizedBox(width: Dimensions.space5),
                      Text(
                        '${StringConverter.voiceInMinutes(
                          double.tryParse(planData[index].smsQuantity.toString()) ?? 0.0,
                        )} ${MyStrings.sms.tr}',
                        style: regularDefault.copyWith(
                          fontSize: Dimensions.space14,
                          color: isSelected ? MyColor.colorWhite.withValues(alpha: .9) : MyColor.getTextFieldHintColor().withValues(alpha: .6),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

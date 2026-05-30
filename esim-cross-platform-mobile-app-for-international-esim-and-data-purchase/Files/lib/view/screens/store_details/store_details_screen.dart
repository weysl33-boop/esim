import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/core/route/route.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/core/utils/my_icons.dart';
import 'package:esim/core/utils/my_images.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/style.dart';
import 'package:esim/core/utils/url_container.dart';
import 'package:esim/core/utils/util.dart';
import 'package:esim/data/controller/store_details/store_details_controller.dart';
import 'package:esim/data/model/store/store_data_response_model.dart';
import 'package:esim/data/model/store/store_details_data_response_model.dart';
import 'package:esim/data/repo/store/store_details_repo.dart';
import 'package:esim/view/components/buttons/rounded_button.dart';
import 'package:esim/view/components/card/custom_app_card.dart';
import 'package:esim/view/components/custom_loader/custom_loader.dart';
import 'package:esim/view/components/image/my_local_image_widget.dart';
import 'package:esim/view/components/image/my_network_image_widget.dart';
import 'package:esim/view/components/snack_bar/show_custom_snackbar.dart';
import 'package:esim/view/screens/auth/registration/widget/country_bottom_sheet_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreDetailsScreen extends StatefulWidget {
  const StoreDetailsScreen({super.key});

  @override
  State<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends State<StoreDetailsScreen> {
  final ScrollController _scrollController = ScrollController();

  static const double _expandedHeight = 125;

  @override
  void initState() {
    super.initState();

    Get.put(StoreDetailsRepo(apiClient: Get.find()));
    var controller = Get.put(StoreDetailsController(storeDetailsRepo: Get.find()));
    controller.selectedCountryId = Get.arguments[0];
    controller.selectedPlanName = Get.arguments[1];
    controller.fromCampaign = Get.arguments[2] ?? false;
    controller.fromRegion = Get.arguments[3] ?? false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadStoreData();
    });

    // Add scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        // Load more plans when near bottom
        final controller = Get.find<StoreDetailsController>();
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

  double _fadeValue() {
    if (!_scrollController.hasClients) return 1;

    final double offset = _scrollController.offset;
    final double collapsedHeight = kToolbarHeight + MediaQuery.of(context).padding.top;

    return ((_expandedHeight - offset - collapsedHeight) / (_expandedHeight - collapsedHeight)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreDetailsController>(builder: (controller) {
      return Scaffold(
        body: controller.isLoading
            ? CustomLoader()
            : Stack(
                children: [
                  CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverAppBar(
                        toolbarHeight: 80,
                        expandedHeight: _expandedHeight,
                        pinned: true,
                        backgroundColor: Colors.black,
                        leading: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.arrow_back,
                            color: MyColor.colorWhite,
                            size: 25,
                          ),
                          onPressed: () => Get.back(),
                        ),
                        titleSpacing: 0,
                        title: Text(
                          controller.selectedPlanName,
                          style: semiBoldLarge.copyWith(color: MyColor.colorWhite),
                        ),
                        flexibleSpace: LayoutBuilder(
                          builder: (context, constraints) {
                            final fadeValue = _fadeValue();

                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                Opacity(
                                  opacity: fadeValue,
                                  child: controller.selectedPlanName == MyStrings.global
                                      ? MyLocalImageWidget(imagePath: MyImages.globalBg)
                                      : Image.network(
                                          controller.fromCampaign ? controller.campaign?.bannerPath ?? "" : controller.bannnerPath,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Icon(Icons.info_outline),
                                        ),
                                ),
                                Opacity(
                                  opacity: fadeValue * 0.5,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          MyColor.colorBlack.withValues(alpha: .5),
                                          MyColor.getTransparentColor(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Opacity(
                                  opacity: .55,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          MyColor.colorBlack.withValues(alpha: .5),
                                          MyColor.getTransparentColor(),
                                        ],
                                      ),
                                    ),
                                    child: controller.selectedPlanName == MyStrings.global
                                        ? MyLocalImageWidget(imagePath: MyImages.globalBg)
                                        : MyNetworkImageWidget(
                                            imageUrl: controller.fromCampaign ? controller.campaign?.bannerPath ?? "" : controller.bannnerPath,
                                            boxFit: BoxFit.cover,
                                            errorWidget: Icon(
                                              Icons.info_outline,
                                              color: MyColor.colorWhite.withValues(alpha: .7),
                                              size: 30,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          color: MyColor.getScreenBgColor(),
                          child: Column(
                            children: [
                              const SizedBox(height: Dimensions.space40),

                              controller.selectedIndex == -1
                                  ? SizedBox()
                                  : AppCard(
                                      onTap: () {
                                        CountryBottomSheetPlus.showValidCountriesBottomSheet(context);
                                      },
                                      shadow: BoxShadow(
                                        color: MyColor.secondaryColor950.withValues(alpha: .03),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 3),
                                      ),
                                      margin: EdgeInsetsDirectional.symmetric(horizontal: Dimensions.screenPaddingH),
                                      padding: const EdgeInsetsDirectional.symmetric(vertical: Dimensions.space10, horizontal: Dimensions.space8),
                                      child: controller.isRegionLoading
                                          ? CustomLoader()
                                          : Row(
                                              children: [
                                                Builder(
                                                  builder: (context) {
                                                    final countriesData = controller.countries?.data ?? const <Datum>[];
                                                    return Stack(
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        if (countriesData.isNotEmpty)
                                                          ClipRRect(
                                                            borderRadius: BorderRadius.circular(Dimensions.space100),
                                                            child: MyNetworkImageWidget(
                                                              height: Dimensions.space25,
                                                              width: Dimensions.space25,
                                                              boxFit: BoxFit.fill,
                                                              imageUrl: countriesData[0].image == null || countriesData[0].image!.isEmpty ? UrlContainer.countryFlagImageLink.replaceAll("{countryCode}", (countriesData[0].code ?? '').toLowerCase()) : "${countriesData[0].image}",
                                                              errorWidget: MyLocalImageWidget(
                                                                imagePath: MyIcons.globe,
                                                                height: Dimensions.space25,
                                                                width: Dimensions.space25,
                                                              ),
                                                            ),
                                                          ),
                                                        if (countriesData.length > 1)
                                                          Positioned(
                                                            left: Dimensions.space12,
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(Dimensions.space100),
                                                              child: MyNetworkImageWidget(
                                                                height: Dimensions.space25,
                                                                width: Dimensions.space25,
                                                                boxFit: BoxFit.fill,
                                                                imageUrl: countriesData[1].image == null || countriesData[1].image!.isEmpty ? UrlContainer.countryFlagImageLink.replaceAll("{countryCode}", (countriesData[1].code ?? '').toLowerCase()) : "${countriesData[1].image}",
                                                                errorWidget: MyLocalImageWidget(
                                                                  imagePath: MyIcons.globe,
                                                                  height: Dimensions.space25,
                                                                  width: Dimensions.space25,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        if (countriesData.length > 2)
                                                          Positioned(
                                                            left: Dimensions.space25,
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(Dimensions.space100),
                                                              child: MyNetworkImageWidget(
                                                                height: Dimensions.space25,
                                                                width: Dimensions.space25,
                                                                boxFit: BoxFit.fill,
                                                                imageUrl: countriesData[2].image == null || countriesData[2].image!.isEmpty ? UrlContainer.countryFlagImageLink.replaceAll("{countryCode}", (countriesData[2].code ?? '').toLowerCase()) : "${countriesData[2].image}",
                                                                errorWidget: MyLocalImageWidget(
                                                                  imagePath: MyIcons.globe,
                                                                  height: Dimensions.space25,
                                                                  width: Dimensions.space25,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                                const SizedBox(width: Dimensions.space30),
                                                Text(MyStrings.seeValidCountries.tr, style: semiBoldLarge.copyWith(fontWeight: FontWeight.w500)),
                                                const Spacer(),
                                                const Icon(Icons.chevron_right, color: Colors.grey),
                                              ],
                                            ),
                                    ),

                              const SizedBox(height: Dimensions.screenPaddingH),

                              // Info message
                              controller.understand
                                  ? SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: AppCard(
                                        shadow: BoxShadow(
                                          color: MyColor.secondaryColor950.withValues(alpha: .03),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 3),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(Icons.info, color: MyColor.colorBlue, size: 20),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    MyStrings.globalPlanMessage.tr,
                                                    style: regularDefault,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: Dimensions.space5),
                                            Padding(
                                              padding: EdgeInsets.only(left: 32),
                                              child: GestureDetector(
                                                onTap: () {
                                                  controller.changeUnderstand();
                                                },
                                                child: Text(
                                                  MyStrings.iUnderstand.tr,
                                                  style: semiBoldLarge.copyWith(color: MyColor.colorBlue),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              const SizedBox(height: Dimensions.screenPaddingH),

                              // Plan list
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
                                          controller.selectPlan(index);
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
                  controller.fromCampaign
                      ? SizedBox()
                      : AnimatedBuilder(
                          animation: _scrollController,
                          builder: (context, child) {
                            final double fade = _fadeValue();
                            final double offset = _scrollController.hasClients ? _scrollController.offset : 0;

                            return Positioned(
                              top: _expandedHeight - 5 - offset,
                              left: 0,
                              right: 0,
                              child: IgnorePointer(
                                child: Opacity(
                                  opacity: fade,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(Dimensions.space100),
                                        child: MyNetworkImageWidget(
                                          height: Dimensions.space50,
                                          width: Dimensions.space50,
                                          boxFit: BoxFit.fill,
                                          imageUrl: controller.imagePath,
                                          errorWidget: MyLocalImageWidget(
                                            imagePath: MyIcons.globe,
                                            height: Dimensions.space45,
                                            width: Dimensions.space45,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                  // Initial loading overlay
                  if (controller.isLoading)
                    Container(
                      color: MyColor.colorBlack.withValues(alpha: .3),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: MyColor.getPrimaryColor(),
                        ),
                      ),
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
                    if (!controller.checkUserIsLoggedInOrNot()) {
                      Get.toNamed(RouteHelper.authenticationScreen, arguments: true);
                      MyUtils.vibrationOn();
                      CustomSnackBar.error(
                        errorList: [MyStrings.youHaveToLoginFirst],
                      );
                      return;
                    }
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
  required List<PlanData> planData,
  required String days,
  required int index,
  required String price,
  required String currency,
  bool isRecommended = false,
  VoidCallback? onTap,
}) {
  double actualPrice = double.tryParse(planData[index].price ?? "") ?? 0.0;
  double discountPercentage = double.tryParse(planData[index].campaign?.discount ?? "") ?? 0.0;
  double discountPrice = (actualPrice / 100) * (discountPercentage);
  double afterDiscountPrice = (actualPrice - discountPrice);
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
                        child: Column(
                          children: [
                            Get.find<StoreDetailsController>().fromCampaign
                                ? Text(
                                    '${StringConverter.formatNumber(actualPrice.toString(), precision: 2)} ${planData[index].currency ?? ''}',
                                    style: semiBoldLarge.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: MyColor.redCancelTextColor,
                                      decorationThickness: 2,
                                      color: isSelected ? MyColor.colorBlack.withValues(alpha: .9) : MyColor.getTextFieldHintColor(),
                                    ),
                                  )
                                : SizedBox(),
                            Text(
                              '${StringConverter.formatNumber(Get.find<StoreDetailsController>().fromCampaign ? afterDiscountPrice.toString() : planData[index].price.toString(), precision: 2)} ${planData[index].currency ?? ''}',
                              style: semiBoldLarge.copyWith(
                                color: isSelected ? MyColor.colorBlack.withValues(alpha: .9) : MyColor.getTextFieldHintColor(),
                              ),
                            ),
                          ],
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
                        )}${planData[index].voiceUnit != null ? ' ${planData[index].voiceUnit}' : ''}',
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

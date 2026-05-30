import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/data/model/store/store_details_data_response_model.dart';

import '../../../core/route/route.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_icons.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/style.dart';
import '../../../data/controller/deposit/deposit_controller.dart';
import '../../../data/model/top_up/top_up_plans_response_model.dart';
import '../../../data/repo/deposit/deposit_repo.dart';
import '../../../data/services/api_service.dart';
import '../../components/app-bar/app_main_appbar.dart';
import '../../components/divider/custom_spacer.dart';
import '../../components/image/my_local_image_widget.dart';
import 'widgets/wallet/deposit_screen_all_wallet_widget.dart';

class DepositScreen extends StatefulWidget {
  final List<PlanData>? planData;
  final String planId;
  final String price;
  final String uid;
  final List<Plan>? topupPlans;
  final int initialTabIndex;
  final bool forceTopUpMode;
  final bool? returnToDepositWallet;

  const DepositScreen({
    super.key,
    this.planData,
    this.planId = '',
    this.price = '',
    this.uid = '',
    this.topupPlans,
    this.initialTabIndex = 0,
    this.forceTopUpMode = false,
    this.returnToDepositWallet,
  });

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  @override
  void initState() {
    super.initState();

    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(DepositRepo(apiClient: Get.find()));
    var controller = Get.put(DepositController(depositRepo: Get.find()));
    controller.loadDepositTabsData();
    controller.initializePlanData(widget.planData ?? [], widget.planId, widget.price, shouldUpdate: false);
    controller.setTopUpMode(widget.forceTopUpMode, shouldUpdate: false);
    controller.changeTabIndex(
      widget.returnToDepositWallet == true ? 1 : widget.initialTabIndex,
      shouldUpdate: false,
      shouldAnimate: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.update();
      controller.getDepositAllMethodAndCurrencyList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DepositController>(builder: (controller) {
      return Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          appBar: AppMainAppBar(
            isTitleCenter: true,
            isProfileCompleted: true,
            title: MyStrings.paymentDetails.tr,
            bgColor: MyColor.transparentColor,
            titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
            actions: [
              if (controller.checkUserIsLoggedInOrNot()) ...[
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: Dimensions.space15),
                  child: Ink(
                    decoration: ShapeDecoration(
                      color: MyColor.getAppBarBackgroundColor(),
                      shape: const CircleBorder(),
                    ),
                    child: FittedBox(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          if (controller.checkUserIsLoggedInOrNot()) {
                            Get.toNamed(
                              RouteHelper.depositHistoryScreen,
                            );
                          } else {
                            Get.toNamed(RouteHelper.authenticationScreen);
                          }
                        },
                        icon: MyLocalImageWidget(
                          imagePath: MyIcons.historyIcon,
                          imageOverlayColor: MyColor.getAppBarContentColor(),
                          width: Dimensions.space25,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              horizontalSpace(Dimensions.space10),
            ],
          ),
          body: Column(
            children: [
              verticalSpace(Dimensions.space10),
              if (controller.isTopUp) ...[DepositScreenAllWalletFrom(controller: controller, walletType: 'direct', selectedCurrencyFromParamsID: widget.planId, planId: widget.planId, uid: widget.uid)],
              if (!controller.isTopUp) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
                  padding: const EdgeInsets.all(Dimensions.space8),
                  decoration: BoxDecoration(
                    color: MyColor.getScreenBgSecondaryColor(),
                    borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                  ),
                  child: TabBar(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: controller.depositTabController,
                    splashBorderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: MyColor.getPrimaryColor(),
                      borderRadius: const BorderRadiusDirectional.all(
                        Radius.circular(Dimensions.cardRadius2),
                      ),
                    ),
                    labelColor: MyColor.colorWhite,
                    labelStyle: regularLarge.copyWith(color: MyColor.colorWhite, fontSize: Dimensions.fontLarge),
                    //Unselected
                    unselectedLabelColor: MyColor.getSecondaryTextColor(),
                    unselectedLabelStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge),
                    onTap: (value) => controller.changeTabIndex(value),
                    padding: EdgeInsets.zero,
                    tabs: [
                      Tab(text: MyStrings.directPayment.tr),
                      Tab(text: MyStrings.esimWallets.tr),
                    ],
                  ),
                ),

                // Tab bar

                Expanded(
                  child: TabBarView(physics: const NeverScrollableScrollPhysics(), controller: controller.depositTabController, children: [
                    DepositScreenAllWalletFrom(controller: controller, walletType: 'direct', selectedCurrencyFromParamsID: widget.planId, planId: widget.planId, uid: widget.uid),
                    DepositScreenAllWalletFrom(controller: controller, walletType: 'wallet', selectedCurrencyFromParamsID: widget.planId, planId: widget.planId, uid: widget.uid),
                  ]),
                ),
              ]
            ],
          ));
    });
  }
}

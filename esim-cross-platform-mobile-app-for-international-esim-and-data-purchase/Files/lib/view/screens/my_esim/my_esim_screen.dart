import 'package:esim/core/utils/my_icons.dart';
import 'package:esim/data/controller/home/home_controller.dart';
import 'package:esim/view/components/image/my_local_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/core/route/route.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/style.dart';
import 'package:esim/data/controller/my_esim/my_esim_controller.dart';
import 'package:esim/data/model/my_esim/active_esim_response_model.dart';
import 'package:esim/data/repo/my_esim/my_esim_repo.dart';
import 'package:esim/view/components/card/custom_app_card.dart';
import 'package:esim/view/components/custom_loader/custom_loader.dart';
import 'package:esim/view/components/image/my_network_image_widget.dart';
import 'package:esim/view/components/no_data.dart';
import 'package:esim/view/components/shimmer/match_card_shimmer.dart';

class MyEsimScreen extends StatefulWidget {
  const MyEsimScreen({super.key});

  @override
  State<MyEsimScreen> createState() => _MyEsimScreenState();
}

class _MyEsimScreenState extends State<MyEsimScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _activeScrollController = ScrollController();
  final ScrollController _expiredScrollController = ScrollController();
  @override
  void initState() {
    super.initState();

    Get.put(MyEsimRepo(apiClient: Get.find()));
    Get.put(MyEsimController(myEsimRepo: Get.find()));
    _tabController = TabController(length: 2, vsync: this);

    _activeScrollController.addListener(_handleActivePagination);
    _expiredScrollController.addListener(_handleExpiredPagination);
  }

  void _handleActivePagination() {
    if (!_activeScrollController.hasClients) return;
    if (_activeScrollController.position.pixels >= _activeScrollController.position.maxScrollExtent - 200) {
      final controller = Get.find<MyEsimController>();
      if (controller.hasNextPlan() && !controller.esimPageLoading) {
        controller.getMyEsimController();
      }
    }
  }

  void _handleExpiredPagination() {
    if (!_expiredScrollController.hasClients) return;
    if (_expiredScrollController.position.pixels >= _expiredScrollController.position.maxScrollExtent - 200) {
      final controller = Get.find<MyEsimController>();
      if (controller.hasNextExpiredEsimPlan() && !controller.expiredEsimPageLoading) {
        controller.getMyExpiredEsimController();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _activeScrollController.dispose();
    _expiredScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyEsimController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          body: controller.isLoading
              ? CustomLoader()
              : SafeArea(
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverAppBar(
                          backgroundColor: MyColor.getScreenBgColor(),
                          elevation: 0,
                          pinned: false,
                          floating: false,
                          expandedHeight: 65,
                          automaticallyImplyLeading: false,
                          flexibleSpace: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.screenPaddingH,
                                vertical: Dimensions.screenPaddingV,
                              ),
                              child: Text(
                                MyStrings.myEsims.tr,
                                style: semiBoldOverLarge.copyWith(
                                  fontSize: Dimensions.space25,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _StoreHeaderDelegate(
                            tabController: _tabController,
                          ),
                        ),
                      ];
                    },
                    body: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.screenPaddingH),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          RefreshIndicator(
                            color: MyColor.primaryColor,
                            onRefresh: () async {
                              controller.loadStoreData(shouldLoad: false);
                            },
                            child: _buildActiveListView(controller),
                          ),
                          RefreshIndicator(
                            color: MyColor.primaryColor,
                            onRefresh: () async {
                              controller.loadStoreData(shouldLoad: false);
                            },
                            child: _buildExpiredListView(controller),
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

  Widget _buildActiveListView(MyEsimController controller) {
    if (controller.isLoading || !controller.hasInitialDataLoaded) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 8,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return const MatchCardShimmer();
        },
      );
    }

    // Show no data widget if list is empty
    if (controller.activeEsimData.isEmpty) {
      return Center(
        child: NoDataWidget(
          text: MyStrings.noDataFound.tr,
        ),
      );
    }

    return ListView.builder(
      controller: _activeScrollController,
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: EdgeInsets.only(top: Dimensions.space15, bottom: Dimensions.space20),
      itemCount: controller.activeEsimData.length + (controller.hasNextPlan() ? 1 : 0),
      itemBuilder: (context, index) {
        if (controller.activeEsimData.length == index) {
          return controller.hasNextPlan() ? const CustomLoader(isPagination: true) : const SizedBox();
        }

        final esim = controller.activeEsimData[index];
        return _buildActiveEsimCard(esim);
      },
    );
  }

  Widget _buildActiveEsimCard(ActiveESIMPlanData esim) {
    // Extract plan name (country/region)
    String planName = esim.orderItem?.plan?.name ?? "";

    return InkWell(
      onTap: () {
        Get.toNamed(RouteHelper.myEsimDetailsScreen, arguments: [esim.id.toString()]);
      },
      borderRadius: BorderRadius.circular(Dimensions.space12),
      child: AppCard(
        margin: EdgeInsets.only(bottom: Dimensions.space12),
        padding: EdgeInsets.all(Dimensions.space16),
        shadow: BoxShadow(
          color: MyColor.colorBlack.withValues(alpha: .03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country/Region name with status indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  planName,
                  style: semiBoldDefault.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: MyColor.colorBlack,
                  ),
                ),
                MyNetworkImageWidget(
                  imageUrl: esim.image ?? "",
                  width: Dimensions.space30,
                  height: Dimensions.space30,
                  radius: Dimensions.space100,
                  isCountry: true,
                  errorWidget: MyLocalImageWidget(
                    imagePath: MyIcons.globe,
                    height: Dimensions.space30,
                    width: Dimensions.space30,
                  ),
                ),
              ],
            ),

            SizedBox(height: Dimensions.space10),

            // Data remaining - prominent display
            Text(
              esim.readableDataVolume ?? "0",
              style: semiBoldLarge.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: MyColor.colorBlack,
                height: 1.0,
              ),
            ),
            SizedBox(height: Dimensions.space8),
            // Expiry date
            Text(
              '${MyStrings.expiresOn} ${esim.expiryDate}',
              style: regularDefault.copyWith(
                fontSize: 13,
                color: MyColor.colorBlack.withValues(alpha: .5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiredListView(MyEsimController controller) {
    if (controller.isLoading || !controller.hasInitialDataLoaded) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 8,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return const MatchCardShimmer();
        },
      );
    }
    // Show no data widget if list is empty
    if (controller.expiredEsimData.isEmpty) {
      return Center(
        child: NoDataWidget(
          text: MyStrings.noDataFound.tr,
        ),
      );
    }

    return ListView.builder(
      controller: _expiredScrollController,
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: EdgeInsets.only(top: Dimensions.space15, bottom: Dimensions.space20),
      itemCount: controller.expiredEsimData.length + (controller.hasNextExpiredEsimPlan() ? 1 : 0),
      itemBuilder: (context, index) {
        if (controller.expiredEsimData.length == index) {
          return controller.hasNextExpiredEsimPlan() ? const CustomLoader(isPagination: true) : const SizedBox();
        }
        final esim = controller.expiredEsimData[index];
        return _buildExpiredEsimCard(esim);
      },
    );
  }

  Widget _buildExpiredEsimCard(ActiveESIMPlanData esim) {
    return AppCard(
      onTap: () {
        Get.toNamed(RouteHelper.myEsimDetailsScreen, arguments: [esim.id.toString()]);
      },
      margin: EdgeInsets.only(bottom: Dimensions.space16),
      shadow: BoxShadow(
        color: MyColor.colorBlack.withValues(alpha: .04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expired badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      esim.orderItem?.plan?.name ?? "",
                      style: semiBoldLarge.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MyColor.colorBlack.withValues(alpha: .8),
                      ),
                    ),
                    SizedBox(height: Dimensions.space5),
                    Text(
                      "${StringConverter.formatNumber(esim.price ?? "")} ${Get.find<HomeController>().defaultCurrency}",
                      style: regularDefault.copyWith(
                        color: MyColor.bodyTextColor.withValues(alpha: .5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.space12,
                  vertical: Dimensions.space7,
                ),
                decoration: BoxDecoration(
                  color: MyColor.redCancelTextColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(Dimensions.space20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 14, color: MyColor.redCancelTextColor),
                    SizedBox(width: Dimensions.space5),
                    Text(
                      MyStrings.expired,
                      style: semiBoldDefault.copyWith(
                        color: MyColor.redCancelTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: Dimensions.space15),

          // Usage Summary
          Container(
            padding: EdgeInsets.all(Dimensions.space15),
            decoration: BoxDecoration(
              color: MyColor.colorGrey.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(Dimensions.space12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      MyStrings.expiredOn.tr,
                      style: regularDefault.copyWith(
                        color: MyColor.colorBlack.withValues(alpha: .6),
                      ),
                    ),
                    Text(
                      esim.formattedExpiryDate ?? "",
                      style: semiBoldDefault.copyWith(
                        color: MyColor.colorRed.withValues(alpha: .8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: Dimensions.space15),

          // Renew Button
        ],
      ),
    );
  }
}

class _StoreHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  _StoreHeaderDelegate({required this.tabController});

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: MyColor.getScreenBgColor(),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.screenPaddingH, vertical: 10),
      child: Container(
        height: Dimensions.space45,
        padding: const EdgeInsets.all(Dimensions.space5),
        decoration: BoxDecoration(
          color: MyColor.getCardBgColor(),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: MyColor.colorBlack.withValues(alpha: .04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          controller: tabController,
          indicator: BoxDecoration(
            color: MyColor.getPrimaryColor(),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: EdgeInsets.zero,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: MyColor.colorWhite,
          labelStyle: semiBoldDefault.copyWith(fontSize: 14),
          unselectedLabelColor: MyColor.colorBlack.withValues(alpha: .6),
          unselectedLabelStyle: semiBoldDefault.copyWith(fontSize: 14),
          dividerColor: MyColor.getTransparentColor(),
          tabs: [
            Tab(text: MyStrings.active.tr),
            Tab(text: MyStrings.expired.tr),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

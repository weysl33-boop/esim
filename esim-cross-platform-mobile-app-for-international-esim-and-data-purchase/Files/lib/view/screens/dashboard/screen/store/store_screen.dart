import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/core/utils/my_icons.dart';
import 'package:esim/core/utils/url_container.dart';
import 'package:esim/view/components/image/my_local_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/core/route/route.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/style.dart';
import 'package:esim/data/controller/home/home_controller.dart';
import 'package:esim/data/controller/store/store_controller.dart';
import 'package:esim/data/repo/store/store_repo.dart';
import 'package:esim/view/components/card/custom_app_card.dart';
import 'package:esim/view/components/custom_loader/custom_loader.dart';
import 'package:esim/view/components/image/my_network_image_widget.dart';
import 'package:esim/view/components/no_data.dart';
import 'package:esim/view/components/shimmer/match_card_shimmer.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Scroll controllers for pagination
  final ScrollController _countryScrollController = ScrollController();
  final ScrollController _regionScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        Get.find<StoreController>().onTabChanged(_tabController.index);
      }
    });
    Get.put(StoreRepo(apiClient: Get.find()));
    var controller = Get.put(StoreController(storeRepo: Get.find()));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadStoreData();

      // Add scroll listeners for pagination
      _countryScrollController.addListener(_countryScrollListener);
      _regionScrollController.addListener(_regionScrollListener);
    });
  }

  // Country scroll listener for pagination
  void _countryScrollListener() {
    if (_countryScrollController.position.pixels == _countryScrollController.position.maxScrollExtent) {
      if (Get.find<StoreController>().hasNextCountry() && !Get.find<StoreController>().isCountryFetching) {
        Get.find<StoreController>().getCountries(shouldLoad: false);
      }
    }
  }

  // Region scroll listener for pagination
  void _regionScrollListener() {
    if (_regionScrollController.position.pixels == _regionScrollController.position.maxScrollExtent) {
      if (Get.find<StoreController>().hasNextRegion() && !Get.find<StoreController>().isRegionFetching) {
        Get.find<StoreController>().getRegions(shouldLoad: false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _countryScrollController.dispose();
    _regionScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          body: controller.isLoading
              ? CustomLoader()
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        backgroundColor: MyColor.getScreenBgColor(),
                        elevation: 0,
                        pinned: false,
                        floating: false,
                        expandedHeight: 60,
                        automaticallyImplyLeading: false,
                        flexibleSpace: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.screenPaddingH,
                              vertical: Dimensions.screenPaddingV,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                MyStrings.store.tr,
                                style: semiBoldOverLarge.copyWith(
                                  fontSize: Dimensions.space25,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _StoreHeaderDelegate(
                          tabController: _tabController,
                          searchController: _searchController, // pass controller
                          onSearchChanged: (value) {
                            Get.find<StoreController>().onSearchChanged(value);
                          },
                        ),
                      ),
                    ];
                  },
                  body: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.screenPaddingH),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Countries Tab
                        RefreshIndicator(
                          color: MyColor.getPrimaryColor(),
                          onRefresh: () async {
                            await controller.refreshData(shouldLoad: false);
                          },
                          child: _buildCountryListView(controller),
                        ),
                        // Regions Tab
                        RefreshIndicator(
                          color: MyColor.getPrimaryColor(),
                          onRefresh: () async {
                            await controller.refreshData(shouldLoad: false);
                          },
                          child: _buildRegionsListView(controller),
                        ),
                        // Global Tab
                        RefreshIndicator(
                          color: MyColor.getPrimaryColor(),
                          onRefresh: () async {
                            await controller.refreshData(shouldLoad: false);
                          },
                          child: _buildGlobalListView(controller),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildCountryListView(StoreController controller) {
    final showInitialLoading = controller.isCountryLoading || (!controller.hasLoadedCountry && controller.isCountryFetching);
    if (showInitialLoading) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 10,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return const MatchCardShimmer();
        },
      );
    }

    if (controller.hasLoadedCountry && !controller.isCountryFetching && controller.countryList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          const SizedBox(height: 220),
          Center(
            child: NoDataWidget(
              text: MyStrings.noDataFound.tr,
            ),
          ),
        ],
      );
    }

    final showPaginationSlot = controller.hasNextCountry() || (controller.isCountryFetching && controller.countryList.isNotEmpty);

    return ListView.builder(
      controller: _countryScrollController,
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: controller.countryList.length + (showPaginationSlot ? 1 : 0),
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      itemBuilder: (context, index) {
        if (controller.countryList.length == index) {
          return controller.isCountryFetching && controller.countryList.isNotEmpty ? const CustomLoader(isPagination: true) : const SizedBox.shrink();
        }

        final country = controller.countryList[index];

        return AppCard(
          onTap: () {
            Get.toNamed(RouteHelper.storeDetailsScreen, arguments: [country.id.toString(), country.name ?? "", false, false]);
          },
          shadow: BoxShadow(
            color: MyColor.colorBlack.withValues(alpha: .03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
          margin: const EdgeInsets.only(bottom: Dimensions.space18),
          padding: EdgeInsets.zero,
          enableShadow: true,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.space100),
              child: MyNetworkImageWidget(
                height: Dimensions.space45,
                width: Dimensions.space45,
                boxFit: BoxFit.fill,
                imageUrl: country.image == null || country.image!.isEmpty ? UrlContainer.countryFlagImageLink.replaceAll("{countryCode}", (country.code ?? '').toLowerCase()) : "${country.image}",
                errorWidget: MyLocalImageWidget(
                  imagePath: MyIcons.globe,
                  height: Dimensions.space45,
                  width: Dimensions.space45,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  country.name ?? "",
                  style: semiBoldMediumLarge,
                ),
                Text(
                  "${MyStrings.startsFrom.tr}  ${Get.find<HomeController>().defaultCurrencySymbol.toString()}${StringConverter.formatDouble(country.startsFrom ?? "", precision: 2)} ${Get.find<HomeController>().defaultCurrency.toString()}",
                  style: regularDefault.copyWith(color: MyColor.getTextFieldHintColor()),
                ),
              ],
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: MyColor.grayColor1,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegionsListView(StoreController controller) {
    final showInitialLoading = controller.isRegionLoading || (!controller.hasLoadedRegion && controller.isRegionFetching);
    if (showInitialLoading) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 10,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return const MatchCardShimmer();
        },
      );
    }

    if (controller.hasLoadedRegion && !controller.isRegionFetching && controller.regionList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          const SizedBox(height: 220),
          Center(
            child: NoDataWidget(
              text: MyStrings.noDataFound.tr,
            ),
          ),
        ],
      );
    }

    final showPaginationSlot = controller.hasNextRegion() || (controller.isRegionFetching && controller.regionList.isNotEmpty);

    return ListView.builder(
      controller: _regionScrollController,
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: controller.regionList.length + (showPaginationSlot ? 1 : 0),
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      itemBuilder: (context, index) {
        if (controller.regionList.length == index) {
          return controller.isRegionFetching && controller.regionList.isNotEmpty ? const CustomLoader(isPagination: true) : const SizedBox.shrink();
        }
        final region = controller.regionList[index];
        return AppCard(
          onTap: () {
            Get.toNamed(RouteHelper.storeDetailsScreen, arguments: [region.id.toString(), region.name ?? "", false, true]);
          },
          shadow: BoxShadow(
            color: MyColor.colorBlack.withValues(alpha: .03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
          margin: const EdgeInsets.only(bottom: Dimensions.space18),
          padding: EdgeInsets.zero,
          enableShadow: true,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.space100),
              child: MyNetworkImageWidget(
                height: Dimensions.space45,
                width: Dimensions.space45,
                boxFit: BoxFit.fill,
                imageUrl: "${region.image}",
                errorWidget: MyLocalImageWidget(
                  imagePath: MyIcons.globe,
                  height: Dimensions.space45,
                  width: Dimensions.space45,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  region.name ?? "",
                  style: semiBoldMediumLarge,
                ),
                Text(
                  "${region.totalPlans} ${MyStrings.plans.tr} ",
                  style: regularDefault.copyWith(color: MyColor.getTextFieldHintColor()),
                ),
              ],
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: MyColor.grayColor1,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlobalListView(StoreController controller) {
    final showInitialLoading = controller.isGlobalLoading || (!controller.hasLoadedGlobal && controller.isGlobalFetching);
    if (showInitialLoading) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 1,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return const MatchCardShimmer();
        },
      );
    }

    final totalPlans = controller.totalGlobalPlans?.trim() ?? '';
    if (controller.hasLoadedGlobal && !controller.isGlobalFetching && (totalPlans.isEmpty || totalPlans == '0')) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          const SizedBox(height: 220),
          Center(
            child: NoDataWidget(
              text: MyStrings.noDataFound.tr,
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: AppCard(
        onTap: () {
          Get.toNamed(RouteHelper.storeDetailsScreen, arguments: ["0", MyStrings.global, false, false]);
        },
        shadow: BoxShadow(
          color: MyColor.colorBlack.withValues(alpha: .03),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
        margin: const EdgeInsets.only(bottom: Dimensions.space18),
        padding: EdgeInsets.zero,
        enableShadow: true,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.space100),
            child: MyLocalImageWidget(
              imagePath: MyIcons.globe,
              height: Dimensions.space45,
              width: Dimensions.space45,
            ),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MyStrings.global.tr,
                style: semiBoldMediumLarge,
              ),
              Text(
                "${controller.totalGlobalPlans ?? ""} ${MyStrings.plans.tr}",
                style: regularDefault.copyWith(color: MyColor.getTextFieldHintColor()),
              ),
            ],
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: MyColor.grayColor1,
          ),
        ),
      ),
    );
  }
}

class _StoreHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final ValueChanged<String> onSearchChanged;
  final TextEditingController searchController;

  _StoreHeaderDelegate({
    required this.tabController,
    required this.onSearchChanged,
    required this.searchController,
  });
  @override
  double get minExtent => 132;

  @override
  double get maxExtent => 132;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: MyColor.getScreenBgColor(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: MyColor.colorWhite,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: MyColor.colorBlack.withValues(alpha: .05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: MyStrings.whereAreWeTraveling,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 45,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: MyColor.getCardBgColor(),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: tabController,
              indicator: BoxDecoration(
                color: MyColor.getPrimaryColor(),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: EdgeInsets.zero,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: MyColor.getCardBgColor(),
              unselectedLabelColor: MyColor.colorBlack,
              dividerColor: MyColor.getTransparentColor(),
              tabs: [
                Tab(text: MyStrings.countries),
                Tab(text: MyStrings.regions),
                Tab(text: MyStrings.global),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

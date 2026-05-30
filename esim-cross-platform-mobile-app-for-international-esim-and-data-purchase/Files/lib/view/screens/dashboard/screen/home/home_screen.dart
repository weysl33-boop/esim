import 'package:esim/core/utils/url_container.dart';
import 'package:esim/core/utils/util.dart';
import 'package:esim/view/components/custom_loader/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/core/route/route.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/core/utils/my_icons.dart';
import 'package:esim/core/utils/my_images.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/style.dart';
import 'package:esim/data/controller/dashbaord/dashboard_controller.dart';
import 'package:esim/data/controller/home/home_controller.dart';
import 'package:esim/data/repo/home/home_repo.dart';
import 'package:esim/view/components/image/my_local_image_widget.dart';
import 'package:esim/view/components/image/my_network_image_widget.dart';
import 'package:esim/view/components/text-form-field/custom_text_field.dart';
import 'package:esim/view/screens/dashboard/screen/home/widgets/kyc_warning_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.put(HomeRepo(apiClient: Get.find()));
    final controller = Get.put(HomeController(homeRepo: Get.find()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initialData();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final greeting = MyUtils.getGreeting();
        final greetingEmoji = MyUtils.getGreetingEmoji();
        final isLoggedIn = controller.checkUserIsLoggedInOrNot();
        final fullName = (controller.userData?.getFullName().trim().isNotEmpty ?? false)
            ? controller.userData!.getFullName().trim()
            : (controller.userData?.username?.trim().isNotEmpty ?? false)
                ? controller.userData!.username!.trim()
                : controller.usernameValue;
        return Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          body: controller.isLoading
              ? CustomLoader()
              : RefreshIndicator(
                  onRefresh: () async => controller.initialData(shouldLoad: false),
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    slivers: [
                      SliverAppBar(
                        automaticallyImplyLeading: false,
                        pinned: true,
                        expandedHeight: 180,
                        backgroundColor: MyColor.transparentColor,
                        elevation: 0,
                        title: const SizedBox.shrink(),
                        titleSpacing: 0,
                        actions: const [],
                        flexibleSpace: LayoutBuilder(
                          builder: (context, constraints) {
                            final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
                            final deltaExtent = settings!.maxExtent - settings.minExtent;

                            final t = ((settings.currentExtent - settings.minExtent) / deltaExtent).clamp(0.0, 1.0);

                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                IgnorePointer(
                                  ignoring: true,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(t * 32),
                                      bottomRight: Radius.circular(t * 32),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF020203),
                                            Color(0xFF1D2331),
                                          ],
                                        ),
                                        image: DecorationImage(
                                          image: AssetImage(MyImages.dashboardAppBarBg),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: SafeArea(
                                    bottom: false,
                                    child: Opacity(
                                      opacity: (1.0 - t / 0.4).clamp(0.0, 1.0),
                                      child: SizedBox(
                                        height: kToolbarHeight,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const SizedBox(width: Dimensions.space16),
                                            //  _buildAvatar(controller, size: 36),
                                            const SizedBox(width: Dimensions.space10),
                                            Expanded(
                                              child: isLoggedIn
                                                  ? Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          "$greeting $greetingEmoji",
                                                          style: regularDefault.copyWith(
                                                            color: MyColor.colorWhite.withValues(alpha: 0.80),
                                                            fontSize: Dimensions.fontSmall,
                                                          ),
                                                        ),
                                                        Text(
                                                          fullName,
                                                          style: semiBoldLarge.copyWith(
                                                            color: MyColor.colorWhite,
                                                            fontSize: Dimensions.fontMediumLarge,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ],
                                                    )
                                                  : Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Image.asset(
                                                            MyImages.appLogoLight,
                                                            height: 26,
                                                            fit: BoxFit.contain,
                                                          ),
                                                          const SizedBox(height: 2),
                                                          Text(
                                                            "$greeting $greetingEmoji",
                                                            style: regularDefault.copyWith(
                                                              color: MyColor.colorWhite.withValues(alpha: 0.85),
                                                              fontSize: Dimensions.fontSmall,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Get.find<DashboardController>().changeSelectedIndex(1);
                                              },
                                              child: Container(
                                                  padding: EdgeInsets.all(Dimensions.space8),
                                                  decoration: BoxDecoration(border: Border.all(color: MyColor.colorWhite.withValues(alpha: .25)), shape: BoxShape.circle, color: MyColor.colorWhite.withValues(alpha: .15)),
                                                  child: Icon(
                                                    Icons.search,
                                                    color: MyColor.colorWhite,
                                                  )),
                                            ),
                                            SizedBox(width: Dimensions.space10),
                                            GestureDetector(
                                              onTap: () {
                                                Get.toNamed(RouteHelper.notificationScreen);
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(Dimensions.space8),
                                                decoration: BoxDecoration(border: Border.all(color: MyColor.colorWhite.withValues(alpha: .25)), shape: BoxShape.circle, color: MyColor.colorWhite.withValues(alpha: .15)),
                                                child: Icon(
                                                  Icons.notifications_none,
                                                  color: MyColor.colorWhite,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: Dimensions.space8),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: Dimensions.space16,
                                  right: Dimensions.space16,
                                  bottom: Dimensions.space25,
                                  child: IgnorePointer(
                                    ignoring: t.abs() < 0.001,
                                    child: Opacity(
                                      opacity: ((t - 0.6) / 0.4).clamp(0.0, 1.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: isLoggedIn
                                                    ? Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            "$greeting $greetingEmoji",
                                                            style: regularDefault.copyWith(
                                                              color: MyColor.colorWhite.withValues(alpha: 0.85),
                                                              fontSize: Dimensions.fontDefault,
                                                            ),
                                                          ),
                                                          Text(
                                                            fullName,
                                                            style: semiBoldLarge.copyWith(
                                                              color: MyColor.colorWhite,
                                                              fontSize: 20,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ],
                                                      )
                                                    : Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Image.asset(
                                                            MyImages.appLogoLight,
                                                            height: 30,
                                                            fit: BoxFit.contain,
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            "$greeting $greetingEmoji",
                                                            style: regularDefault.copyWith(
                                                              color: MyColor.colorWhite.withValues(alpha: 0.90),
                                                              fontSize: Dimensions.fontDefault,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                              ),
                                              const SizedBox(width: Dimensions.space10),
                                              GestureDetector(
                                                onTap: () {
                                                  Get.toNamed(RouteHelper.notificationScreen);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(Dimensions.space8),
                                                  decoration: BoxDecoration(border: Border.all(color: MyColor.colorWhite.withValues(alpha: .25)), shape: BoxShape.circle, color: MyColor.colorWhite.withValues(alpha: .15)),
                                                  child: Icon(
                                                    Icons.notifications_none,
                                                    color: MyColor.colorWhite,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: Dimensions.space10),
                                          SizedBox(
                                            height: 56,
                                            child: CustomTextField(
                                              fillColor: MyColor.homeTextFieldFillColor,
                                              searchIconColor: MyColor.homeTextFieldHintColor,
                                              hintStyle: regularMediumLarge.copyWith(color: MyColor.homeTextFieldHintColor),
                                              onChanged: () {},
                                              readOnly: true,
                                              onTap: () {
                                                if (t.abs() > 0.001) {
                                                  Get.find<DashboardController>().changeSelectedIndex(1);
                                                }
                                              },
                                              isSearchField: true,
                                            ),
                                          ),
                                        ],
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (controller.checkUserIsLoggedInOrNot()) ...[const SizedBox(height: Dimensions.space16), KYCWarningSection(controller: controller)],
                            const SizedBox(height: Dimensions.space16),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: Dimensions.space16),
                              child: Text(
                                MyStrings.popularDestination.tr,
                                style: semiBoldMediumLarge.copyWith(color: MyColor.colorBlack),
                              ),
                            ),
                            const SizedBox(height: Dimensions.space15),
                            GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space10),
                              itemCount: (controller.popularCountries?.length ?? 0) + 1,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                mainAxisSpacing: 0,
                                crossAxisSpacing: 10,
                                childAspectRatio: .75,
                              ),
                              itemBuilder: (context, index) {
                                if (index == 9) {
                                  return DestinationItem(
                                    label: MyStrings.all.tr,
                                    isBlack: true,
                                    customIcon: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                    ),
                                    onTap: () {
                                      Get.find<DashboardController>().changeSelectedIndex(1);
                                    },
                                  );
                                }

                                final countryIndex = index > 9 ? index - 1 : index;
                                if (countryIndex >= (controller.popularCountries?.length ?? 0)) {
                                  return const SizedBox.shrink();
                                }

                                final country = controller.popularCountries![countryIndex];
                                return DestinationItem(
                                  code: "",
                                  icon: country.imageSrc ?? "",
                                  label: country.name ?? "",
                                  onTap: () {
                                    Get.toNamed(
                                      RouteHelper.storeDetailsScreen,
                                      arguments: [country.id.toString(), country.name ?? "", false, false],
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: Dimensions.space15),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: Dimensions.screenPaddingH),
                              child: Text(
                                MyStrings.campaign.tr,
                                style: semiBoldMediumLarge.copyWith(color: MyColor.colorBlack),
                              ),
                            ),
                            const SizedBox(height: Dimensions.space12),
                            ListView.separated(
                              separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space10),
                              itemCount: controller.campaigns.length,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(horizontal: Dimensions.screenPaddingH),
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.toNamed(
                                        RouteHelper.storeDetailsScreen,
                                        arguments: [controller.campaigns[index].id.toString(), controller.campaigns[index].title ?? "", true, false],
                                      );
                                    },
                                    child: MyNetworkImageWidget(
                                      height: 200,
                                      boxFit: BoxFit.fill,
                                      imageUrl: "${controller.campaignImagePath}/${controller.campaigns[index].banner}",
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  // Widget _buildAvatar(HomeController controller, {double size = 36}) {
  //   final hasImage = controller.userData?.profileImage != null &&
  //       controller.userData!.profileImage!.isNotEmpty;

  //   return CircleAvatar(
  //     radius: size / 2,
  //     backgroundColor: MyColor.colorWhite.withValues(alpha:0.2),
  //     child: ClipOval(
  //       child: hasImage
  //           ? MyNetworkImageWidget(
  //               imageUrl: controller.userData!.profileImage!,
  //               boxFit: BoxFit.cover,
  //             )
  //           : Padding(
  //               padding: const EdgeInsets.all(6),
  //               child: MyLocalImageWidget(
  //                 imagePath: MyImages.defaultAvatar,
  //                 boxFit: BoxFit.contain,
  //               ),
  //             ),
  //     ),
  //   );
  // }
}

// ── DestinationItem ────────────────────────────────────────────────────────────

class DestinationItem extends StatelessWidget {
  final String? icon;
  final String? code;
  final String label;
  final bool isBlack;
  final VoidCallback onTap;
  final Widget? customIcon;

  const DestinationItem({
    super.key,
    this.icon,
    this.code,
    required this.label,
    this.isBlack = false,
    required this.onTap,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isBlack ? Colors.black : Colors.white,
              shape: BoxShape.circle,
            ),
            child: customIcon ??
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.space100),
                  child: MyNetworkImageWidget(
                    boxFit: BoxFit.fill,
                    imageUrl: icon == null || icon!.isEmpty ? UrlContainer.countryFlagImageLink.replaceAll("{countryCode}", (code ?? '').toLowerCase()) : "$icon",
                    errorWidget: MyLocalImageWidget(
                      imagePath: MyIcons.globe,
                      height: Dimensions.space25,
                      width: Dimensions.space25,
                    ),
                  ),
                ),
          ),
          const SizedBox(height: Dimensions.space5),
          SizedBox(
            width: 80,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: regularDefault,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

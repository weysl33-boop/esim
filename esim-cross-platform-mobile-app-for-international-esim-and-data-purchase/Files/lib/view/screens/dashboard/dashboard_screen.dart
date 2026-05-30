import 'package:esim/core/route/route.dart';
import 'package:esim/view/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/core/helper/shared_preference_helper.dart';
import 'package:esim/core/utils/util.dart';
import 'package:esim/data/controller/common/theme_controller.dart';
import 'package:esim/data/services/api_service.dart';
import 'package:esim/view/components/annotated_region/annotated_region.dart';
import 'package:esim/view/components/image/my_local_image_widget.dart';
import 'package:esim/view/screens/dashboard/screen/store/store_screen.dart';
import 'package:esim/view/screens/my_esim/my_esim_screen.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_icons.dart';
import '../../../core/utils/my_strings.dart';
import '../../../data/controller/dashbaord/dashboard_controller.dart';
import '../../../data/controller/my_esim/my_esim_controller.dart';
import '../../components/will_pop_widget.dart';
import 'screen/home/home_screen.dart';
import 'screen/profile_and_settings/profile_and_settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardController dashboardController;
  late GlobalKey<ScaffoldState> _dashBoardScaffoldKey;
  late List<Widget> _widgets;

  void _loadMyEsimDataIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Get.isRegistered<MyEsimController>()) return;

      final myEsimController = Get.find<MyEsimController>();
      final hasAnyData = myEsimController.activeEsimData.isNotEmpty || myEsimController.expiredEsimData.isNotEmpty;

      if (!hasAnyData && !myEsimController.isLoading) {
        myEsimController.loadStoreData();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Get.put(ApiClient(sharedPreferences: Get.find()));
    dashboardController = Get.put(DashboardController(apiClient: Get.find()));
    _dashBoardScaffoldKey = GlobalKey<ScaffoldState>();
    Get.find<ApiClient>().sharedPreferences.setBool(SharedPreferenceHelper.firstTimeOnAppKey, false);
    _widgets = <Widget>[
      const HomeScreen(),
      const StoreScreen(),
      const MyEsimScreen(),
      const ProfileAndSettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (controller) {
      return GetBuilder<ThemeController>(builder: (themeController) {
        return AnnotatedRegionWidget(
          child: WillPopWidget(
            child: Scaffold(
              backgroundColor: MyColor.getScreenBgColor(),
              key: _dashBoardScaffoldKey,
              extendBody: true,
              body: IndexedStack(
                index: controller.selectedBottomNavIndex,
                children: _widgets,
              ),
              bottomNavigationBar: _BubbleNavBar(
                selectedIndex: controller.selectedBottomNavIndex,
                onTap: (index) {
                  final isMyEsimTab = index == 2;

                  if (isMyEsimTab && !dashboardController.checkUserIsLoggedInOrNot()) {
                    Get.toNamed(RouteHelper.authenticationScreen, arguments: true);
                    MyUtils.vibrationOn();
                    CustomSnackBar.error(
                      errorList: [MyStrings.youHaveToLoginFirst],
                    );
                    return;
                  }

                  controller.changeSelectedIndex(index);

                  if (isMyEsimTab) {
                    _loadMyEsimDataIfNeeded();
                  }

                  MyUtils.vibrationOn();
                },
              ),
            ),
          ),
        );
      });
    });
  }
}

// ── Pill-shaped floating bottom nav bar ────────────────────────────────────────

class _BubbleNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BubbleNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(label: MyStrings.home, icon: MyIcons.home),
    _NavItem(label: MyStrings.store, icon: MyIcons.simCard),
    _NavItem(label: MyStrings.myeSims, icon: MyIcons.store),
    _NavItem(label: MyStrings.myAccount, icon: MyIcons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      color: MyColor.getTransparentColor(), // outer bg matches screen
      padding: EdgeInsets.only(
        left: 50,
        right: 50,
        top: Dimensions.space8,
        bottom: bottomPadding > 0 ? bottomPadding : Dimensions.space16,
      ),
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: MyColor.getScreenBgColor(),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: MyColor.colorBlack.withValues(alpha: .08),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: MyColor.colorBlack.withValues(alpha: .04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _items.length,
            (index) => _BubbleNavItem(
              item: _items[index],
              isSelected: selectedIndex == index,
              onTap: () => onTap(index),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final String icon;
  const _NavItem({required this.label, required this.icon});
}

class _BubbleNavItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _BubbleNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? MyColor.getPrimaryColor() // filled green circle
              : MyColor.unselectedTabColor.withValues(alpha: .5), // subtle grey bubble
        ),
        child: Center(
          child: MyLocalImageWidget(
            imagePath: item.icon,
            width: 24,
            height: 24,
            imageOverlayColor: isSelected ? MyColor.colorWhite : MyColor.homeTextFieldHintColor,
          ),
        ),
      ),
    );
  }
}

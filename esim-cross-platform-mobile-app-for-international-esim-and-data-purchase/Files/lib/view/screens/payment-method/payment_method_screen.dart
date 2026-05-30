import 'package:flutter/material.dart';
import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/core/route/route.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/style.dart';
import 'package:esim/data/controller/payment_method/payment_method_controller.dart';
import 'package:esim/data/repo/payment_method/payment_method_repo.dart';
import 'package:esim/data/services/api_service.dart';
import 'package:esim/view/components/app-bar/app_main_appbar.dart';
import 'package:esim/view/components/bottom-sheet/custom_bottom_sheet_plus.dart';
import 'package:esim/view/components/custom_loader/custom_loader.dart';
import 'package:esim/view/components/divider/custom_spacer.dart';
import 'package:get/get.dart';
import 'package:esim/view/components/no_data.dart';
import 'package:esim/view/components/shimmer/history_list_data_shimmer.dart';
import 'package:esim/view/screens/payment-method/widget/method_bottom_sheet.dart';
import 'package:esim/view/screens/payment-method/widget/method_card.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final ScrollController scrollController = ScrollController();

  void fetchData() {
    Get.find<PaymentMethodController>().getData(shouldLoading: false);
  }

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<PaymentMethodController>().hasNext()) {
        fetchData();
      }
    }
  }

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(PaymentMethodRepo());
    final controller = Get.put(PaymentMethodController());
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      controller.initData();
      scrollController.addListener(scrollListener);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: AppMainAppBar(
        isTitleCenter: true,
        isProfileCompleted: true,
        title: MyStrings.paymentMethod,
        bgColor: MyColor.transparentColor,
        titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: Dimensions.space15),
            child: Ink(
              decoration: ShapeDecoration(color: MyColor.getAppBarBackgroundColor(), shape: const CircleBorder()),
              child: FittedBox(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Get.toNamed(RouteHelper.addPaymentMethodScreen)?.then((v) {
                      printX("aaaaa");
                      Get.find<PaymentMethodController>().initData(shouldLoading: false);
                    });
                  },
                  icon: Icon(Icons.add, color: MyColor.getAppBarContentColor()),
                ),
              ),
            ),
          ),
          horizontalSpace(Dimensions.space10),
        ],
      ),
      body: GetBuilder<PaymentMethodController>(
        builder: (controller) {
          return controller.isLoading
              ? const HistoryListDataShimmer(length: 10)
              : !controller.isLoading && controller.methodList.isEmpty
                  ? SizedBox(height: context.height, width: context.width, child: const NoDataWidget())
                  : RefreshIndicator(
                      onRefresh: () async {
                        controller.initData();
                      },
                      backgroundColor: MyColor.getScreenBgColor(),
                      color: MyColor.colorWhite,
                      child: Padding(
                        padding: Dimensions.screenPaddingHV,
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                          controller: scrollController,
                          separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space15),
                          itemCount: controller.methodList.length + 1,
                          itemBuilder: (context, index) {
                            if (controller.methodList.length == index) {
                              return controller.hasNext() ? const CustomLoader(isPagination: true) : const SizedBox();
                            }
                            final method = controller.methodList[index];
                            return GestureDetector(
                              onTap: () {
                                CustomBottomSheetPlus(
                                  isNeedPadding: false,
                                  bgColor: MyColor.transparentColor,
                                  child: PaymentMethodHistoryBottomSheet(method: method),
                                ).show(context);
                              },
                              child: MethodCard(method: method),
                            );
                          },
                        ),
                      ),
                    );
        },
      ),
    );
  }

  Widget row({required String title, required String subtitle, TextStyle? subtitleStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: regularDefault.copyWith(color: MyColor.getLabelTextColor()),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
          ),
        ),
        Expanded(
          child: Text(
            subtitle,
            style: subtitleStyle ?? lightDefault.copyWith(color: MyColor.getSecondaryTextColor()),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

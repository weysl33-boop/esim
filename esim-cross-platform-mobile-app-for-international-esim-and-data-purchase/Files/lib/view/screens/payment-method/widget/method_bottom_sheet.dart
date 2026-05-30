import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/core/route/route.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/core/utils/my_icons.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/style.dart';
import 'package:esim/data/controller/payment_method/payment_method_controller.dart';
import 'package:esim/data/model/payment_method/payment_method_list_response.dart';
import 'package:esim/view/components/custom_loader/custom_loader.dart';
import 'package:esim/view/components/divider/custom_divider.dart';
import 'package:esim/view/components/image/my_local_image_widget.dart';

class PaymentMethodHistoryBottomSheet extends StatelessWidget {
  final PaymentMethodData method;
  const PaymentMethodHistoryBottomSheet({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //Main code
        GetBuilder<PaymentMethodController>(builder: (controller) {
          return AnimatedContainer(
            duration: const Duration(microseconds: 700),
            curve: Curves.easeInCubic,
            margin: const EdgeInsetsDirectional.only(top: Dimensions.space20),
            decoration: BoxDecoration(
              color: MyColor.getScreenBgColor(),
              borderRadius: const BorderRadiusDirectional.only(
                topEnd: Radius.circular(25),
                topStart: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: MyColor.getPrimaryColor().withValues(alpha: 0.2),
                  offset: const Offset(0, -4),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: MyStrings.managePaymentMethod.tr,
                              style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                CustomDivider(height: 1, space: Dimensions.space5, color: MyColor.getBorderColor()),
                Expanded(
                  child: Container(
                    margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space10),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.back();
                            Get.toNamed(RouteHelper.editPaymentMethodScreen, arguments: method.id);
                          },
                          child: Container(
                            padding: const EdgeInsetsDirectional.symmetric(vertical: Dimensions.space15, horizontal: Dimensions.space20),
                            margin: const EdgeInsetsDirectional.only(bottom: Dimensions.space20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
                              border: Border.all(color: MyColor.getBorderColor()),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.edit, size: 20, color: MyColor.getPrimaryTextColor()),
                                    const SizedBox(width: Dimensions.space10),
                                    Text(MyStrings.edit.tr, style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor())),
                                  ],
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 14, color: MyColor.primaryColor),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => controller.deleteMethod(method.id ?? ''),
                          child: Container(
                            padding: const EdgeInsetsDirectional.symmetric(vertical: Dimensions.space15, horizontal: Dimensions.space20),
                            margin: const EdgeInsetsDirectional.only(bottom: Dimensions.space20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
                              border: Border.all(color: MyColor.getBorderColor()),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.delete_forever, size: 20, color: MyColor.redCancelTextColor),
                                    const SizedBox(width: Dimensions.space10),
                                    Text(MyStrings.delete.tr, style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor())),
                                  ],
                                ),
                                controller.isSubmitLoading ? const CustomLoader(isPagination: true, loaderColor: MyColor.redCancelTextColor) : const Icon(Icons.arrow_forward_ios, size: 14, color: MyColor.primaryColor),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.space10)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        //bottom sheet closer
        Positioned(
          top: 0,
          right: 20,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(),
            child: Material(
              type: MaterialType.transparency,
              child: Ink(
                decoration: ShapeDecoration(
                  color: MyColor.getTabBarTabBackgroundColor(),
                  shape: const CircleBorder(),
                ),
                child: FittedBox(
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Get.back();
                    },
                    icon: MyLocalImageWidget(
                      imagePath: MyIcons.doubleArrowDown,
                      imageOverlayColor: MyColor.getPrimaryTextColor(),
                      width: Dimensions.space25,
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

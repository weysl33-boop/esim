import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_color.dart';

import '../../../../../core/utils/my_strings.dart';
import '../../../../../data/controller/deposit/deposit_controller.dart';
import '../../../../components/row_widget/custom_row.dart';

class ChargeAmountOnDepositWidget extends StatelessWidget {
  const ChargeAmountOnDepositWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DepositController>(builder: (controller) {
      bool showRate = controller.isShowRate();
      return Container(
        padding: const EdgeInsets.all(Dimensions.space15),
        decoration: BoxDecoration(
          color: MyColor.getScreenBgSecondaryColor(),
          borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
          border: Border.all(
            color: MyColor.getBorderColor(),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const SizedBox(
                    height: Dimensions.space5,
                  ),
                  CustomRow(
                    firstText: MyStrings.depositLimit.tr,
                    lastText: controller.depositLimit,
                  ),
                  CustomRow(
                    firstText: MyStrings.depositCharge.tr,
                    lastText: controller.charge,
                  ),
                  CustomRow(
                    firstText: MyStrings.payable.tr,
                    lastText: controller.payableText,
                    showDivider: showRate,
                  ),
                  showRate
                      ? CustomRow(
                          firstText: MyStrings.conversionRate.tr,
                          lastText: controller.conversionRate,
                          showDivider: showRate,
                        )
                      : const SizedBox.shrink(),
                  showRate
                      ? CustomRow(
                          firstText: 'in ${controller.selectedDepositPaymentMethod?.currency}',
                          lastText: controller.inLocal,
                          showDivider: false,
                        )
                      : const SizedBox.shrink()
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

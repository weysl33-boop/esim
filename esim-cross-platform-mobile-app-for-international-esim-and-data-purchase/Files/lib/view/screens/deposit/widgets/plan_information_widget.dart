import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/view/components/divider/custom_spacer.dart';
import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../data/controller/deposit/deposit_controller.dart';

class PlanInformationWidget extends StatelessWidget {
  final DepositController controller;

  const PlanInformationWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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
          // Header
          Text(
            MyStrings.planInformation.tr,
            style: semiBoldExtraLarge.copyWith(
              color: MyColor.getPrimaryTextColor(),
              fontSize: Dimensions.fontExtraLarge,
            ),
          ),
          verticalSpace(Dimensions.space20),

          // Plan Details
          _buildInfoRow(
            MyStrings.plan.tr,
            controller.getPlanDetails(),
            isHighlighted: true,
          ),
          verticalSpace(Dimensions.space12),
          _buildInfoRow(
            MyStrings.data.tr,
            controller.getPlanData(),
          ),
          if (controller.getPlanTalkTimes() != "") ...[
            verticalSpace(Dimensions.space12),
            _buildInfoRow(
              MyStrings.talkTimes.tr,
              controller.getPlanTalkTimes(),
            )
          ],
          if (controller.getPlanSMS() != "0 SMS") ...[
            verticalSpace(Dimensions.space12),
            _buildInfoRow(
              MyStrings.sms.tr,
              controller.getPlanSMS(),
            )
          ],
          verticalSpace(Dimensions.space12),
          _buildInfoRow(
            MyStrings.price.tr,
            controller.getPlanPrice(),
            isBold: true,
            hasDiscount: controller.planDataList.isNotEmpty && controller.planDataList[0].campaign != null,
            actualPrice: controller.planDataList.isNotEmpty ? "${StringConverter.formatNumber(controller.planDataList[0].price.toString())} ${controller.currency}" : "",
          ),
          verticalSpace(Dimensions.space20),

          // Divider
          Divider(
            color: MyColor.getBorderColor(),
            thickness: 1,
          ),

          verticalSpace(Dimensions.space20),

          // Subtotal
          _buildInfoRow(
            MyStrings.subtotal.tr,
            controller.getSubtotal(),
          ),
          verticalSpace(Dimensions.space12),
          _buildInfoRow(
            MyStrings.processingCharge.tr,
            controller.getProcessingCharge(),
          ),

          verticalSpace(Dimensions.space20),

          // Divider
          Divider(
            color: MyColor.getBorderColor(),
            thickness: 1,
          ),

          verticalSpace(Dimensions.space20),

          // Total
          _buildInfoRow(
            MyStrings.total.tr,
            controller.getTotal(),
            isBold: true,
            isLarge: true,
          ),
          if (controller.shouldShowConvertedTotal()) ...[
            verticalSpace(Dimensions.space12),
            _buildInfoRow(
              MyStrings.conversionRate.tr,
              controller.getTotalConversionRateText(),
            ),
            verticalSpace(Dimensions.space12),
            _buildInfoRow(
              'Converted Total',
              controller.getConvertedTotalText(),
              isBold: true,
            ),
          ],

          verticalSpace(Dimensions.space15),

          // Security Message
          Text(
            MyStrings.secureDepositMessage.tr,
            style: regularDefault.copyWith(
              color: MyColor.getSecondaryTextColor(),
              fontSize: Dimensions.fontSmall,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    String actualPrice = "",
    bool isLarge = false,
    bool hasDiscount = false,
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: (isBold || isLarge ? semiBoldLarge : regularLarge).copyWith(
                color: MyColor.getSecondaryTextColor(),
                fontSize: isLarge ? Dimensions.fontLarge : Dimensions.fontDefault,
              ),
            ),
          ],
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (hasDiscount) ...[
                Text(
                  actualPrice,
                  style: (isBold || isLarge ? semiBoldLarge : regularLarge).copyWith(
                    color: MyColor.getPrimaryTextColor(),
                    decoration: TextDecoration.lineThrough,
                    decorationColor: MyColor.redCancelTextColor,
                    fontSize: isLarge ? Dimensions.fontLarge : Dimensions.fontDefault,
                  ),
                  textAlign: TextAlign.right,
                )
              ],
              Text(
                value,
                style: (isBold || isLarge ? semiBoldLarge : regularLarge).copyWith(
                  color: MyColor.getPrimaryTextColor(),
                  fontSize: isLarge ? Dimensions.fontLarge : Dimensions.fontDefault,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

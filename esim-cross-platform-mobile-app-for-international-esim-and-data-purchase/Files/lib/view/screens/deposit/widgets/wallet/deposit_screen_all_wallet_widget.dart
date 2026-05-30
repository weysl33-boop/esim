import 'package:esim/core/utils/url_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/view/components/text-form-field/custom_text_field.dart';
import 'package:esim/view/screens/deposit/widgets/deposit_select_gateway_widget.dart';
import 'package:esim/view/screens/deposit/widgets/plan_information_widget.dart';
import 'package:esim/view/screens/deposit/widgets/wallet/charge_amount_on_deposit_widget.dart';
import 'package:esim/view/screens/deposit/widgets/wallet/wallet_balance_card.dart';
import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../data/controller/deposit/deposit_controller.dart';
import '../../../../components/buttons/rounded_button.dart';
import '../../../../components/divider/custom_spacer.dart';
import '../../../../components/image/my_network_image_widget.dart';
import '../../../../components/shimmer/text_field_loading_shimmer.dart';

class DepositScreenAllWalletFrom extends StatelessWidget {
  final DepositController controller;
  final String walletType;
  final String selectedCurrencyFromParamsID;
  final String? planId;
  final String? uid;
  const DepositScreenAllWalletFrom({
    super.key,
    required this.controller,
    this.walletType = '',
    required this.selectedCurrencyFromParamsID,
    required this.planId,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
        child: controller.isDepositMethodLoading
            ? const TextFieldLoadingShimmer()
            : Column(
                children: [
                  if (walletType == 'wallet') ...[
                    verticalSpace(Dimensions.space10),
                    WalletBalanceCard(
                      balance: StringConverter.formatNumber(controller.userData?.userBalance ?? '0'),
                      currency: controller.currency,
                      onDeposit: () {
                        controller.changeTopUpValue();
                      },
                    ),
                  ],
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (walletType == 'direct') ...[
                        verticalSpace(Dimensions.space20),
                        Text(
                          MyStrings.gateway.tr,
                          style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                        ),
                        verticalSpace(Dimensions.space10),
                        DepositSelectGateWayWidget(
                          controller: controller,
                        ),
                        verticalSpace(Dimensions.space20),
                        const SizedBox(
                          height: Dimensions.space10,
                        ),
                        Text(
                          MyStrings.amount.tr,
                          style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                        ),
                        verticalSpace(Dimensions.space10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 50,
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.space15,
                              ),
                              decoration: BoxDecoration(color: MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.circular(Dimensions.cardRadius2)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MyNetworkImageWidget(
                                    imageUrl: "${UrlContainer.domainUrl}/${controller.methodPath}/${controller.selectedDepositPaymentMethod?.method?.image ?? ''}",
                                    height: Dimensions.space30,
                                    width: Dimensions.space30,
                                    boxFit: BoxFit.fitWidth,
                                  ),
                                  horizontalSpace(Dimensions.space10),
                                  Text(
                                    controller.selectedCurrency?.symbol.toString() ?? '',
                                    style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                  ),
                                ],
                              ),
                            ),
                            horizontalSpace(Dimensions.space10),
                            Expanded(
                              child: CustomTextField(
                                animatedLabel: false,
                                needOutlineBorder: true,
                                inputAction: TextInputAction.done,
                                controller: controller.amountController,
                                textInputType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*$')),
                                ],
                                readOnly: controller.isTopUp ? false : true,
                                fillColor: MyColor.getScreenBgSecondaryColor(),
                                hintText: MyStrings.enterAmount.tr,
                                onChanged: (value) {
                                  if (value.toString().isEmpty) {
                                    controller.changeDepositChargeInfoWidgetValue(0);
                                  } else {
                                    double amount = double.tryParse(value.toString()) ?? 0;
                                    controller.changeDepositChargeInfoWidgetValue(amount);
                                  }
                                  return;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (controller.isTopUp) ...[
                        verticalSpace(Dimensions.space20),
                        controller.selectedDepositPaymentMethod?.name != MyStrings.selectOne ? const ChargeAmountOnDepositWidget() : const SizedBox(),
                      ],
                      verticalSpace(Dimensions.space20),
                      if (!controller.isTopUp) ...[
                        PlanInformationWidget(controller: controller),
                        verticalSpace(Dimensions.space20),
                      ],
                      verticalSpace(Dimensions.space20),
                      RoundedButton(
                        isLoading: controller.submitLoading,
                        horizontalPadding: Dimensions.space10,
                        verticalPadding: Dimensions.space15,
                        text: MyStrings.continueTxt.tr,
                        onPress: () {
                          final hasPlanData = controller.planDataList.isNotEmpty;
                          final selectedPlan = hasPlanData ? controller.planDataList.first : null;
                          final safeUid = selectedPlan?.uid?.toString() ?? '';
                          final safePlanId = (selectedPlan?.uid != null ? selectedPlan?.id : null) ?? (planId ?? '');

                          controller.submitNewDeposit(
                            walletType: walletType,
                            uid: safeUid,
                            planId: safePlanId,
                          );
                        },
                        cornerRadius: 8,
                        isOutlined: false,
                        color: MyColor.getPrimaryButtonColor(),
                      ),
                      verticalSpace(Dimensions.space20),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

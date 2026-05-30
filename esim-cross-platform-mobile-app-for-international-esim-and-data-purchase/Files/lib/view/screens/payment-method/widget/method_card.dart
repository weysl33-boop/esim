import 'package:flutter/material.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/style.dart';
import 'package:esim/core/utils/util.dart';
import 'package:esim/data/model/payment_method/payment_method_list_response.dart';
import 'package:get/get.dart';

class MethodCard extends StatelessWidget {
  final PaymentMethodData method;
  const MethodCard({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.space20, vertical: Dimensions.space10),
      decoration: BoxDecoration(color: MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.circular(Dimensions.cardRadius1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(height: 10, width: 2, color: method.paymentMethod?.brandingColor == null ? MyColor.getPrimaryColor() : MyUtils.hexToColor(method.paymentMethod?.brandingColor ?? '')),
              const SizedBox(width: Dimensions.space10),
              Expanded(
                child: Text(
                  method.paymentMethod?.name ?? '',
                  style: regularDefault.copyWith(color: MyColor.getLabelTextColor()),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.space10),
          Column(
            children: List.generate(
              method.userData?.length ?? 0,
              (index) => Container(
                margin: const EdgeInsets.symmetric(vertical: Dimensions.space5),
                child: row(
                  title: method.userData?[index].name ?? '',
                  subtitle: method.userData?[index].value ?? '',
                ),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.space10),
          Text(MyStrings.remark.tr, style: regularDefault.copyWith(color: MyColor.getLabelTextColor())),
          Text(method.remark ?? '', style: lightDefault.copyWith(color: MyColor.getSecondaryTextColor())),
        ],
      ),
    );
  }

  Row row({required String title, required String subtitle, TextStyle? subtitleStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(title, style: regularDefault.copyWith(color: MyColor.getLabelTextColor()), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.start),
        ),
        Expanded(
          child: Text(subtitle, style: subtitleStyle ?? lightDefault.copyWith(color: MyColor.getSecondaryTextColor()), maxLines: 4, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end),
        ),
      ],
    );
  }
}

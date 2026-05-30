import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_images.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/style.dart';

class WalletBalanceCard extends StatelessWidget {
  final String balance;
  final String currency;
  final VoidCallback onDeposit;

  const WalletBalanceCard({
    super.key,
    required this.balance,
    required this.currency,
    required this.onDeposit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(
              MyImages.walletCardImage,
            )),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(MyStrings.walletBalance.tr, style: regularMediumLarge.copyWith(color: MyColor.colorWhite)),
          const SizedBox(height: Dimensions.space8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                balance,
                style: boldLarge.copyWith(color: MyColor.colorWhite, fontSize: Dimensions.space30),
              ),
              SizedBox(width: Dimensions.space6),
              Text(currency, style: regularLarge.copyWith(color: MyColor.colorWhite)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: onDeposit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColor.colorBlack.withValues(alpha: .4),
                  foregroundColor: MyColor.colorBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
                  child: Text(
                    MyStrings.topUp.tr,
                    style: regularDefault.copyWith(color: MyColor.colorWhite, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

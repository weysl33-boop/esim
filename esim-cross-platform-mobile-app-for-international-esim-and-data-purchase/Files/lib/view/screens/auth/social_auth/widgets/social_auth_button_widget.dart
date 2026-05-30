import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/view/components/card/custom_app_card.dart';

import 'package:esim/view/components/image/my_local_image_widget.dart';

import '../../../../../core/utils/style.dart';

class SocialAuthButtonWidget extends StatelessWidget {
  final String assetImage;
  final String text;
  final bool isLoading;
  final bool showText;
  final Function()? onPressed;
  const SocialAuthButtonWidget({super.key, required this.assetImage, required this.text, this.onPressed, this.isLoading = false, this.showText = false});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: MyColor.textFieldFillColor.withValues(alpha: .7),
      onTap: () {
        if (onPressed != null) {
          if (!isLoading) {
            onPressed!();
          }
        }
      },
      enableShadow: false,
      child: SizedBox(
        height: 20,
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      MyColor.primaryColor,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        child: MyLocalImageWidget(
                          imagePath: assetImage,
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                    if (showText) ...[
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          text.tr,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: regularLarge.copyWith(
                            fontWeight: FontWeight.w500,
                            color: MyColor.secondaryColor900,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
        ),
      ),
    );
  }
}

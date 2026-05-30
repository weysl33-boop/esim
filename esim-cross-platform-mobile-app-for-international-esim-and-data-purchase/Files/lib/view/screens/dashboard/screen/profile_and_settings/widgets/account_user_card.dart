import 'package:esim/core/utils/my_images.dart';
import 'package:esim/view/components/image/my_local_image_widget.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/utils/dimensions.dart';
import '../../../../../../core/utils/my_color.dart';
import '../../../../../../core/utils/my_icons.dart';
import '../../../../../../core/utils/style.dart';
import '../../../../../components/shimmer/account_info_card_loader_shimmer.dart';

class AccountUserCard extends StatelessWidget {
  final String? username, fullName, subtitle;
  final String? image;
  final bool isAsset;
  final bool isLoading;
  final bool noAvatar;
  final TextStyle? titleStyle, subtitleStyle;
  final String? rating;
  final Widget? imgWidget;
  final Widget? rightWidget;
  final double? imgHeight;
  final double? imgwidth;
  final VoidCallback? onTap;
  const AccountUserCard({
    super.key,
    this.username,
    this.fullName,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.rightWidget,
    this.image = MyIcons.addAction,
    this.isAsset = true,
    this.noAvatar = false,
    this.rating,
    this.imgHeight,
    this.imgwidth,
    this.imgWidget,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const AccountInfoCardLoaderShimmer()
        : GestureDetector(
            onTap: () {
              if (onTap != null) {
                onTap!();
              }
            },
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyLocalImageWidget(
                          imagePath: MyImages.appLogoDark,
                          height: Dimensions.space50,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  fullName.toString().toUpperCase(),
                                  style: titleStyle ??
                                      boldDefault.copyWith(
                                        color: MyColor.colorBlack,
                                        fontWeight: FontWeight.bold,
                                        fontSize: Dimensions.fontLarge + 3,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.space3,
                              ),
                              Text(
                                "@$username",
                                style: titleStyle ??
                                    regularDefault.copyWith(
                                      color: MyColor.colorBlack,
                                      fontSize: Dimensions.fontSmall,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: Dimensions.space5,
                              ),
                              if (subtitle?.trim().toString() != "") ...[
                                Text(
                                  "+${subtitle?.trim().toString()}",
                                  style: subtitleStyle ?? regularDefault.copyWith(fontSize: Dimensions.fontSmall, color: MyColor.colorBlack.withValues(alpha: 0.8)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(
                                  height: Dimensions.space5,
                                ),
                              ],
                              if (rating != "hide") ...[
                                Container(
                                  decoration: BoxDecoration(
                                    color: MyColor.getScreenBgColor(),
                                    borderRadius: BorderRadius.circular(Dimensions.space20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.space10,
                                    vertical: Dimensions.space5,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: MyColor.pendingColor,
                                        size: Dimensions.fontLarge,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "${rating?.trim().isEmpty ?? true ? 'N/A' : rating!} ",
                                        style: boldDefault.copyWith(
                                          fontSize: Dimensions.fontDefault,
                                          color: MyColor.getPrimaryTextColor(),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  rightWidget ?? const SizedBox.shrink()
                ],
              ),
            ),
          );
  }
}

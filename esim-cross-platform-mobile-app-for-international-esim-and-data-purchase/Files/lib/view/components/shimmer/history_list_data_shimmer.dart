import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/data/controller/common/theme_controller.dart';
import 'package:esim/view/components/divider/custom_spacer.dart';

import '../../../core/utils/dimensions.dart';

class HistoryListDataShimmer extends StatelessWidget {
  final int length;
  final bool isChatHistory;
  const HistoryListDataShimmer({super.key, this.length = 4, this.isChatHistory = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (controller) {
      return ListView(
        children: List.generate(
          length,
          (index) => Container(
            decoration: isChatHistory ? null : BoxDecoration(border: Border(bottom: BorderSide(color: MyColor.getBorderColor()))),
            padding: const EdgeInsets.all(Dimensions.space10),
            margin: EdgeInsetsDirectional.only(bottom: isChatHistory ? Dimensions.space5 : Dimensions.space10),
            child: isChatHistory
                ? Row(
                    mainAxisAlignment: index.isEven ? MainAxisAlignment.start : MainAxisAlignment.end,
                    children: [
                      if (index.isEven) ...[
                        SizedBox(
                          height: Dimensions.space40,
                          width: Dimensions.space40,
                          child: Shimmer.fromColors(
                            baseColor: MyColor.getShimmerBaseColor(),
                            highlightColor: MyColor.getShimmerHighLightColor(),
                            child: Container(
                              height: Dimensions.space40,
                              width: Dimensions.space40,
                              decoration: BoxDecoration(color: MyColor.getShimmerBaseColor(), borderRadius: BorderRadius.circular(100)),
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.space15)
                      ],
                      Shimmer.fromColors(
                        baseColor: MyColor.getShimmerBaseColor(),
                        highlightColor: MyColor.getShimmerHighLightColor(),
                        child: Container(
                          height: 15,
                          width: 100,
                          constraints: const BoxConstraints(maxWidth: 100),
                          decoration: BoxDecoration(
                            color: MyColor.getShimmerBaseColor(),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      if (index.isOdd) ...[
                        const SizedBox(width: Dimensions.space15),
                        SizedBox(
                          height: Dimensions.space40,
                          width: Dimensions.space40,
                          child: Shimmer.fromColors(
                            baseColor: MyColor.getShimmerBaseColor(),
                            highlightColor: MyColor.getShimmerHighLightColor(),
                            child: Container(
                              height: Dimensions.space40,
                              width: Dimensions.space40,
                              decoration: BoxDecoration(color: MyColor.getShimmerBaseColor(), borderRadius: BorderRadius.circular(100)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  )
                : Row(
                    children: [
                      SizedBox(
                        height: Dimensions.space50,
                        width: Dimensions.space50,
                        child: Shimmer.fromColors(
                          baseColor: MyColor.getShimmerBaseColor(),
                          highlightColor: MyColor.getShimmerHighLightColor(),
                          child: Container(
                            height: Dimensions.space50,
                            width: Dimensions.space50,
                            decoration: BoxDecoration(color: MyColor.getShimmerBaseColor(), borderRadius: BorderRadius.circular(100)),
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.space20),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: MyColor.getShimmerBaseColor(),
                                    highlightColor: MyColor.getShimmerHighLightColor(),
                                    child: Container(
                                      width: double.infinity,
                                      height: 15,
                                      decoration: BoxDecoration(color: MyColor.getShimmerBaseColor(), borderRadius: BorderRadius.circular(100)),
                                    ),
                                  ),
                                  verticalSpace(Dimensions.space10),
                                  Shimmer.fromColors(
                                    baseColor: MyColor.getShimmerBaseColor(),
                                    highlightColor: MyColor.getShimmerHighLightColor(),
                                    child: Container(
                                      width: 100,
                                      height: 15,
                                      decoration: BoxDecoration(color: MyColor.getShimmerBaseColor(), borderRadius: BorderRadius.circular(100)),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
          ),
        ),
      );
    });
  }
}

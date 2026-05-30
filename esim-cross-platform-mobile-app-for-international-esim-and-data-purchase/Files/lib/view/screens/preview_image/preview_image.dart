import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/core/utils/style.dart';
import 'package:esim/view/components/app-bar/app_main_appbar.dart';
import 'package:esim/view/components/divider/custom_spacer.dart';

// ignore: must_be_immutable
class PreviewImage extends StatefulWidget {
  String url;
  VoidCallback? onDownloadButtonPress;
  PreviewImage({super.key, required this.url, this.onDownloadButtonPress});

  @override
  State<PreviewImage> createState() => _PreviewImageState();
}

class _PreviewImageState extends State<PreviewImage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppMainAppBar(
        title: "",
        isTitleCenter: true,
        isProfileCompleted: true,
        bgColor: MyColor.transparentColor,
        titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
        actions: [
          if (widget.onDownloadButtonPress != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: Dimensions.space15),
              child: Ink(
                decoration: ShapeDecoration(color: MyColor.getAppBarBackgroundColor(), shape: const CircleBorder()),
                child: FittedBox(
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: widget.onDownloadButtonPress,
                    icon: Icon(Icons.file_download_outlined, color: MyColor.getAppBarContentColor()),
                  ),
                ),
              ),
            ),
          horizontalSpace(Dimensions.space10),
        ],
      ),
      backgroundColor: MyColor.getScreenBgColor(),
      body: InteractiveViewer(
        child: CachedNetworkImage(
          imageUrl: widget.url.toString(),
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              boxShadow: const [],
              // borderRadius:  BorderRadius.circular(radius),
              image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
            ),
          ),
          placeholder: (context, url) => SizedBox(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
              child: Center(
                child: SpinKitFadingCube(
                  color: MyColor.primaryColor.withValues(alpha: 0.3),
                  size: Dimensions.space20,
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => SizedBox(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
              child: Center(
                child: Icon(
                  Icons.image,
                  color: MyColor.colorGrey.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

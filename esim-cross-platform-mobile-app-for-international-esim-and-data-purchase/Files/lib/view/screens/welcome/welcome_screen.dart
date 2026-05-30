import 'package:esim/core/route/route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_images.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/style.dart';
import 'package:esim/environment.dart';
import 'package:esim/view/components/buttons/rounded_button.dart'; // Assuming you have a reusable button
import 'package:esim/view/components/card/custom_app_card.dart';
import 'package:esim/view/components/image/my_local_image_widget.dart';
import '../../../core/utils/my_color.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      body: SafeArea(
        child: AppCard(
          margin: Dimensions.screenPaddingHV,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MyLocalImageWidget(
                imagePath: MyImages.security,
                width: Dimensions.space30,
                height: Dimensions.space30,
              ),
              const SizedBox(height: Dimensions.space10),
              Text(
                "${MyStrings.welcomeToAppName.tr} ${Environment.appName}",
                style: boldExtraLarge.copyWith(fontSize: 28, color: MyColor.getPrimaryTextColor()),
              ),
              const SizedBox(height: 12),
              Text(
                MyStrings.readyToGetStarted.tr,
                style: regularDefault.copyWith(color: MyColor.getContentTextColor().withValues(alpha: .7)),
              ),
              const SizedBox(height: Dimensions.space10),
              Expanded(
                child: AppCard(
                  enableShadow: false,
                  backgroundColor: MyColor.secondaryCardBgColor,
                  padding: const EdgeInsets.all(Dimensions.space20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(MyStrings.privacyPolicy.tr, style: boldDefault.copyWith(fontSize: Dimensions.space18)),
                        const SizedBox(height: Dimensions.space20),
                        _buildPolicyItem(Icons.verified_user_outlined, MyStrings.yourPrivacy),
                        _buildPolicyItem(Icons.lock_outline, MyStrings.yourDataIsEncrypted),
                        _buildPolicyItem(Icons.description_outlined, MyStrings.byUsingTheApp),
                        _buildPolicyItem(Icons.analytics_outlined, MyStrings.weCollectMinimulData),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.space10),
              AppCard(
                enableShadow: false,
                backgroundColor: MyColor.secondaryCardBgColor,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: regularSmall.copyWith(color: MyColor.getContentTextColor()),
                    children: [
                      TextSpan(text: "${MyStrings.byTappingAgree.tr} ${Environment.appName} "),
                      TextSpan(
                        text: MyStrings.termsOfService.tr,
                        style: boldSmall.copyWith(color: MyColor.getPrimaryColor()),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      TextSpan(text: MyStrings.and.tr),
                      TextSpan(
                        text: MyStrings.privacyPolicy.tr,
                        style: boldSmall.copyWith(color: MyColor.getPrimaryColor()),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.space20),
              RoundedButton(
                text: MyStrings.agreeAndContinue,
                onPress: () {
                  Get.offAndToNamed(RouteHelper.onboardScreen);
                },
              ),
            ],
          ),
        ),

        //     Column(
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: [
        //     Text(
        //       "${MyStrings.welcomeToAppName.tr} ${Environment.appName}",
        //       style: boldExtraLarge.copyWith(fontSize: 28, color: MyColor.getPrimaryTextColor()),
        //     ),
        //     SizedBox(height: Dimensions.space10),
        //     Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: Dimensions.space50),
        //       child: Text(
        //         MyStrings.stayConnected.tr,
        //         textAlign: TextAlign.center,
        //         style: regularDefault.copyWith(color: MyColor.getContentTextColor().withValues(alpha: .7)),
        //       ),
        //     ),
        //     SizedBox(height: Dimensions.space30),
        //     RoundedButton(
        //       text: MyStrings.getStarted,
        //       onPress: () {},
        //     ),
        //   ],
        // ),
      ),
    );
  }

  Widget _buildPolicyItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.space20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: Dimensions.space20, color: MyColor.getPrimaryColor().withValues(alpha: .8)),
          const SizedBox(width: Dimensions.space12),
          Expanded(
            child: Text(
              text,
              style: regularDefault.copyWith(
                color: MyColor.getContentTextColor(),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

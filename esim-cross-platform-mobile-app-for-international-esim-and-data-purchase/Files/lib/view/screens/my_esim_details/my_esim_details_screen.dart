import 'package:esim/view/components/snack_bar/show_custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:esim/core/helper/date_converter.dart';
import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/core/route/route.dart';
import 'package:esim/core/utils/dimensions.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/core/utils/style.dart';
import 'package:esim/data/controller/home/home_controller.dart';
import 'package:esim/data/controller/my_esim_details/my_esim_details_controller.dart';
import 'package:esim/data/model/my_esim/my_esim_details_response_model.dart';
import 'package:esim/data/repo/my_esim_details/my_esim_details_repo.dart';
import 'package:esim/view/components/buttons/rounded_button.dart';
import 'package:esim/view/components/card/custom_app_card.dart';
import 'package:esim/view/components/custom_loader/custom_loader.dart';
import 'package:esim/view/components/image/my_network_image_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyEsimDetailsScreen extends StatefulWidget {
  const MyEsimDetailsScreen({super.key});

  @override
  State<MyEsimDetailsScreen> createState() => _MyEsimDetailsScreenState();
}

class _MyEsimDetailsScreenState extends State<MyEsimDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Get.put(MyEsimDetailsRepo(apiClient: Get.find()));
    var controller = Get.put(MyEsimDetailsController(myEsimDetailsRepo: Get.find()));
    controller.esimId = Get.arguments[0];
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.getMyEsimController();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyEsimDetailsController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          appBar: AppBar(
            backgroundColor: MyColor.colorWhite,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: MyColor.colorBlack,
                size: 18,
              ),
            ),
            title: Text(
              MyStrings.esimDetails.tr,
              style: semiBoldLarge.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              controller.isTopupAvailable
                  ? IconButton(
                      onPressed: () {
                        Get.toNamed(RouteHelper.topUpScreen, arguments: [controller.esimId]);
                      },
                      icon: Container(
                        padding: EdgeInsets.symmetric(vertical: Dimensions.space5, horizontal: Dimensions.space10),
                        decoration: BoxDecoration(
                          color: MyColor.colorWhite,
                          border: Border.all(color: MyColor.topUpButtonBorderColor),
                          borderRadius: BorderRadius.circular(Dimensions.space8),
                          boxShadow: [
                            BoxShadow(
                              color: MyColor.colorBlack.withValues(alpha: .05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline_rounded,
                              color: MyColor.colorBlack,
                              size: 18,
                            ),
                            SizedBox(width: Dimensions.space5),
                            Text(MyStrings.topUp.tr, style: regularMediumLarge.copyWith(color: MyColor.colorBlack, fontSize: Dimensions.space16)),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),
              SizedBox(width: Dimensions.space15),
            ],
          ),
          body: controller.isLoading
              ? CustomLoader()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimensions.screenPaddingH),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // QR Code & Installation Guide Section
                      _buildQRSection(controller),
                      SizedBox(height: Dimensions.space25),
                      // Tab Section
                      _buildTabSection(controller),
                      SizedBox(height: Dimensions.space20),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildQRSection(MyEsimDetailsController controller) {
    return AppCard(
      padding: EdgeInsets.all(Dimensions.space20),
      shadow: BoxShadow(
        color: MyColor.colorBlack.withValues(alpha: .06),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              AppCard(
                enableShadow: false,
                radius: Dimensions.space8,
                padding: EdgeInsets.all(Dimensions.space4),
                backgroundColor: MyColor.primaryColor50,
                child: Icon(
                  Icons.qr_code_2_rounded,
                  color: MyColor.primaryColor,
                  size: 22,
                ),
              ),
              SizedBox(width: Dimensions.space12),
              Text(
                MyStrings.qrCodeInstallationGuide.tr,
                style: semiBoldLarge.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.space25),
          // QR Code Container
          Align(
            alignment: AlignmentGeometry.center,
            child: Container(
              padding: EdgeInsets.all(Dimensions.space15),
              decoration: BoxDecoration(
                color: MyColor.colorWhite,
                borderRadius: BorderRadius.circular(Dimensions.space15),
                border: Border.all(
                  color: MyColor.colorGrey.withValues(alpha: .2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: MyColor.colorBlack.withValues(alpha: .04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.space10),
                  color: Colors.white,
                ),
                child: (controller.esimDetailsDataList?.qrCode ?? "").startsWith('LPA:') || (controller.esimDetailsDataList?.qrCode ?? "").startsWith('lpa:')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.space10),
                        child: QrImageView(
                          data: controller.esimDetailsDataList?.qrCode ?? "",
                          version: QrVersions.auto,
                          size: 140,
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.all(Dimensions.space8),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.space10),
                        child: MyNetworkImageWidget(
                          imageUrl: controller.esimDetailsDataList?.qrCode ?? "",
                        ),
                      ),
              ),
            ),
          ),

          SizedBox(width: Dimensions.space20),

          SizedBox(height: Dimensions.space20),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInstallationStep(
                number: '1',
                title: 'Open Settings',
                description: 'Go to mobile network settings',
              ),
              SizedBox(height: Dimensions.space12),
              _buildInstallationStep(
                number: '2',
                title: 'Add eSIM',
                description: 'Look for Add eSIM option',
              ),
              SizedBox(height: Dimensions.space12),
              _buildInstallationStep(
                number: '3',
                title: 'Scan QR',
                description: 'Use camera to scan code',
              ),
              SizedBox(height: Dimensions.space12),
              _buildInstallationStep(
                number: '4',
                title: MyStrings.confirmInstallation.tr,
                description: MyStrings.followThePrompt.tr,
              ),
              SizedBox(height: Dimensions.space12),
              _buildInstallationStep(
                number: '5',
                title: MyStrings.enableYourEsim.tr,
                description: MyStrings.onceInstalledMsg.tr,
              ),
            ],
          ),

          SizedBox(height: Dimensions.space20),

          RoundedButton(
            text: MyStrings.downloadQrCode.tr,
            onPress: () {
              controller.downloadQr(controller.esimDetailsDataList?.qrCode ?? "");
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.download_rounded, size: Dimensions.space20, color: MyColor.colorWhite),
                SizedBox(width: Dimensions.space5),
                Text(
                  MyStrings.downloadQrCode.tr,
                  style: semiBoldMediumLarge.copyWith(color: MyColor.colorWhite),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInstallationStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(Dimensions.space12),
          decoration: BoxDecoration(color: MyColor.colorWhite, shape: BoxShape.circle, border: Border.all(color: MyColor.stepBorderColor)),
          child: Text(
            number,
            style: semiBoldDefault.copyWith(
              color: MyColor.colorBlack,
              fontWeight: FontWeight.w700,
              fontSize: Dimensions.space16,
            ),
          ),
        ),
        SizedBox(width: Dimensions.space10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: semiBoldDefault.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Dimensions.space2),
              Text(
                description,
                style: regularDefault.copyWith(
                  fontSize: 11,
                  color: MyColor.bodyTextColor.withValues(alpha: .6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection(MyEsimDetailsController controller) {
    return Column(
      children: [
        // Tab Bar
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: MyColor.colorWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: MyColor.colorBlack.withValues(alpha: .06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MyColor.primaryColor,
                  MyColor.primaryColor.withValues(alpha: .85),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: MyColor.primaryColor.withValues(alpha: .3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.zero,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: MyColor.colorWhite,
            labelStyle: semiBoldDefault.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelColor: MyColor.colorBlack.withValues(alpha: .6),
            unselectedLabelStyle: semiBoldDefault.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: MyStrings.esimInfo.tr),
              Tab(text: MyStrings.planInfo.tr),
            ],
          ),
        ),

        SizedBox(height: Dimensions.space20),

        // Tab Views
        SizedBox(
          height: 450,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildEsimInformation(controller.esimDetailsDataList ?? Esim()),
              _buildPlanInformation(controller.esimDetailsDataList ?? Esim()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEsimInformation(Esim esimList) {
    return AppCard(
      padding: EdgeInsets.all(Dimensions.space20),
      shadow: BoxShadow(
        color: MyColor.colorBlack.withValues(alpha: .06),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.credit_card_rounded,
            label: MyStrings.iccid.tr,
            value: esimList.iccid ?? "",
            iconColor: MyColor.colorBlack,
            valueColor: MyColor.colorBlack,
            showCopy: true,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.event_available_rounded,
            label: MyStrings.expiaryDate.tr,
            value: esimList.formattedExpiryDate ?? "",
            iconColor: MyColor.colorBlack,
            valueColor: MyColor.colorBlack,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.data_usage_rounded,
            label: MyStrings.remainingData,
            value: esimList.remaining?.remainingCapacity ?? "",
            iconColor: MyColor.colorBlack,
            valueColor: MyColor.colorBlack,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.schedule_rounded,
            label: MyStrings.date.tr,
            value: DateConverter.convertIsoToString(esimList.createdAt ?? ""),
            iconColor: MyColor.colorBlack,
            valueColor: MyColor.colorBlack,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanInformation(Esim esimList) {
    var plan = esimList.orderItem?.plan;
    return AppCard(
      padding: EdgeInsets.all(Dimensions.space20),
      shadow: BoxShadow(
        color: MyColor.colorBlack.withValues(alpha: .06),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.sim_card_rounded,
            label: MyStrings.name.tr,
            value: plan?.name ?? "",
            iconColor: MyColor.colorBlack,
            valueColor: MyColor.colorBlack,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.timer_rounded,
            label: MyStrings.validity.tr,
            value: esimList.remaining?.planExpiry ?? "",
            iconColor: MyColor.colorBlack,
            valueColor: MyColor.colorBlack,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.storage_rounded,
            label: MyStrings.data.tr,
            value: esimList.readableDataVolume ?? "",
            iconColor: MyColor.colorBlack,
            valueColor: MyColor.colorBlack,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.payments_rounded,
            label: MyStrings.price.tr,
            value: "${StringConverter.formatNumber(esimList.price ?? "")} ${Get.find<HomeController>().defaultCurrency}",
            iconColor: MyColor.colorBlack,
            valueColor: MyColor.colorBlack,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    Color? valueColor,
    bool showCopy = false,
    bool showAction = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.space12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Dimensions.space10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(Dimensions.space10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          SizedBox(width: Dimensions.space15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: regularDefault.copyWith(
                    fontSize: 12,
                    color: MyColor.bodyTextColor.withValues(alpha: .6),
                  ),
                ),
                SizedBox(height: Dimensions.space5),
                Text(
                  value,
                  style: semiBoldDefault.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? MyColor.colorBlack,
                  ),
                ),
              ],
            ),
          ),
          if (showCopy)
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                CustomSnackBar.success(successList: [MyStrings.iccidCopiedToClipboard.tr]);
              },
              icon: Container(
                padding: EdgeInsets.all(Dimensions.space8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(Dimensions.space8),
                ),
                child: Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: iconColor,
                ),
              ),
            ),
          if (showAction)
            TextButton(
              onPressed: () {
                // Show countries
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View',
                    style: semiBoldDefault.copyWith(
                      fontSize: 13,
                      color: MyColor.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: Dimensions.space4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: MyColor.primaryColor,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.space8),
      child: Divider(
        height: 1,
        color: MyColor.colorGrey.withValues(alpha: .15),
      ),
    );
  }
}

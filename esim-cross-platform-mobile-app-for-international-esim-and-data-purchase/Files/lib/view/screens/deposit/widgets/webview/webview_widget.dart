import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:esim/core/utils/my_color.dart';
import 'package:esim/data/model/store/store_details_data_response_model.dart';

import '../../../../../core/route/route.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/url_container.dart';
import '../../../../components/snack_bar/show_custom_snackbar.dart';

class DepositAppWebViewWidget extends StatefulWidget {
  const DepositAppWebViewWidget({
    super.key,
    required this.url,
    required this.planId,
    this.returnToDepositWallet = false,
    this.planData,
    this.price = '',
    this.uid = '',
  });

  final String url;
  final String planId;
  final bool returnToDepositWallet;
  final List<PlanData>? planData;
  final String price;
  final String uid;

  @override
  State<DepositAppWebViewWidget> createState() => _DepositAppWebViewWidgetState();
}

class _DepositAppWebViewWidgetState extends State<DepositAppWebViewWidget> {
  @override
  void initState() {
    url = widget.url;
    super.initState();
  }

  String url = '';
  final GlobalKey webViewKey = GlobalKey();
  PullToRefreshController? pullToRefreshController;
  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
    transparentBackground: true,
  );

  bool isLoading = true;
  bool _handledNavigation = false;

  void _handleSuccess() {
    if (_handledNavigation) return;
    _handledNavigation = true;

    if (widget.returnToDepositWallet) {
      Get.offAllNamed(
        RouteHelper.depositScreen,
        arguments: [
          widget.planData ?? <PlanData>[],
          widget.planId,
          widget.price,
          widget.uid,
          true,
        ],
      );
      CustomSnackBar.success(successList: [MyStrings.topUpSuccessful]);
      return;
    }

    Get.offAllNamed(RouteHelper.dashboardScreen);
    CustomSnackBar.success(successList: [MyStrings.depositSuccessful]);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: MyColor.getPrimaryTextColor(),
              ))
            : const SizedBox(),
        InAppWebView(
          key: webViewKey,
          initialUrlRequest: URLRequest(url: WebUri(url.isEmpty ? "about:blank" : url)),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          initialSettings: settings,
          onLoadStart: (controller, url) {
            if (url.toString() == "${UrlContainer.domainUrl}/user/deposit/history" || url.toString() == "${UrlContainer.domainUrl}/user/order/detail/${widget.planId}" || url.toString() == "${UrlContainer.domainUrl}/user/esim/topups") {
              _handleSuccess();
            } else if (url.toString() == '${UrlContainer.domainUrl}/user/deposit' || url.toString() == '${UrlContainer.domainUrl}/user/dashboard') {
              Get.back();
              CustomSnackBar.error(errorList: [MyStrings.requestFail]);
            }
            setState(() {
              this.url = url.toString();
            });
          },
          onPermissionRequest: (controller, request) async {
            return PermissionResponse(resources: request.resources, action: PermissionResponseAction.GRANT);
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            var uri = navigationAction.request.url!;

            if (!["http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri.scheme)) {
              if (await canLaunchUrl(uri)) {
                // Launch the App
                await launchUrl(
                  uri,
                );
                // and cancel the request
                return NavigationActionPolicy.CANCEL;
              }
            }

            return NavigationActionPolicy.ALLOW;
          },
          onLoadStop: (controller, url) async {
            final currentUrl = url.toString();

            if (mounted) {
              setState(() {
                isLoading = false;
                this.url = currentUrl;
              });
            }

            if (currentUrl.contains("/user/deposit/history") || currentUrl.contains("/user/order/detail/${widget.planId}") || currentUrl.contains("/user/esim/topups")) {
              Future.microtask(() {
                _handleSuccess();
              });
            }
          },
          onReceivedError: (controller, request, error) {
            pullToRefreshController?.endRefreshing();
          },
          onProgressChanged: (controller, progress) {},
          onUpdateVisitedHistory: (controller, url, androidIsReload) {
            setState(() {
              this.url = url.toString();
            });
          },
          onConsoleMessage: (controller, consoleMessage) {},
        )
      ],
    );
  }
}

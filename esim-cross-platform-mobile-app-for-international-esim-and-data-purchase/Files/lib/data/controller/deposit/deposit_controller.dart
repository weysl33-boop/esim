// ignore_for_file: dead_null_aware_expression

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esim/data/model/deposit/user_response_model.dart';
import 'package:esim/data/model/store/store_details_data_response_model.dart';
import 'package:esim/data/model/user/user_model.dart';

import '../../../core/helper/shared_preference_helper.dart';
import '../../../core/helper/string_format_helper.dart';
import '../../../core/route/route.dart';
import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/deposit/deposit_insert_response_model.dart';
import '../../model/deposit/deposit_method_response_model.dart';
import '../../model/global/response_model/response_model.dart';
import '../../repo/deposit/deposit_repo.dart';

class DepositController extends GetxController with GetTickerProviderStateMixin {
  DepositRepo depositRepo;
  DepositController({required this.depositRepo});

  //Deposit tabs
  TabController? depositTabController;
  int currentTabIndex = 0;

  List<PlanData> planDataList = [];
  String planId = '';
  String planPriceFromRoute = '';
  double basePlanAmount = 0.0; // Store the original plan price separately

  bool isTopUp = false;
  bool hasUid = false;

  void setTopUpMode(bool value, {bool shouldUpdate = true}) {
    isTopUp = value;
    amountController.text = isTopUp ? "0.00" : basePlanAmount.toStringAsFixed(2);
    if (shouldUpdate) update();
  }

  void changeTopUpValue({bool shouldUpdate = true}) {
    isTopUp = !isTopUp;
    amountController.text = isTopUp ? "0.00" : basePlanAmount.toStringAsFixed(2);
    if (shouldUpdate) update();
  }

  void loadDepositTabsData() {
    depositTabController = TabController(initialIndex: currentTabIndex, length: 2, vsync: this);
  }

  void changeTabIndex(int value, {bool shouldUpdate = true, bool shouldAnimate = true}) {
    currentTabIndex = value;
    if (shouldAnimate && depositTabController != null && depositTabController!.index != value) {
      depositTabController!.animateTo(value);
    }
    if (shouldUpdate) update();
  }

  int spotWalletStep = 1;
  int fundingWalletStep = 1;

  void changeSpotWalletStep(int value) {
    spotWalletStep = value;
    update();
  }

  void changeFundingWalletStep(int value) {
    fundingWalletStep = value;
    update();
  }

  //get deposit all methods

  bool isDepositMethodLoading = true;
  List<DepositMethod> depositMethodList = [];
  List<DepositMethod> filteredDepositMethodList = [];
  List<DepositCurrency> depositCurrencyList = [];
  List<DepositCurrency> filteredDepositCurrencyList = [];
  DepositMethod? selectedDepositPaymentMethod = DepositMethod(name: MyStrings.selectOne, id: -1);
  DepositCurrency? selectedCurrency;

  TextEditingController amountController = TextEditingController();

  double rate = 1;
  double mainAmount = 0;
  String selectedValue = "";
  String depositLimit = "";
  String charge = "";
  String payable = "";
  String amount = "";
  String fixedCharge = "";
  String currency = '';
  String payableText = '';
  String conversionRate = '';
  String inLocal = '';
  User? userData;
  String planName = '';
  String planTalkTime = '';
  String planSMS = '';
  double planPrice = 0.0;
  double processingChargeAmount = 0.0;
  double processingChargePercentage = 0.0;

  String planDataDisplay = '';
  String planTalkTimeDisplay = '';
  String planSMSDisplay = '';
  String planDaysDisplay = '';
  // Display properties
  String planNameDisplay = ''; // Plan name

  // Initialize plan data from route arguments
  void initializePlanData(List<PlanData> planData, String id, String price, {bool shouldUpdate = true}) {
    planDataList = planData;
    planId = id;
    // planPriceFromRoute = planData.isNotEmpty ? (planData[0].price ?? "") : "";
    planPriceFromRoute = price ?? "";

    // Store the base plan amount separately
    basePlanAmount = double.tryParse(planPriceFromRoute) ?? 0.0;

    if (planPriceFromRoute.isNotEmpty) {
      // Set the initial amount without charges
      amountController.text = basePlanAmount.toStringAsFixed(2);
    }

    // Extract plan details from the first plan data
    if (planDataList.isNotEmpty) {
      extractPlanDetails(planDataList[0], shouldUpdate: false);
    } else {
      printX("ERROR: Plan data list is empty!");
    }

    if (shouldUpdate) update();
  }

  // Extract plan details from PlanData object
  void extractPlanDetails(PlanData plan, {bool shouldUpdate = true}) {
    printX("=== Extracting Plan Details ===");
    printX("Plan Object: ${plan.toJson()}");

    // Extract data volume
    if (plan.dataVolume != null && plan.dataVolume != "-1") {
      planDataDisplay = StringConverter.dataVolume(plan.dataVolume.toString(), isString: true);
    } else if (plan.dataVolume == "-1") {
      // API uses -1 for unlimited data.
      planDataDisplay = "Unlimited";
    } else {
      planDataDisplay = ''; // Default
    }

    // Extract voice/talk time
    if (plan.voiceQuantity != null && plan.voiceQuantity != "0.00") {
      double voiceMinutes = double.tryParse(plan.voiceQuantity.toString()) ?? 0.0;
      double voiceValue = StringConverter.voiceInMinutes(voiceMinutes);

      planTalkTimeDisplay = plan.voiceUnit != null ? '${voiceValue.toInt()} ${plan.voiceUnit}' : '${voiceValue.toInt()} Mins';
    } else {
      planTalkTimeDisplay = '';
    }

    // Extract SMS
    if (plan.smsQuantity != null && plan.smsQuantity != "0.00") {
      double smsCount = double.tryParse(plan.smsQuantity.toString()) ?? 0.0;
      double smsValue = StringConverter.voiceInMinutes(smsCount);

      planSMSDisplay = '${smsValue.toInt()} SMS';
    } else {
      planSMSDisplay = '';
    }
    printX("SMS Display: $planSMSDisplay");

    // Extract plan name/validity
    planNameDisplay = plan.name ?? '';
    planDaysDisplay = plan.period ?? '';
    printX("Plan Name: $planNameDisplay");
    printX("Days Display: $planDaysDisplay");

    if (shouldUpdate) update();
  }

  // Check if plan information should be shown
  bool shouldShowPlanInfo() {
    bool hasData = planDataList.isNotEmpty;
    bool hasGateway = selectedDepositPaymentMethod?.name != MyStrings.selectOne;
    bool hasAmount = amountController.text.trim().isNotEmpty;

    printX("=== Should Show Plan Info ===");
    printX("Has Data: $hasData");
    printX("Has Gateway: $hasGateway");
    printX("Has Amount: $hasAmount");
    printX("Result: ${hasData && hasGateway && hasAmount}");

    return hasData && hasGateway && hasAmount;
  }

  // Get plan details string
  String getPlanDetails() {
    if (planDataList.isEmpty) {
      return 'No plan details available';
    }
    final List<String> parts = [];

    if (planDataDisplay.trim().isNotEmpty) {
      parts.add(planDataDisplay.trim());
    }

    if (planSMSDisplay.trim().isNotEmpty && planSMSDisplay.trim() != "0 SMS") {
      parts.add(planSMSDisplay.trim());
    }

    if (planTalkTimeDisplay.trim().isNotEmpty) {
      parts.add(planTalkTimeDisplay.trim());
    }

    if (planDaysDisplay.trim().isNotEmpty) {
      parts.add(planDaysDisplay.trim());
    }

    if (parts.isNotEmpty) {
      return parts.join(' - ');
    }

    if (planNameDisplay.trim().isNotEmpty) {
      return planNameDisplay.trim();
    }

    return 'No plan details available';
  }

  // Get plan data
  String getPlanData() {
    return planDataDisplay.isEmpty ? '' : planDataDisplay;
  }

  // Get plan talk times
  String getPlanTalkTimes() {
    return planTalkTimeDisplay.isEmpty ? '' : planTalkTimeDisplay;
  }

  // Get plan SMS
  String getPlanSMS() {
    return planSMSDisplay.isEmpty ? '' : planSMSDisplay;
  }

  // Get plan days
  String getPlanDays() {
    return planDaysDisplay.isEmpty ? '' : planDaysDisplay;
  }

  // Get plan name
  String getPlanName() {
    return planNameDisplay;
  }

  // Get the base plan price (without charges)
  double getBasePlanPrice() {
    return basePlanAmount;
  }

  // Get plan price (display version)
  String getPlanPrice() {
    if (planDataList.isNotEmpty && planDataList[0].currency != null) {
      currency = planDataList[0].currency ?? currency;
    }

    return '${basePlanAmount.toStringAsFixed(2)} $currency';
  }

  // Get subtotal (same as plan price)
  String getSubtotal() {
    if (planDataList.isNotEmpty && planDataList[0].currency != null) {
      currency = planDataList[0].currency ?? currency;
    }

    return '${basePlanAmount.toStringAsFixed(2)} $currency';
  }

  // Calculate processing charge based on base plan price
  String getProcessingCharge() {
    // Get the processing charge from gateway if available
    processingChargeAmount = 0.0;
    processingChargePercentage = 0.0;

    if (selectedDepositPaymentMethod?.fixedCharge != null) {
      processingChargeAmount = double.tryParse(selectedDepositPaymentMethod?.fixedCharge.toString() ?? '0') ?? 0.0;
    }

    if (selectedDepositPaymentMethod?.percentCharge != null) {
      processingChargePercentage = double.tryParse(selectedDepositPaymentMethod?.percentCharge.toString() ?? '0') ?? 0.0;
    }

    // Calculate charge based on BASE PLAN AMOUNT, not current amountController value
    double charge = processingChargeAmount + (basePlanAmount * processingChargePercentage / 100);

    if (planDataList.isNotEmpty && planDataList[0].currency != null) {
      currency = planDataList[0].currency ?? currency;
    }

    return '${charge.toStringAsFixed(2)} $currency';
  }

  // Get total amount (display version)
  String getTotal() {
    double charge = processingChargeAmount + (basePlanAmount * processingChargePercentage / 100);
    double total = basePlanAmount + charge;

    if (planDataList.isNotEmpty && planDataList[0].currency != null) {
      currency = planDataList[0].currency ?? currency;
    }

    return '${total.toStringAsFixed(2)} $currency';
  }

  // Get total as double (useful for API calls)
  double getTotalAmount() {
    double charge = processingChargeAmount + (basePlanAmount * processingChargePercentage / 100);
    return basePlanAmount + charge;
  }

  String getBaseCurrency() {
    if (planDataList.isNotEmpty && planDataList[0].currency != null && planDataList[0].currency!.isNotEmpty) {
      return planDataList[0].currency!;
    }
    return currency;
  }

  String getTargetCurrency() {
    return selectedDepositPaymentMethod?.currency ?? '';
  }

  double getConversionRateValue() {
    return double.tryParse(selectedDepositPaymentMethod?.rate ?? '0') ?? 0;
  }

  bool shouldShowConvertedTotal() {
    if (selectedDepositPaymentMethod?.id == null || selectedDepositPaymentMethod?.id == -1) {
      return false;
    }

    final baseCurrency = getBaseCurrency().trim().toUpperCase();
    final targetCurrency = getTargetCurrency().trim().toUpperCase();
    final rateValue = getConversionRateValue();

    return baseCurrency.isNotEmpty && targetCurrency.isNotEmpty && rateValue > 0 && baseCurrency != targetCurrency;
  }

  String getTotalConversionRateText() {
    if (!shouldShowConvertedTotal()) return '';
    return '1 ${getBaseCurrency()} = ${StringConverter.formatNumber(getConversionRateValue().toString())} ${getTargetCurrency()}';
  }

  String getConvertedTotalText() {
    if (!shouldShowConvertedTotal()) return '';

    final convertedTotal = getTotalAmount() * getConversionRateValue();
    return '${StringConverter.formatNumber(convertedTotal.toString())} ${getTargetCurrency()}';
  }

  String methodPath = "";
  void selectDepositPaymentMethod(DepositMethod? method) {
    String amt = isTopUp ? "0.00" : amountController.text.toString();
    mainAmount = amt.isEmpty ? 0 : double.tryParse(amt) ?? 0;
    selectedDepositPaymentMethod = method;

    currency = selectedDepositPaymentMethod?.currency ?? '';
    depositLimit = '${StringConverter.formatNumber(method?.minAmount?.toString() ?? '-1')} - ${StringConverter.formatNumber(method?.maxAmount?.toString() ?? '-1')} $currency';

    // Update charges based on current selection
    changeDepositChargeInfoWidgetValue(basePlanAmount);

    // Recalculate and update the amount controller
    calculateAndSetTotalAmount();

    update();
  }

  void calculateAndSetTotalAmount() {
    // Use the stored base plan amount
    double baseAmount = basePlanAmount;

    if (selectedDepositPaymentMethod == null || selectedDepositPaymentMethod?.id == -1) {
      amountController.text = baseAmount.toStringAsFixed(2);
      return;
    }

    // Get charges
    double fixed = double.tryParse(selectedDepositPaymentMethod?.fixedCharge ?? '0') ?? 0.0;
    double percent = double.tryParse(selectedDepositPaymentMethod?.percentCharge ?? '0') ?? 0.0;

    // Calculate charge based on BASE amount
    double percentCharge = (baseAmount * percent) / 100;
    double totalCharge = fixed + percentCharge;

    // Store globally (used elsewhere)
    processingChargeAmount = fixed;
    processingChargePercentage = percent;

    // Calculate total
    double total = baseAmount + totalCharge;

    // Update the amount controller with total
    amountController.text = total.toStringAsFixed(2);
  }

  void selectDepositCurrency(DepositCurrency? currency) {
    selectedCurrency = currency;
    selectedDepositPaymentMethod = DepositMethod(name: MyStrings.selectOne, id: -1);

    filterDepositMethodBasedOnSelectedCurrency(selectedCurrency);

    update();
  }

  Future<void> getDepositAllMethodAndCurrencyList({String planId = ''}) async {
    depositMethodList.clear();
    depositMethodList.add(selectedDepositPaymentMethod!);
    currency = selectedDepositPaymentMethod?.currency ?? '';

    try {
      ResponseModel responseModel = await depositRepo.getDepositMethods();

      if (responseModel.statusCode == 200) {
        DepositMethodResponseModel methodsModel = DepositMethodResponseModel.fromJson(jsonDecode(responseModel.responseJson));

        if (methodsModel.message != null && methodsModel.message!.success != null) {
          List<DepositMethod>? tempList = methodsModel.data?.methods;
          if (tempList != null && tempList.isNotEmpty) {
            depositMethodList.addAll(tempList);
            methodPath = methodsModel.data?.imagePath ?? "";
            getUserData();
            update();
          }
          // List<DepositCurrency>? tempCurrencyList = methodsModel.data?.currencies;
          // if (tempCurrencyList != null && tempCurrencyList.isNotEmpty) {
          //   //set first wallet to selected

          //   //add all data to list;
          //   depositCurrencyList.addAll(tempCurrencyList);
          //   filteredDepositCurrencyList = depositCurrencyList;
          // }
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
        return;
      }
    } catch (e) {
      printX(e.toString());
    } finally {
      isDepositMethodLoading = false;
      update();
    }
  }

  Future<void> getUserData() async {
    try {
      ResponseModel responseModel = await depositRepo.getUserDataRepo();

      if (responseModel.statusCode == 200) {
        UserResponseModel methodsModel = userResponseModelFromJson(responseModel.responseJson);

        userData = methodsModel.data?.user;
        update();
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
        return;
      }
    } catch (e) {
      printX(e.toString());
    } finally {
      isDepositMethodLoading = false;
      update();
    }
  }

  void filterDepositCurrencyDataList(String searchText) {
    if (searchText.isEmpty) {
      filteredDepositCurrencyList = depositCurrencyList;
    } else {
      filteredDepositCurrencyList = depositCurrencyList.where((item) => item.symbol?.toLowerCase().contains(searchText.toLowerCase()) == true || item.name?.toLowerCase().contains(searchText.toLowerCase()) == true).toList();
    }

    update();
  }

  void filterDepositMethodBasedOnSelectedCurrency(DepositCurrency? depositCurrency) {
    if (depositCurrency == null) {
      filteredDepositMethodList = [];
    } else {
      filteredDepositMethodList = depositMethodList.where((item) => item.currency?.toLowerCase() == depositCurrency.symbol.toString().toLowerCase()).toList();
    }

    update();
  }

  // deposit charge calculations
  void changeDepositChargeInfoWidgetValue(double amount) {
    if (selectedDepositPaymentMethod?.id.toString() == '-1') {
      return;
    }
    currency = selectedDepositPaymentMethod?.currency ?? '';
    final String baseCurrency = getBaseCurrency();
    final String targetCurrency = getTargetCurrency();
    mainAmount = amount;

    double percent = double.tryParse(selectedDepositPaymentMethod?.percentCharge ?? '0') ?? 0;

    double percentCharge = (amount * percent) / 100;

    double temCharge = double.tryParse(selectedDepositPaymentMethod?.fixedCharge ?? '0') ?? 0;

    double totalCharge = percentCharge + temCharge;

    charge = '${StringConverter.formatNumber('$totalCharge')} $currency';

    double payable = totalCharge + amount;

    payableText = '${StringConverter.formatNumber(payable.toString())} $currency';

    rate = double.tryParse(selectedDepositPaymentMethod?.rate ?? '0') ?? 0;

    conversionRate = '1 $baseCurrency = $rate $targetCurrency';

    inLocal = '${StringConverter.formatNumber('${payable * rate}')} $targetCurrency';

    update();

    return;
  }

  void clearData() {
    depositLimit = '';

    charge = '';

    amountController.text = '';

    isDepositMethodLoading = false;

    depositMethodList.clear();
  }

  bool isShowRate() {
    if (rate > 1 && currency.toLowerCase() != selectedDepositPaymentMethod?.currency?.toLowerCase()) {
      return true;
    } else {
      return false;
    }
  }

  //Submit deposit

  bool submitLoading = false;
  Future<void> submitNewDeposit({
    String walletType = 'direct',
    String uid = '',
    String planId = '',
  }) async {
    if (walletType == 'direct') {
      if (selectedDepositPaymentMethod?.id.toString() == '-1') {
        CustomSnackBar.error(errorList: [MyStrings.selectPaymentGateway]);
        return;
      }

      String amount = amountController.text.toString();
      if (amount.isEmpty) {
        CustomSnackBar.error(errorList: [MyStrings.enterAmount]);
        return;
      }
    }
    submitLoading = true;
    update();
    final cleanUid = (uid == "null") ? "" : uid;
    final bool shouldReturnToDepositWallet = isTopUp || cleanUid.isNotEmpty || walletType == 'wallet';
    ResponseModel responseModel = await depositRepo.insertDeposit(planId: planId, uid: cleanUid, amount: amountController.text.toString(), isTopUp: cleanUid.isNotEmpty ? false : isTopUp, orderId: planId, methodCode: selectedDepositPaymentMethod?.methodCode ?? "", currency: walletType == "direct" ? selectedDepositPaymentMethod?.currency ?? "" : currency, walletType: walletType);

    if (responseModel.statusCode == 200) {
      DepositInsertResponseModel insertResponseModel = DepositInsertResponseModel.fromJson(jsonDecode(responseModel.responseJson));

      if (insertResponseModel.status.toString().toLowerCase() == "success") {
        if (isTopUp) {
          showWebView(insertResponseModel.data?.redirectUrl ?? "", returnToDepositWallet: shouldReturnToDepositWallet, uid: cleanUid);
        } else if (cleanUid.isNotEmpty) {
          if (walletType == 'direct') {
            hasUid = true;
            showWebView(insertResponseModel.data?.redirectUrl ?? "", returnToDepositWallet: shouldReturnToDepositWallet, uid: cleanUid);
          } else {
            Get.offAndToNamed(
              RouteHelper.depositScreen,
              arguments: [
                List<PlanData>.from(planDataList),
                this.planId,
                planPriceFromRoute,
                cleanUid,
                1,
                false,
              ],
            );
            CustomSnackBar.success(successList: [MyStrings.topUpSuccessful]);
          }

          update();
        } else {
          if (walletType == 'direct') {
            showWebView(insertResponseModel.data?.redirectUrl ?? "", returnToDepositWallet: shouldReturnToDepositWallet, uid: cleanUid);
          } else {
            Get.offAndToNamed(
              RouteHelper.depositScreen,
              arguments: [
                List<PlanData>.from(planDataList),
                this.planId,
                planPriceFromRoute,
                cleanUid,
                1,
                false,
              ],
            );
            CustomSnackBar.success(successList: insertResponseModel.message?.success ?? [MyStrings.depositSuccessful]);
          }
          update();
        }
        planDataList.clear();
        update();
      } else {
        CustomSnackBar.error(errorList: insertResponseModel.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(
        errorList: [responseModel.message],
      );
    }

    submitLoading = false;
    update();
  }

  void showWebView(
    String redirectUrl, {
    bool returnToDepositWallet = false,
    String uid = '',
  }) {
    Get.offAndToNamed(RouteHelper.depositWebViewScreen, arguments: [redirectUrl, planId]);
  }

  bool checkUserIsLoggedInOrNot() {
    return depositRepo.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.rememberMeKey) ?? false;
  }
}

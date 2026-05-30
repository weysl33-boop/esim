import 'package:get/get.dart';
import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/core/route/route.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/data/model/global/response_model/response_model.dart';
import 'package:esim/data/model/store/store_data_response_model.dart';
import 'package:esim/data/model/store/store_details_data_response_model.dart';
import 'package:esim/data/model/top_up/top_up_selected_plan_response_model.dart';
import 'package:esim/data/repo/top_up/top_up_repo.dart';
import 'package:esim/view/components/snack_bar/show_custom_snackbar.dart';

import '../../model/top_up/top_up_plans_response_model.dart';

class TopUpController extends GetxController {
  TopupRepo topupRepo;
  TopUpController({required this.topupRepo});
  int selectedIndex = -1;

  // Existing properties
  String? totalGlobalPlans;
  String? countryImagePath;
  String? regionImagePath;

  // Plans pagination
  List<Plan> planData = [];
  int countryPage = 0;
  String? countryNextPageUrl;
  bool isCountryLoading = false;

  // Regions pagination
  List<Datum> regionList = [];
  int validCountriesPage = 0;
  String? regionNextPageUrl;
  bool isRegionLoading = false;
  Countries? countries;

  // General loading state
  bool isLoading = false;

  // Dashboard data
  StoreDataResponseModel storeResponseModel = StoreDataResponseModel();
  String selectedPlanId = "";
  String selectedPlanName = "";
  // Initial load
  Future<void> loadStoreData() async {
    planData.clear();
    regionList.clear();
    countryPage = 0;
    validCountriesPage = 0;
    isLoading = true;
    update();

    try {
      // Load plans first page
      await getStoreDetails();
      // Load global plans count
      await loadGlobalPlansCount();
    } catch (e) {
      printX(e.toString());
    }

    isLoading = false;
    update();
  }

  String imagePath = "";

  // Get plans with pagination - IMPROVED VERSION
  Future<void> getStoreDetails() async {
    // Prevent loading if already loading
    if (isCountryLoading) return;

    // Prevent loading if no more pages
    if (countryPage > 0 && !hasNextPlan()) return;

    countryPage = countryPage + 1;

    // Clear list only on first page
    if (countryPage == 1) {
      planData.clear();
      update();
    }

    isCountryLoading = true;
    update();

    try {
      ResponseModel responseModel = await topupRepo.getStoreDetailsRepo(countryPage.toString(), selectedPlanId);

      if (responseModel.statusCode == 200) {
        TopUpPlansResponseModel model = topUpPlansResponseModelFromJson(responseModel.responseJson);

        if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
          // Get image path from first page only

          // Append or set plan data
          if (countryPage == 1) {
            planData = model.data?.plans ?? [];
          } else {
            // Append data for subsequent pages
            if (model.data?.plans != null) {
              planData.addAll(model.data!.plans ?? []);
            }
          }

          // Update next page URL
          //   countryNextPageUrl = model.data?.plans?.nextPageUrl;

          update();
        } else {
          CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printX(e.toString());
      CustomSnackBar.error(errorList: [MyStrings.somethingWentWrong]);
    }

    isCountryLoading = false;
    update();
  }

  bool planLoading = false;
  Future<void> getPlan() async {
    Plan selectedPlan = planData[selectedIndex];
    try {
      // Create PlanData from Plan

      planLoading = true;
      update();
      ResponseModel responseModel = await topupRepo.getPlanRepo(selectedPlan.uid ?? "", selectedPlanId);

      if (responseModel.statusCode == 200) {
        TopUpSelectedPlanResponseModel model = topUpSelectedPlanResponseModelFromJson(responseModel.responseJson);

        if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
          PlanData planData = PlanData(
            uid: selectedPlan.uid,
            price: selectedPlan.price,
            dataVolume: selectedPlan.dataVolume,
            voiceQuantity: selectedPlan.voiceQuantity,
            smsQuantity: selectedPlan.smsQuantity,
            currency: selectedPlan.currency,
            validity: selectedPlan.validity,
            name: selectedPlan.name,
            period: selectedPlan.name,
            voiceUnit: 'Mins',
            id: model.data?.topup?.id,
          );
          Get.toNamed(
            RouteHelper.depositScreen,
            arguments: [
              [planData],
              selectedPlanId.toString(),
              selectedPlan.price.toString(),
              model.data?.topup?.id.toString(),
            ],
          );

          update();
        } else {
          CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printX(e.toString());
      CustomSnackBar.error(errorList: [MyStrings.somethingWentWrong]);
    }

    planLoading = false;
    update();
  }

  String planId = "";

  // Get regions with pagination - IMPROVED VERSION
  Future<void> getValidCountries() async {
    // Prevent loading if already loading
    if (isRegionLoading) return;

    // Prevent loading if no more pages
    if (validCountriesPage > 0 && !hasNextRegion()) return;

    validCountriesPage = validCountriesPage + 1;

    // Clear list only on first page
    if (validCountriesPage == 1) {
      countries = null;
      regionList.clear();
      update();
    }

    isRegionLoading = true;
    update();

    try {
      ResponseModel responseModel = await topupRepo.getRegions(
        validCountriesPage.toString(),
        planId,
      );

      if (responseModel.statusCode == 200) {
        StoreDataResponseModel model = storeDataResponseModelFromJson(responseModel.responseJson);

        if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
          // Initialize countries if first page
          if (validCountriesPage == 1) {
            countries = model.data?.countries;
          } else {
            // Append data for subsequent pages
            if (model.data?.countries?.data != null) {
              countries?.data?.addAll(model.data!.countries!.data!);
            }
          }

          // Update next page URL
          regionNextPageUrl = model.data?.countries?.nextPageUrl;

          update();
        } else {
          CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printX(e.toString());
      CustomSnackBar.error(errorList: [MyStrings.somethingWentWrong]);
    }

    isRegionLoading = false;
    update();
  }

  // Reset valid countries when plan changes
  void resetValidCountries() {
    validCountriesPage = 0;
    countries = null;
    regionList.clear();
    regionNextPageUrl = null;
    update();
  }

  // Load global plans count (no pagination needed)
  Future<void> loadGlobalPlansCount() async {
    try {
      ResponseModel responseModel = await topupRepo.getGlobalPlansCount();

      if (responseModel.statusCode == 200) {
        StoreDataResponseModel model = storeDataResponseModelFromJson(responseModel.responseJson);

        if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
          totalGlobalPlans = model.data?.totalGlobalPlans;
          update();
        }
      }
    } catch (e) {
      printX(e.toString());
    }
  }

  // Check if plans have next page
  bool hasNextPlan() {
    return countryNextPageUrl != null && countryNextPageUrl!.isNotEmpty;
  }

  // Check if regions have next page
  bool hasNextRegion() {
    return regionNextPageUrl != null && regionNextPageUrl!.isNotEmpty;
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadStoreData();
  }
}

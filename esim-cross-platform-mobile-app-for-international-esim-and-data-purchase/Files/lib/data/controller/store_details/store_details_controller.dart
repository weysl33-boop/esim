import 'dart:async';

import 'package:get/get.dart';
import 'package:esim/core/helper/shared_preference_helper.dart';
import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/core/route/route.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/data/model/dashboard/dashboard_response_model.dart';
import 'package:esim/data/model/global/response_model/response_model.dart';
import 'package:esim/data/model/store/plan_purchase_response_model.dart';
import 'package:esim/data/model/store/store_data_response_model.dart';
import 'package:esim/data/model/store/store_details_data_response_model.dart';
import 'package:esim/data/repo/store/store_details_repo.dart';
import 'package:esim/view/components/snack_bar/show_custom_snackbar.dart';

class StoreDetailsController extends GetxController {
  StoreDetailsRepo storeDetailsRepo;
  StoreDetailsController({required this.storeDetailsRepo});
  int selectedIndex = -1;

  // Existing properties
  String? totalGlobalPlans;
  String? countryImagePath;
  String? regionImagePath;

  // Plans pagination
  List<PlanData> planData = [];
  Campaign? campaign;
  int countryPage = 0;
  String? countryNextPageUrl;
  bool isCountryLoading = false;

  // Regions pagination
  List<Datum> regionList = [];
  int validCountriesPage = 0;
  String? regionNextPageUrl;
  bool isRegionLoading = false;
  Countries? countries;
  int _validCountriesRequestId = 0;

  // General loading state
  bool isLoading = false;

  // Dashboard data
  StoreDataResponseModel storeResponseModel = StoreDataResponseModel();
  String selectedCountryId = "";
  String desiredPlanId = "";
  String selectedPlanName = "";
  String discountPrice = "";
  bool fromCampaign = false;
  bool fromRegion = false;
  bool understand = false;
  bool checkUserIsLoggedInOrNot() {
    return storeDetailsRepo.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.rememberMeKey) ?? false;
  }

  void changeUnderstand() {
    understand = !understand;
    update();
  }

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
  String bannnerPath = "";

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
      ResponseModel responseModel = await storeDetailsRepo.getStoreDetailsRepo(countryPage.toString(), selectedCountryId, fromCampaign, fromRegion);

      if (responseModel.statusCode == 200) {
        StoreDetailsDataResponseModel model = storeDetailsDataResponseModelFromJson(responseModel.responseJson);

        if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
          // Get image path from first page only
          if (countryPage == 1) {
            if (fromRegion) {
              imagePath = model.data?.region?.imagePath ?? "";
              bannnerPath = model.data?.region?.bannerPath ?? "";
            } else {
              imagePath = model.data?.country?.imageSrc ?? "";
              bannnerPath = model.data?.country?.bannerPath ?? "";
            }
          }

          // Append or set plan data
          if (countryPage == 1) {
            planData = model.data?.plans?.data ?? [];
            campaign = model.data?.campaign;
          } else {
            // Append data for subsequent pages
            if (model.data?.plans?.data != null) {
              planData.addAll(model.data!.plans!.data!);
            }
          }

          // Update next page URL
          countryNextPageUrl = model.data?.plans?.nextPageUrl;

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
    try {
      planLoading = true;
      update();
      ResponseModel responseModel = await storeDetailsRepo.getPlanRepo(desiredPlanId);

      if (responseModel.statusCode == 200) {
        PlanPurchaseResponseModel model = planPurchaseResponseModelFromJson(responseModel.responseJson);

        if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
          Get.toNamed(
            RouteHelper.depositScreen,
            arguments: [
              [planData[selectedIndex]],
              model.data?.order?.id?.toString() ?? "",
              fromCampaign ? discountPrice : model.data?.order?.totalAmount?.toString() ?? "",
              ""
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
  String searchText = "";
  Timer? _debounce;

  // Add these separate fields for bottom sheet search
  Countries? searchCountries; // used only in bottom sheet
  bool isBottomSheetSearchLoading = false;
  int searchCountriesPage = 1;
  String searchNextPageUrl = '';

  void onSearchChanged(String value) {
    searchText = value;
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    isBottomSheetSearchLoading = true;
    update();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      loadBottomSheetCountries(isSearch: true);
    });

    isBottomSheetSearchLoading = false;
    update();
  }

  bool isSearchPaginationLoading = false;

  Future<void> loadBottomSheetCountries({bool isSearch = false}) async {
    if (isSearch) {
      if (isBottomSheetSearchLoading) return;
      searchCountriesPage = 1;
      searchCountries = null;
      searchNextPageUrl = '';
      isBottomSheetSearchLoading = true;
    } else {
      if (isSearchPaginationLoading || !hasNextSearchCountry()) return;
      searchCountriesPage++;
      isSearchPaginationLoading = true;
    }
    update();

    try {
      ResponseModel responseModel = await storeDetailsRepo.getRegions(
        searchCountriesPage.toString(),
        planId,
        searchText,
      );

      if (responseModel.statusCode == 200) {
        StoreDataResponseModel model = storeDataResponseModelFromJson(responseModel.responseJson);

        if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
          if (searchCountriesPage == 1) {
            searchCountries = model.data?.countries;
          } else {
            searchCountries?.data?.addAll(model.data?.countries?.data ?? []);
          }
          searchNextPageUrl = model.data?.countries?.nextPageUrl ?? '';
        }
      }
    } catch (e) {
      printX(e.toString());
    }

    isBottomSheetSearchLoading = false;
    isSearchPaginationLoading = false;
    update();
  }

  void resetBottomSheetSearch() {
    searchText = "";
    searchCountries = null;
    searchCountriesPage = 1;
    searchNextPageUrl = '';
    isBottomSheetSearchLoading = false;
    isSearchPaginationLoading = false;
    _debounce?.cancel();
    update();
  }

  bool hasNextSearchCountry() => searchNextPageUrl.isNotEmpty;

  // Get regions with pagination - IMPROVED VERSION
  Future<void> getValidCountries({bool isSearch = false}) async {
    if (isRegionLoading) return;
    final int requestId = ++_validCountriesRequestId;

    if (!isSearch) {
      if (validCountriesPage > 0 && !hasNextRegion()) return;
      validCountriesPage++;
    } else {
      validCountriesPage = 1;
      countries = null;
    }

    isRegionLoading = true;
    update();

    try {
      ResponseModel responseModel = await storeDetailsRepo.getRegions(
        validCountriesPage.toString(),
        planId,
        searchText,
      );

      if (responseModel.statusCode == 200) {
        StoreDataResponseModel model = storeDataResponseModelFromJson(responseModel.responseJson);

        if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
          // Ignore stale responses from previous fast taps.
          if (requestId != _validCountriesRequestId) return;

          if (validCountriesPage == 1) {
            countries = model.data?.countries;
          } else {
            countries?.data?.addAll(model.data?.countries?.data ?? []);
          }

          regionNextPageUrl = model.data?.countries?.nextPageUrl;
          update();
        }
      }
    } catch (e) {
      printX(e.toString());
    } finally {
      if (requestId == _validCountriesRequestId) {
        isRegionLoading = false;
        update();
      }
    }
  }

  // Reset valid countries when plan changes
  void resetValidCountries() {
    _validCountriesRequestId++;
    isRegionLoading = false;
    validCountriesPage = 0;
    countries = Countries(data: const []);
    regionList.clear();
    regionNextPageUrl = null;
    update();
  }

  void selectPlan(int index) {
    selectedIndex = index;
    final selectedPlan = planData[index];
    planId = selectedPlan.id.toString();

    final double actualPrice = double.tryParse(selectedPlan.price ?? "") ?? 0.0;
    final double discountPercentage = double.tryParse(selectedPlan.campaign?.discount ?? "") ?? 0.0;
    final double calculatedDiscount = (actualPrice / 100) * discountPercentage;
    final double afterDiscountPrice = actualPrice - calculatedDiscount;

    discountPrice = afterDiscountPrice.toString();
    desiredPlanId = selectedPlan.id.toString();

    resetValidCountries();
    getValidCountries();
    update();
  }

  // Load global plans count (no pagination needed)
  Future<void> loadGlobalPlansCount() async {
    try {
      ResponseModel responseModel = await storeDetailsRepo.getGlobalPlansCount();

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

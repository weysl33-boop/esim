import 'dart:async';

import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/data/model/global/response_model/response_model.dart';
import 'package:esim/data/model/store/store_data_response_model.dart';
import 'package:esim/data/repo/store/store_repo.dart';
import 'package:esim/view/components/snack_bar/show_custom_snackbar.dart';
import 'package:get/get.dart';

class StoreController extends GetxController {
  StoreRepo storeRepo;
  StoreController({required this.storeRepo});

  String? totalGlobalPlans;
  String? countryImagePath;
  String? regionImagePath;

  // Countries pagination
  List<Datum> countryList = [];
  int countryPage = 0;
  String? countryNextPageUrl;
  bool isCountryLoading = false;
  bool isCountryFetching = false;
  bool hasLoadedCountry = false;

  // Regions pagination
  List<Datum> regionList = [];
  int regionPage = 0;
  String? regionNextPageUrl;
  bool isRegionLoading = false;
  bool isRegionFetching = false;
  bool hasLoadedRegion = false;

  bool isGlobalLoading = false;
  bool isGlobalFetching = false;
  bool hasLoadedGlobal = false;

  bool isLoading = false;
  StoreDataResponseModel storeResponseModel = StoreDataResponseModel();

  // Search
  String searchQuery = '';
  int activeTabIndex = 0;
  Timer? _debounce;

  void onTabChanged(int index) {
    activeTabIndex = index;
    // Re-run search for the newly active tab if there's a query
    if (searchQuery.isNotEmpty) {
      _triggerSearch();
    }
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _triggerSearch();
    });
  }

  void _triggerSearch() {
    if (activeTabIndex == 0) {
      countryPage = 0;
      countryList.clear();
      getCountries();
    } else if (activeTabIndex == 1) {
      regionPage = 0;
      regionList.clear();
      getRegions();
    }
  }

  Future<void> loadStoreData({bool shouldLoad = true}) async {
    isLoading = shouldLoad;

    countryPage = 0;
    regionPage = 0;
    countryNextPageUrl = null;
    regionNextPageUrl = null;
    searchQuery = '';
    hasLoadedCountry = false;
    hasLoadedRegion = false;
    hasLoadedGlobal = false;
    update();
    try {
      await getCountries(shouldLoad: shouldLoad);
      await getRegions(shouldLoad: shouldLoad);
      await loadGlobalPlansCount(shouldLoad: shouldLoad);
    } catch (e) {
      printX(e.toString());
    }

    isLoading = false;
    update();
  }

  Future<void> getCountries({bool shouldLoad = true}) async {
    final isFirstPageRequest = countryPage == 0;
    if (isFirstPageRequest) {
      countryList.clear();
      countryNextPageUrl = null;
    }
    countryPage = countryPage + 1;
    isCountryLoading = shouldLoad && isFirstPageRequest;
    isCountryFetching = true;
    update();

    try {
      ResponseModel responseModel = await storeRepo.getCountries(
        countryPage.toString(),
        search: searchQuery,
      );

      if (responseModel.statusCode == 200) {
        StoreDataResponseModel model = storeDataResponseModelFromJson(responseModel.responseJson);

        if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
          countryNextPageUrl = model.data?.countries?.nextPageUrl;
          List<Datum>? tempList = model.data?.countries?.data;
          countryImagePath = model.data?.countries?.path;

          if (tempList != null && tempList.isNotEmpty) {
            countryList.addAll(tempList);
          }
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
    isCountryFetching = false;
    hasLoadedCountry = true;
    update();
  }

  Future<void> getRegions({bool shouldLoad = true}) async {
    final isFirstPageRequest = regionPage == 0;
    if (isFirstPageRequest) {
      regionList.clear();
      regionNextPageUrl = null;
    }
    regionPage = regionPage + 1;
    isRegionLoading = shouldLoad && isFirstPageRequest;
    isRegionFetching = true;
    update();

    try {
      ResponseModel responseModel = await storeRepo.getRegions(
        regionPage.toString(),
        search: searchQuery,
      );

      if (responseModel.statusCode == 200) {
        StoreDataResponseModel model = storeDataResponseModelFromJson(responseModel.responseJson);

        if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
          regionNextPageUrl = model.data?.regions?.nextPageUrl;
          List<Datum>? tempList = model.data?.regions?.data;
          regionImagePath = model.data?.regions?.path;

          if (tempList != null && tempList.isNotEmpty) {
            regionList.addAll(tempList);
          }
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
    isRegionFetching = false;
    hasLoadedRegion = true;
    update();
  }

  Future<void> loadGlobalPlansCount({bool shouldLoad = true}) async {
    isGlobalLoading = shouldLoad;
    isGlobalFetching = true;
    totalGlobalPlans = null;
    update();

    try {
      ResponseModel responseModel = await storeRepo.getGlobalPlansCount();

      if (responseModel.statusCode == 200) {
        StoreDataResponseModel model = storeDataResponseModelFromJson(responseModel.responseJson);

        if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
          totalGlobalPlans = model.data?.totalGlobalPlans;
        }
      }
    } catch (e) {
      printX(e.toString());
    }

    isGlobalLoading = false;
    isGlobalFetching = false;
    hasLoadedGlobal = true;
    update();
  }

  bool hasNextCountry() => countryNextPageUrl != null && countryNextPageUrl!.isNotEmpty;
  bool hasNextRegion() => regionNextPageUrl != null && regionNextPageUrl!.isNotEmpty;

  Future<void> refreshData({bool shouldLoad = true}) async {
    searchQuery = '';
    await loadStoreData(shouldLoad: shouldLoad);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}

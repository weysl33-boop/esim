import 'package:esim/core/helper/shared_preference_helper.dart';
import 'package:get/get.dart';
import 'package:esim/core/helper/string_format_helper.dart';
import 'package:esim/core/utils/my_strings.dart';
import 'package:esim/data/model/global/response_model/response_model.dart';
import 'package:esim/data/model/my_esim/active_esim_response_model.dart';
import 'package:esim/data/repo/my_esim/my_esim_repo.dart';
import 'package:esim/view/components/snack_bar/show_custom_snackbar.dart';

class MyEsimController extends GetxController {
  MyEsimRepo myEsimRepo;
  MyEsimController({required this.myEsimRepo});
  bool isLoading = false;
  bool hasInitialDataLoaded = false;
  bool esimPageLoading = false;
  bool expiredEsimPageLoading = false;
  String? esimNextPageUrl;
  String? expiredEsimNextPageUrl;
  List<ActiveESIMPlanData> activeEsimData = [];
  List<ActiveESIMPlanData> expiredEsimData = [];
  int esimPage = 0;
  int expiredEsimPage = 0;

  Future<void> loadStoreData({bool shouldLoad = true}) async {
    if (!checkUserIsLoggedInOrNot()) {
      return;
    }

    activeEsimData.clear();
    expiredEsimData.clear();

    esimPage = 0;
    expiredEsimPage = 0;
    esimNextPageUrl = null;
    expiredEsimNextPageUrl = null;
    isLoading = shouldLoad;
    hasInitialDataLoaded = false;
    update();

    try {
      // Load plans first page
      await getMyEsimController();
      // Load expired plans first page
      await getMyExpiredEsimController();
      // Load global plans count
      // await loadGlobalPlansCount();
    } catch (e) {
      printX(e.toString());
    } finally {
      isLoading = false;
      hasInitialDataLoaded = true;
      update();
    }
  }

  String imagePath = "";

  // Get plans with pagination - IMPROVED VERSION
  Future<void> getMyEsimController() async {
    // Prevent loading if already loading
    if (esimPageLoading) return;

    // Prevent loading if no more pages
    if (esimPage > 0 && !hasNextPlan()) return;

    final requestedPage = esimPage + 1;

    // Clear list only on first page
    if (requestedPage == 1) {
      activeEsimData.clear();
      update();
    }

    esimPageLoading = true;
    update();

    try {
      ResponseModel responseModel = await myEsimRepo.getMyActiveEsimRepo(requestedPage.toString());

      if (responseModel.statusCode == 200) {
        ActiveEsimResponseModel model = activeEsimResponseModelFromJson(responseModel.responseJson);

        if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
          esimPage = requestedPage;
          // Get image path from first page only
          // if (esimPage == 1) {
          //   imagePath = model.data?.esims?. ?? "";
          // }

          // Append or set plan data
          if (requestedPage == 1) {
            activeEsimData = model.data?.esims?.data ?? [];
          } else {
            // Append data for subsequent pages
            if (model.data?.esims?.data != null) {
              activeEsimData.addAll(model.data!.esims!.data!);
            }
          }

          // Update next page URL
          esimNextPageUrl = model.data?.esims?.nextPageUrl;

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

    esimPageLoading = false;
    update();
  }

  bool hasNextPlan() {
    final next = esimNextPageUrl?.trim();
    return next != null && next.isNotEmpty && next.toLowerCase() != 'null';
  }

  // Get plans with pagination - IMPROVED VERSION
  Future<void> getMyExpiredEsimController() async {
    // Prevent loading if already loading
    if (expiredEsimPageLoading) return;

    // Prevent loading if no more pages
    if (expiredEsimPage > 0 && !hasNextExpiredEsimPlan()) return;

    final requestedPage = expiredEsimPage + 1;

    // Clear list only on first page
    if (requestedPage == 1) {
      expiredEsimData.clear();
      update();
    }

    expiredEsimPageLoading = true;
    update();

    try {
      ResponseModel responseModel = await myEsimRepo.getMyExpiredEsimRepo(requestedPage.toString());

      if (responseModel.statusCode == 200) {
        ActiveEsimResponseModel model = activeEsimResponseModelFromJson(responseModel.responseJson);

        if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
          expiredEsimPage = requestedPage;
          // Get image path from first page only
          // if (esimPage == 1) {
          //   imagePath = model.data?.esims?. ?? "";
          // }
          // Append or set plan data
          if (requestedPage == 1) {
            expiredEsimData = model.data?.esims?.data ?? [];
          } else {
            // Append data for subsequent pages
            if (model.data?.esims?.data != null) {
              expiredEsimData.addAll(model.data?.esims?.data ?? []);
            }
          }

          // Update next page URL
          expiredEsimNextPageUrl = model.data?.esims?.nextPageUrl;

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

    expiredEsimPageLoading = false;
    update();
  }

  bool hasNextExpiredEsimPlan() {
    final next = expiredEsimNextPageUrl?.trim();
    return next != null && next.isNotEmpty && next.toLowerCase() != 'null';
  }

  bool checkUserIsLoggedInOrNot() {
    return myEsimRepo.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.rememberMeKey) ?? false;
  }
}

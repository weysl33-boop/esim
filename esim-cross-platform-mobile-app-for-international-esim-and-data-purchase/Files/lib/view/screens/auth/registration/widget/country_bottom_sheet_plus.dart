import 'package:esim/core/utils/my_icons.dart';
import 'package:esim/data/controller/store_details/store_details_controller.dart';
import 'package:esim/view/components/card/custom_app_card.dart';
import 'package:esim/view/components/custom_loader/custom_loader.dart';
import 'package:esim/view/components/image/my_local_image_widget.dart';
import 'package:esim/view/components/image/my_network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/url_container.dart';
import '../../../../../data/controller/account/profile_complete_controller.dart';
import '../../../../../data/controller/auth/auth/registration_controller.dart';
import '../../../../components/bottom-sheet/bottom_sheet_header_row.dart';
import '../../../../components/bottom-sheet/custom_bottom_sheet_plus.dart';

class CountryBottomSheetPlus {
  static void showSignUpBottomSheet(BuildContext context, RegistrationController controller) {
    CustomBottomSheetPlus(
      isNeedPadding: false,
      bgColor: MyColor.transparentColor,
      child: StatefulBuilder(
        builder: (BuildContext context, setState) {
          if (controller.filteredCountries.isEmpty) {
            controller.filteredCountries = controller.countryList;
          }
          // Function to filter countries based on the search input.
          void filterCountries(String query) {
            if (query.isEmpty) {
              controller.filteredCountries = controller.countryList;
            } else {
              setState(() {
                controller.filteredCountries = controller.countryList.where((country) => country.country!.toLowerCase().contains(query.toLowerCase())).toList();
              });
            }
          }

          return Container(
            height: MediaQuery.of(context).size.height * 1,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              color: MyColor.getScreenBgSecondaryColor(),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const BottomSheetHeaderRow(header: '', bottomSpace: 15),

                // Add the search field.
                TextField(
                  controller: controller.searchCountryController,
                  onChanged: filterCountries,
                  decoration: InputDecoration(
                    hintText: MyStrings.searchCountry.tr,
                    prefixIcon: Icon(
                      Icons.search,
                      color: MyColor.getSecondaryTextColor(),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: MyColor.getBorderColor()),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: MyColor.getPrimaryColor()),
                    ),
                  ),
                  cursorColor: MyColor.getPrimaryColor(),
                ),
                const SizedBox(
                  height: 15,
                ),
                Flexible(
                  child: ListView.builder(
                      itemCount: controller.filteredCountries.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        var countryItem = controller.filteredCountries[index];

                        return GestureDetector(
                          onTap: () {
                            // controller.setCountryNameAndCode(
                            //   controller.filteredCountries[index].country.toString(),
                            //   controller.filteredCountries[index].countryCode.toString(),
                            //   controller.filteredCountries[index].dialCode.toString(),
                            // );
                            // controller.updateMobilecode(controller.filteredCountries[index].dialCode.toString());
                            // controller.selectCountryData(controller.filteredCountries[index]);
                            // Navigator.pop(context);
                            // FocusScopeNode currentFocus = FocusScope.of(context);
                            // if (!currentFocus.hasPrimaryFocus) {
                            //   currentFocus.unfocus();
                            // }
                            // controller.mobileFocusNode.nextFocus();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: MyColor.transparentColor,
                              border: Border(
                                bottom: BorderSide(
                                  color: MyColor.colorGrey.withValues(alpha: 0.3),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(end: Dimensions.space10),
                                  child: MyNetworkImageWidget(
                                    imageUrl: UrlContainer.countryFlagImageLink.replaceAll("{countryCode}", countryItem.countryCode.toString().toLowerCase()),
                                    height: Dimensions.space25,
                                    width: Dimensions.space40 + 2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(end: Dimensions.space10),
                                  child: Text(
                                    '+${countryItem.dialCode}',
                                    style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${countryItem.country}',
                                    style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          );
        },
      ),
    ).show(context);
  }

  static void showProfileCompleteBottomSheet(BuildContext context, ProfileCompleteController controller) {
    CustomBottomSheetPlus(
      isNeedPadding: false,
      bgColor: MyColor.transparentColor,
      child: StatefulBuilder(
        builder: (BuildContext context, setState) {
          if (controller.filteredCountries.isEmpty) {
            controller.filteredCountries = controller.countryList;
          }
          // Function to filter countries based on the search input.
          void filterCountries(String query) {
            if (query.isEmpty) {
              controller.filteredCountries = controller.countryList;
            } else {
              setState(() {
                controller.filteredCountries = controller.countryList.where((country) => country.country!.toLowerCase().contains(query.toLowerCase())).toList();
              });
            }
          }

          return Container(
            height: MediaQuery.of(context).size.height * 1,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              color: MyColor.getScreenBgSecondaryColor(),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const BottomSheetHeaderRow(header: '', bottomSpace: 15),

                // Add the search field.
                TextField(
                  controller: controller.searchCountryController,
                  onChanged: filterCountries,
                  decoration: InputDecoration(
                    hintText: MyStrings.searchCountry.tr,
                    prefixIcon: Icon(
                      Icons.search,
                      color: MyColor.getSecondaryTextColor(),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: MyColor.getBorderColor()),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: MyColor.getPrimaryColor()),
                    ),
                  ),
                  cursorColor: MyColor.getPrimaryColor(),
                ),
                const SizedBox(
                  height: 15,
                ),
                Flexible(
                  child: ListView.builder(
                      itemCount: controller.filteredCountries.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        var countryItem = controller.filteredCountries[index];

                        return GestureDetector(
                          onTap: () {
                            controller.setCountryNameAndCode(
                              controller.filteredCountries[index].country.toString(),
                              controller.filteredCountries[index].countryCode.toString(),
                              controller.filteredCountries[index].dialCode.toString(),
                            );
                            controller.updateMobilecode(controller.filteredCountries[index].dialCode.toString());
                            controller.selectCountryData(controller.filteredCountries[index]);
                            Navigator.pop(context);
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                            controller.mobileNoFocusNode.nextFocus();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: MyColor.transparentColor,
                              border: Border(
                                bottom: BorderSide(
                                  color: MyColor.colorGrey.withValues(alpha: 0.3),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(end: Dimensions.space10),
                                  child: MyNetworkImageWidget(
                                    imageUrl: UrlContainer.countryFlagImageLink.replaceAll("{countryCode}", countryItem.countryCode.toString().toLowerCase()),
                                    height: Dimensions.space25,
                                    width: Dimensions.space40 + 2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(end: Dimensions.space10),
                                  child: Text(
                                    '+${countryItem.dialCode}',
                                    style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${countryItem.country}',
                                    style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          );
        },
      ),
    ).show(context);
  }

  static void showValidCountriesBottomSheet(BuildContext context) {
    final controller = Get.find<StoreDetailsController>();
    final ScrollController scrollController = ScrollController();

    scrollController.addListener(() {
      if (!scrollController.hasClients) return;
      final maxScroll = scrollController.position.maxScrollExtent;
      final current = scrollController.position.pixels;

      // Use threshold to avoid triggering at exact 0.0 on initial load
      if (maxScroll > 0 && current >= maxScroll - 100) {
        if (controller.hasNextSearchCountry() && !controller.isSearchPaginationLoading) {
          controller.loadBottomSheetCountries(); // pagination call (isSearch: false)
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetBottomSheetSearch();
      controller.loadBottomSheetCountries(isSearch: true);
    });

    CustomBottomSheetPlus(
      isNeedPadding: false,
      bgColor: MyColor.getScreenBgColor(),
      child: StatefulBuilder(
        builder: (BuildContext context, setState) {
          return GetBuilder<StoreDetailsController>(
            builder: (controller) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.85,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  color: MyColor.getScreenBgSecondaryColor(),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    const BottomSheetHeaderRow(
                      header: MyStrings.validCountries,
                      bottomSpace: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: MyColor.colorWhite,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: MyColor.colorBlack.withValues(alpha: .05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (v) => controller.onSearchChanged(v),
                        decoration: InputDecoration(
                          hintText: MyStrings.whereAreWeTraveling,
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 22),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.space15),
                    Flexible(
                      child: controller.isBottomSheetSearchLoading
                          ? const CustomLoader()
                          : (controller.searchCountries?.data?.isEmpty ?? true)
                              ? Center(
                                  child: Text(
                                    MyStrings.noDataFound.tr,
                                    style: const TextStyle(fontSize: 16, color: MyColor.colorGrey),
                                  ),
                                )
                              : ListView.builder(
                                  controller: scrollController,
                                  itemCount: (controller.searchCountries?.data?.length ?? 0) + (controller.isSearchPaginationLoading ? 1 : 0),
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    if (index == (controller.searchCountries?.data?.length ?? 0)) {
                                      return CustomLoader(
                                        isPagination: true,
                                      );
                                    }

                                    var countryItem = controller.searchCountries!.data![index];
                                    return AppCard(
                                      onTap: () {},
                                      shadow: BoxShadow(
                                        color: MyColor.colorBlack.withValues(alpha: .03),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                      margin: const EdgeInsets.only(bottom: Dimensions.space18),
                                      padding: EdgeInsets.zero,
                                      enableShadow: true,
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(Dimensions.space100),
                                          child: MyNetworkImageWidget(
                                            height: Dimensions.space25,
                                            width: Dimensions.space25,
                                            boxFit: BoxFit.fill,
                                            imageUrl: countryItem.image == null || countryItem.image!.isEmpty ? UrlContainer.countryFlagImageLink.replaceAll("{countryCode}", (countryItem.code ?? '').toLowerCase()) : "${countryItem.image}",
                                            errorWidget: MyLocalImageWidget(
                                              imagePath: MyIcons.globe,
                                              height: Dimensions.space25,
                                              width: Dimensions.space25,
                                            ),
                                          ),
                                        ),
                                        title: Text(countryItem.name ?? "", style: semiBoldMediumLarge),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    ).show(context);
  }
}

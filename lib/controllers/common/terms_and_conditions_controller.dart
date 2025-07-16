import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sarf/controllers/auth/register_controller.dart';
import 'package:sarf/src/Auth/change_password.dart';
import '../../constant/api_links.dart';
import '../../model/moreModel/about.dart';
import '../../resources/resources.dart';
import '../../services/app_exceptions.dart';
import '../../services/dio_client.dart';
import '../../src/utils/routes_name.dart';
import '../../src/widgets/loader.dart';

class TermsAndConditionsController extends GetxController {
  var message;
  moreModel? userInfo;
  var isLoadingSupport = false.obs;

  @override
  void onInit() {
    // GetStorage().write('lang', 'en');
    super.onInit();
  }

  Future<void> terms() async {
    try {
      debugPrint('[terms] Starting terms and conditions API call...');

      final request = {
        'language': GetStorage().read('lang') ?? 'en',
        'id': 3
      };
      debugPrint('[terms] Request data: $request');

      debugPrint('[terms] Making POST request to ${ApiLinks.about}');
      final response = await DioClient().post(ApiLinks.about, request).catchError((error) {
        debugPrint('[terms] API request failed: ${error.toString()}');
        if (Get.isDialogOpen == true) Get.back();

        String errorMessage = 'Failed to load terms and conditions'.tr;
        Color backgroundColor = R.colors.themeColor;

        if (error is BadRequestException) {
          try {
            final apiError = json.decode(error.message!);
            errorMessage = apiError["reason"]?.toString() ?? errorMessage;
          } catch (e) {
            errorMessage = error.message ?? errorMessage;
          }
        }

        // Show already translated string
        Get.snackbar(
          'Error'.tr,
          errorMessage, // Don't call .tr here as it's already translated or a raw API message
          snackPosition: SnackPosition.TOP,
          backgroundColor: backgroundColor,
          colorText: Colors.white,
        );
        return null;
      });

      if (response == null) return;

      debugPrint('[terms] API response received: ${response.toString()}');
      final apiMessage = response['message']?.toString() ?? 'No message from server';
      message = apiMessage; // Store raw message

      if (response['success'] == true) {
        userInfo = moreModel.fromJson(response);
        update();
      } else {
        if (Get.isDialogOpen == true) Get.back();

        // Show API message without .tr since it's from server
        Get.snackbar(
          'Error'.tr,
          apiMessage, // Raw API message
          snackPosition: SnackPosition.TOP,
          backgroundColor: R.colors.themeColor,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[terms] Uncaught exception: $e\n$stackTrace');
      if (Get.isDialogOpen == true) Get.back();

      Get.snackbar(
        'Error'.tr,
        'An unexpected error occurred'.tr, // Pre-translated string
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
      );
    } finally {
      debugPrint('[terms] Terms function completed');
    }
  }}

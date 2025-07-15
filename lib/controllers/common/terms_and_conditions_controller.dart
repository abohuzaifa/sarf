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

      // Prepare request data with default language fallback
      final request = {
        'language': GetStorage().read('lang') ?? 'en',
        'id': 3  // Terms and conditions identifier
      };
      debugPrint('[terms] Request data: $request');

      // Show loading dialog (uncomment if needed)
      // DialogBoxes.openLoadingDialog();
      debugPrint('[terms] Loading dialog shown');

      // Make API call
      debugPrint('[terms] Making POST request to ${ApiLinks.about}');
      final response = await DioClient().post(ApiLinks.about, request).catchError((error) {
        debugPrint('[terms] API request failed: ${error.toString()}');

        // Hide loading dialog if open
        if (Get.isDialogOpen == true) Get.back();

        String errorMessage = 'Failed to load terms and conditions';
        Color backgroundColor = R.colors.themeColor;

        if (error is BadRequestException) {
          debugPrint('[terms] BadRequestException: ${error.message}');
          try {
            final apiError = json.decode(error.message!);
            errorMessage = apiError["reason"]?.toString() ?? error.message ?? errorMessage;
          } catch (e) {
            debugPrint('[terms] Error parsing error message: $e');
          }
        } else if (error is FetchDataException) {
          debugPrint('[terms] FetchDataException: ${error.message}');
          errorMessage = 'Connection error. Please try again.';
        } else if (error is ApiNotRespondingException) {
          debugPrint('[terms] ApiNotRespondingException');
          errorMessage = 'Server timeout. Please try again later.';
        }

        // Show error to user
        debugPrint('[terms] Displaying error to user: $errorMessage');
        Get.snackbar(
          'Error'.tr,
          errorMessage.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: backgroundColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        return null;
      });

      // Handle null response
      if (response == null) {
        debugPrint('[terms] Received null response from API');
        return;
      }

      debugPrint('[terms] API response received: ${response.toString()}');
      message = response['message'] ?? 'No message from server';
      debugPrint('[terms] API message: $message');

      if (response['success'] == true) {
        debugPrint('[terms] API call successful');

        // Parse and store response
        userInfo = moreModel.fromJson(response);
        debugPrint('[terms] Parsed terms content: ${userInfo.toString()}');

        // Update UI
        update();
        debugPrint('[terms] UI updated with new terms content');

        // Optional success notification
        // Get.snackbar(
        //   'Success'.tr,
        //   'Terms loaded successfully'.tr,
        //   snackPosition: SnackPosition.TOP,
        //   backgroundColor: Colors.green,
        //   duration: const Duration(seconds: 1),
        // );
      } else {
        debugPrint('[terms] API returned success: false');
        if (Get.isDialogOpen == true) Get.back();

        // Show API error message
        debugPrint('[terms] Displaying API error to user');
        Get.snackbar(
          'Error'.tr,
          message.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: R.colors.themeColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[terms] Uncaught exception: $e');
      debugPrint('[terms] Stack trace: $stackTrace');

      if (Get.isDialogOpen == true) Get.back();

      Get.snackbar(
        'Error'.tr,
        'An unexpected error occurred'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      );
    } finally {
      debugPrint('[terms] Terms function completed');
    }
  }}

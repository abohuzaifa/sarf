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

class PrivacyController extends GetxController {
  var message;
  moreModel? userInfo;

  @override
  void onInit() {
    // GetStorage().write('lang', 'en');
    super.onInit();
  }

  Future<void> privacy() async {
    try {
      debugPrint('[privacy] Starting privacy API call...');

      // Prepare request data
      final language = GetStorage().read('lang') ?? 'en'; // Default to English
      final request = {
        'language': language,
        'id': 2  // Privacy policy identifier
      };
      debugPrint('[privacy] Request data: $request');

      // Show loading dialog
      // DialogBoxes.openLoadingDialog();
      debugPrint('[privacy] Showing loading dialog');

      // Make API call
      debugPrint('[privacy] Making POST request to ${ApiLinks.about}');
      final response = await DioClient().post(ApiLinks.about, request).catchError((error) {
        debugPrint('[privacy] API call failed: ${error.toString()}');

        // Hide loading dialog
        if (Get.isDialogOpen == true) Get.back();

        String errorMessage = 'An unknown error occurred';
        Color backgroundColor = R.colors.themeColor;

        if (error is BadRequestException) {
          debugPrint('[privacy] BadRequestException occurred');
          try {
            final apiError = json.decode(error.message!);
            errorMessage = apiError["reason"]?.toString() ?? error.message ?? 'Bad request';
            debugPrint('[privacy] Parsed API error: $apiError');
          } catch (e) {
            debugPrint('[privacy] Error parsing error message: $e');
            errorMessage = error.message ?? 'Bad request';
          }
        } else if (error is FetchDataException) {
          debugPrint('[privacy] FetchDataException occurred');
          errorMessage = 'Failed to connect to server'.tr;
        } else if (error is ApiNotRespondingException) {
          debugPrint('[privacy] ApiNotRespondingException occurred');
          errorMessage = 'Server took too long to respond'.tr;
        }

        // Show error to user
        debugPrint('[privacy] Showing error snackbar: $errorMessage');
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
        debugPrint('[privacy] Received null response from API');
        return;
      }

      debugPrint('[privacy] Full API response received');
      message = response['message'] ?? 'No message from server';
      debugPrint('[privacy] API message: $message');

      if (response['success'] == true) {
        debugPrint('[privacy] API call successful');

        // Parse response
        userInfo = moreModel.fromJson(response);
        debugPrint('[privacy] Parsed privacy content: ${userInfo.toString()}');

        // Update UI
        update();
        debugPrint('[privacy] UI updated with new privacy content');

        // Optional: Show success message
        // Get.snackbar(
        //   'Success'.tr,
        //   'Privacy policy loaded successfully'.tr,
        //   snackPosition: SnackPosition.TOP,
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        //   duration: const Duration(seconds: 2),
        // );
      } else {
        debugPrint('[privacy] API returned success: false');
        if (Get.isDialogOpen == true) Get.back();

        // Show error message
        debugPrint('[privacy] Showing error snackbar for unsuccessful response');
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
      debugPrint('[privacy] Unhandled exception: $e');
      debugPrint('[privacy] Stack trace: $stackTrace');

      if (Get.isDialogOpen == true) Get.back();

      Get.snackbar(
        'Error'.tr,
        'Failed to load privacy policy'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      debugPrint('[privacy] Privacy function completed');
    }
  }}

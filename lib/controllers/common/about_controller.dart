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

class AboutController extends GetxController {
  var message;
  moreModel? userInfo;

  @override
  void onInit() {
    // GetStorage().write('lang', 'en');
    super.onInit();
  }

  Future<void> about() async {
    try {
      debugPrint('[about] Starting about API call...');

      // Prepare request data
      final request = {
        'language': GetStorage().read('lang') ?? 'en', // Default to 'en' if null
        'id': 1
      };
      debugPrint('[about] Request data: $request');

      // Show loading dialog
      // DialogBoxes.openLoadingDialog();
      debugPrint('[about] Showing loading dialog');

      // Make API call
      debugPrint('[about] Making POST request to ${ApiLinks.about}');
      var response = await DioClient().post(ApiLinks.about, request).catchError((error) {
        debugPrint('[about] API call failed: ${error.toString()}');

        // Hide loading dialog
        Get.back();

        String errorMessage = 'An unknown error occurred';
        Color backgroundColor = R.colors.themeColor;

        if (error is BadRequestException) {
          debugPrint('[about] BadRequestException occurred');
          try {
            final apiError = json.decode(error.message!);
            errorMessage = apiError["reason"]?.toString() ?? error.message ?? 'Bad request';
            debugPrint('[about] Parsed API error: $apiError');
          } catch (e) {
            debugPrint('[about] Error parsing error message: $e');
            errorMessage = error.message ?? 'Bad request';
          }
        } else if (error is FetchDataException) {
          debugPrint('[about] FetchDataException occurred');
          errorMessage = error.message ?? 'Failed to fetch data';
        } else if (error is ApiNotRespondingException) {
          debugPrint('[about] ApiNotRespondingException occurred');
          errorMessage = 'Oops! It took longer to respond';
        }

        // Show error to user
        debugPrint('[about] Showing error snackbar: $errorMessage');
        Get.snackbar(
          'Error'.tr,
          errorMessage.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: backgroundColor,
          colorText: Colors.white,
        );

        return null;
      });

      // Handle null response
      if (response == null) {
        debugPrint('[about] Received null response from API');
        return;
      }

      debugPrint('[about] Full API response: $response');
      message = response['message'] ?? 'No message';
      debugPrint('[about] API message: $message');

      if (response['success'] == true) {
        debugPrint('[about] API call successful');

        // Parse response
        userInfo = moreModel.fromJson(response);
        debugPrint('[about] Parsed user info: ${userInfo.toString()}');

        // Update UI
        update();
        debugPrint('[about] UI updated');

        // Show success message if needed
        // Get.snackbar(
        //   'Success'.tr,
        //   message.tr,
        //   snackPosition: SnackPosition.TOP,
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        // );
      } else {
        debugPrint('[about] API returned success: false');
        Get.back(); // Hide loading dialog

        // Show error message
        debugPrint('[about] Showing error snackbar for unsuccessful response');
        Get.snackbar(
          'Error'.tr,
          message.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: R.colors.themeColor,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[about] Unhandled exception: $e');
      debugPrint('[about] Stack trace: $stackTrace');

      Get.back(); // Hide loading dialog

      Get.snackbar(
        'Error'.tr,
        'An unexpected error occurred'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      debugPrint('[about] About function completed');
    }
  }}

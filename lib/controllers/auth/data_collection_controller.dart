import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sarf/model/data_collection.dart';

import '../../constant/api_links.dart';

import '../../resources/resources.dart';
import '../../services/app_exceptions.dart';
import '../../services/dio_client.dart';

// class DataCollectionController extends GetxController {
//   var loginFormKey = GlobalKey<FormState>();
//   List<Cities>? cities = [];
//   List<ExpenseType>? types = [];
//   List<Countries>? countries = [];
//
//   @override
//   void onInit() async {
//     GetStorage().write('lang', 'en');
//    await dataCollection();
//     super.onInit();
//   }
//
//   Future dataCollection() async {
//     var response = await DioClient()
//         .get(
//       ApiLinks.data_collection,
//     )
//         .catchError((error) {
//       if (error is BadRequestException) {
//         Get.back();
//         var apiError = json.decode(error.message!);
//         Get.snackbar(
//           'Error'.tr,
//           apiError["reason"].toString(),
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: R.colors.themeColor,
//         );
//       } else {
//         Get.back();
//         if (error is BadRequestException) {
//           var message = error.message;
//           Get.snackbar(
//             'Error'.tr,
//             message.toString(),
//             snackPosition: SnackPosition.TOP,
//             backgroundColor: R.colors.themeColor,
//           );
//         } else if (error is FetchDataException) {
//           var message = error.message;
//           Get.snackbar(
//             'Error'.tr,
//             message.toString(),
//             snackPosition: SnackPosition.TOP,
//             backgroundColor: R.colors.themeColor,
//           );
//         } else if (error is ApiNotRespondingException) {
//           Get.snackbar(
//             'Error'.tr,
//             'Oops! It took longer to respond.'.tr,
//             snackPosition: SnackPosition.TOP,
//             backgroundColor: R.colors.themeColor,
//           );
//         }
//       }
//     });
//     if (response['success'] == true) {
//       cities?.clear();
//       types?.clear();
//       countries?.clear();
//       log(response.toString());
//       var data = DataCollection.fromJson(response);
//       cities = data.data!.cities;
//       types = data.data!.expenseType!;
//       countries = data.data?.countries;
//       // await GetStorage().write('user_token', userInfo.token);
//       // await GetStorage().write('userId', userInfo.user!.id);
//       // await GetStorage().write('name', userInfo.user!.name);
//       // await GetStorage().write('username', userInfo.user!.username);
//       // await GetStorage().write('email', userInfo.user!.email);
//       // await GetStorage().write('firebase_email', userInfo.user!.firebaseEmail);
//       // await GetStorage().write('mobile', userInfo.user!.mobile);
//       // await GetStorage().write('photo', userInfo.user!.photo);
//       // await GetStorage().write('status', userInfo.user!.status);
//       // Get.offAllNamed(RoutesName.base);
//     } else {
//       Get.back();
//       Get.snackbar(
//         'Error'.tr,
//         'Something wnet wrong try later'.tr,
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: R.colors.themeColor,
//       );
//     }
//     return null;
//   }
// }

class DataCollectionController extends GetxController {
  var loginFormKey = GlobalKey<FormState>();
  List<City>? cities = [];
  List<ExpenseType>? types = [];
  List<Country>? countries = [];

  @override
  void onInit() async {
    print('🔄 DataCollectionController initialization started');
    try {
      await GetStorage().write('lang', 'en');
      print('🌍 Default language set to English');
      // await dataCollection();
    } catch (e, stack) {
      print('❌ Error in onInit: $e');
      print('Stack trace: $stack');
    }
    super.onInit();
  }

  Future<void> dataCollection() async {
    final url = ApiLinks.data_collection;
    print('🌐 Starting data collection API call');
    print('🔗 Full URL: $url');

    try {
      var response = await DioClient().get(url).catchError((error) {
        print('⚠️ API call error: $error');
        _handleApiError(error);
        return null;
      });

      print(
          '🔔 API response received: ${response?.toString() ?? "NULL RESPONSE"}');

      // Null check for response
      if (response == null) {
        print('❌ API returned null response');
        _showErrorSnackbar('No response from server');
        return;
      }

      // Null-safe success check
      final success = response['success'] as bool?;
      if (success != true) {
        print('❌ API returned unsuccessful response');
        _showErrorSnackbar(
            response['message']?.toString() ?? 'Something went wrong');
        return;
      }

      print('✅ API call successful, processing data...');

      // Detailed response logging
      print('\n📋 COMPLETE RESPONSE STRUCTURE:');
      print('----------------------------------------');
      _printResponse(response); // Helper function to print nested response
      print('----------------------------------------\n');

      // Clear existing data
      cities?.clear();
      types?.clear();
      countries?.clear();
      print('🧹 Cleared existing data collections');

      try {
        var data = DataCollection.fromJson(response);
        print('📦 Parsed data collection: ${data.toString()}');

        // Null-safe data assignment
        cities = data.data?.cities ?? [];
        types = data.data?.expenseType ?? [];
        countries = data.data?.countries ?? [];

        print('📊 Data updated:');
        print('   - Cities: ${cities!.length} items');
        if (cities!.isNotEmpty) {
          print('     First city: ${cities!.first.toJson()}');
        }

        print('   - Expense Types: ${types!.length} items');
        if (types!.isNotEmpty) {
          print('     First type: ${types!.first.toJson()}');
        }

        print('   - Countries: ${countries!.length} items');
        if (countries!.isNotEmpty) {
          print('     First country: ${countries!.first.toJson()}');
        }
      } catch (e, stack) {
        print('❌ Data parsing error: $e');
        print('Stack trace: $stack');
        _showErrorSnackbar('Failed to process server data');
      }
    } catch (e, stack) {
      print('❌ Unexpected error in dataCollection: $e');
      print('Stack trace: $stack');
      _showErrorSnackbar('Unexpected error occurred');
    }
  }

// Helper function to print nested response structure
  void _printResponse(dynamic response, [String prefix = '']) {
    if (response is Map) {
      response.forEach((key, value) {
        if (value is Map || value is List) {
          print('$prefix$key: ');
          _printResponse(value, '$prefix  ');
        } else {
          print('$prefix$key: $value');
        }
      });
    } else if (response is List) {
      print('${prefix}List[${response.length}]');
      if (response.isNotEmpty) {
        // Print first 3 items or all if less than 3
        for (var i = 0; i < (response.length > 3 ? 3 : response.length); i++) {
          print('${prefix}Item ${i + 1}:');
          _printResponse(response[i], '$prefix  ');
        }
        if (response.length > 3) {
          print('${prefix}... and ${response.length - 3} more items');
        }
      }
    } else {
      print('$prefix$response');
    }
  }

  void _handleApiError(dynamic error) {
    Get.back();
    print('⚠️ Handling API error: ${error.runtimeType}');

    if (error is BadRequestException) {
      try {
        var apiError = json.decode(error.message!);
        print('🔍 BadRequestException details: ${apiError.toString()}');
        _showErrorSnackbar(apiError["reason"]?.toString() ?? 'Invalid request');
      } catch (e) {
        print('❌ Failed to parse error message: $e');
        _showErrorSnackbar(error.message?.toString() ?? 'Bad request');
      }
    } else if (error is FetchDataException) {
      print('📡 FetchDataException: ${error.message}');
      _showErrorSnackbar(error.message?.toString() ?? 'Data fetch failed');
    } else if (error is ApiNotRespondingException) {
      print('⏳ API timeout');
      _showErrorSnackbar('Oops! It took longer to respond');
    } else {
      print('🚨 Unknown error type: ${error.runtimeType}');
      _showErrorSnackbar('Unknown error occurred');
    }
  }

  void _showErrorSnackbar(String message) {
    print('🛑 Showing error snackbar: $message');
    Get.snackbar(
      'Error'.tr,
      message.tr,
      snackPosition: SnackPosition.TOP,
      backgroundColor: R.colors.themeColor,
    );
  }
}

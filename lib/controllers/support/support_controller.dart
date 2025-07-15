import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getpackage;
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sarf/model/support/support_list_model.dart';
import 'package:sarf/model/support/support_types.dart';
import 'package:sarf/src/widgets/loader.dart';

import '../../constant/api_links.dart';
import '../../model/support/support_detail_model.dart';
import '../../resources/resources.dart';
import '../../services/app_exceptions.dart';
import '../../services/dio_client.dart';

class SupportController extends getpackage.GetxController {
  List<SingleSupport> supportTypes = <SingleSupport>[].obs;
  var selectedTypeName = ''.obs;
  var selectedTypeIndex = 0.obs;
  var selectedTypeId = ''.obs;
  var supportStatus = '0'.obs;
  TextEditingController txt = TextEditingController();
  List<File> uploadImages = <File>[].obs;
  var isLoadingSupport = false.obs;
  var isLoadingSupportDetails = false.obs;
  List<SingleSupportList> supportList = <SingleSupportList>[].obs;
  getpackage.Rx<SupportDetails> supportDetails = SupportDetails().obs;

  @override
  void onInit() async {
    super.onInit();
    await getSupportTypes();
    await getSupport('0');
  }

  Future<void> getSupportTypes() async {
    try {
      debugPrint('[getSupportTypes] Starting to fetch support types...');

      // Get language from storage
      final lang = GetStorage().read('lang') ?? 'en';
      debugPrint('[getSupportTypes] Using language: $lang');

      // Build the API URL
      final url = '${ApiLinks.getSupportTypes}$lang';
      debugPrint('[getSupportTypes] API URL: $url');

      // Make the API call
      debugPrint('[getSupportTypes] Making API request...');
      var response = await DioClient().get(url).catchError((error) {
        debugPrint('[getSupportTypes] Error occurred: ${error.toString()}');

        String errorMessage = 'An unknown error occurred';
        if (error is BadRequestException) {
          errorMessage = error.message ?? 'Bad request';
          try {
            final apiError = json.decode(error.message!);
            errorMessage = apiError["reason"]?.toString() ?? errorMessage;
          } catch (e) {
            debugPrint('[getSupportTypes] Error parsing error message: $e');
          }
        } else if (error is FetchDataException) {
          errorMessage = error.message ?? 'Failed to fetch data';
        } else if (error is ApiNotRespondingException) {
          errorMessage = 'Oops! It took longer to respond';
        }

        debugPrint('[getSupportTypes] Showing error to user: $errorMessage');
        Get.snackbar(
          'Error'.tr,
          errorMessage.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red, // Using standard red for errors
          colorText: Colors.white,
        );

        return null;
      });

      debugPrint('[getSupportTypes] API response received');

      if (response == null) {
        debugPrint('[getSupportTypes] Response is null, aborting');
        return;
      }

      debugPrint('[getSupportTypes] Response success: ${response['success']}');

      if (response['success'] == true) {
        debugPrint('[getSupportTypes] Clearing existing support types');
        supportTypes.clear();

        debugPrint('[getSupportTypes] Parsing response data');
        var data = SupportTypes.fromJson(response);

        if (data.data?.isNotEmpty ?? false) {
          debugPrint(
              '[getSupportTypes] Found ${data.data!.length} support types');
          supportTypes.addAll(data.data!);

          if (supportTypes.isNotEmpty) {
            debugPrint(
                '[getSupportTypes] First support type name (EN): ${supportTypes.first.name?.en}');
          }
        } else {
          debugPrint('[getSupportTypes] No support types found in response');
          Get.snackbar(
            'Info'.tr,
            'No support types available'.tr,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.blue,
            colorText: Colors.white,
          );
        }
      } else {
        debugPrint('[getSupportTypes] API returned unsuccessful response');
        final errorMessage =
            response['message'] ?? 'Failed to load support types';
        Get.snackbar(
          'Error'.tr,
          errorMessage.toString().tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[getSupportTypes] Unhandled exception: $e');
      debugPrint('[getSupportTypes] Stack trace: $stackTrace');
      Get.snackbar(
        'Error'.tr,
        'An unexpected error occurred'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      debugPrint('[getSupportTypes] Function completed');
    }
  }

  Future postNewSupport(String message) async {
    openLoader();
    // Map<String,dynamic> request = {
    //   'language': storage.read('lang'),
    //   'category_id': homeController.myCategories[categoryIndex.value].id,
    //   'sub_category_id': homeController.myCategories[categoryIndex.value]
    //       .subCategories![subCategoryIndex.value].id,
    //   'title': titleCtrl.text,
    //   'price': priceCtrl.text,
    //   'country_id': storage.read('country_id'),
    //   'city_id': storage.read('city_id'),
    //   'description': descCtrl.text,
    //   'images': images,
    // };
    // for(int i=0;i<images.length;i++){
    //     request.addAll({"images[$i]":images[i]});
    //   }
    //  print(request);

    FormData formData = FormData();
    if (kIsWeb) {
      for (var i = 0; i < uploadImages.length; i++) {
        var file = uploadImages[i];
        var xfile = XFile(uploadImages[i].path);
        String fileName = file.path.split('/').last;
        formData.files.add(MapEntry(
            "files[$i]",
            await MultipartFile.fromBytes(
                await xfile.readAsBytes().then((value) {
                  return value.cast();
                }),
                filename: fileName)));
      }
    } else {
      for (var i = 0; i < uploadImages.length; i++) {
        var file = uploadImages[i];
        String fileName = file.path.split('/').last;
        formData.files.add(MapEntry("files[$i]",
            await MultipartFile.fromFile(file.path, filename: fileName)));
      }
    }

    formData.fields
        .add(MapEntry('language', GetStorage().read('lang').toString()));
    formData.fields.add(MapEntry('type', selectedTypeId.value));
    formData.fields.add(MapEntry('message', message));
    // debugPrint(formData.fields.toString());

    //debugPrint(formData.files.first.toString());

    //Dio http = API.getInstance();
    var response = await DioClient()
        .post(ApiLinks.addSupport, formData, true)
        .catchError((error) {
      getpackage.Get.back();
      if (error is BadRequestException) {
        var apiError = json.decode(error.message!);
        // debugPrint("aaaaaaaa${error.toString()}");
        getpackage.Get.snackbar('Error'.tr, apiError["reason"].toString());
        //DialogBoxes.showErroDialog(description: apiError["reason"]);
      } else {
        getpackage.Get.snackbar('Error'.tr, 'Something went wrong'.tr);
        // debugPrint("aaaaaaaa${error.toString()}");
        //Navigator.of(getpackage.Get.context!).pop();
        //HandlingErrors().handleError(error);
      }
    });

    // final response = await http.post(ApiLinks.addNewAdApi,data: formData );

    // debugPrint("aaaaaaaaaaa$response");
    // Navigator.of(getpackage.Get.context!).pop();
    if (response == null) return;
    if (response['success']) {
      getpackage.Get.back();
      //SnakeBars.showSuccessSnake(description: response['message'].toString());

      uploadImages.clear();
      selectedTypeId.value = '';
      selectedTypeIndex.value = 0;
      selectedTypeName.value = '';
      txt.clear();
      // await getSupport('1');
      getpackage.Get.back();
      getpackage.Get.snackbar('Success'.tr, response['message'].toString());
      //files.clear();
    } else {
      // debugPrint('here');
      (response.containsKey('validation_errors'))
          ? getpackage.Get.snackbar(response['message'].toString(),
              response['validation_errors'].toString())
          // SnakeBars.showValidationErrorSnake(
          //     title: response['message'].toString(),
          //     description: response['validation_errors'].toString())
          : getpackage.Get.snackbar('Error'.tr, response['message'].toString());
      //SnakeBars.showErrorSnake(description: response['message'].toString());
      Navigator.of(getpackage.Get.context!).pop();
    }
  }

  Future getSupport(String id) async {
    supportList.clear();
    //print("${ApiLinks.membersList}${GetStorage().read('lang')}");
    // openLoader();
    // print('here');
    isLoadingSupport.value = true;
    var request = {
      "language": GetStorage().read('lang'),
      "status": id,
    };
    // print(request);
    var response = await DioClient()
        .post(ApiLinks.getSupport, request)
        .catchError((error) {
      if (error is BadRequestException) {
        isLoadingSupport.value = false;
        var apiError = json.decode(error.message!);
        getpackage.Get.snackbar(
          'Error'.tr,
          apiError["reason"].toString(),
          snackPosition: getpackage.SnackPosition.TOP,
          backgroundColor: R.colors.themeColor,
        );
        // print(error.toString());
      } else {
        isLoadingSupport.value = false;
        if (error is BadRequestException) {
          var message = error.message;
          getpackage.Get.snackbar(
            'Error'.tr,
            message.toString(),
            snackPosition: getpackage.SnackPosition.TOP,
            backgroundColor: R.colors.themeColor,
          );
        } else if (error is FetchDataException) {
          var message = error.message;
          getpackage.Get.snackbar(
            'Error'.tr,
            message.toString(),
            snackPosition: getpackage.SnackPosition.TOP,
            backgroundColor: R.colors.themeColor,
          );
        } else if (error is ApiNotRespondingException) {
          getpackage.Get.snackbar(
            'Error'.tr,
            'Oops! It took longer to respond.'.tr,
            snackPosition: getpackage.SnackPosition.TOP,
            backgroundColor: R.colors.themeColor,
          );
        }
      }
    });
    // debugPrint(response.toString());
    if (response == null) return;
    if (response['success'] == true) {
      // print("here2");
      supportList.clear();
      isLoadingSupport.value = false;
      // debugPrint(response.toString());
      // print("here3");
      var data = SupportList.fromJson(response);
      // print("here4");
      //print( " asasasasasas ${data.data?.budgets?.length.toString()}" );
      if (data.data!.isNotEmpty) {
        for (var support in data.data!) {
          supportList.add(support);
        }
      }
      //print(budgets.first.name);

      // return data;
    } else {
      isLoadingSupport.value = false;
      // debugPrint('here');
    }
    return null;
  }

  Future getSupportDetails(String id) async {
    //print("${ApiLinks.membersList}${GetStorage().read('lang')}");
    // openLoader();
    isLoadingSupportDetails.value = true;
    var request = {
      "language": GetStorage().read('lang'),
      "support_id": id,
    };
    var response = await DioClient()
        .post(ApiLinks.getSupportDetails, request)
        .catchError((error) {
      if (error is BadRequestException) {
        isLoadingSupportDetails.value = false;
        var apiError = json.decode(error.message!);
        getpackage.Get.snackbar(
          'Error'.tr,
          apiError["reason"].toString(),
          snackPosition: getpackage.SnackPosition.TOP,
          backgroundColor: R.colors.themeColor,
        );
        // print(error.toString());
      } else {
        isLoadingSupportDetails.value = false;
        if (error is BadRequestException) {
          var message = error.message;
          getpackage.Get.snackbar(
            'Error'.tr,
            message.toString(),
            snackPosition: getpackage.SnackPosition.TOP,
            backgroundColor: R.colors.themeColor,
          );
        } else if (error is FetchDataException) {
          var message = error.message;
          getpackage.Get.snackbar(
            'Error'.tr,
            message.toString(),
            snackPosition: getpackage.SnackPosition.TOP,
            backgroundColor: R.colors.themeColor,
          );
        } else if (error is ApiNotRespondingException) {
          getpackage.Get.snackbar(
            'Error'.tr,
            'Oops! It took longer to respond.'.tr,
            snackPosition: getpackage.SnackPosition.TOP,
            backgroundColor: R.colors.themeColor,
          );
        }
      }
    });
    // debugPrint(response.toString());
    if (response == null) return;
    if (response['success'] == true) {
      supportList.clear();

      // debugPrint(response.toString());
      var data = SupportDetails.fromJson(response);
      supportDetails.value = data;
      isLoadingSupportDetails.value = false;
      //print(budgets.first.name);

      // return data;
    } else {
      // debugPrint('here');
    }
    return null;
  }

  Future supportReply(String id, String message) async {
    //print("${ApiLinks.membersList}${GetStorage().read('lang')}");
    // openLoader();
    //  isLoadingSupportDetails.value = true;
    var request = {
      "language": GetStorage().read('lang'),
      "support_id": id,
      "message": message,
    };
    var response = await DioClient()
        .post(ApiLinks.supportReply, request)
        .catchError((error) {
      // debugPrint(error.toString());
      //   if (error is BadRequestException) {
      //     isLoadingSupportDetails.value = false;
      //      var apiError = json.decode(error.message!);
      //     getpackage.Get.snackbar(
      //       'Error'.tr,
      //       apiError["reason"].toString(),
      //       snackPosition: getpackage.SnackPosition.TOP,
      //       backgroundColor: R.colors.themeColor,
      //     );
      //    // print(error.toString());
      //   } else {
      //     isLoadingSupportDetails.value = false;
      //   if (error is BadRequestException) {
      //   var message = error.message;
      //   getpackage.Get.snackbar(
      //       'Error'.tr,
      //       message.toString(),
      //       snackPosition: getpackage.SnackPosition.TOP,
      //       backgroundColor: R.colors.themeColor,
      //     );
      // } else if (error is FetchDataException) {
      //   var message = error.message;
      //   getpackage.Get.snackbar(
      //       'Error'.tr,
      //       message.toString(),
      //       snackPosition: getpackage.SnackPosition.TOP,
      //       backgroundColor: R.colors.themeColor,
      //     );
      // } else if (error is ApiNotRespondingException) {

      //   getpackage.Get.snackbar(
      //       'Error'.tr,
      //       'Oops! It took longer to respond.'.tr,
      //       snackPosition: getpackage.SnackPosition.TOP,
      //       backgroundColor: R.colors.themeColor,
      //     );
      // }

      //   }
    });
    // debugPrint(response.toString());
    if (response == null) return;
    if (response['success'] == true) {
      getSupportDetails(id);
      // supportList.clear();
      // isLoadingSupportDetails.value = false;
      // debugPrint(response.toString());
      //   var data = SupportDetails.fromJson(response);
      //   supportDetails.value = data;

      //print(budgets.first.name);

      // return data;
    } else {
      // debugPrint('here');
    }
    return null;
  }
}

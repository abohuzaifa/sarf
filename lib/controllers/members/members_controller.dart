import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sarf/model/members/city_list_model.dart';

import '../../constant/api_links.dart';
import '../../model/members/member_details_model.dart';
import '../../model/members/members_list_model.dart';
import '../../model/members/members_list_new_model.dart';
import '../../model/members/single_invoice_model.dart';
import '../../resources/resources.dart';
import '../../services/app_exceptions.dart';
import '../../services/dio_client.dart';
import 'package:dio/dio.dart' as deo;

import '../../src/widgets/loader.dart';

class MembersController extends GetxController {
  var loadingMemDetails = false.obs;
  var loadingInvoiceDetails = false.obs;
  var selectExpanseTypeID = '';
  var selectCityID = '';
  Rx<MemberDetails> memDetails = MemberDetails().obs;
  Rx<SingleInvoiceDetails> inVoiceDetails = SingleInvoiceDetails().obs;
  List<File> uploadImages = <File>[].obs;

  @override
  void onInit() {
    //getMembersList();
    super.onInit();
  }

  Future<MembersList?> getMembersList(String query) async {
    // print("${ApiLinks.membersList}${GetStorage().read('lang')}");
    EasyLoading.instance
      ..loadingStyle =
          EasyLoadingStyle.custom //This was missing in earlier code
      ..backgroundColor = Colors.white
      ..indicatorColor = R.colors.blue
      ..maskColor = R.colors.blue
      ..dismissOnTap = false
      ..textColor = R.colors.blue
      ..userInteractions = false;
    EasyLoading.show(status: 'Sarf');
    var request = {};
    if (query == '') {
      request = {
        "language": GetStorage().read('lang'),
      };
    } else {
      request = {
        "language": GetStorage().read('lang'),
        "query_string": query,
      };
    }
    var response = await DioClient()
        .post("${ApiLinks.membersList}${GetStorage().read('lang')}", request)
        .catchError((error) {
      // debugPrint(error.toString());
      if (error is BadRequestException) {
        EasyLoading.dismiss();
        // print(error.toString());
      } else {
        EasyLoading.dismiss();
        // print(error.toString());

        if (error is BadRequestException) {
          EasyLoading.dismiss();
          //  print(error.toString());
        } else if (error is FetchDataException) {
          EasyLoading.dismiss();
          // print(error.toString());
        } else if (error is ApiNotRespondingException) {
          EasyLoading.dismiss();
          // print(error.message.toString());
        }
      }
    });
    // print(response);
    if (response['success'] == true) {
      // debugPrint(response.toString());
      var membersList = MembersList.fromJson(response);
      EasyLoading.dismiss();
      print(membersList.data?.first.expenseName);
      return membersList;
    } else {
      // debugPrint('here');
    }
    return null;
  }

  Future<CityList?> getCityList(String id, String query) async {
    //  print("${ApiLinks.cityList}${GetStorage().read('lang')}");

    // openLoader();
    var request = {};
    if (query == '') {
      request = {
        "language": GetStorage().read('lang'),
        "expense_type_id": id,
      };
    } else {
      request = {
        "language": GetStorage().read('lang'),
        "expense_type_id": id,
        "query_string": query,
      };
    }
    // var request = {
    //   "language": GetStorage().read('lang'),
    //   "expense_type_id": id,
    // };
    // debugPrint(request.toString());
    var response =
        await DioClient().post(ApiLinks.cityList, request).catchError((error) {
      if (error is BadRequestException) {
        // debugPrint(error.toString());
      } else {
        // debugPrint(error.toString());

        if (error is BadRequestException) {
          // debugPrint(error.toString());
        } else if (error is FetchDataException) {
          // debugPrint(error.toString());
        } else if (error is ApiNotRespondingException) {
          // debugPrint(error.message.toString());
        }
      }
    });
    // debugPrint(response.toString());
    if (response['success'] == true) {
      // debugPrint(response.toString());
      var cityList = CityList.fromJson(response);
      // print(membersList.data?.first.expenseName);
      return cityList;
    } else {
      // debugPrint('here');
    }
    return null;
  }

  Future<ListMembersNewList?> getMembersNewList(
      String id, String city, String query) async {
    try {
      debugPrint('[Members] Starting getMembersNewList with params:');
      debugPrint('[Members] - id: $id');
      debugPrint('[Members] - city: $city');
      debugPrint('[Members] - query: $query');

      // Prepare request based on query presence
      var request = {};
      if (query.isEmpty) {
        request = {
          "language": GetStorage().read('lang'),
          "expense_type_id": id,
          "city_id": city
        };
        debugPrint('[Members] Request without query: $request');
      } else {
        request = {
          "language": GetStorage().read('lang'),
          "expense_type_id": id,
          "city_id": city,
          "query_string": query,
        };
        debugPrint('[Members] Request with query: $request');
      }

      debugPrint('[Members] Making POST request to ${ApiLinks.memberNewList}');
      var response = await DioClient()
          .post(ApiLinks.memberNewList, request)
          .catchError((error) {
        debugPrint('[Members] API call failed with error: $error');

        if (error is BadRequestException) {
          debugPrint('[Members] BadRequestException: ${error.message}');
          try {
            var apiError = json.decode(error.message!);
            debugPrint('[Members] Parsed API error: $apiError');
          } catch (e) {
            debugPrint('[Members] Error parsing error message: $e');
          }
        } else if (error is FetchDataException) {
          debugPrint('[Members] FetchDataException: ${error.message}');
        } else if (error is ApiNotRespondingException) {
          debugPrint('[Members] ApiNotRespondingException: ${error.message}');
        } else {
          debugPrint('[Members] Unknown error type: ${error.runtimeType}');
        }

        return null;
      });

      if (response == null) {
        debugPrint('[Members] Received null response from API');
        return null;
      }

      debugPrint('[Members] Full API response: $response');

      if (response['success'] == true) {
        debugPrint('[Members] API call successful');
        var listNew = ListMembersNewList.fromJson(response);
        debugPrint('[Members] Parsed ${listNew.data?.length ?? 0} members');
        return listNew;
      } else {
        debugPrint('[Members] API returned success: false');
        debugPrint('[Members] API message: ${response['message']}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('[Members] Unhandled exception in getMembersNewList: $e');
      debugPrint('[Members] Stack trace: $stackTrace');
      return null;
    } finally {
      debugPrint('[Members] getMembersNewList execution completed');
    }
  }

  Future getMemberDetails(String id) async {
    memDetails.value = MemberDetails();
    //  print("${ApiLinks.cityList}${GetStorage().read('lang')}");
    // openLoader();
    loadingMemDetails.value = true;
    var request = {
      "language": GetStorage().read('lang'),
      "member_id": id,
    };
    //  debugPrint(request.toString());
    var response = await DioClient()
        .post(ApiLinks.memberDetails, request)
        .catchError((error) {
      loadingMemDetails.value = false;
      if (error is BadRequestException) {
        // debugPrint(error.toString());
      } else {
        // debugPrint(error.toString());

        if (error is BadRequestException) {
          // debugPrint(error.toString());
        } else if (error is FetchDataException) {
          // debugPrint(error.toString());
        } else if (error is ApiNotRespondingException) {
          // debugPrint(error.message.toString());
        }
      }
    });
    // debugPrint(response.toString());
    if (response['success'] == true) {
      loadingMemDetails.value = false;
      // debugPrint(response.toString());
      var listNew = MemberDetails.fromJson(response);
      memDetails.value = listNew;
    } else {
      loadingMemDetails.value = false;
      // debugPrint('here');
    }
    return null;
  }

  Future getInvoiceDetail(String id) async {
    //  print("${ApiLinks.cityList}${GetStorage().read('lang')}");
    // openLoader();
    EasyLoading.instance
      ..loadingStyle =
          EasyLoadingStyle.custom //This was missing in earlier code
      ..backgroundColor = Colors.white
      ..indicatorColor = R.colors.blue
      ..maskColor = R.colors.blue
      ..dismissOnTap = false
      ..textColor = R.colors.blue
      ..userInteractions = false;
    EasyLoading.show(status: 'Sarf');
    loadingInvoiceDetails.value = true;
    inVoiceDetails.value = SingleInvoiceDetails();
    var request = {
      "language": GetStorage().read('lang'),
      "invoice_id": id,
    };
    //  debugPrint(request.toString());
    var response = await DioClient()
        .post(ApiLinks.invoiceDetails, request)
        .catchError((error) {
      EasyLoading.dismiss();
      loadingMemDetails.value = false;
      if (error is BadRequestException) {
        EasyLoading.dismiss();
        // debugPrint(error.toString());
      } else {
        EasyLoading.dismiss();
        // debugPrint(error.toString());

        if (error is BadRequestException) {
          EasyLoading.dismiss();
          // debugPrint(error.toString());
        } else if (error is FetchDataException) {
          EasyLoading.dismiss();
          // debugPrint(error.toString());
        } else if (error is ApiNotRespondingException) {
          EasyLoading.dismiss();
          // debugPrint(error.message.toString());
        }
      }
    });
    // debugPrint(response.toString());
    if (response['success'] == true) {
      loadingInvoiceDetails.value = false;
      // debugPrint(response.toString());
      var invoice = SingleInvoiceDetails.fromJson(response);
      inVoiceDetails.value = invoice;
      print(
          "Attachment length ${inVoiceDetails.value.data?.attachments?.length}");
      update();
      refresh();
      EasyLoading.dismiss();
    } else {
      EasyLoading.dismiss();
      loadingInvoiceDetails.value = false;
      // debugPrint('here');
    }
    return null;
  }

  Future postInvoiceAttach(String id) async {
    openLoader();
    deo.FormData formData = deo.FormData();

// for (var i = 0; i < uploadImages.length; i++) {
//   var file = uploadImages[i];
//   String fileName = file.path.split('/').last;
//   formData.files.add(
//     MapEntry("file_attach[$i]", await deo.MultipartFile.fromFile(file.path, filename: fileName))
//    );
// }
    if (kIsWeb) {
      for (var i = 0; i < uploadImages.length; i++) {
        var file = uploadImages[i];
        var xfile = XFile(uploadImages[i].path);
        String fileName = file.path.split('/').last;
        formData.files.add(MapEntry(
            "file_attach[$i]",
            await deo.MultipartFile.fromBytes(
                await xfile.readAsBytes().then((value) {
                  return value.cast();
                }),
                filename: fileName)));
      }
    } else {
      for (var i = 0; i < uploadImages.length; i++) {
        var file = uploadImages[i];
        String fileName = file.path.split('/').last;
        formData.files.add(MapEntry("file_attach[$i]",
            await deo.MultipartFile.fromFile(file.path, filename: fileName)));
      }
    }
    formData.fields
        .add(MapEntry('language', GetStorage().read('lang').toString()));
    formData.fields.add(MapEntry('invoice_id', id));
    // debugPrint(formData.fields.toString());

    //  debugPrint(formData.files.first.toString());

    //Dio http = API.getInstance();
    var response = await DioClient()
        .post(ApiLinks.invoiceAttach, formData, true)
        .catchError((error) {
      Get.back();
      if (error is BadRequestException) {
        var apiError = json.decode(error.message!);
        // debugPrint("aaaaaaaa${error.toString()}");
        Get.snackbar('Error'.tr, apiError["reason"].toString());
        //DialogBoxes.showErroDialog(description: apiError["reason"]);
      } else {
        Get.snackbar('Error'.tr, 'Something went wrong'.tr);
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
      Get.back();
      //SnakeBars.showSuccessSnake(description: response['message'].toString());
      Get.snackbar('Success'.tr, response['message'].toString());
      uploadImages.clear();
      //Get.back();
      //files.clear();
      getInvoiceDetail(id);
    } else {
      // debugPrint('here');
      (response.containsKey('validation_errors'))
          ? Get.snackbar(response['message'].toString(),
              response['validation_errors'].toString())
          // SnakeBars.showValidationErrorSnake(
          //     title: response['message'].toString(),
          //     description: response['validation_errors'].toString())
          : Get.snackbar('Success'.tr, response['message'].toString());
      //SnakeBars.showErrorSnake(description: response['message'].toString());
      Navigator.of(Get.context!).pop();
    }
  }
}

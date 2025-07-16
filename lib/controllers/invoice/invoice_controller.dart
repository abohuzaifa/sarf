import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart' as getpackage;
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sarf/model/members/invoice_list_model.dart';
import 'package:sarf/services/app_exceptions.dart';

import '../../constant/api_links.dart';
import '../../model/invoice/invoice_members_home.dart';
import '../../model/invoice/invoice_members_model.dart';
import '../../model/invoice/searched_mobile_model.dart';
import '../../resources/resources.dart';
import '../../services/dio_client.dart';
import '../../src/widgets/loader.dart';

class InvoiceController extends getpackage.GetxController {
  List<File> uploadImages = <File>[].obs;
  var selectedBudgetId = "".obs;
  var selectedExptId = "".obs;
  var selectedBudgetName = "Select Category".obs;
  var selectedExpName = "Select Expanse".obs;
  // var selectedBudgetName = "Select Category".obs;
  // List<File> uploadImages2 = <File>[].obs;
  var qrCode = "".obs;
  var filter = 0;
  bool checkMobile = false;
  getpackage.Rx<SearchedMobileList> searchedUsers = SearchedMobileList().obs;
  TextEditingController mobile1 = TextEditingController();
  TextEditingController amount2 = TextEditingController();
  TextEditingController amount22 = TextEditingController();
  TextEditingController note3 = TextEditingController();
  TextEditingController note33 = TextEditingController();
  bool loading = false;

  Future<void> postNewInvoice(String mobile, String amount, String note) async {
    try {
      debugPrint('[Invoice] Starting postNewInvoice');
      debugPrint(
          '[Invoice] Parameters - Mobile: $mobile, Amount: $amount, Note: $note');

      openLoader();
      debugPrint('[Invoice] Loader opened');

      FormData formData = FormData();
      debugPrint('[Invoice] FormData created');

      // Process each image
      debugPrint('[Invoice] Processing ${uploadImages.length} attached images');
      for (var i = 0; i < uploadImages.length; i++) {
        var file = uploadImages[i];
        int fileSizeInBytes = await file.length();
        double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
        debugPrint(
            '[Invoice] Original file ${i + 1} size: ${fileSizeInMB.toStringAsFixed(2)} MB');

        if (fileSizeInMB > 2.0) {
          debugPrint('[Invoice] Compressing file ${i + 1} (over 2MB)');
          File? compressedFile = await compressImage(file);
          if (compressedFile != null) {
            int compressedFileSizeInBytes = await compressedFile.length();
            double compressedFileSizeInMB =
                compressedFileSizeInBytes / (1024 * 1024);
            debugPrint(
                '[Invoice] Compressed file ${i + 1} size: ${compressedFileSizeInMB.toStringAsFixed(2)} MB (${((fileSizeInMB - compressedFileSizeInMB) / fileSizeInMB * 100).toStringAsFixed(1)}% reduction)');
            file = compressedFile;
          } else {
            debugPrint(
                '[Invoice] Compression failed for file ${i + 1}, using original');
          }
        }

        String fileName = file.path.split('/').last;
        formData.files.add(MapEntry("file_attach[]",
            await MultipartFile.fromFile(file.path, filename: fileName)));
        debugPrint('[Invoice] Added file ${i + 1} to form data: $fileName');
      }

      // Add form fields
      formData.fields
          .add(MapEntry('language', GetStorage().read('lang').toString()));
      formData.fields.add(MapEntry('mobile', mobile));
      formData.fields.add(MapEntry('amount', amount));
      formData.fields.add(MapEntry('note', note));
      formData.fields.add(const MapEntry('paid_status', "0"));
      debugPrint('[Invoice] Form fields added to request');

      debugPrint('[Invoice] Making POST request to ${ApiLinks.simpleInvoice}');
      var response = await DioClient()
          .post(ApiLinks.simpleInvoice, formData, true)
          .catchError((error) {
        debugPrint('[Invoice] API request failed');
        checkMobile = false;
        getpackage.Get.back();
        debugPrint('[Invoice] Closed any open dialogs');

        if (error is BadRequestException) {
          debugPrint('[Invoice] BadRequestException occurred');
          try {
            var apiError = json.decode(error.message!);
            debugPrint(
                '[Invoice] Server error details: ${apiError.toString()}');
            getpackage.Get.snackbar('Error'.tr, apiError["reason"].toString());
          } catch (e) {
            debugPrint('[Invoice] Error parsing API error: $e');
            getpackage.Get.snackbar('Error'.tr, "Invalid server response".tr);
          }
        } else {
          debugPrint('[Invoice] Network error occurred');
          debugPrint('[Invoice] Status code: ${error.response?.statusCode}');
          debugPrint('[Invoice] Error data: ${error.response?.data}');
          debugPrint('[Invoice] Error message: ${error.message}');
          getpackage.Get.snackbar('Error'.tr, "Something went wrong".tr);
        }
      });

      debugPrint('[Invoice] API response received');
      if (response == null) {
        debugPrint('[Invoice] Null response received');
        return;
      }

      debugPrint('[Invoice] Response status: ${response['success']}');
      debugPrint('[Invoice] Response message: ${response['message']}');

      if (response['success']) {
        debugPrint('[Invoice] Invoice created successfully');
        checkMobile = false;
        getpackage.Get.back();
        uploadImages.clear();
        mobile1.clear();
        amount2.clear();
        note3.clear();
        debugPrint('[Invoice] Cleared all form data');
        getpackage.Get.back();
        getpackage.Get.snackbar('Success'.tr, response['message'].toString());
      } else {
        debugPrint('[Invoice] Invoice creation failed');
        if (response.containsKey('validation_errors')) {
          debugPrint(
              '[Invoice] Validation errors: ${response['validation_errors']}');
          getpackage.Get.snackbar(response['message'].toString(),
              response['validation_errors'].toString());
        } else {
          getpackage.Get.snackbar('Error'.tr, response['message'].toString());
        }
        Navigator.of(getpackage.Get.context!).pop();
      }
    } catch (e, stackTrace) {
      debugPrint('[Invoice] Unexpected error in postNewInvoice: $e');
      debugPrint('[Invoice] Stack trace: $stackTrace');
      getpackage.Get.snackbar('Error'.tr, "An unexpected error occurred".tr);
    } finally {
      if (EasyLoading.isShow) {
        await EasyLoading.dismiss();
        debugPrint('[Invoice] Loader dismissed');
      }
      debugPrint('[Invoice] postNewInvoice completed');
    }
  }

  Future<File?> compressImage(File file) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      file.absolute.path + '_compressed.jpg',
      quality: 35, // Adjust quality (0-100)
    );

    if (result != null) {
      return File(result.path);
    } else {
      return null;
    }
  }

  String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  Future postNewCustomInvoice(
      String bid, String expId, String amount, String note) async {
    openLoader();

    FormData formData = FormData();

    // for (var i = 0; i < uploadImages.length; i++) {
    //   var file = uploadImages[i];
    //   String fileName = file.path.split('/').last;
    //   formData.files.add(MapEntry("file_attach[$i]",
    //       await MultipartFile.fromFile(file.path, filename: fileName)));
    // }
    if (kIsWeb) {
      for (var i = 0; i < uploadImages.length; i++) {
        var file = uploadImages[i];
        var xfile = XFile(uploadImages[i].path);
        String fileName = file.path.split('/').last;
        formData.files.add(MapEntry(
            "file_attach[$i]",
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
        formData.files.add(MapEntry("file_attach[$i]",
            await MultipartFile.fromFile(file.path, filename: fileName)));
      }
    }
    formData.fields
        .add(MapEntry('language', GetStorage().read('lang').toString()));
    formData.fields.add(MapEntry('budget_id', bid));
    formData.fields.add(MapEntry('expense_type_id', expId));
    formData.fields.add(MapEntry('amount', amount));
    formData.fields.add(MapEntry('note', note));

    // debugPrint(formData.fields.toString());

    // debugPrint(formData.files.first.toString());

    //Dio http = API.getInstance();
    var response = await DioClient()
        .post(ApiLinks.customSimpleInvoice, formData, true)
        .catchError((error) {
      checkMobile = false;
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
      checkMobile = false;
      getpackage.Get.back();
      //SnakeBars.showSuccessSnake(description: response['message'].toString());

      uploadImages.clear();
      selectedBudgetId.value = '';
      selectedExptId.value = '';
      selectedBudgetName.value = "Select Category";
      selectedExpName.value = "Select Expanse";

      amount22.clear();
      note33.clear();
      getpackage.Get.back();
      getpackage.Get.snackbar('Success'.tr, response['message'].toString());
      //files.clear();
    } else {
      //uploadImages.clear();
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

  Future<InvoiceMemberListModel?> getInvoiceMemberList(String query) async {
    //print("${ApiLinks.membersList}${GetStorage().read('lang')}");
    //  openLoader();
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
        .post(ApiLinks.invoiceMemList, request)
        .catchError((error) {
      debugPrint(error.toString());
      if (error is BadRequestException) {
        print(error.toString());
      } else {
        print(error.toString());

        if (error is BadRequestException) {
          print(error.toString());
        } else if (error is FetchDataException) {
          print(error.toString());
        } else if (error is ApiNotRespondingException) {
          print(error.message.toString());
        }
      }
    });
    debugPrint(response.toString());
    if (response == null) return null;
    if (response['success'] == true) {
      // getpackage.Get.back();
      debugPrint(response.toString());
      var membersList = InvoiceMemberListModel.fromJson(response);
      update();
      refresh();
      //print(membersList.data?.first.expenseName);
      return membersList;
    } else {
      // getpackage.Get.back();
      debugPrint('else why?');
    }
    return null;
  }

  Future<InvoiceMemberListModelHome?> getInvoiceMemberListHome(
      String query, String expanseId, String bId) async {
    //print("${ApiLinks.membersList}${GetStorage().read('lang')}");
    loading = true;

    var request = {};
    if (query == '') {
      request = {
        "language": GetStorage().read('lang'),
        "expense_type_id": expanseId,
        "budget_id": bId,
      };
    } else {
      request = {
        "language": GetStorage().read('lang'),
        "query_string": query,
        "expense_type_id": expanseId,
        "budget_id": bId,
      };
    }
    debugPrint(request.toString());
    var response = await DioClient()
        .post(ApiLinks.invoiceMemList, request)
        .catchError((error) {
      // debugPrint(error.toString());
      if (error is BadRequestException) {
        print(error.toString());
      } else {
        print(error.toString());

        if (error is BadRequestException) {
          // print(error.toString());
        } else if (error is FetchDataException) {
          // print(error.toString());
        } else if (error is ApiNotRespondingException) {
          //print(error.message.toString());
        }
      }
    });
    if (response == null) return null;
    if (response['success'] == true) {
      // getpackage.Get.back();
      // debugPrint(response.toString());
      loading = false;
      var membersList = InvoiceMemberListModelHome.fromJson(response);
      //print(membersList.data?.first.expenseName);
      return membersList;
    } else {
      // getpackage.Get.back();
      // debugPrint('here');
    }
    return null;
  }

  Future<InvoiceList?> getInvoiceListMember(
      String query, String memberID) async {
    //print("${ApiLinks.membersList}${GetStorage().read('lang')}");
    //  openLoader();
    var request = {};
    if (query == '') {
      request = {"language": GetStorage().read('lang'), "member_id": memberID};
    } else {
      request = {
        "language": GetStorage().read('lang'),
        "query_string": query,
        "member_id": memberID
      };
    }
    var response = await DioClient()
        .post("${ApiLinks.invoiceListNew}", request)
        .catchError((error) {
      // debugPrint(error.toString());
      if (error is BadRequestException) {
        // print(error.toString());
      } else {
        //print(error.toString());

        if (error is BadRequestException) {
          // print(error.toString());
        } else if (error is FetchDataException) {
          // print(error.toString());
        } else if (error is ApiNotRespondingException) {
          //print(error.message.toString());
        }
      }
    });
    if (response == null) return null;
    if (response['success'] == true) {
      // getpackage.Get.back();
      // debugPrint(response.toString());
      var membersList = InvoiceList.fromJson(response);
      //print(membersList.data?.first.expenseName);
      return membersList;
    } else {
      // getpackage.Get.back();
      // debugPrint('here');
    }
    return null;
  }

  Future<InvoiceList?> getInvoiceList(
    String query,
  ) async {
    //print("${ApiLinks.membersList}${GetStorage().read('lang')}");
    //  openLoader();
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
        .post("${ApiLinks.invoiceList}${GetStorage().read('lang')}", request)
        .catchError((error) {
      // debugPrint(error.toString());
      if (error is BadRequestException) {
        // print(error.toString());
      } else {
        //print(error.toString());

        if (error is BadRequestException) {
          // print(error.toString());
        } else if (error is FetchDataException) {
          // print(error.toString());
        } else if (error is ApiNotRespondingException) {
          //print(error.message.toString());
        }
      }
    });
    if (response == null) return null;
    if (response['success'] == true) {
      // getpackage.Get.back();
      // debugPrint(response.toString());
      var membersList = InvoiceList.fromJson(response);
      //print(membersList.data?.first.expenseName);
      return membersList;
    } else {
      // getpackage.Get.back();
      // debugPrint('here');
    }
    return null;
  }

  //  Future<InvoiceList?> getInvoiceListHome(String query,String expenseId,String bId) async {
  //   //print("${ApiLinks.membersList}${GetStorage().read('lang')}");
  //   //  openLoader();
  //   var request = {};
  //   if(query == ''){
  //   request = {
  //     "language": GetStorage().read('lang'),
  //     "expense_id" : expenseId,
  //     "budget_id" : bId,

  //   };
  //  }else{
  //   request = {
  //     "language": GetStorage().read('lang'),
  //     "query_string": query,
  //     "expense_id" : expenseId,
  //     "budget_id" : bId,
  //   };
  //  }
  //   var response = await DioClient()
  //       .post("${ApiLinks.invoiceList}${GetStorage().read('lang')}",request)
  //       .catchError((error) {
  // debugPrint(error.toString());
  //     if (error is BadRequestException) {
  //       // print(error.toString());
  //     } else {
  //       //print(error.toString());

  //       if (error is BadRequestException) {
  //         // print(error.toString());

  //       } else if (error is FetchDataException) {
  //         // print(error.toString());

  //       } else if (error is ApiNotRespondingException) {
  //         //print(error.message.toString());
  //       }
  //     }
  //   });
  //   if(response == null ) return null;
  //   if (response['success'] == true) {
  //     // getpackage.Get.back();
  // debugPrint(response.toString());
  //     var membersList = InvoiceList.fromJson(response);
  //     //print(membersList.data?.first.expenseName);
  //     return membersList;
  //   } else {
  //     // getpackage.Get.back();
  // debugPrint('here');
  //   }
  //   return null;
  // }

  Future<InvoiceList?> getInvoiceListHome(
      String query, String expenseId, String bId, String memberID) async {
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

    //print("${ApiLinks.membersList}${GetStorage().read('lang')}");
    // openLoader();
    // expense_id
    var request = {};
    if (query == '') {
      request = {
        "language": GetStorage().read('lang'),
        "expense_type_id": expenseId,
        "budget_id": bId,
        "member_id": memberID
      };
    } else {
      request = {
        "language": GetStorage().read('lang'),
        "query_string": query,
        "expense_type_id": expenseId,
        "budget_id": bId,
        "member_id": memberID
      };
    }
    //  debugPrint(request.toString());
    var response = await DioClient()
        .post("${ApiLinks.invoiceListNew}", request)
        .catchError((error) {
      EasyLoading.dismiss();
      // debugPrint(error.toString());
      if (error is BadRequestException) {
        EasyLoading.dismiss();
        // print(error.toString());
      } else {
        EasyLoading.dismiss();
        //print(error.toString());

        if (error is BadRequestException) {
          EasyLoading.dismiss();
          // print(error.toString());
        } else if (error is FetchDataException) {
          EasyLoading.dismiss();
          // print(error.toString());
        } else if (error is ApiNotRespondingException) {
          EasyLoading.dismiss();
          //print(error.message.toString());
        }
      }
    });
    if (response == null) return null;
    if (response['success'] == true) {
      // debugPrint(response.toString());
      var membersList = InvoiceList.fromJson(response);
      EasyLoading.dismiss();
      //print(membersList.data?.first.expenseName);
      update();
      refresh();
      return membersList;
    } else {
      EasyLoading.dismiss();
      // debugPrint('here');
    }
    return null;
  }

  Future mobileCheck(String number) async {
    var data;
    //print("${ApiLinks.membersList}${GetStorage().read('lang')}");
    // openLoader();
    //  isLoadingSupportDetails.value = true;
    var request = {
      "language": GetStorage().read('lang'),
      "mobile": number,
      "is_invoice": true,
    };
    var response = await DioClient()
        .post(ApiLinks.mobileCheckInvoice, request)
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
      // print(response['message']);
      // print(response['user']['name']);
      data = response;
      //getSupportDetails(id);
      // supportList.clear();
      // isLoadingSupportDetails.value = false;
      // debugPrint(response.toString());
      //   var data = SupportDetails.fromJson(response);
      //   supportDetails.value = data;

      //print(budgets.first.name);

      // return data;
    } else {
      data = response;
      // debugPrint('here');
    }
    return data;
  }

  Future getMobileUsers(String number) async {
    searchedUsers.value = SearchedMobileList();
    var request = {
      "mobile": number,
    };
    var response = await DioClient()
        .post(ApiLinks.getUserList, request)
        .catchError((error) {
      // debugPrint(error.toString());
    });
    // debugPrint(response.toString());
    if (response == null) return;
    if (response['success'] == true) {
      debugPrint(response.toString());
      var data = SearchedMobileList.fromJson(response);
      searchedUsers.value = data;
      debugPrint("Searched users${searchedUsers.value.data}");
    } else {
      searchedUsers.value = SearchedMobileList();
      // debugPrint('here error');
    }
    return null;
  }
}

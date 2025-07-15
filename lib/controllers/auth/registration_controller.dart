import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart' as ddio;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:platform_device_id/platform_device_id.dart';
import 'package:sarf/controllers/auth/register_controller.dart';
import '../../constant/api_links.dart';
import '../../model/loginModel.dart';
import '../../resources/resources.dart';
import '../../services/app_exceptions.dart';
import '../../services/dio_client.dart';
import '../../services/notification_services.dart';
import '../../src/baseview/base_controller.dart';
import '../../src/utils/routes_name.dart';
import '../../src/widgets/loader.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class RegistrationController extends GetxController {
  var registerFormKey = GlobalKey<FormState>();
  RegisterController registerController = Get.find<RegisterController>();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  TextEditingController twitterController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController whatsappController = TextEditingController();
  TextEditingController websiteOptionalController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  int accountType = 2;
  bool isOnline = false;
  bool isGroup = false;
  var cityId;
  var expense_typeId;
  var message;
  var finalSelectedCity = ''.obs;
  var finalSelectedType = ''.obs;
  var location = ''.obs;
  var location_lat = ''.obs;
  var location_lng = ''.obs;
  File? profileImage;
  NotificationServices notificationServices = NotificationServices();


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  String replaceArabicNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(arabic[i], english[i]);
    }
    // print("$input");
    return input;
  }

  Future registration(
    String mob,
    String country_id,
  ) async
  {
    openLoader();
    // debugPrint("here");
    ddio.FormData formData = ddio.FormData();

    String pass = replaceArabicNumber(registerController.password.text);

    if (profileImage != null) {
      var file = profileImage;
      var xfile = XFile(profileImage!.path);
      String fileName = file!.path.split('/').last;
      if (kIsWeb) {
        // await xFile.readAsBytes().then((value) {
        //           return value.cast();
        //         }),
        formData.files.add(MapEntry(
            "photo",
            await ddio.MultipartFile.fromBytes(
                await xfile.readAsBytes().then((value) {
                  return value.cast();
                }),
                filename: fileName)));
      } else {
        formData.files.add(MapEntry("photo",
            await ddio.MultipartFile.fromFile(file.path, filename: fileName)));
      }
    }

    formData.fields
        .add(MapEntry('language', GetStorage().read('lang').toString()));
    formData.fields.add(MapEntry(
      'mobile',
      mob,
    ));
    formData.fields.add(MapEntry(
      'country_id',
      country_id,
    ));
    print(accountType.toString());
    formData.fields.add(MapEntry(
        // 'account_type', accountType == true ? 0.toString() : 1.toString()));
        'account_type',
        accountType == 0
            ? "0"
            : accountType == 1
                ? "1"
                : "2"));
    formData.fields.add(MapEntry(
      'password',
      pass,
    ));
    formData.fields.add(MapEntry(
      'name',
      accountType == 0 || accountType == 2
          ? companyNameController.text
          : fullNameController.text,
    ));
    if (accountType == 0 || accountType == 2) {
      formData.fields.add(MapEntry(
        'city_id',
        cityId.toString(),
      ));
    }

    if (accountType == 0 || accountType == 2) {
      formData.fields.add(MapEntry(
        'expense_type_id',
        expense_typeId.toString(),
      ));
    }
    if (isGroup) {
      if (GetStorage().read('groupId') != null &&
          GetStorage().read('groupId') != '') {
        formData.fields.add(MapEntry(
          'group_id',
          GetStorage().read('groupId').toString(),
        ));
      }
    }
    formData.fields.add(MapEntry(
      'insta_link',
      instagramController.text,
    ));
    formData.fields.add(MapEntry(
      'contact_no',
      contactController.text,
    ));
    formData.fields.add(MapEntry(
      'whatsapp',
      whatsappController.text,
    ));
    formData.fields.add(MapEntry(
      'website',
      websiteController.text,
    ));
    formData.fields.add(MapEntry(
      'is_online',
      isOnline == true ? 0.toString() : 1.toString(),
    ));
    formData.fields.add(MapEntry(
      'location',
      location.value,
    ));
    formData.fields.add(MapEntry(
      'location_lat',
      location_lat.value,
    ));
    formData.fields.add(MapEntry(
      'location_lng',
      location_lng.value,
    ));
    // String? result = await PlatformDeviceId.getDeviceId;
    String? result = await notificationServices.getDeviceToken();
    // debugPrint(result);
    if (!kIsWeb) {
      formData.fields.add(MapEntry(
        'ios_device_id',
        Platform.isIOS == true ? result : '',
      ));
    }
    if (!kIsWeb) {
      formData.fields.add(MapEntry(
        'name',
        accountType == 0 || accountType == 2
            ? companyNameController.text
            : fullNameController.text,
      ));
    }
    if (!kIsWeb) {
      formData.fields.add(MapEntry(
          'android_device_id', Platform.isAndroid == true ? result : ''));
    }

    debugPrint(formData.fields.toString());

    // var request = {
    //   'language': GetStorage().read('lang'),
    //   'mobile': splitted[1],
    //   'account_type': accountType == true ? 0 : 1,
    //   'password': passwordController.text,
    //   'name': accountType == true
    //       ? companyNameController.text
    //       : fullNameController.text,
    //   'city_id': cityId.toString(),
    //   'expense_type_id': expense_typeId.toString(),
    //   'insta_link': instagramController.text,
    //   'twitter_link': twitterController.text,
    //   'contact_no': contactController.text,
    //   'whatsapp': whatsappController.text,
    //   'website': websiteController.text,
    //   'is_online': isOnline == true ? 0 : 1,
    //   'location': location.value,
    //   'location_lat': location_lat.value,
    //   'location_lng': location_lng.value,
    //   'ios_device_id': 'yewuihjkfhsdjkfhdkjfhdkf',
    //   'android_device_id': 'kfhsdkjfhsdifhikfekjdjfhdk',
    //   'photo': ''
    // };
    // print('This is ${''}');
    // print("This is our request ==================${formData}");

    //DialogBoxes.openLoadingDialog();
    // print("${ApiLinks.registration}");
    var response = await DioClient()
        .post(ApiLinks.registration, formData, true)
        .catchError((error) {
      if (error is BadRequestException) {
        log("idhar bad");
        Get.snackbar(
          'Error'.tr,
          error.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: R.colors.themeColor,
        );
        var apiError = json.decode(error.message!);
        debugPrint(apiError.toString());

        // DialogBoxes.showErroDialog(description: apiError["reason"]);
      } else {
        log("idhar else");
        Get.back();
        // Get.back();
        Get.snackbar(
          'Error'.tr,
          'Something went wrong'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: R.colors.themeColor,
        );
        debugPrint("This is error==================${error.toString()}");

        //HandlingErrors().handleError(error);
      }
    });
    //  message = response['message'];
    // if (response == null) return;
    debugPrint("This is my response================== $response");

    if (response == null || response == "") return;
    log(response.toString());
    if (response['success'] == true) {
      debugPrint(response.toString());
      registerController.password.clear();
      registerController.phone.clear();
      fullNameController.clear();
      companyNameController.clear();
      twitterController.clear();
      contactController.clear();
      websiteController.clear();
      whatsappController.clear();
      cityId = '';
      expense_typeId = '';
      location.value = '';
      location_lat.value = '';
      location_lng.value = '';
      finalSelectedType.value = 'Select Type'.tr;
      finalSelectedCity.value = 'Select City'.tr;
      accountType == 2;
      var userInfo = LoginModel.fromJson(response);
      await GetStorage().write('user_token', userInfo.token);
      await GetStorage().write('userId', userInfo.user!.id);
      await GetStorage().write('name', userInfo.user!.name);
      await GetStorage().write('username', userInfo.user!.username);
      await GetStorage().write('email', userInfo.user!.email);
      await GetStorage().write('firebase_email', userInfo.user!.firebaseEmail);
      await GetStorage().write('mobile', userInfo.user!.mobile);
      await GetStorage().write('photo', userInfo.user!.photo);
      await GetStorage().write('status', userInfo.user!.status);
      await GetStorage().write('groupId', userInfo.user!.groupId);
      await GetStorage().write('user_type', userInfo.user!.userType);
      await GetStorage().write('countryId', userInfo.user!.countryId);
      await GetStorage().write('accountType', userInfo.user!.accountType);
      debugPrint("heeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeer");
      // debugPrint(GetStorage().read("countryId").toString());
      await createFirebaseUser();
      MyBottomNavigationController ctr =
          Get.put<MyBottomNavigationController>(MyBottomNavigationController());
      ctr.tabIndex.value = 0;
      Get.offAllNamed(RoutesName.base);
    } else {
      Get.back();
      Get.snackbar(
        'Error'.tr,
        // 'Something went wrong'.tr,
        response["validation_errors"],
        snackPosition: SnackPosition.TOP,
        backgroundColor: R.colors.themeColor,
      );
    }
    return null;
    // return null;
  }

  Future createFirebaseUser() async {
    await firebase_auth.FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: GetStorage().read('mobile') + '@gmail.com',
            password: GetStorage().read('mobile'))
        .then((value) {
      // SnakeBars.showSuccessSnake(description: "FireBase signin");
      //Get.snackbar('FireBase signin', '');
    }).catchError((error) async {
      if (error.code == 'user-not-found') {
        await firebase_auth.FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: GetStorage().read('mobile') + '@gmail.com',
                password: GetStorage().read('mobile'))
            .then((value) {
          //  SnakeBars.showSuccessSnake(description: "FireBase Created");
          // Get.snackbar('FireBase created', '');
        }).catchError((error) {
          // DialogBoxes.showErroDialog(description: error.code);
        });
      }
      // DialogBoxes.showErroDialog(description: error.code);
      // debugPrint('Firebase signin ${error.code}');
    });

    // await firebase_auth.FirebaseAuth.instance
    //     .createUserWithEmailAndPassword(
    //         email: GetStorage().read('mobile') + '@gmail.com',
    //         password: GetStorage().read('mobile'))
    //     .then((value) {
    //   //Get.snackbar("firebase-created", 'firebase-created');
    //   //SnakeBars.showSuccessSnake(description: 'firebase reg');
    // }).catchError((error) {
    //   Get.snackbar("firebase-error", error.toString());
    //   // SnakeBars.showErrorSnake(description: error.toString());
    // });
  }
}

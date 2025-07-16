import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sarf/model/moreModel/account_model.dart';
import 'package:sarf/model/moreModel/alerts_model.dart';
import '../../constant/api_links.dart';
import '../../model/loginModel.dart';
import '../../model/moreModel/profile.dart';
import '../../resources/resources.dart';
import '../../services/app_exceptions.dart';
import '../../services/dio_client.dart';
import '../../services/notification_services.dart';
import '../../src/baseview/base_controller.dart';
import '../../src/utils/routes_name.dart';
import '../../src/widgets/loader.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class ProfileController extends GetxController {
  TextEditingController userNameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController instaController = TextEditingController();
  TextEditingController twitterController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController whatsappController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  NotificationServices notificationServices = NotificationServices();
  var alertCount = 0.obs;
  String id = '';
  var location = ''.obs;
  var location_lat = ''.obs;
  var location_lng = ''.obs;
  var message;
  ProfileModel? profileModel;
  Rx<UserAccounts> accounts = UserAccounts().obs;

  @override
  void onInit() {
    // GetStorage().write('lang', 'en');
    getAlertCount();
    getProfile();
    getAccounts();
    super.onInit();
  }

  Future getProfile() async {
    // Log: Loading started
    print('[ProfileController] Starting profile loading...');

    try {
      // Configure loading indicator
      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.custom
        ..backgroundColor = Colors.white
        ..indicatorColor = R.colors.blue
        ..maskColor = R.colors.blue
        ..dismissOnTap = false
        ..textColor = R.colors.blue
        ..userInteractions = false;

      EasyLoading.show(status: 'Loading...');
      print('[ProfileController] Loading indicator shown');

      // Prepare request
      var request = {
        'language': GetStorage().read('lang'),
      };
      print('[ProfileController] Request prepared: $request');

      // Make API call
      print('[ProfileController] Making API call to ${ApiLinks.profile}');
      var response = await DioClient().post(ApiLinks.profile, request)
          .catchError((error) async {
        print('[ProfileController] API Error: $error');

        if (error is BadRequestException) {
          EasyLoading.dismiss();
          print('[ProfileController] BadRequestException: ${error.message}');

          Get.back();
          Get.snackbar(
            'Error'.tr,
            '$message',
            snackPosition: SnackPosition.TOP,
            backgroundColor: R.colors.themeColor,
          );

          var apiError = json.decode(error.message!);
          print('[ProfileController] API Error Details: $apiError');
        } else {
          print('[ProfileController] Other Error: $error');
          EasyLoading.dismiss();
          Get.back();

          // Clear storage
          print('[ProfileController] Clearing storage data...');
          await GetStorage().remove('user_token');
          await GetStorage().remove('groupId');
          await GetStorage().remove('userId');
          await GetStorage().remove('name');
          await GetStorage().remove('username');
          await GetStorage().remove('email');
          await GetStorage().remove('firebase_email');
          await GetStorage().remove('mobile');
          await GetStorage().remove('photo');
          await GetStorage().remove('status');

          print('[ProfileController] Navigating to login screen');
          Get.offAllNamed(RoutesName.LogIn);
        }
      });

      if (response == null) {
        print('[ProfileController] Response is null');
        return;
      }

      print('[ProfileController] API Response received: ${response.toString()}');
      message = response['message'];
      print('[ProfileController] Message from response: $message');

      if (response['success'] == true) {
        print('[ProfileController] Successful response, parsing data...');

        // Parse profile model
        profileModel = ProfileModel.fromJson(response);
        print('[ProfileController] Profile model parsed successfully');

        try {
          // Update form fields
          nameController.text = profileModel!.user!.name ?? '';
          userNameController.text = profileModel!.user!.username ?? '';
          emailController.text = profileModel!.user!.email ?? '';
          mobileController.text = profileModel!.user!.mobile ?? '';
          instaController.text = profileModel!.user!.userDetail?.instaLink ?? '';
          twitterController.text = profileModel!.user!.userDetail?.twitterLink ?? '';
          contactController.text = profileModel!.user!.userDetail?.contactNo ?? '';
          whatsappController.text = profileModel!.user!.userDetail?.whatsapp ?? '';
          websiteController.text = profileModel!.user!.userDetail?.website ?? '';
          location.value = profileModel!.user!.userDetail?.location ?? '';

          print('[ProfileController] Form fields updated successfully');

          // Save user data to storage
          if (profileModel!.user!.name != null) {
            await GetStorage().write('name', profileModel!.user!.name);
            print('[ProfileController] User name saved to storage: ${profileModel!.user!.name}');
          }

          EasyLoading.dismiss();
          update();
          print('[ProfileController] Profile loaded and UI updated successfully');
        } catch (e) {
          print('[ProfileController] Error updating form fields: $e');
          EasyLoading.dismiss();
          throw e;
        }
      } else {
        print('[ProfileController] API returned success=false');
        EasyLoading.dismiss();
        Get.back();
        Get.snackbar(
          'Error'.tr,
          '$message',
          snackPosition: SnackPosition.TOP,
          backgroundColor: R.colors.themeColor,
        );
      }
    } catch (e) {
      print('[ProfileController] Unexpected error in getProfile(): $e');
      EasyLoading.dismiss();
      rethrow;
    } finally {
      print('[ProfileController] Profile loading process completed');
    }

    return null;
  }
  Future getAccounts() async {
    accounts.value = UserAccounts();
    //check validation
    // final isValid = loginFormKey.currentState!.validate();
    // if (!isValid) {
    //   return;
    // }
    // loginFormKey.currentState!.save();
    // validation ends
    // var a = forgotPasswordController.phone.text;
    // final splitted = a.split('+');

    var request = {
      'language': GetStorage().read('lang'),
    };

    //DialogBoxes.openLoadingDialog();

    var response = await DioClient()
        .post(ApiLinks.getAccounts, request)
        .catchError((error) {
      if (error is BadRequestException) {
        var apiError = json.decode(error.message!);
        // debugPrint(apiError.toString());

        // DialogBoxes.showErroDialog(description: apiError["reason"]);
      } else {
        // debugPrint('Something went Wrong===============${error.toString()}');
        //HandlingErrors().handleError(error);
      }
    });
    //message = response['message'];
    if (response == null) return;
    // debugPrint("This ==================$response");
    if (response['success'] == true) {
      //debugPrint("This ==================$response");
      var data = UserAccounts.fromJson(response);
      accounts.value = data;
    } else {
      // debugPrint(response.toString());
    }
    return null;
    // return null;
  }

  Future getAlertCount() async {
    var request = {
      'language': GetStorage().read('lang'),
    };

    var response = await DioClient()
        .post(ApiLinks.alertCount, request)
        .catchError((error) {
      if (error is BadRequestException) {
        var apiError = json.decode(error.message!);
        // debugPrint(apiError.toString());
      } else {
        // debugPrint('Something went Wrong===============${error.toString()}');
      }
    });

    if (response == null) return;
    // debugPrint("This ==================$response");
    if (response != null) {
      if (response['success'] == true) {
        var data = AlertsCount.fromJson(response);
        if (data.data?.alertCount != null) {
          alertCount.value = data.data!.alertCount!;
        }
      } else {
        alertCount.value = 0;
        // debugPrint(response.toString());
      }
    }
    return null;
    // return null;
  }

  Future login(String phone, String password, String groupId) async {
    openLoader();
    String? result = await notificationServices.getDeviceToken();
    debugPrint(result);
    var request = {};
    if (id == '' && !kIsWeb) {
      request = {
        'language': GetStorage().read('lang'),
        'mobile': phone,
        'password': password,
        'ios_device_id': Platform.isIOS == true ? result : '',
        'android_device_id': Platform.isAndroid == true ? result : '',
        "group_id": groupId
      };
    } else {
      request = {
        'language': GetStorage().read('lang'),
        'mobile': phone,
        'password': password,
        "group_id": groupId
      };
    }
    debugPrint("This is my request====================$request");
    var response =
        await DioClient().post(ApiLinks.loginUser, request).catchError((error) {
      if (error is BadRequestException) {
        Get.back();
        var apiError = json.decode(error.message!);
        Get.snackbar(
          'Error'.tr,
          apiError["reason"].toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: R.colors.themeColor,
        );
      } else {
        Get.back();
        if (error is BadRequestException) {
          var message = error.message;
          Get.snackbar(
            'Error'.tr,
            message.toString(),
            snackPosition: SnackPosition.TOP,
            backgroundColor: R.colors.themeColor,
          );
        } else if (error is FetchDataException) {
          var message = error.message;
          Get.snackbar(
            'Error'.tr,
            message.toString(),
            snackPosition: SnackPosition.TOP,
            backgroundColor: R.colors.themeColor,
          );
        } else if (error is ApiNotRespondingException) {
          Get.snackbar(
            'Error'.tr,
            'Oops! It took longer to respond.'.tr,
            snackPosition: SnackPosition.TOP,
            backgroundColor: R.colors.themeColor,
          );
        }
      }
    });
    debugPrint("hereeeeeeeeeeeererer");
    debugPrint(response.toString());
    if (response['success'] == true) {
      result = 'true';
      Get.back();
      debugPrint(response.toString());
      Get.snackbar(
        'Success'.tr,
        'Login Successfully'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: R.colors.blue,
      );
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
      await GetStorage().write('user_lang', userInfo.user!.locale);
      await GetStorage().write('user_type', userInfo.user!.userType);
      await GetStorage().write('countryId', userInfo.user!.countryId);
      await GetStorage().write('accountType', userInfo.user!.accountType);
      await createFirebaseUser(GetStorage().read('mobile') + '@gmail.com',
          GetStorage().read('mobile'));
      MyBottomNavigationController ctr =
          Get.put<MyBottomNavigationController>(MyBottomNavigationController());
      ctr.tabIndex.value = 0;
      Get.offAllNamed(RoutesName.base);
    } else {
      result = 'false';
      Get.back();
      Get.snackbar(
        'Error'.tr,
        response['message'].toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: R.colors.themeColor,
      );
    }
    return result;
  }

  Future createFirebaseUser(String email, String password) async {
    await signIn(email, password);
    // // final user = firebase_auth.FirebaseAuth.instance.currentUser;
    // // print(user);
    // if (user != null) {
    //   print('firebaseUser');
    //   signIn();
    // } else {
    //   signUp();
    // }
  }

  Future signIn(String email, String password) async {
    // try {
    await firebase_auth.FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      // SnakeBars.showSuccessSnake(description: "FireBase signin");
      //Get.snackbar('FireBase signin', '');
    }).catchError((error) async {
      if (error.code == 'user-not-found') {
        await firebase_auth.FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password)
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

    //  final user = _auth.currentUser;
    //   if (user != null) {
    //     loggedInUser = user;
    //     // print(loggedInUser?.email);
    //   }

    // } catch (e) {
    //   //var error =

    //    //debugPrint('Firebase signin ${e['code']}');
    // }
  }

  Future signUp() async {
    try {
      await firebase_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: GetStorage().read('mobile') + '@gmail.com',
          password: GetStorage().read('mobile'));
    } catch (e) {
      // debugPrint('Firebase signUp $e');
    }
  }
}

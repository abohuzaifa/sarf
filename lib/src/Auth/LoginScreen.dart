import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
//import 'package:new_version/new_version.dart';
import 'package:sarf/controllers/auth/login_controller.dart';
import 'package:sarf/resources/images.dart';
import 'package:sarf/src/Auth/registration.dart';
import 'package:sarf/src/utils/routes_name.dart';

import '../../controllers/auth/data_collection_controller.dart';
import '../../controllers/auth/forgot_password_controller.dart';
import '../../resources/resources.dart';
import '../baseview/home/update_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool english = false;
  bool arabic = true;
  String? countryName;
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();
  FocusNode searchFieldNode = FocusNode();
  LoginController loginController = Get.find<LoginController>();
  DataCollectionController ctr = Get.find<DataCollectionController>();
  var loginFormKey = GlobalKey<FormState>();
  ForgotPasswordController forgotPasswordController =
      Get.find<ForgotPasswordController>();

  @override
  void initState() {
    EasyLoading.dismiss();
   // final newVersion = NewVersion(androidId: 'com.sarf', iOSId: "com.sarf");

    // Timer(const Duration(milliseconds: 800), () {
    //   checkNewVersion(newVersion);
    // });
    english = GetStorage().read("lang") == "en" ? true : false;
    arabic = GetStorage().read("lang") == "ar" ? true : false;
    super.initState();
  }


/*  Future<void> checkNewVersion(NewVersion newVersion) async {
    try {
      // Log initialization
      debugPrint('[Version Check] Starting version check process...');

      // Get version status
      debugPrint('[Version Check] Fetching version status from store...');
      final status = await newVersion.getVersionStatus();

      if (status == null) {
        debugPrint('[Version Check] No version status information available');
        return;
      }

      // Log version information
      debugPrint('[Version Check] Current version: ${status.localVersion}');
      debugPrint('[Version Check] Store version: ${status.storeVersion}');
      debugPrint('[Version Check] Can update: ${status.canUpdate}');

      if (status.canUpdate) {
        debugPrint('[Version Check] Update available - showing dialog');

        // Show custom dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return UpdateDialog(
              allowDismissal: true,
              description: status.releaseNotes ?? 'Bug fixes and performance improvements',
              version: status.storeVersion,
              appLink: status.appStoreLink,
            );
          },
        );

        // Log dialog details
        debugPrint('[Version Check] Custom UpdateDialog shown with version ${status.storeVersion}');

        // Show default dialog as fallback
        newVersion.showUpdateDialog(
          context: context,
          versionStatus: status,
          dialogText: 'New Version is available in the store (${status.storeVersion}), update now!',
          dialogTitle: 'Update is Available!',
        );

        debugPrint('[Version Check] Default update dialog shown');
      } else {
        debugPrint('[Version Check] App is up to date (${status.localVersion})');
      }
    } catch (e, stackTrace) {
      // Error handling
      debugPrint('[Version Check] Error during version check: $e');
      debugPrint('[Version Check] Stack trace: $stackTrace');

      // You might want to add error reporting here (e.g., Sentry, Firebase Crashlytics)
      // await reportError(e, stackTrace);
    } finally {
      debugPrint('[Version Check] Version check process completed');
    }
  }*/
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // exit(0);
        //  SystemNavigator.pop();
        SystemNavigator.pop(animated: true);
        return true;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  buildBackGroundImage(),
                ],
              ),
              buildLoginCard(),
            ],
          ),
        ),
      ),
    );
  }

  buildBackGroundImage() {
    return Image.asset(
      'assets/images/backgroundImage.png',
      width: MediaQuery.of(context).size.width,
      height: kIsWeb == true ? 200 : null,
      fit: BoxFit.fill,
    );
  }

  buildBackArrowContainer() {
    return Positioned(
      top: 50,
      left: 30,
      child: InkWell(
        onTap: () {},
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: const Color(0xFFFFFFFF)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/arrow.png'),
          ),
        ),
      ),
    );
  }

  Widget buildLoginCard() {
    return Container(
      // height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: kIsWeb == true
          ? Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Get.width > 750 ? Get.width / 3 : 0),
              child: Column(
                children: [
                  buildLoginTextAndLanguageOptions(),
                  Form(
                    key: loginFormKey,
                    child: Column(
                      children: [
                        //  buildPhoneFieldForLogin(),
                        Container(
                            margin: const EdgeInsets.only(left: 15, right: 15),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xFFEAEEF2)),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.dialog(Dialog(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        width: Get.width * 0.80,
                                        decoration: BoxDecoration(
                                            color: R.colors.lightGrey,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Text("data"),
                                            Expanded(
                                                child: ListView.separated(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        ctr.countries?.length ??
                                                            0,
                                                    separatorBuilder:
                                                        (context, index) {
                                                      return Divider(
                                                        color: R.colors.grey,
                                                        thickness: 1,
                                                      );
                                                    },
                                                    itemBuilder:
                                                        (context, index) {
                                                      var singleData =
                                                          ctr.countries?[index];
                                                      return GestureDetector(
                                                        onTap: () {
                                                          loginController
                                                                  .code.value =
                                                              singleData.code ??
                                                                  "966";
                                                          loginController.flag
                                                              .value = singleData
                                                                  .flag ??
                                                              "admin/country/sa.png";
                                                          loginController.lenght
                                                              .value = singleData
                                                                  .mobileNumberLength ??
                                                              9;
                                                          loginController
                                                              .selectedCountry
                                                              .value = singleData
                                                                  .id ??
                                                              2;
                                                          Get.back();
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                  "https://sarfapp.com/${singleData!.flag}",
                                                                  width: 40,
                                                                  height: 40,
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(GetStorage().read(
                                                                            "lang") ==
                                                                        "en"
                                                                    ? singleData
                                                                            .name.toString()??
                                                                        ''
                                                                    : singleData
                                                                            .name.toString()??
                                                                        ''),
                                                              ],
                                                            ),
                                                            Text(singleData
                                                                    .code ??
                                                                ''),
                                                          ],
                                                        ),
                                                      );
                                                    })),
                                          ],
                                        ),
                                      ),
                                    ));
                                  },
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Obx(() => Image.network(
                                              "https://sarfapp.com/${loginController.flag.value}",
                                              width: 40,
                                              height: 40,
                                            )),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Obx(() =>
                                            Text(loginController.code.value)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    // focusNode: searchFieldNode,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Required Field".tr;
                                      }

                                      return null;
                                    },
                                    controller: loginController.phone,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                        hintText: 'Enter Mobile Number'.tr,
                                        hintStyle: TextStyle(
                                            fontSize: 10,
                                            fontFamily: 'medium',
                                            color: const Color(0xFF9A9A9A)
                                                .withOpacity(0.8)),
                                        border: InputBorder.none),
                                  ),
                                )
                              ],
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        buildPasswordField(),
                      ],
                    ),
                  ),
                  buildForgotPassword(),
                  buildNextButton(),
                  buildDontHaveAnAccount(),
                  const SizedBox(
                    height: 100,
                  ),
                  // Spacer()
                ],
              ),
            )
          :
      Column(
              children: [
                buildLoginTextAndLanguageOptions(),
                Form(
                  key: loginFormKey,
                  child: Column(
                    children: [
                      //  buildPhoneFieldForLogin(),
                      Container(
                          margin: const EdgeInsets.only(left: 15, right: 15),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xFFEAEEF2)),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.dialog(Dialog(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      width: Get.width * 0.80,
                                      decoration: BoxDecoration(
                                          color: R.colors.lightGrey,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Text("data"),
                                          Expanded(
                                              child: ListView.separated(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      ctr.countries?.length ??
                                                          0,
                                                  separatorBuilder:
                                                      (context, index) {
                                                    return Divider(
                                                      color: R.colors.grey,
                                                      thickness: 1,
                                                    );
                                                  },
                                                  itemBuilder:
                                                      (context, index) {
                                                    var singleData =
                                                        ctr.countries?[index];
                                                    return GestureDetector(
                                                      onTap: () {
                                                        loginController
                                                                .code.value =
                                                            singleData.code ??
                                                                "966";
                                                        loginController.flag
                                                            .value = singleData
                                                                .flag ??
                                                            "admin/country/sa.png";
                                                        loginController.lenght
                                                            .value = singleData
                                                                .mobileNumberLength ??
                                                            9;
                                                        loginController
                                                                .selectedCountry
                                                                .value =
                                                            singleData.id ?? 2;
                                                        Get.back();
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Image.network(
                                                                "https://sarfapp.com/${singleData!.flag}",
                                                                width: 40,
                                                                height: 40,
                                                              ),
                                                              const SizedBox(
                                                                  width: 5),
                                                              Text(GetStorage()
                                                                          .read(
                                                                              "lang") ==
                                                                      "en"
                                                                  ? singleData
                                                                          .name.toString()??
                                                                      ''
                                                                  : singleData
                                                                          .name.toString()??
                                                                      ''),
                                                            ],
                                                          ),
                                                          Text(
                                                              singleData.code ??
                                                                  ''),
                                                        ],
                                                      ),
                                                    );
                                                  })),
                                        ],
                                      ),
                                    ),
                                  ));
                                },
                                child: Container(
                                  child: Row(
                                    children: [
                                      Obx(() => Image.network(
                                            "https://sarfapp.com/${loginController.flag.value}",
                                            width: 40,
                                            height: 40,
                                          )),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Obx(() =>
                                          Text(loginController.code.value)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: TextFormField(
                                  // focusNode: searchFieldNode,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Required Field".tr;
                                    }

                                    return null;
                                  },
                                  controller: loginController.phone,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                      hintText: 'Enter Mobile Number'.tr,
                                      hintStyle: TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'medium',
                                          color: const Color(0xFF9A9A9A)
                                              .withOpacity(0.8)),
                                      border: InputBorder.none),
                                ),
                              )
                            ],
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      buildPasswordField(),
                    ],
                  ),
                ),
                buildForgotPassword(),
                buildNextButton(),
                buildDontHaveAnAccount()
              ],
            ),
    );
  }

  buildLoginTextAndLanguageOptions() {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
      child: Row(
        children: [buildLoginText(), buildLanguageCard()],
      ),
    );
  }

  buildLoginText() {
    return Expanded(
      child: Text(
        'Login'.tr,
        style: const TextStyle(
            color: Color(0xFF9A9A9A), fontFamily: 'bold', fontSize: 18),
      ),
    );
  }

  buildLanguageCard() {
    return Container(
      height: 30,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey)),
      child: Row(
        children: [buildEnglishOption(), buildArabicOption()],
      ),
    );
  }

  buildEnglishOption() {
    return Material(
        child: InkWell(
      onTap: () {
        english = true;
        arabic = false;
        GetStorage().write('lang', 'en');
        var locale = const Locale('en', 'US');
        Get.updateLocale(locale);
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: english ? const Color(0xFFFB7B57) : Colors.transparent,
        ),
        margin: const EdgeInsets.only(left: 5, top: 5, right: 5, bottom: 5),
        width: 50,
        height: 30,
        child: Center(
          child: Text(
            'Eng',
            style: TextStyle(
                fontSize: 10,
                fontFamily: 'semibold',
                color: english ? Colors.white : Colors.black),
          ),
        ),
      ),
    ));
  }

  buildArabicOption() {
    return Material(
      child: InkWell(
        onTap: () {
          english = false;
          arabic = true;
          GetStorage().write('lang', 'ar');
          var locale = const Locale('ar', 'SA');
          Get.updateLocale(locale);
          setState(() {});
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: arabic ? const Color(0xFFFB7B57) : Colors.transparent,
          ),
          margin: const EdgeInsets.only(left: 5, top: 5, right: 5, bottom: 5),
          width: 50,
          height: 30,
          child: Center(
            child: Text(
              "العربية",
              style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'semibold,',
                  color: arabic ? Colors.white : Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPhoneFieldForLogin() {
    return Row(
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: IntlPhoneField(
            // countries: ["SA"],
            showDropdownIcon: false,
            flagsButtonPadding: const EdgeInsets.only(left: 10),
            onChanged: (number) {
              phone.text = number.completeNumber;
              loginController.phone.text = phone.text;
              // debugPrint(
              //     'This is my phoneNumber===============${loginController.phone.text}');
            },
            invalidNumberMessage: 'Invalid mobile number'.tr,
            initialCountryCode: 'SA',
            onCountryChanged: (country) {},
            decoration: InputDecoration(
              border: InputBorder.none,
              label: Container(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                child: Text('Enter Mobile Number'.tr,
                    style: const TextStyle(
                        color: Color(0xFF707070),
                        fontFamily: 'regular',
                        fontSize: 12)),
              ),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              // border: OutlineInputBorder(
              //   borderRadius: BorderRadius.circular(5.0),
              // ),
              filled: true,
              //  fillColor: const Color(0xffF0F0F0)
            ),
          ),
        ))
      ],
    );
  }

  Widget buildPhonefield() {
    return Row(
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: IntlPhoneField(
            // countries: ["SA"],
            showDropdownIcon: false,
            flagsButtonPadding: const EdgeInsets.only(left: 10),
            onChanged: (number) {
              phone.text = number.completeNumber;
              forgotPasswordController.phone.text = phone.text;
              // print(
              //     'This is my phoneNumber===============${forgotPasswordController.phone}');
            },
            initialCountryCode: 'SA',
            invalidNumberMessage: 'Invalid mobile number'.tr,
            onCountryChanged: (country) {},
            decoration: InputDecoration(
              border: InputBorder.none,
              label: Container(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                child: Text('Enter Mobile Number'.tr,
                    style: const TextStyle(
                        color: Color(0xFF707070),
                        fontFamily: 'regular',
                        fontSize: 12)),
              ),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              // border: OutlineInputBorder(
              //   borderRadius: BorderRadius.circular(5.0),
              // ),
              filled: true,
              //  fillColor: const Color(0xffF0F0F0)
            ),
          ),
        ))
      ],
    );
  }

  buildPasswordField() {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15),
      height: 50,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFEAEEF2)),
      child: Row(
        children: [
          Container(
              margin: const EdgeInsets.only(left: 20, right: 10, top: 3),
              child: Image.asset('assets/images/passwordIcon.png',
                  height: 15, color: const Color(0xFF9A9A9A).withOpacity(0.8))),
          Expanded(
            child: TextFormField(
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Required Field".tr;
                }
                return null;
              },
              controller: loginController.password,
              focusNode: searchFieldNode,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  hintText: 'Enter Password'.tr,
                  hintStyle: TextStyle(
                      fontSize: 10,
                      fontFamily: 'medium',
                      color: const Color(0xFF9A9A9A).withOpacity(0.8)),
                  border: InputBorder.none),
            ),
          )
        ],
      ),
    );
  }

  Widget buildForgotPassword() {
    return InkWell(
      onTap: () {
        openForgotPasswordDialog();
      },
      child: Container(
        margin: const EdgeInsets.only(top: 30, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Forgot Password?'.tr,
              style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'semibold',
                  color: Color(0xFFFB7B57)),
            )
          ],
        ),
      ),
    );
  }

  buildNextButton() {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFFB7B57),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          //  Get.toNamed(RoutesName.Base);
          // print(
          //     'This is my phoneNumber before apiCall===============${loginController.phone}');

          if (loginFormKey.currentState!.validate()) {
            if (loginController.phone.text.length <
                    loginController.lenght.value ||
                loginController.phone.text.length >
                    loginController.lenght.value) {
              Get.snackbar(
                'Alert'.tr,
                "Invalid mobile number".tr,
                snackPosition: SnackPosition.TOP,
                backgroundColor: R.colors.themeColor,
              );
              return;
            }
            loginController
                .login("${loginController.code}${loginController.phone.text}");
          }
        },
        child: Center(
          child: Text(
            'Next'.tr,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontFamily: 'medium'),
          ),
        ),
      ),
    );
  }

  buildDontHaveAnAccount() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Text(
              'Dont Have An Account'.tr,
              style: const TextStyle(
                  color: Colors.black, fontSize: 13, fontFamily: 'medium'),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext) => const Registration()));
            },
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              child: Text(
                'Register'.tr,
                style: const TextStyle(
                    color: Color(0xFFFB7B57),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    fontFamily: 'medium'),
              ),
            ),
          )
        ],
      ),
    );
  }

  void openForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.pop(context);
            },
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height - 100,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 15.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0),
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0)),
                    ),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 15,
                        ),
                        buildCrossIcon(),
                        buildForgotPasswordText(),
                        //  buildPhonefield(),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                            margin: const EdgeInsets.only(left: 15, right: 15),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xFFEAEEF2)),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.dialog(Dialog(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        width: Get.width * 0.80,
                                        decoration: BoxDecoration(
                                            color: R.colors.lightGrey,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Text("data"),
                                            Expanded(
                                                child: ListView.separated(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        ctr.countries?.length ??
                                                            0,
                                                    separatorBuilder:
                                                        (context, index) {
                                                      return Divider(
                                                        color: R.colors.grey,
                                                        thickness: 1,
                                                      );
                                                    },
                                                    itemBuilder:
                                                        (context, index) {
                                                      var singleData =
                                                          ctr.countries?[index];
                                                      return GestureDetector(
                                                        onTap: () {
                                                          forgotPasswordController
                                                                  .code.value =
                                                              singleData.code ??
                                                                  "966";
                                                          forgotPasswordController
                                                              .flag
                                                              .value = singleData
                                                                  .flag ??
                                                              "admin/country/sa.png";
                                                          forgotPasswordController
                                                              .lenght
                                                              .value = singleData
                                                                  .mobileNumberLength ??
                                                              9;
                                                          forgotPasswordController
                                                              .selectedCountry
                                                              .value = singleData
                                                                  .id ??
                                                              2;
                                                          Get.back();
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Image.network(
                                                                  "https://sarfapp.com/${singleData!.flag}",
                                                                  width: 40,
                                                                  height: 40,
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(GetStorage().read(
                                                                            "lang") ==
                                                                        "en"
                                                                    ? singleData
                                                                            .name.toString()??
                                                                        ''
                                                                    : singleData
                                                                            .name.toString()??
                                                                        ''),
                                                              ],
                                                            ),
                                                            Text(singleData
                                                                    .code ??
                                                                ''),
                                                          ],
                                                        ),
                                                      );
                                                    })),
                                          ],
                                        ),
                                      ),
                                    ));
                                  },
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Obx(() => Image.network(
                                              "https://sarfapp.com/${forgotPasswordController.flag.value}",
                                              width: 40,
                                              height: 40,
                                            )),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Obx(() => Text(forgotPasswordController
                                            .code.value)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    // focusNode: searchFieldNode,

                                    controller: forgotPasswordController.phone,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                        hintText: 'Enter Mobile Number'.tr,
                                        hintStyle: TextStyle(
                                            fontSize: 10,
                                            fontFamily: 'medium',
                                            color: const Color(0xFF9A9A9A)
                                                .withOpacity(0.8)),
                                        border: InputBorder.none),
                                  ),
                                )
                              ],
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        buildGetCodeButton()
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildForgotPasswordText() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Text(
        'Forgot Password'.tr,
        style:
            TextStyle(fontSize: 16, fontFamily: 'bold', color: R.colors.black),
      ),
    );
  }

  Widget buildCrossIcon() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              R.images.cross,
              height: 30,
            ),
          )
        ],
      ),
    );
  }

  buildGetCodeButton() {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
      height: 50,
      decoration: BoxDecoration(
        color: R.colors.buttonColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          // print(
          //     'This is my phoneNumber===============${forgotPasswordController.phone}');
          if (forgotPasswordController.phone.text.isEmpty) {
            Get.snackbar(
              'Alert'.tr,
              'Enter Mobile Number'.tr,
              snackPosition: SnackPosition.TOP,
              backgroundColor: R.colors.themeColor,
            );
          }
          if (forgotPasswordController.phone.text.isEmpty) {
            Get.snackbar(
              'Alert'.tr,
              'Enter Mobile Number'.tr,
              snackPosition: SnackPosition.TOP,
              backgroundColor: R.colors.themeColor,
            );
            return;
          }
          if (forgotPasswordController.phone.text.length <
                  forgotPasswordController.lenght.value ||
              forgotPasswordController.phone.text.length >
                  forgotPasswordController.lenght.value) {
            Get.snackbar(
              'Alert'.tr,
              "Invalid mobile number".tr,
              snackPosition: SnackPosition.TOP,
              backgroundColor: R.colors.themeColor,
            );
            return;
          } else {
            forgotPasswordController.forgotPassword(
                "${forgotPasswordController.code.value}${forgotPasswordController.phone.text}");
          }
        },
        child: Center(
          child: Text(
            'Get Code'.tr,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontFamily: 'medium'),
          ),
        ),
      ),
    );
  }
}

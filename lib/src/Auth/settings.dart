import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../controllers/auth/reset_password_controller.dart';
import '../../resources/resources.dart';
import '../widgets/custom_textfield.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  ResetPasswordController resetPasswordController =
      Get.find<ResetPasswordController>();
  bool english = true;
  bool arabic = false;
  String? countryName;
  TextEditingController phone = TextEditingController();

  @override
  void initState() {
    english = GetStorage().read("lang") == "en" ? true : false;
    arabic = GetStorage().read("lang") == "ar" ? true : false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            backgroundColor: Color(0xFFF2F2F9),
            body: Stack(
              children: [
                buildBackGroundImage(),
                buildBackArrowContainerAndSettingsText(),
              ],
            ),
          ),
          buildSettingsOptionsCard()
        ],
      ),
    );
  }

  Widget buildBackGroundImage() {
    return Stack(alignment: Alignment.topLeft, children: [
      Image.asset(
        R.images.backgroundImageChangePassword,
        width: MediaQuery.of(context).size.width,
      ),
      buildBackArrowContainerAndSettingsText(),
    ]);
  }

  Widget buildBackArrowContainerAndSettingsText() {
    return Positioned(
      top: 50,
      left: GetStorage().read("lang") == "en" ? 30 : null,
      right: GetStorage().read("lang") != "en" ? 30 : null,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: kIsWeb == true ? Get.width * 0.11 : 0),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Color(0xFFFFFFFF)),
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(R.images.arrowBlue)),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                'Settings'.tr,
                style: TextStyle(
                    color: R.colors.white, fontFamily: 'bold', fontSize: 16),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSettingsOptionsCard() {
    return Positioned(
      top: 100,
      right: 20,
      left: 20,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: kIsWeb == true ? Get.width * 0.11 : 0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              )),
          child: Column(
            children: [
              buildLanguageTextAndLanguageOptions(),
              if (GetStorage().read("user_type") != 3) ...[
                buildDivider(),
                buildChangeProfileTextAndIcon(),
                buildDivider(),
                buildChangePrivacyPolicyTextAndIcon()
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDivider() {
    return Container(
      margin: EdgeInsets.only(
        top: 10.0,
        bottom: 10,
        left: 30,
      ),
      color: R.colors.lightGrey,
      height: 2.0,
    );
  }

  Widget buildUpdateButton() {
    return Container(
      margin: EdgeInsets.only(top: 30, bottom: 20, left: 15, right: 15),
      child: customButton(
          margin: 20,
          width: MediaQuery.of(context).size.width,
          titleTextAlign: TextAlign.center,
          onPress: (() {
            if (resetPasswordController.currentPassword.text.isEmpty) {
              Get.snackbar(
                'Alert'.tr,
                'Enter Current Password'.tr,
                snackPosition: SnackPosition.TOP,
                backgroundColor: R.colors.themeColor,
              );
              return;
            } else if (resetPasswordController.newPassword.text.isEmpty) {
              Get.snackbar(
                'Alert'.tr,
                'Enter New Password'.tr,
                snackPosition: SnackPosition.TOP,
                backgroundColor: R.colors.themeColor,
              );
              return;
            } else if (resetPasswordController
                .confirmNewPassword.text.isEmpty) {
              Get.snackbar(
                'Alert'.tr,
                'Enter Confirm New Password'.tr,
                snackPosition: SnackPosition.TOP,
                backgroundColor: R.colors.themeColor,
              );
              return;
            } else {
              resetPasswordController.resetPassword();
            }
          }),
          title: 'Update'.tr,
          color: R.colors.buttonColor,
          height: 45,
          borderColour: R.colors.transparent,
          textColor: R.colors.white),
    );
  }

  buildChangePrivacyPolicyTextAndIcon() {
    return InkWell(
      onTap: () {
        openChangePasswordDialog();
      },
      child: Container(
        margin: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
        child: Row(
          children: [buildChangePasswordIcon(), buildChangePasswordText()],
        ),
      ),
    );
  }

  buildChangeProfileTextAndIcon() {
    return InkWell(
      onTap: () {
        Get.toNamed('change_profile');
      },
      child: Container(
        margin: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
        child: Row(
          children: [
            buildProfileIcon(),
            buildProfileText(),
          ],
        ),
      ),
    );
  }

  buildLanguageTextAndLanguageOptions() {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
      child: Row(
        children: [
          buildLanguageIcon(),
          buildLanguageText(),
          buildLanguageCard()
        ],
      ),
    );
  }

  Widget buildChangePasswordIcon() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: Image.asset(
        R.images.privacyPolicyIconForSettings,
        height: 15,
        width: 15,
      ),
    );
  }

  Widget buildProfileIcon() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: Image.asset(
        R.images.profile,
        height: 15,
        width: 15,
      ),
    );
  }

  Widget buildLanguageIcon() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: Image.asset(
        R.images.languageIcon,
        height: 15,
        width: 15,
      ),
    );
  }

  buildChangePasswordText() {
    return Expanded(
      child: Text(
        'Change Password'.tr,
        style: TextStyle(
            color: R.colors.black, fontFamily: 'medium', fontSize: 14),
      ),
    );
  }

  buildProfileText() {
    return Expanded(
      child: Text(
        'Profile'.tr,
        style: TextStyle(
            color: R.colors.black, fontFamily: 'medium', fontSize: 14),
      ),
    );
  }

  buildLanguageText() {
    return Expanded(
      child: Text(
        'Language'.tr,
        style: TextStyle(
            color: R.colors.black, fontFamily: 'medium', fontSize: 14),
      ),
    );
  }

  buildLanguageCard() {
    return Container(
      height: 25,
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
          color: english ? Color(0xFFFB7B57) : Colors.transparent,
        ),
        margin: EdgeInsets.only(left: 5, top: 5, right: 5, bottom: 5),
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
            color: arabic ? Color(0xFFFB7B57) : Colors.transparent,
          ),
          margin: EdgeInsets.only(left: 5, top: 5, right: 5, bottom: 5),
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

  void openChangePasswordDialog() {
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
                        buildChangePasswordext(),
                        buildCurrentPasswordField(),
                        buildNewPasswordField(),
                        buildConfirmNewPasswordField(),
                        buildUpdateButton()
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

  Widget buildChangePasswordext() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Text(
        'Change Password'.tr,
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
            padding: EdgeInsets.all(10),
            child: Image.asset(
              R.images.cross,
              height: 30,
            ),
          )
        ],
      ),
    );
  }

  Widget buildCurrentPasswordField() {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 20),
      child: customTextField(
          isPasswordObscureText: true,
          hintTextSize: 12,
          color: Colors.grey[300]!,
          height: 45,
          borderColour: R.colors.transparent,
          controller: resetPasswordController.currentPassword,
          hintText: 'Enter Current Password'.tr,
          hintStyle: TextStyle(color: R.colors.black)),
    );
  }

  Widget buildNewPasswordField() {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 20),
      child: customTextField(
          isPasswordObscureText: true,
          hintTextSize: 12,
          color: Colors.grey[300]!,
          height: 45,
          borderColour: R.colors.transparent,
          controller: resetPasswordController.newPassword,
          hintText: 'Enter New Password'.tr,
          hintStyle: TextStyle(color: R.colors.black)),
    );
  }

  Widget buildConfirmNewPasswordField() {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15, top: 20),
      child: customTextField(
          isPasswordObscureText: true,
          hintTextSize: 12,
          color: Colors.grey[300]!,
          height: 45,
          borderColour: R.colors.transparent,
          controller: resetPasswordController.confirmNewPassword,
          hintText: 'Confirm New Password'.tr,
          hintStyle: TextStyle(color: R.colors.black)),
    );
  }
}

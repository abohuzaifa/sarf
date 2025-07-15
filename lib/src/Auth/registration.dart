import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:sarf/constant/api_links.dart';

import '../../controllers/auth/data_collection_controller.dart';
import '../../controllers/auth/register_controller.dart';
import '../../resources/resources.dart';
import '../utils/routes_name.dart';

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  bool english = true;
  bool arabic = false;
  String? countryName;
  TextEditingController phone = TextEditingController();
  FocusNode searchFieldNode = FocusNode();
  bool checkBox = false;
  RegisterController registerController = Get.find<RegisterController>();
  DataCollectionController ctr = Get.find<DataCollectionController>();

  @override
  void initState() {
    registerController.phone.clear();
    registerController.password.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            backgroundColor: const Color(0xFFF2F2F9),
            body: Stack(
              children: [
                buildBackGroundImage(),
                buildBackArrowContainer(),
              ],
            ),
          ),
          buildRegistrationCard(),
        ],
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
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), color: const Color(0xFFFFFFFF)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/arrow.png'),
          ),
        ),
      ),
    );
  }

  buildRegistrationCard() {
    return Positioned(
      top: kIsWeb == true ? Get.width > 500 ? 200 : 150 : 250,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: kIsWeb == true ? Padding(
          padding:  EdgeInsets.symmetric(horizontal: Get.width > 750 ? Get.width/3 : 0),
          child: Column(
            children: [
              Expanded(child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildRegisterText(),
                // buildPhonefield(),
                Container(
                  margin: const EdgeInsets.only(left: 15, right: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10), color: const Color(0xFFEAEEF2)),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: (){
                          Get.dialog(Dialog(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                              width: Get.width * 0.80,
                              decoration: BoxDecoration(
                                color: R.colors.lightGrey,
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child:  Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text("data"),
                                    Expanded(child:
                                     ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: ctr.countries?.length ?? 0,
                                      separatorBuilder: (context, index) {
                                        return Divider(color: R.colors.grey,thickness: 1,);
                                      },
                                      itemBuilder: (context,index){
                                        var singleData = ctr.countries?[index];
                                      return GestureDetector(
                                        onTap: (){
                                          registerController.code.value = singleData.code ?? "966";
                                          registerController.flag.value = singleData.flag ?? "admin/country/sa.png";
                                          registerController.length.value = singleData.mobileNumberLength ?? 9;
                                          registerController.selectedCountry.value = singleData.id ?? 2;
                                          Get.back();
                                        },
                                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Image.network("https://sarfapp.com/${singleData!.flag}",width: 40,height: 40,),
                                              const SizedBox(width: 5,),
                                              Text(GetStorage().read("lang") == "en" ? singleData.name.toString()?? '' :  singleData.name.toString()?? ''),
                  
                  
                                            ],
                                          ),
                                          Text(singleData.code ?? ''),
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
                              Obx(() => Image.network("https://sarfapp.com/${registerController.flag.value}",width: 40,height: 40,)), 
                              const SizedBox(width: 5,),
                              Obx(() => Text(registerController.code.value)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 5,),
                       Expanded(
                child: TextField(
                 // focusNode: searchFieldNode,
                 controller: registerController.phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      hintText: 'Enter Mobile Number'.tr,
                      hintStyle: TextStyle(
                          fontSize: 10,
                          fontFamily: 'medium',
                          color: const Color(0xFF9A9A9A).withOpacity(0.8)),
                      border: InputBorder.none),
                ),
                          )
                    ],
                  )),
                  const SizedBox(height: 20,),
                buildPasswordField(),
                buildAgreeToTermsAndConditionsBox(),
                buildNextButton(),
                  ],
                ),
              ))
            ],
          ),
        ) :  Column(
          children: [
            buildRegisterText(),
            // buildPhonefield(),
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      height: 50,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: const Color(0xFFEAEEF2)),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: (){
                      Get.dialog(Dialog(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                          width: Get.width * 0.80,
                          decoration: BoxDecoration(
                            color: R.colors.lightGrey,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child:  Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text("data"),
                                Expanded(child:
                                 ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: ctr.countries?.length ?? 0,
                                  separatorBuilder: (context, index) {
                                    return Divider(color: R.colors.grey,thickness: 1,);
                                  },
                                  itemBuilder: (context,index){
                                    var singleData = ctr.countries?[index];
                                  return GestureDetector(
                                    onTap: (){
                                      registerController.code.value = singleData.code ?? "966";
                                      registerController.flag.value = singleData.flag ?? "admin/country/sa.png";
                                      registerController.length.value = singleData.mobileNumberLength ?? 9;
                                      registerController.selectedCountry.value = singleData.id ?? 2;
                                      Get.back();
                                    },
                                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.network("https://sarfapp.com/${singleData!.flag}",width: 40,height: 40,),
                                          const SizedBox(width: 5,),
                                          Text(GetStorage().read("lang") == "en" ? singleData.name.toString()?? '' :  singleData.name.toString() ?? ''),


                                        ],
                                      ),
                                      Text(singleData.code ?? ''),
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
                          Obx(() => Image.network("https://sarfapp.com/${registerController.flag.value}",width: 40,height: 40,)), 
                          const SizedBox(width: 5,),
                          Obx(() => Text(registerController.code.value)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 5,),
                   Expanded(
            child: TextField(
             // focusNode: searchFieldNode,
             controller: registerController.phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  hintText: 'Enter Mobile Number'.tr,
                  hintStyle: TextStyle(
                      fontSize: 10,
                      fontFamily: 'medium',
                      color: const Color(0xFF9A9A9A).withOpacity(0.8)),
                  border: InputBorder.none),
            ),
          )
                ],
              )),
              const SizedBox(height: 20,),
            buildPasswordField(),
            buildAgreeToTermsAndConditionsBox(),
            buildNextButton(),
          ],
        ),
      ),
    );
  }

  buildRegisterText() {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Registration'.tr,
            style: const TextStyle(
                fontFamily: 'bold', fontSize: 18, color: Color(0xFF9A9A9A)),
          )
        ],
      ),
    );
  }

  

  
  buildPhonefield() {
    return Row(
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: IntlPhoneField(
            showDropdownIcon: false,
            flagsButtonPadding: const EdgeInsets.only(left: 10),
            onChanged: (number) {
              phone.text = number.completeNumber;
              registerController.phone.text = phone.text;
              // print(
              //     'This is my phoneNumber===============${registerController.phone}');
            },
            initialCountryCode: 'SA',
            invalidNumberMessage: "Invalid mobile number".tr,
            onCountryChanged: (country) =>
                setState(() => countryName = country.code),
            decoration: InputDecoration(
              // focusedBorder: const OutlineInputBorder(
              //   borderSide:
              //       const BorderSide(color: Color(0xFF9A9A9A), width: 0.0),
              // ),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
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
          borderRadius: BorderRadius.circular(10), color: const Color(0xFFEAEEF2)),
      child: Row(
        children: [
          Container(
              margin: const EdgeInsets.only(left: 20, right: 10, top: 3),
              child: Image.asset('assets/images/passwordIcon.png',
                  height: 15, color: const Color(0xFF9A9A9A).withOpacity(0.8))),
          Expanded(
            child: TextField(
              obscureText: true,
             // focusNode: searchFieldNode,
             controller: registerController.password,
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

  

  buildNextButton() {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15, top: 40),
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFFB7B57),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          // print(
          //     'This is my phoneNumber===============${registerController.phone.text}');
          // print(
          //     'This is my phoneNumber===============${registerController.phone.text}');
          if (registerController.phone.text.isEmpty) {
            Get.snackbar(
              'Alert'.tr,
              'Enter Mobile Number'.tr,
              snackPosition: SnackPosition.TOP,
              backgroundColor: R.colors.themeColor,
            );
            return;
          }
          if (registerController.phone.text.length < registerController.length.value || registerController.phone.text.length > registerController.length.value ) {
            Get.snackbar(
              'Alert'.tr,
              "Invalid mobile number".tr,
              snackPosition: SnackPosition.TOP,
              backgroundColor: R.colors.themeColor,
            );
            return;
          }
          // 
           if (registerController.password.text.isEmpty) {
            Get.snackbar(
              'Alert'.tr,
              'Enter Password'.tr,
              snackPosition: SnackPosition.TOP,
              backgroundColor: R.colors.themeColor,
            );
            return;
          }
            if (checkBox == false) {
            Get.snackbar(
              'Alert'.tr,
              'Please Agree to Terms And Conditions'.tr,
              snackPosition: SnackPosition.TOP,
              backgroundColor: R.colors.themeColor,
            );
            return;
          }
          
           else {
            registerController.register("${registerController.code}${registerController.phone.text}");
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

  

  buildAgreeToTermsAndConditionsBox() {
    return Container(
      margin: const EdgeInsets.only(top: 30,left: kIsWeb == true ? 20: 0,right: kIsWeb == true ? 20: 0 ),
      child: Row(
        children: <Widget>[
          Checkbox(
            checkColor: Colors.white,
            activeColor: const Color(0xFF2C313E),
            value: checkBox,
            onChanged: (bool? value) {
              setState(() {
                checkBox = value!;
              });
            },
          ),
          Text(
            'I Accept'.tr,
            style: const TextStyle(fontSize: 17, color: Colors.grey),
          ),
          InkWell(
            onTap: () {
              Get.toNamed('terms_and_conditions');
            },
            child: Text(
              '(Terms & Conditions)'.tr,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 17,
              ),
            ),
          ),
        ], //<Widget>[]
      ),
    );
  }
}

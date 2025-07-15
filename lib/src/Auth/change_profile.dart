import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sarf/constant/api_links.dart';
import 'package:sarf/controllers/auth/change_password_controller.dart';
import 'package:video_player/video_player.dart';
import '../../controllers/auth/data_collection_controller.dart';
import '../../controllers/common/about_controller.dart';
import '../../controllers/common/change_profile_controller.dart';
import '../../controllers/common/profile_controller.dart';
import '../../model/data_collection.dart';
import '../../resources/resources.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/loader.dart';
import 'location_view.dart';

class ChangeProfile extends StatefulWidget {
  const ChangeProfile({Key? key}) : super(key: key);

  @override
  State<ChangeProfile> createState() => _ChangeProfileState();
}

class _ChangeProfileState extends State<ChangeProfile> {
  ProfileController profileController = Get.find<ProfileController>();
  DataCollectionController dataCollectionController =
      Get.find<DataCollectionController>();
  int selectedCityIndex = -1;
  ChangeProfileController changeProfileController =
      Get.find<ChangeProfileController>();
  XFile? _imageFile;
  VideoPlayerController? _controller;
  bool isVideo = false;
  String? _retrieveDataError;
  dynamic _pickImageError;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = true;
  List<City> cities = [];

  @override
  // ignore: must_call_super
  initState() {
    // ignore: avoid_print
    changeProfileController.changeProfileImage = null;
    getData();
    getDataCollection();

    //print("initState Called");
  }

  Future getData() async {
    await profileController.getProfile().then((value) => setState(() {
          isLoading = false;
        }));
  }

  Future getDataCollection() async {
    // await dataCollectionController.dataCollection();
     for (var city in dataCollectionController.cities!) {
      if( city.countryId == GetStorage().read("countryId") ){
        cities.add(city);
      }
    }
    // print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    // print(cities.toString());
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading == true
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Scaffold(
                    backgroundColor: Color(0xFFF2F2F9),
                    body: Stack(
                      children: [
                        buildBackGroundImage(),
                        buildBackArrowContainerAndChangeProfileText(),
                      ],
                    )),
                buildProfileCard()
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
      buildBackArrowContainerAndChangeProfileText(),
    ]);
  }

  Widget buildBackArrowContainerAndChangeProfileText() {
    return Positioned(
      top: 50,
      left: GetStorage().read("lang") == "en" ? 30 : null,
      right: GetStorage().read("lang") != "en" ? 30 : null,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: kIsWeb == true ? Get.width * 0.11 : 0),
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
                'Change Profile'.tr,
                style: TextStyle(
                    color: R.colors.white, fontFamily: 'bold', fontSize: 16),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileCard() {
    return Positioned(
      top: 100,
      right: 20,
      left: 20,
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: kIsWeb == true ? Get.width * 0.11 : 0),
        child: Container(
          height: MediaQuery.of(context).size.height - 100,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              )),
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5,),
                  Text('Name'.tr,),
                  buildNameField(),
                  Text('Select City'.tr,),
                  buildSelectCityDropDown(),
                  //  buildUserNameField(),
                  Text("Whatsapp (Optional)".tr),
                  buildWhatsappField(),
                  Text("Twitter Link (Optional)".tr),
                  buildTwitterField(),
                  Text("Instagram Link (Optional)".tr),
                  buildInstaField(),
                  Text('Contact No (Optional)'.tr),
                  buildContactNoField(),
                  Text("Website (Optional)".tr),
                  buildWebsiteField(),
                  if(kIsWeb == false)
                  Text("Location".tr),
                  buildLocationButton(),
                  Center(child: buildUploadImage()),
                  buildUpdateButton()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onImageButtonPressed(ImageSource source,
      {BuildContext? context,
      bool isMultiImage = false,
      required bool isCamera}) async {
    if (_controller != null) {
      log('this is video function');
      await _controller!.setVolume(0.0);
    }
    if (isVideo) {
      log('this is video function');
      //_pickVideo(isCamera);
      // final XFile? file = await _picker.pickVideo(
      //     source: source, maxDuration: const Duration(seconds: 10));

      // setState(() {
      //   _videoList = file;
      // });

      // final uint8list = await VideoThumbnail.thumbnailData(
      //   video: file!.path.toString(),
      //   imageFormat: ImageFormat.JPEG,
      //   maxWidth:
      //       128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      //   quality: 25,
      // );
      //
      // debugPrint(uint8list.toString());
      // //   await _playVideo(file);

    } else if (isMultiImage) {
      log('this is my gallery images');
      // await _displayPickImageDialog(context!,
      //         (double? maxWidth, double? maxHeight, int? quality) async {
      //       try {
      //         final List<XFile> pickedFileList = await _picker.pickMultiImage(
      //           maxWidth: maxWidth,
      //           maxHeight: maxHeight,
      //           imageQuality: quality,
      //         );
      //
      //         setState(() {
      //           if (_imageFile != null) {
      //             _imageFile = pickedFileList.first;
      //           }
      //         });
      //       } catch (e) {
      //         setState(() {
      //           _pickImageError = e;
      //         });
      //       }
      //    });
    } else {
      print('singleImage///////');
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
        );
        setState(() {
          _imageFile = pickedFile!;
          changeProfileController.changeProfileImage = File(_imageFile!.path);
          print(changeProfileController.changeProfileImage);
        });
      } catch (e) {
        setState(() {
          _pickImageError = e;
        });
      }
    }
  }

  void openGalleryCameraPickDialogs(bool video) {
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
                margin: EdgeInsets.symmetric(horizontal: 15.0),
                child: Center(
                  child: Container(
                    height: 145,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 15.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0),
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0)),
                    ),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          child: Text(
                            'Select'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontFamily: 'medium',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          child: Text(
                            'Select the source'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF999999),
                              fontFamily: 'medium',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          height: 18,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                _onImageButtonPressed(ImageSource.camera,
                                    context: context,
                                    isMultiImage: false,
                                    isCamera: true);
                                setState(() {});
                              },
                              child: Container(
                                height: 32,
                                width: 105,
                                decoration: BoxDecoration(
                                  color: R.colors.buttonColor,
                                ),
                                child: Center(
                                  child: Text(
                                    'Camera'.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontFamily: 'bold',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);

                                _onImageButtonPressed(ImageSource.gallery,
                                    context: context,
                                    isMultiImage: false,
                                    isCamera: false);
                                setState(() {});
                              },
                              child: Container(
                                height: 32,
                                width: 105,
                                decoration: BoxDecoration(
                                  color: R.colors.blue,
                                ),
                                child: Center(
                                  child: Text(
                                    'Gallery'.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontFamily: 'bold',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget buildUploadImage() {
    return InkWell(
      onTap: () {
        openGalleryCameraPickDialogs(false);
      },
      child: Container(
        margin: EdgeInsets.only(top: 20),
        child: Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  100,
                ),
                color: profileController.profileModel!.user!.photo != null
                    ? R.colors.transparent
                    : R.colors.blue),
            child: changeProfileController.changeProfileImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: kIsWeb == true ? Image.network(
                      changeProfileController.changeProfileImage!.path,
                      fit: BoxFit.cover,
                    )  : Image.file(
                      File(changeProfileController.changeProfileImage!.path),
                      fit: BoxFit.cover,
                    )
                    )
                : profileController.profileModel!.user!.photo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          ApiLinks.assetBasePath +
                              profileController.profileModel!.user!.photo!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Text(
                          'Add Image'.tr,
                          style: TextStyle(
                              fontFamily: 'regular',
                              color: Colors.white,
                              fontSize: 12),
                        ),
                      )),
      ),
    );
  }

  Widget buildLocationButton() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      height: 50,
      decoration: BoxDecoration(
        color: R.colors.lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () async{
          if (!kIsWeb) {
             bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    Get.snackbar("Alert".tr, "Location services are disabled.".tr);
    return; 
    // Future.error('');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      Get.snackbar("Alert".tr, "Location permissions are denied".tr);
      return; 
      // Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately. 
    Get.snackbar("Alert".tr, "Location permissions are denied".tr);
    return;
    //  Future.error(
    //   'Location permissions are permanently denied, we cannot request permissions.');
  } 
  openLoader();
  await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value){
    Get.back();
    Get.to(() => const LocationView(),
              arguments: {'Screen': 'From Profile Screen',
              "lat": value.latitude,
              "lng": value.longitude
              
              });
  });
          

          }
               
          // Get.to(() => const LocationView(),
          //     arguments: {'Screen': 'From Profile Screen'});
        },
        child: Row(
          children: [
            Container(
                margin: const EdgeInsets.only(left: 10),
                child: const Icon(
                  Icons.pin_drop,
                  size: 20,
                  color: Colors.blue,
                )),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.all(0),
                children: [
                  Container(
                      margin: EdgeInsets.only(left: 20, top: 20, right: 20),
                      child: Obx(
                        () => Text(
                          profileController.location.value != null
                              ? profileController.location.value
                              : 'Select Location'.tr,
                          style: TextStyle(
                              color: R.colors.black,
                              fontSize: 13,
                              fontFamily: 'medium'),
                        ),
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildSelectCityDropDown() {
    return Container(
      margin: EdgeInsets.only(top: 10,bottom: 10),
      height: 45,
      decoration: BoxDecoration(
        color: R.colors.lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          openPopUpOptionsForCities();
        },
        child: Container(
          margin: EdgeInsets.only(left: 15, right: 15),
          child: Row(
            children: [
              Expanded(
                  child: Obx(() => Text(
                        changeProfileController.finalSelectedCity.value != ''
                            ? changeProfileController.finalSelectedCity.value
                            : GetStorage().read("lang") == "en" ? profileController.profileModel!.user!.userDetail!
                                .cityId!.name!.en!
                                .toString() :  profileController.profileModel!.user!.userDetail!
                                .cityId!.name!.ar!
                                .toString(),
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'medium',
                            color: R.colors.black),
                      ))),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUpdateButton() {
    return Container(
      margin: EdgeInsets.only(
        top: 30,
        bottom: 20,
      ),
      child: customButton(
          margin: 20,
          width: MediaQuery.of(context).size.width,
          titleTextAlign: TextAlign.center,
          onPress: (() {
            changeProfileController.updateProfile();
          }),
          title: 'Update'.tr,
          color: R.colors.buttonColor,
          height: 45,
          borderColour: R.colors.transparent,
          textColor: R.colors.white),
    );
  }

  Widget buildNameField() {
    return Container(
      margin: EdgeInsets.only(top: 10,bottom: 10),
      child: customTextField(
          hintTextSize: 12,
          isPasswordObscureText: false,
          hintText: 'Full Name *',
          controller: profileController.nameController,
          color: R.colors.lightGrey,
          height: 45,
          borderColour: R.colors.transparent),
    );
  }

  Widget buildUserNameField() {
    return Container(
      margin: EdgeInsets.only(top: 10,bottom: 10),
      child: customTextField(
          hintTextSize: 12,
          isPasswordObscureText: false,
          hintText: 'bdscdscb',
          controller: profileController.userNameController,
          color: R.colors.lightGrey,
          height: 45,
          borderColour: R.colors.transparent),
    );
  }

  Widget buildEmailField() {
    return Container(
      margin: EdgeInsets.only(top: 10,bottom: 10),
      child: customTextField(
          hintTextSize: 12,
          isPasswordObscureText: false,
          hintText: '213412',
          controller: profileController.emailController,
          color: R.colors.lightGrey,
          height: 45,
          borderColour: R.colors.transparent),
    );
  }

  Widget buildInstaField() {
    return Container(
      margin: EdgeInsets.only(top: 10,bottom: 10),
      child: customTextField(
          hintTextSize: 12,
          isPasswordObscureText: false,
          hintText: "Enter profile name".tr,
          controller: profileController.instaController,
          color: R.colors.lightGrey,
          height: 45,
          borderColour: R.colors.transparent),
    );
  }

  Widget buildWhatsappField() {
    return Container(
      margin: EdgeInsets.only(top: 10,bottom: 10),
      child: customTextField(
          hintTextSize: 12,
          isPasswordObscureText: false,
          hintText: 'Whatsapp (Optional)'.tr,
          controller: profileController.whatsappController,
          color: R.colors.lightGrey,
          height: 45,
          borderColour: R.colors.transparent),
    );
  }

  Widget buildWebsiteField() {
    return Container(
      margin: EdgeInsets.only(top: 10,bottom: 10),
      child: customTextField(
          hintTextSize: 12,
          hintText: 'https://www.google.com',
          isPasswordObscureText: false,
          controller: profileController.websiteController,
          color: R.colors.lightGrey,
          height: 45,
          borderColour: R.colors.transparent),
    );
  }

  Widget buildContactNoField() {
    return Container(
      margin: EdgeInsets.only(top: 10,bottom: 10),
      child: customTextField(
          hintTextSize: 12,
          isPasswordObscureText: false,
          hintText: 'Contact No (Optional)'.tr,
          controller: profileController.contactController,
          color: R.colors.lightGrey,
          height: 45,
          borderColour: R.colors.transparent),
    );
  }

  Widget buildTwitterField() {
    return Container(
      margin: EdgeInsets.only(top: 10,bottom: 10),
      child: customTextField(
          hintTextSize: 12,
          isPasswordObscureText: false,
          hintText: "Enter profile name".tr,
          controller: profileController.twitterController,
          color: R.colors.lightGrey,
          height: 45,
          borderColour: R.colors.transparent),
    );
  }

  void openPopUpOptionsForCities() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
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
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height / 2,
                        width: MediaQuery.of(context).size.width,
                        //  margin: const EdgeInsets.symmetric(horizontal: 15.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(12.0),
                              bottomLeft: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0)),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Select City'.tr,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'bold',
                                  color: R.colors.buttonColor),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(top: 10, bottom: 10),
                                //  height: MediaQuery.of(context).size.height / 4,
                                color: R.colors.lightGrey,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount:
                                        cities.length,
                                    itemBuilder: (BuildContext, index) {
                                      return InkWell(
                                        onTap: () {
                                          selectedCityIndex = index;
                                          print(selectedCityIndex);
                                          changeProfileController
                                                  .finalSelectedCity.value =
                                              GetStorage().read("lang") == "en" ?    
                                              
                                                  cities[selectedCityIndex]
                                                  .name!
                                                  .toString() : 
                                                  cities[selectedCityIndex]
                                                  .name!
                                                  .toString() ;
                                          var getCityId =
                                              
                                                  cities[selectedCityIndex]
                                                  .id;
                                          changeProfileController.finalSelectedCityId = getCityId.toString();
                                          // print(
                                          //     "This is my selctedCity Id ============${getCityId} ${cities[selectedCityIndex]
                                          //         .name?}");

                                          setState(() {
                                            changeProfileController
                                                .finalSelectedCity;
                                          });

                                          Get.back();
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                                color:
                                                    selectedCityIndex == index
                                                        ? R.colors.buttonColor
                                                        : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                border: Border.all(
                                                    color: Colors.grey)),
                                            margin: EdgeInsets.only(top: 2),
                                            child: Center(
                                              child: Text(
                                               GetStorage().read("lang") == "en"? 
                                                    cities[index].name!
                                                    .toString() : 
                                                    cities[index].name!
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: R.colors.black),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ));
        });
      },
    );
  }
}

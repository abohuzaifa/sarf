import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sarf/constant/api_links.dart';
import 'package:sarf/controllers/home/home_controller.dart';
import 'package:sarf/controllers/invoice/invoice_controller.dart';
import 'package:sarf/resources/resources.dart';
import 'package:sarf/src/baseview/Send/custom_invoice.dart';
import 'package:sarf/src/baseview/members/qr_code_scanner.dart';
import 'package:scan/scan.dart';

import '../../../controllers/common/profile_controller.dart';
import '../../utils/navigation_observer.dart';
import '../../widgets/custom_appbar.dart';

class SimpleInvoice extends StatefulWidget {
  const SimpleInvoice({super.key});

  @override
  State<SimpleInvoice> createState() => _SimpleInvoiceState();
}

class _SimpleInvoiceState extends State<SimpleInvoice> with RouteAware {
  File? _scannedImage;
  Timer? searchOnStoppedTyping;
  String name = "";
  bool searching = false;

  void _startScan(BuildContext context) async {
    try {
      var image =
          await CunningDocumentScanner.getPictures(false).catchError((error) {
        Get.snackbar("Error".tr, error.toString(),
            backgroundColor: R.colors.blue);
        return error;
      });

      if (image != null) {
        for (var img in image) {
          _scannedImage = File(img);
          ctr.uploadImages.add(_scannedImage!);
        }

        setState(() {});
      }
    } on PlatformException catch (e) {
      // print("hereeeeee");
      Get.snackbar("Error".tr, e.toString());
      // debugPrint('Failed to pick image: $e');
    }
  }

  InvoiceController ctr = Get.find<InvoiceController>();
  HomeController homeController = Get.put<HomeController>(HomeController());
  ProfileController profileController =
      Get.put<ProfileController>(ProfileController());

  String replaceArabicNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(arabic[i], english[i]);
    }
    // print("$input");
    return input;
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      List<XFile>? pickedFiles;

      if (source == ImageSource.camera) {
        XFile? pickedFile =
            await ImagePicker().pickImage(source: source, imageQuality: 35);
        if (pickedFile != null) {
          pickedFiles = [pickedFile];
        }
      } else {
        pickedFiles = await ImagePicker().pickMultiImage();
      }

      if (pickedFiles == null || pickedFiles.isEmpty) return;

      for (var item in pickedFiles) {
        File file = File(item.path);
        print('File path: ${file.path}');
        print('File size: ${await file.length()} bytes');

        if (source == ImageSource.camera) {
          final compressedFile = await compressImage(file);
          if (compressedFile != null) {
            print('Compressed file path: ${compressedFile.path}');
            print(
                'Compressed file size: ${await compressedFile.length()} bytes');
            ctr.uploadImages.add(compressedFile);
          }
        } else {
          ctr.uploadImages.add(file);
        }
      }
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<File?> compressImage(File file) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      file.absolute.path + '_compressed.jpg',
      quality: 35,
      format: CompressFormat.jpeg,
      minWidth: 500,
      minHeight: 500,
    );

    if (result != null) {
      return File(result.path);
    } else {
      return null;
    }
  }

  // Future<File?> compressImage(File file) async {
  //   final result = await FlutterImageCompress.compressAndGetFile(
  //     file.absolute.path,
  //     file.absolute.path + '_compressed.jpg', // Output file path
  //     quality: 35, // Compression quality (0-100)
  //   );
  //
  //   if (result != null) {
  //     return File(result.path);
  //   } else {
  //     return null;
  //   }
  // }

  Future pickImageQr() async {
    print('[pickImageQr] Starting image picker for QR code');
    try {
      print('[pickImageQr] Attempting to pick image from gallery');
      var pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      print('[pickImageQr] Picked file: ${pickedFile?.path ?? 'null'}');
      if (pickedFile == null) {
        print('[pickImageQr] No file was selected, returning');
        return;
      }

      print('[pickImageQr] Attempting to parse QR code from image');
      String? parsedResult = await Scan.parse(pickedFile.path);
      print('[pickImageQr] Parsed result: ${parsedResult ?? 'null'}');

      if (parsedResult != null) {
        ctr.mobile1.text = parsedResult;
        ctr.checkMobile = true;
        print('[pickImageQr] Successfully updated mobile number and validated');
        Get.back();
      } else {
        print('[pickImageQr] Failed to parse QR code - no valid data found');
      }
    } on PlatformException catch (e) {
      print('[pickImageQr] PlatformException occurred: $e');
      // You might want to show this error to the user
      Get.snackbar('Error', 'Failed to pick image: ${e.message}');
    } catch (e) {
      print('[pickImageQr] Unexpected error occurred: $e');
      Get.snackbar('Error', 'An unexpected error occurred');
    } finally {
      print('[pickImageQr] Image picker process completed');
    }
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Helper.routeObserver.subscribe(this, ModalRoute.of(context)!);
      ctr.mobile1.clear();
      ctr.amount2.clear();
      ctr.note3.clear();
      ctr.uploadImages.clear();
    });
  }

  @override
  void didPopNext() {
    if (ctr.checkMobile) {
      log("Hello");
      // _onChangeHandler(ctr.mobile1.text);
      ctr.mobileCheck(ctr.mobile1.text).then((value) {
        if (value['message'] == 'User record available') {
          setState(() {
            name = value['user']['name'];
          });
        }
        if (value['message'] == 'User not found!') {
          setState(() {
            name = "User not found".tr;
          });
        }
      });
    } else {
      ctr.uploadImages.clear();
    }

    super.didPopNext();
  }

  _onChangeHandler(value) {
    print(value);

    const duration = Duration(
        milliseconds:
            1000); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping?.cancel()); // clear timer
    }
    setState(() => searchOnStoppedTyping = Timer(duration, () {
          String val = '';

          val = value;
          ctr.mobile1.text = val;
          ctr.mobile1.selection =
              TextSelection.collapsed(offset: ctr.mobile1.text.length);

          search(val);
        }));
  }

  search(value) {
    //print('hello world from search . the value is $value');
    if (value == null) {
      // qrCode = false;
      setState(() {
        searching = false;
      });
      return;
    }

    ctr.getMobileUsers(ctr.mobile1.text).then((value) async {
      if (ctr.searchedUsers.value.data != null) {
        log(ctr.searchedUsers.value.data![0].username.toString());
        setState(() {
          searching = true;
        });
      }
      //  await ctr.mobileCheck(ctr.mobile1.text).then((value){
      //   if(value['message'] == 'User record available'){
      //     setState(() {
      //       name = value['user']['name'];
      //     });
      //   }
      //   if(value['message'] == 'User not found!'){
      //     setState(() {
      //       name = "User not found".tr;
      //     });
      //   }
      // });
    });

    //print(ctr.mobile1.text);
  }

  @override
  void dispose() {
    searchOnStoppedTyping?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // exit(0);
        SystemNavigator.pop(animated: true);
        //  SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: R.colors.lightGrey,
        body: Stack(
          // mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(
                  left: GetStorage().read("lang") == 'en' ? 16.w : 0,
                  top: 20.h,
                  right: GetStorage().read("lang") == 'en' ? 0 : 16.w),
              height: 120.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    R.colors.blueGradient1,
                    R.colors.blueGradient2,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: kIsWeb == true
                        ? Get.width > 750
                            ? Get.width * 0.21
                            : 0
                        : 0),
                child: Align(
                  alignment: GetStorage().read('lang') == 'en'
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Text(
                    'Send Invoice 2'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 80),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: kIsWeb == true
                          ? Get.width > 750
                              ? Get.width * 0.2
                              : 0
                          : 0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 25.h),
                        padding: EdgeInsets.only(
                            left: 12.w, right: 12.w, top: 15.h, bottom: 20),
                        child: Form(
                          child: Column(
                            // mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: budgetName(),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              // Text('Mobile Number'.tr,style: TextStyle(
                              //       color: R.colors.grey,
                              //       fontSize: 14.sp,
                              //     ),),
                              //     const SizedBox(height: 5,),
                              // Container(
                              //   padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                              //   decoration: BoxDecoration(
                              //     color: R.colors.lightGrey,
                              //     borderRadius: BorderRadius.circular(10)
                              //   ),
                              //   child: Row(
                              //     children: [
                              //       Expanded(
                              //         child: IntlPhoneField(
                              //            controller: ctr.mobile1,
                              //           keyboardType: TextInputType.text,
                              //           disableLengthCheck: true,
                              //           onChanged: _onChangeHandler,
                              //                   // countries: ["SA"],
                              //                   showDropdownIcon: false,
                              //                   flagsButtonPadding: const EdgeInsets.only(left: 10),

                              //                   invalidNumberMessage: 'Invalid mobile number'.tr,
                              //                   initialCountryCode: 'SA',
                              //                   onCountryChanged: (country) {},
                              //                   decoration: InputDecoration(
                              //                     border: InputBorder.none,
                              //                     label: Container(
                              //                       margin: const EdgeInsets.symmetric(horizontal: 0),
                              //                       child: Text('Enter Mobile Number'.tr,
                              //                           style: const TextStyle(
                              //                               color: Color(0xFF707070),
                              //                               fontFamily: 'regular',
                              //                               fontSize: 12)),
                              //                     ),
                              //                     isDense: false,
                              //                     contentPadding:
                              //                         const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                              //                     // border: OutlineInputBorder(
                              //                     //   borderRadius: BorderRadius.circular(5.0),
                              //                     // ),
                              //                     // filled: true,
                              //                     //  fillColor: const Color(0xffF0F0F0)
                              //                   ),
                              //                 ),

                              //       ),

                              //        Padding(
                              //         padding: const EdgeInsets.only(bottom: 10),
                              //          child: GestureDetector(
                              //                                            onTap: (){
                              //                                              Get.bottomSheet(Container(
                              //           padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                              //           decoration: BoxDecoration(
                              //             borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                              //             color: R.colors.white,

                              //           ),
                              //           child: Column(
                              //             crossAxisAlignment: CrossAxisAlignment.start,
                              //             mainAxisSize: MainAxisSize.min,
                              //             children: [
                              //               GestureDetector(
                              //                 onTap: (){
                              //                   Get.back();
                              //                   // qrCode = true;
                              //                   Get.to(() => const QRScannerScreen(invoice: true,) );
                              //                 },
                              //                 child: Text("Camera".tr,style: TextStyle(fontSize: 14,color: R.colors.black),)),
                              //                 const SizedBox(height: 10,),
                              //                 Divider(color: R.colors.grey,thickness: 0.5,),
                              //                 const SizedBox(height: 10,),
                              //                 GestureDetector(
                              //                 onTap: (){
                              //                   pickImageQr();

                              //                 },
                              //                 child: Text("Gallery".tr,style: TextStyle(fontSize: 14,color: R.colors.black),)),
                              //             ],
                              //           ),

                              //                                              ),
                              //                                              );

                              //                                            },
                              //                                            child: Icon(
                              //                                              Icons.qr_code,
                              //                                              color: R.colors.blue,
                              //                                              size: 25.sp,
                              //                                            ),
                              //                                          ),
                              //        )

                              //     ],
                              //   ),
                              // ),
                              TextFormField(
                                //initialValue: ctr.mobile1.text,

                                controller: ctr.mobile1,
                                keyboardType: TextInputType.text,
                                onTap: () {
                                  ctr.mobile1.selection =
                                      TextSelection.collapsed(
                                          offset: ctr.mobile1.text.length);
                                },
                                onChanged: _onChangeHandler,
                                decoration: InputDecoration(
                                  suffixIcon: kIsWeb == true
                                      ? SizedBox()
                                      : GestureDetector(
                                          onTap: () {
                                            Get.bottomSheet(
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 20),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10)),
                                                  color: R.colors.white,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    GestureDetector(
                                                        onTap: () {
                                                          Get.back();
                                                          // qrCode = true;
                                                          Get.to(() =>
                                                              const QRScannerScreen(
                                                                invoice: true,
                                                              ));
                                                        },
                                                        child: Text(
                                                          "Camera".tr,
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: R.colors
                                                                  .black),
                                                        )),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Divider(
                                                      color: R.colors.grey,
                                                      thickness: 0.5,
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    GestureDetector(
                                                        onTap: () {
                                                          pickImageQr();
                                                        },
                                                        child: Text(
                                                          "Gallery".tr,
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: R.colors
                                                                  .black),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Icon(
                                            Icons.qr_code,
                                            color: R.colors.blue,
                                            size: 25.sp,
                                          ),
                                        ),
                                  //'Mobile Number'.tr
                                  fillColor: R.colors.lightGrey,
                                  filled: true,
                                  // hintText: 'Search 2'.tr,
                                  labelText: 'Search 2'.tr,
                                  labelStyle: TextStyle(
                                    color: R.colors.grey,
                                    fontSize: 14.sp,
                                  ),

                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: R.colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              Obx(
                                () => Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        if (name != '')
                                          Text(
                                            name,
                                            style: TextStyle(
                                              color: name == 'User not found'.tr
                                                  ? Colors.red
                                                  : R.colors.black,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        TextFormField(
                                          controller: ctr.amount2,
                                          decoration: InputDecoration(
                                            fillColor: R.colors.lightGrey,
                                            filled: true,
                                            labelText: 'Amount 2'.tr,
                                            labelStyle: TextStyle(
                                              color: R.colors.grey,
                                              fontSize: 14.sp,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: R.colors.grey,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        TextFormField(
                                          controller: ctr.note3,
                                          maxLines: 7,
                                          decoration: InputDecoration(
                                            fillColor: R.colors.lightGrey,
                                            filled: true,
                                            labelText:
                                                'Description(Optional)'.tr,
                                            labelStyle: TextStyle(
                                              color: R.colors.grey,
                                              fontSize: 14.sp,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: R.colors.grey,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        Container(
                                          width: Get.width,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 0),
                                          height: 70,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  pickImage(
                                                      ImageSource.gallery);
                                                },
                                                child: Container(
                                                  height: 60,
                                                  width: 60,
                                                  margin: const EdgeInsets.only(
                                                      right: 10, top: 1),
                                                  padding:
                                                      const EdgeInsets.all(18),
                                                  decoration: BoxDecoration(
                                                    color: R.colors.grey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Image.asset(
                                                    'assets/images/attach.png',
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              if (kIsWeb == false)
                                                GestureDetector(
                                                  onTap: () async {
                                                    DeviceInfoPlugin
                                                        deviceInfo =
                                                        DeviceInfoPlugin();
                                                    if (Platform.isAndroid) {
                                                      AndroidDeviceInfo
                                                          androidInfo =
                                                          await deviceInfo
                                                              .androidInfo;
                                                      final status =
                                                          await Permission
                                                              .camera
                                                              .request();
                                                      final status2 =
                                                          androidInfo.version
                                                                      .sdkInt <
                                                                  33
                                                              ? await Permission
                                                                  .storage
                                                                  .request()
                                                              : await Permission
                                                                  .photos
                                                                  .request();

                                                      if (status ==
                                                              PermissionStatus
                                                                  .granted &&
                                                          status2 ==
                                                              PermissionStatus
                                                                  .granted) {
                                                        _startScan(context);
                                                      } else {
                                                        openAppSettings();
                                                        // Get.snackbar("Error".tr, "Permission not granted");
                                                      }
                                                    } else {
                                                      _startScan(context);
                                                    }

                                                    //  pickImage(ImageSource.gallery);
                                                  },
                                                  child: Container(
                                                      height: 60,
                                                      width: 60,
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 10,
                                                              top: 1),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              18),
                                                      decoration: BoxDecoration(
                                                        color: R.colors.grey,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .qr_code_scanner_rounded,
                                                        //size: 28.sp,
                                                        color: R.colors.white,
                                                      )),
                                                ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        ctr.uploadImages.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      var singleFile = ctr
                                                          .uploadImages[index];
                                                      return Stack(
                                                        //alignment: Alignment.topRight,
                                                        children: [
                                                          Container(
                                                            width: 60,
                                                            height: 60,
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 10,
                                                                    top: 5),
                                                            decoration:
                                                                BoxDecoration(
                                                              //  color: R.colors.grey,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              child: kIsWeb ==
                                                                      true
                                                                  ? Image
                                                                      .network(
                                                                      singleFile
                                                                          .path,
                                                                      height:
                                                                          25.h,
                                                                      width:
                                                                          25.w,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    )
                                                                  : Image.file(
                                                                      singleFile,
                                                                      height:
                                                                          25.h,
                                                                      width:
                                                                          25.w,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: 0,
                                                            right: 5,
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                ctr.uploadImages
                                                                    .removeAt(
                                                                        index);
                                                              },
                                                              child: Container(
                                                                height: 20,
                                                                width: 20,
                                                                //padding: const EdgeInsets.all(5),
                                                                decoration: const BoxDecoration(
                                                                    color: Colors
                                                                        .red,
                                                                    shape: BoxShape
                                                                        .circle),
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Icon(
                                                                    Icons.close,
                                                                    size: 12,
                                                                    color: R
                                                                        .colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      );
                                                    }),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (name ==
                                                      'User not found') {
                                                    Get.snackbar(
                                                      'Error'.tr,
                                                      "Enter a valid number".tr,
                                                      backgroundColor:
                                                          Colors.red,
                                                      colorText: Colors.black,
                                                    );
                                                    return;
                                                  }
                                                  if (ctr
                                                      .mobile1.text.isEmpty) {
                                                    Get.snackbar(
                                                      'Error'.tr,
                                                      "mobile is required".tr,
                                                      backgroundColor:
                                                          Colors.red,
                                                      colorText: Colors.black,
                                                    );
                                                    return;
                                                  }
                                                  if (ctr
                                                      .amount2.text.isEmpty) {
                                                    Get.snackbar(
                                                      'Error'.tr,
                                                      "amount is required".tr,
                                                      backgroundColor:
                                                          Colors.red,
                                                      colorText: Colors.black,
                                                    );
                                                    return;
                                                  }
                                                  FocusScope.of(context)
                                                      .unfocus();

                                                  String a = ctr.mobile1.text;
                                                  String b =
                                                      replaceArabicNumber(
                                                          ctr.amount2.text);

                                                  ctr
                                                      .postNewInvoice(
                                                          a, b, ctr.note3.text)
                                                      .then((value) {
                                                    setState(() {
                                                      name = '';
                                                    });
                                                  });
                                                },
                                                child: Container(
                                                  height: 50.h,
                                                  decoration: BoxDecoration(
                                                    color: R.colors.themeColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      'Send'.tr,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (searching &&
                                        ctr.searchedUsers.value.data !=
                                            null) ...[
                                      Container(
                                        decoration: BoxDecoration(
                                          color: R.colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                                color: R.colors.lightGrey,
                                                offset: const Offset(0, 2),
                                                spreadRadius: 2,
                                                blurRadius: 2),
                                          ],
                                        ),
                                        height: 300,
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: ctr.searchedUsers.value
                                                .data?.length,
                                            itemBuilder: (context, index) {
                                              var singleData = ctr.searchedUsers
                                                  .value.data?[index];
                                              int numSpace =
                                                  (singleData?.mobile?.length ??
                                                          0) -
                                                      5;
                                              var a = singleData?.mobile
                                                  ?.replaceRange(0, numSpace,
                                                      '*' * numSpace);
                                              return ListTile(
                                                leading: CircleAvatar(
                                                  backgroundColor:
                                                      R.colors.lightGrey,
                                                  radius: 25,
                                                  backgroundImage: singleData
                                                              ?.photo ==
                                                          null
                                                      ? null
                                                      : NetworkImage(
                                                          "${ApiLinks.assetBasePath}${singleData?.photo}"),
                                                ),
                                                title: Text(
                                                    singleData?.name ?? ''),
                                                subtitle: Text(
                                                  a ?? '',
                                                  textAlign: GetStorage()
                                                              .read("lang") ==
                                                          "en"
                                                      ? TextAlign.left
                                                      : TextAlign.right,
                                                  textDirection:
                                                      TextDirection.ltr,
                                                ),
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  // var a = singleData?.mobile ?? '';
                                                  // final spliited = a.split("966");
                                                  ctr.mobile1.text =
                                                      singleData?.mobile ?? '';
                                                  ctr.mobile1.selection =
                                                      TextSelection.collapsed(
                                                          offset: ctr.mobile1
                                                              .text.length);
                                                  setState(() {
                                                    searching = false;
                                                  });
                                                  ctr
                                                      .mobileCheck(
                                                          ctr.mobile1.text)
                                                      .then((value) {
                                                    if (value['message'] ==
                                                        'User record available') {
                                                      setState(() {
                                                        name = value['user']
                                                            ['name'];
                                                      });
                                                    }
                                                    if (value['message'] ==
                                                        'User not found!') {
                                                      setState(() {
                                                        name =
                                                            "User not found".tr;
                                                      });
                                                    }
                                                  });
                                                },
                                              );
                                            }),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.to(() => const CustomInvoice()),
                        child: Container(
                          width: Get.width,
                          margin: EdgeInsets.symmetric(horizontal: 20.w),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: R.colors.blue,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.list_alt,
                                color: R.colors.white,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                "Generate Custom Invoice".tr,
                                style: TextStyle(color: R.colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

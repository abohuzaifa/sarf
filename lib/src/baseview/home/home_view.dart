import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sarf/controllers/home/home_controller.dart';
import 'package:sarf/src/baseview/Invoices/invoice_list_home.dart';
import 'package:sarf/src/utils/routes_name.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xcel;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' show AnchorElement;
import "dart:convert";

import '../../../constant/api_links.dart';
import '../../../controllers/common/profile_controller.dart';
import '../../../controllers/invoice/invoice_controller.dart';
import '../../../model/home/home_model.dart';
import '../../../model/members/invoice_list_model.dart';
import '../../../resources/resources.dart';
import '../../../services/dio_client.dart';
import '../../../services/notification_services.dart';
import '../../utils/navigation_observer.dart';
import '../Invoices/invoice_members_home.dart';
import '../base_controller.dart';
import 'package:qr_flutter/qr_flutter.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  HomeController ctr = Get.put<HomeController>(HomeController());
  InvoiceController invCtr = Get.find<InvoiceController>();

  InvoiceList? invoices;
  ProfileController profileController =
      Get.put<ProfileController>(ProfileController());
  TextEditingController txt = TextEditingController();
  ScreenshotController screenshotController = ScreenshotController();
  DateTime date = DateTime.now();
  DateTime todate = DateTime.now();
  DateTime month = DateTime.now();
  DateTime tomonth = DateTime.now();
  DateTime day = DateTime.now();
  DateTime today = DateTime.now();
  NotificationServices notificationServices = NotificationServices();
  List<ExpenseTypes> expenseTypes = [];
  //ScrollController scrollCtr = ScrollController();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Helper.routeObserver.subscribe(this, ModalRoute.of(context)!);
    });
    day = DateTime(date.year, date.month - 1, date.day);

    super.initState();
    getData();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    // notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value) {
      if (kDebugMode) {
        // print('device token');
        // print(value);
      }
    });
  }

  getData() async {
    expenseTypes.clear();
    await ctr.getHome(null, null, null).then((value) async {
      if (ctr.budgets.isNotEmpty) {
        ctr
            .getHome(
                ctr.budgets.first.id.toString(),
                day == DateTime.now() ? null : day.toIso8601String(),
                today == DateTime.now() ? null : today.toIso8601String())
            .then((value) {
          if (ctr.budgets.isNotEmpty) {
            ctr.selectedBudgetIndex.value = 1;
            ctr.selectedBudgetId.value = ctr.budgets.first.id.toString();
            ctr.selectedBudgetNumbder.value = "";
            ctr.selectedBudgetName.value = GetStorage().read('name') ?? "";
            ctr.qrCode.value = "${GetStorage().read('mobile')}";
            expenseTypes.clear();
            for (var expanse in ctr.expenseTypes) {
              // debugPrint(expanse.invoiceSumAmount.toString());
              if (expanse.invoiceSumAmount != null &&
                  expanse.invoiceSumAmount! > 0) {
                expenseTypes.add(expanse);
              }
            }

            if (mounted) {
              setState(() {});
            }
          }
        });
      }
    }).catchError((error) async {
      // debugPrint(error.toString());
      // await GetStorage().remove('user_token');
      // await GetStorage().remove('groupId');
      // await GetStorage().remove('userId');
      // await GetStorage().remove('user_type');
      // await GetStorage().remove('accountType');
      // await GetStorage().remove('countryId');
      // await GetStorage().remove(
      //   'name',
      // );
      // await GetStorage().remove(
      //   'username',
      // );
      // await GetStorage().remove(
      //   'email',
      // );
      // await GetStorage().remove(
      //   'firebase_email',
      // );
      // await GetStorage().remove(
      //   'mobile',
      // );
      // await GetStorage().remove(
      //   'photo',
      // );
      // await GetStorage().remove(
      //   'status',
      // );
      //  Get.offAllNamed(RoutesName.LogIn);
    });
    // await profileController.getProfile();
  }

  @override
  void dispose() {
    txt.dispose();
    super.dispose();
  }

  _shareQrCode() async {
    if (kIsWeb) {
      screenshotController.capture().then((Uint8List? image) async {
        if (image != null) {
          await WebImageDownloader.downloadImageFromUInt8List(uInt8List: image);
        }
      }).catchError((onError) {
        // debugPrint('Error --->> $onError');
      });
    } else {
      final directory = (await getApplicationDocumentsDirectory()).path;
      screenshotController.capture().then((Uint8List? image) async {
        if (image != null) {
          try {
            String fileName = DateTime.now().microsecondsSinceEpoch.toString();
            final imagePath = await File('$directory/$fileName.png').create();
            await imagePath.writeAsBytes(image);

            // ignore: deprecated_member_use
            Share.shareXFiles([XFile(imagePath.path)]);
          } catch (error) {
            // debugPrint(error.toString());
          }
        }
      }).catchError((onError) {
        // debugPrint('Error --->> $onError');
      });
    }
  }

  @override
  void didPopNext() async {
    expenseTypes.clear();
    //  debugPrint(ctr.selectedBudgetName.value);
    await ctr
        .getHome(
            ctr.selectedBudgetId.value.toString(),
            day == DateTime.now() ? null : day.toIso8601String(),
            today == DateTime.now() ? null : today.toIso8601String())
        .then((value) {
      expenseTypes.clear();
      for (var expanse in ctr.expenseTypes) {
        // debugPrint(expanse.invoiceSumAmount.toString());
        if (expanse.invoiceSumAmount != null && expanse.invoiceSumAmount! > 0) {
          expenseTypes.add(expanse);
        }
      }
      if (mounted) {
        setState(() {});
      }
    });
    // getData();
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    //  debugPrint(ctr.totalInvoicesDaily.value);
    //  debugPrint("0000000000000000000000000000000000000000000000000000000");
    return WillPopScope(
      onWillPop: () async {
        // exit(0);
        SystemNavigator.pop(animated: true);
        //  SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        body: SafeArea(
            child: Obx(
          () =>
              //  ctr.loading.value == true
              //      ?
              //      SizedBox()
              //       // Center(
              //     //     child: SizedBox(
              //     //       width: 50,
              //     //       height: 50,
              //     //       child: CircularProgressIndicator(
              //     //         //backgroundColor: AppColors.whiteClr,
              //     //         color: R.colors.blue,
              //     //       ),
              //     //     ),
              //     //   )
              //     :
              Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // buildLogoutIconAndText

                    if (GetStorage().read("user_type") != 3)
                      GestureDetector(
                          onTap: () {
                            if (GetStorage().read("user_type") == 3) {
                              Get.snackbar(
                                  "Error".tr, "You do not have access".tr);
                              return;
                            }
                            Get.bottomSheet(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 40),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: R.colors.white,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (ctr.selectedBudgetName.value !=
                                        GetStorage().read('name')) ...[
                                      GestureDetector(
                                        onTap: () {
                                          if (ctr.selectedBudgetId.value ==
                                              '') {
                                            Get.snackbar('Error'.tr,
                                                'Select a budget'.tr);
                                            return;
                                          }
                                          Get.dialog(Dialog(
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: R.colors.white),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      "Are you sure you want to delete this budget"
                                                          .tr),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () {
                                                            Get.back();
                                                            ctr.deleteBudget();
                                                          },
                                                          child: Container(
                                                            // width: Get.width,
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        15),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: R.colors
                                                                    .themeColor),
                                                            child: Center(
                                                                child: Text(
                                                              'Delete'.tr,
                                                              style: TextStyle(
                                                                  color: R
                                                                      .colors
                                                                      .white),
                                                            )),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () {
                                                            Get.back();
                                                          },
                                                          child: Container(
                                                            // width: Get.width,
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        15),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: R.colors
                                                                    .blue),
                                                            child: Center(
                                                                child: Text(
                                                              'Back'.tr,
                                                              style: TextStyle(
                                                                  color: R
                                                                      .colors
                                                                      .white),
                                                            )),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ));
                                        },
                                        child: Text(
                                          'Delete this budget'.tr,
                                          style: TextStyle(
                                              color: R.colors.blackSecondery),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Divider(
                                        color: R.colors.grey,
                                        thickness: 1,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                    GestureDetector(
                                      onTap: () {
                                        if (ctr.selectedBudgetId.value == '') {
                                          Get.snackbar(
                                              'Error'.tr, 'Select a budget'.tr);
                                          return;
                                        }
                                        ctr.resetBudget();
                                      },
                                      child: Text(
                                        'Reset this budget'.tr,
                                        style: TextStyle(
                                            color: R.colors.blackSecondery),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Icon(Icons.more_vert, color: R.colors.black)),
                    Row(
                      children: [
                        Obx(() => Text(ctr.selectedBudgetName.value ==
                                GetStorage().read("name")
                            ? GetStorage().read("name")
                            : ctr.selectedBudgetName.value)),
                        GestureDetector(
                            onTap: () {},
                            child: Icon(
                              Icons.close,
                              color: R.colors.black,
                            )),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: Get.width,
                  height: GetStorage().read("lang") == 'en' ? 100 : 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (GetStorage().read("user_type") == 3) {
                            Get.snackbar(
                                "Error".tr, "You do not have access".tr);
                            return;
                          }
                          Get.dialog(Dialog(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: R.colors.white),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                      onTap: () => Get.back(),
                                      child: Image.asset(
                                        R.images.cross,
                                        width: 30,
                                        height: 30,
                                      )),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    'Add new Project type'.tr,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: R.colors.blackSecondery),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: R.colors.lightGrey),
                                    child: TextFormField(
                                      controller: txt,
                                      decoration: InputDecoration(
                                        hintText: 'Project Name'.tr,
                                        hintStyle:
                                            TextStyle(color: R.colors.grey),
                                        focusedBorder: InputBorder.none,
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  customSimpleButton(() {
                                    if (txt.text.isEmpty) {
                                      Get.snackbar(
                                          'Error'.tr, 'Required Field'.tr.tr,
                                          backgroundColor: R.colors.themeColor);
                                      return;
                                    }
                                    ctr.addBudget(txt.text).then((value) {
                                      txt.clear();
                                    });
                                  })
                                ],
                              ),
                            ),
                          ));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: R.colors.black),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: R.colors.white),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                child: const Center(
                                  child: Icon(
                                    Icons.add,
                                    size: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                'New budget'.tr,
                                style: TextStyle(
                                    color: R.colors.white,
                                    decoration: TextDecoration.underline,
                                    fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                "#${ctr.budgets.length}",
                                style: TextStyle(
                                    color: R.colors.white,
                                    decoration: TextDecoration.underline,
                                    fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: GetStorage().read('lang') == "en" ? 10 : 10,
                      ),
                      Expanded(
                        child: ctr.budgets.isNotEmpty
                            ? ListView.builder(
                                // physics: NeverScrollableScrollPhysics(),
                                reverse: true,
                                shrinkWrap: true,
                                padding: EdgeInsets.only(
                                    right: GetStorage().read("lang") != "en"
                                        ? 7
                                        : 0,
                                    left: GetStorage().read("lang") == "en"
                                        ? 7
                                        : 0),
                                scrollDirection: Axis.horizontal,
                                itemCount: ctr.budgets.length,
                                itemBuilder: (context, index) {
                                  var singleData = ctr.budgets[index];
                                  return Obx(
                                    () => Container(
                                      height: GetStorage().read("lang") == 'en'
                                          ? 100
                                          : 100,
                                      margin: const EdgeInsets.only(left: 2),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: (ctr.selectedBudgetIndex
                                                          .value -
                                                      1) ==
                                                  index
                                              ? R.colors.blue.withOpacity(0.2)
                                              : null),
                                      child: GestureDetector(
                                        onTap: () {
                                          ctr.selectedBudgetIndex.value =
                                              (index + 1);
                                          ctr.selectedBudgetId.value =
                                              singleData.id.toString();
                                          ctr.selectedBudgetNumbder.value =
                                              singleData.number == '#0'
                                                  ? ''
                                                  : singleData.number ?? '';
                                          ctr.selectedBudgetName.value =
                                              index == 0
                                                  ? GetStorage().read('name')
                                                  : singleData.name ?? '';
                                          // debugPrint(
                                          //     ctr.selectedBudgetId.value);
                                          ctr
                                              .getHome(
                                                  singleData.id.toString(),
                                                  day == DateTime.now()
                                                      ? null
                                                      : day.toIso8601String(),
                                                  today == DateTime.now()
                                                      ? null
                                                      : today.toIso8601String())
                                              .then((value) {
                                            expenseTypes.clear();
                                            for (var expanse
                                                in ctr.expenseTypes) {
                                              // debugPrint(expanse.invoiceSumAmount.toString());
                                              if (expanse.invoiceSumAmount !=
                                                      null &&
                                                  expanse.invoiceSumAmount! >
                                                      0) {
                                                expenseTypes.add(expanse);
                                              }
                                            }
                                            if (mounted) {
                                              setState(() {});
                                            }
                                          });
                                        },
                                        child: Container(
                                          height:
                                              GetStorage().read("lang") == 'en'
                                                  ? 80
                                                  : 80,
                                          width:
                                              GetStorage().read("lang") == 'en'
                                                  ? 80
                                                  : 80,
                                          padding: const EdgeInsets.all(5),
                                          //margin: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            //borderRadius: BorderRadius.circular(50),
                                            border: Border.all(
                                                color: R.colors.blue, width: 3),
                                            color: R.colors.white,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                "${index == 0 ? GetStorage().read('name') : singleData.name ?? ''}\n${singleData.number == '#0' ? '' : singleData.number ?? ''}",
                                                style: const TextStyle(
                                                    fontSize: 14),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                })
                            : const SizedBox(
                                height: 80,
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),

                if (!kIsWeb) ...[
                  Expanded(
                      flex: 3,
                      child: expenseTypes.isNotEmpty
                          ? GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: kIsWeb == true
                                    ? Get.width > 750
                                        ? MediaQuery.of(context).size.width / 6
                                        : MediaQuery.of(context).size.width / 2
                                    : MediaQuery.of(context).size.width / 2,
                                childAspectRatio: 3,
                                mainAxisSpacing: 0,
                                crossAxisSpacing: 10,
                              ),
                              itemCount: expenseTypes.length,
                              itemBuilder: (context, index) {
                                var singleExpanse = expenseTypes[index];

                                return Obx(
                                  () => GestureDetector(
                                    onTap: () {
                                      Get.to(() => InvoiceMembersHomeListScreen(
                                            expanseId:
                                                singleExpanse.id.toString(),
                                            budgetId: ctr.selectedBudgetId.value
                                                .toString(),
                                          ));
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: Get.width,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: R.colors.blue,
                                                  width: 1),
                                              color: R.colors.white),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              if (singleExpanse.unviewInvoice !=
                                                      null &&
                                                  singleExpanse.unviewInvoice! >
                                                      0) ...[
                                                Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                              ],
                                              Text(
                                                ctr.currency.value,
                                                style: TextStyle(
                                                    color: R.colors.blue),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "${singleExpanse.invoiceSumAmount ?? 0}",
                                                style: TextStyle(
                                                    color: R.colors.blue),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          "${GetStorage().read("lang") == "en" ? singleExpanse.expenseName : singleExpanse.expenseNameAr}",
                                          style: TextStyle(
                                              color: R.colors.blackSecondery),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              })
                          : const SizedBox(
                              width: 60,
                              height: 50,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 69),
                              ))),
                  const SizedBox(
                    height: 15,
                  ),
                ],

                // -------------------------------------------------------------------------------------------------
                if (kIsWeb == true) ...[
                  Expanded(
                    // flex: 3,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          expenseTypes.isNotEmpty
                              ? GridView.builder(
                                  shrinkWrap: true,
                                  primary: false,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: kIsWeb == true
                                        ? Get.width > 750
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                6
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2
                                        : MediaQuery.of(context).size.width / 2,
                                    childAspectRatio: 3,
                                    mainAxisSpacing: 0,
                                    crossAxisSpacing: 10,
                                  ),
                                  itemCount: expenseTypes.length,
                                  itemBuilder: (context, index) {
                                    var singleExpanse = expenseTypes[index];

                                    return Obx(
                                      () => GestureDetector(
                                        onTap: () {
                                          Get.to(() =>
                                              InvoiceMembersHomeListScreen(
                                                expanseId:
                                                    singleExpanse.id.toString(),
                                                budgetId: ctr
                                                    .selectedBudgetId.value
                                                    .toString(),
                                              ));
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: Get.width,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: R.colors.blue,
                                                      width: 1),
                                                  color: R.colors.white),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  if (singleExpanse
                                                              .unviewInvoice !=
                                                          null &&
                                                      singleExpanse
                                                              .unviewInvoice! >
                                                          0) ...[
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                  ],
                                                  Text(
                                                    ctr.currency.value,
                                                    style: TextStyle(
                                                        color: R.colors.blue),
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "${singleExpanse.invoiceSumAmount ?? 0}",
                                                    style: TextStyle(
                                                        color: R.colors.blue),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            Text(
                                              "${GetStorage().read("lang") == "en" ? singleExpanse.expenseName : singleExpanse.expenseNameAr}",
                                              style: TextStyle(
                                                  color:
                                                      R.colors.blackSecondery),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                              : const SizedBox(
                                  width: 45,
                                  height: 45,
                                ),
                          const SizedBox(
                            height: 15,
                          ),
                          if (Get.width > 750)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: Get.width > 750
                                      ? Get.width * 0.3
                                      : Get.width * 0.40,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 60,
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: R.colors.grey,
                                                  width: 1)),
                                          child: GestureDetector(
                                            onTap: () {
                                              Get.bottomSheet(
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(20),
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
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () async {
                                                              debugPrint(
                                                                  "here");
                                                              await ctr.genrateReport(
                                                                  ctr.selectedBudgetId
                                                                      .value,
                                                                  day.toIso8601String(),
                                                                  today.toIso8601String());
                                                              //                                                              await invCtr.getInvoiceList('').then((value){
                                                              //   invoices = value;
                                                              //   return null;
                                                              // });
                                                              // debugPrint(invoices?.data.toString());
                                                              // Get.snackbar("enter func","",backgroundColor: R.colors.blue);
                                                              // debugPrint(invoices?.data?.length.toString());
                                                              final xcel
                                                                      .Workbook
                                                                  workbook =
                                                                  xcel.Workbook();
                                                              final xcel
                                                                      .Worksheet
                                                                  sheet =
                                                                  workbook
                                                                      .worksheets[0];
                                                              if (ctr
                                                                  .receivedInvoices!
                                                                  .isNotEmpty) {
                                                                // Get.snackbar("enter invoices","",backgroundColor: R.colors.blue);

                                                                sheet
                                                                    .getRangeByIndex(
                                                                        1, 1)
                                                                    .setText(
                                                                        "Inv number"
                                                                            .tr);
                                                                sheet
                                                                    .getRangeByIndex(
                                                                        1, 2)
                                                                    .setText(
                                                                        "Created at"
                                                                            .tr);
                                                                sheet
                                                                    .getRangeByIndex(
                                                                        1, 3)
                                                                    .setText(
                                                                        "Customer"
                                                                            .tr);
                                                                sheet
                                                                    .getRangeByIndex(
                                                                        1, 4)
                                                                    .setText(
                                                                        "Description"
                                                                            .tr);
                                                                sheet
                                                                    .getRangeByIndex(
                                                                        1, 5)
                                                                    .setText(
                                                                        "Amount"
                                                                            .tr);
                                                                for (var i = 0;
                                                                    i <
                                                                        ctr.receivedInvoices!
                                                                            .length;
                                                                    i++) {
                                                                  final item =
                                                                      ctr.receivedInvoices![
                                                                          i];
                                                                  var id =
                                                                      (ctr.receivedInvoices!.length -
                                                                              1) -
                                                                          i;
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          i + 2,
                                                                          1)
                                                                      .setText((id +
                                                                              1)
                                                                          .toString());
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          i + 2,
                                                                          2)
                                                                      .setText(item
                                                                          .createdDate
                                                                          .toString());
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          i + 2,
                                                                          3)
                                                                      .setText(item
                                                                          .customer
                                                                          ?.name
                                                                          .toString());
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          i + 2,
                                                                          4)
                                                                      .setText(
                                                                          item.note ??
                                                                              '');
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          i + 2,
                                                                          5)
                                                                      .setText(item
                                                                          .amount
                                                                          .toString());
                                                                }
                                                                var total = ctr
                                                                    .receivedInvoices!
                                                                    .fold(
                                                                        0,
                                                                        (sum, item) =>
                                                                            sum +
                                                                            int.parse(item.amount.toString()));
                                                                sheet
                                                                    .getRangeByIndex(
                                                                        ctr.receivedInvoices!.length +
                                                                            2,
                                                                        4)
                                                                    .setText(
                                                                        "Total"
                                                                            .tr);
                                                                sheet
                                                                    .getRangeByIndex(
                                                                        ctr.receivedInvoices!.length +
                                                                            2,
                                                                        5)
                                                                    .setText(total
                                                                        .toString());

                                                                if (ctr
                                                                    .sendInvoices!
                                                                    .isNotEmpty) {
                                                                  var ind = ctr
                                                                          .receivedInvoices!
                                                                          .length +
                                                                      6;
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          ind,
                                                                          1)
                                                                      .setText(
                                                                          "Inv number"
                                                                              .tr);
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          ind,
                                                                          2)
                                                                      .setText(
                                                                          "Created at"
                                                                              .tr);
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          ind,
                                                                          3)
                                                                      .setText(
                                                                          "Customer"
                                                                              .tr);
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          ind,
                                                                          4)
                                                                      .setText(
                                                                          "Description"
                                                                              .tr);
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          ind,
                                                                          5)
                                                                      .setText(
                                                                          "Amount"
                                                                              .tr);
                                                                  for (var i =
                                                                          0;
                                                                      i <
                                                                          ctr.sendInvoices!
                                                                              .length;
                                                                      i++) {
                                                                    final item =
                                                                        ctr.sendInvoices![
                                                                            i];
                                                                    var id =
                                                                        (ctr.sendInvoices!.length -
                                                                                1) -
                                                                            i;
                                                                    sheet
                                                                        .getRangeByIndex(
                                                                            i +
                                                                                2 +
                                                                                ind,
                                                                            1)
                                                                        .setText((id +
                                                                                1)
                                                                            .toString());
                                                                    sheet
                                                                        .getRangeByIndex(
                                                                            i +
                                                                                2 +
                                                                                ind,
                                                                            2)
                                                                        .setText(item
                                                                            .createdDate
                                                                            .toString());
                                                                    sheet
                                                                        .getRangeByIndex(
                                                                            i +
                                                                                2 +
                                                                                ind,
                                                                            3)
                                                                        .setText(item
                                                                            .customer
                                                                            ?.name
                                                                            .toString());
                                                                    sheet
                                                                        .getRangeByIndex(
                                                                            i +
                                                                                2 +
                                                                                ind,
                                                                            4)
                                                                        .setText(item.note ??
                                                                            '');
                                                                    sheet
                                                                        .getRangeByIndex(
                                                                            i +
                                                                                2 +
                                                                                ind,
                                                                            5)
                                                                        .setText(item
                                                                            .amount
                                                                            .toString());
                                                                  }
                                                                  var total = ctr
                                                                      .sendInvoices!
                                                                      .fold(
                                                                          0,
                                                                          (sum, item) =>
                                                                              sum +
                                                                              int.parse(item.amount.toString()));
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          ctr.sendInvoices!.length +
                                                                              2 +
                                                                              ind,
                                                                          4)
                                                                      .setText(
                                                                          "Total"
                                                                              .tr);
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          ctr.sendInvoices!.length +
                                                                              2 +
                                                                              ind,
                                                                          5)
                                                                      .setText(total
                                                                          .toString());
                                                                }
                                                                final List<int>
                                                                    bytes =
                                                                    workbook
                                                                        .saveAsStream();
                                                                workbook
                                                                    .dispose();
                                                                //  FileStorage.writeCounter(bytes, "geeksforgeeks.xlsx", context);
                                                                AnchorElement(
                                                                    href:
                                                                        'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
                                                                  ..setAttribute(
                                                                      'download',
                                                                      'report.xlsx')
                                                                  ..click();

                                                                Get.back();
                                                              }
                                                            },
                                                            child: Image.asset(
                                                              R.images
                                                                  .excelIcon,
                                                              width: 60,
                                                              height: 60,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 20,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              // debugPrint("here");
                                                              await ctr.genrateReport(
                                                                  ctr.selectedBudgetId
                                                                      .value,
                                                                  day.toIso8601String(),
                                                                  today.toIso8601String());
                                                              // print(ctr.receivedInvoices.toString());
                                                              //                                                              await invCtr.getInvoiceList('').then((value){
                                                              //   invoices = value;
                                                              //   return null;
                                                              // });
                                                              // debugPrint(invoices?.data.toString());
                                                              // Get.snackbar("enter func","",backgroundColor: R.colors.blue);
                                                              // A Suls Regular.ttf
                                                              var total = ctr
                                                                  .receivedInvoices
                                                                  ?.fold(
                                                                      0,
                                                                      (sum, item) =>
                                                                          sum +
                                                                          int.parse(item
                                                                              .amount
                                                                              .toString()));
                                                              var total2 = ctr
                                                                  .sendInvoices
                                                                  ?.fold(
                                                                      0,
                                                                      (sum, item) =>
                                                                          sum +
                                                                          int.parse(item
                                                                              .amount
                                                                              .toString()));
                                                              final font =
                                                                  await rootBundle
                                                                      .load(
                                                                          "assets/fonts/arabic.ttf");
                                                              final ttf =
                                                                  pw.Font.ttf(
                                                                      font);
                                                              // final data = await rootBundle.load("assets/fonts/arabic.ttf");

                                                              //   final  dataint = data.buffer.asUint8List(data.offsetInBytes,data.lengthInBytes);

                                                              //   final  PdfFont  font  =  pw.PdfTrueTypeFont (date,12);
                                                              final pdf =
                                                                  pw.Document();
                                                              if (ctr
                                                                  .receivedInvoices!
                                                                  .isNotEmpty) {
                                                                // Get.snackbar("enter invoices","",backgroundColor: R.colors.blue);

                                                                pdf.addPage(pw
                                                                    .MultiPage(
                                                                        pageFormat:
                                                                            PdfPageFormat
                                                                                .a4,
                                                                        theme: pw.ThemeData
                                                                            .withFont(
                                                                          base:
                                                                              ttf,
                                                                        ),
                                                                        build: (pw.Context
                                                                            context) {
                                                                          return <pw
                                                                              .Widget>[
                                                                            pw.Table(children: [
                                                                              pw.TableRow(children: [
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    "Inv number".tr,
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  )
                                                                                ]),
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    "Created at".tr.toString(),
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  ),
                                                                                ]),
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    "Customer".tr.toString(),
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  ),
                                                                                ]),
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    "Description".tr.toString(),
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  ),
                                                                                ]),
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    "Amount".tr.toString(),
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  ),
                                                                                ]),
                                                                              ]),
                                                                              for (var i = 0; i < ctr.receivedInvoices!.length; i++)
                                                                                pw.TableRow(children: [
                                                                                  pw.Column(children: [
                                                                                    pw.Text("${((ctr.receivedInvoices!.length - 1) - i + 1)}"),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(ctr.receivedInvoices![i].createdDate.toString()),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(ctr.receivedInvoices![i].customer?.name.toString() ?? '', textDirection: pw.TextDirection.rtl),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(ctr.receivedInvoices![i].note ?? ''),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(ctr.receivedInvoices![i].amount.toString()),
                                                                                  ]),
                                                                                ]),
                                                                              pw.TableRow(children: [
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    "",
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  )
                                                                                ]),
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    "",
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  ),
                                                                                ]),
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    "",
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  ),
                                                                                ]),
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    "Total".tr.toString(),
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  ),
                                                                                ]),
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    total.toString(),
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  ),
                                                                                ]),
                                                                              ]),
                                                                            ]),
                                                                            //  pw.Table(children: <>)
                                                                          ]; // Center
                                                                        })); // Page
                                                                if (ctr
                                                                    .sendInvoices!
                                                                    .isNotEmpty) {
                                                                  pdf.addPage(pw
                                                                      .MultiPage(
                                                                          pageFormat: PdfPageFormat
                                                                              .a4,
                                                                          theme: pw.ThemeData
                                                                              .withFont(
                                                                            base:
                                                                                ttf,
                                                                          ),
                                                                          build:
                                                                              (pw.Context context) {
                                                                            return <pw.Widget>[
                                                                              pw.Table(children: [
                                                                                pw.TableRow(children: [
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      "Inv number".tr,
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    )
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      "Created at".tr.toString(),
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    ),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      "Customer".tr.toString(),
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    ),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      "Description".tr.toString(),
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    ),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      "Amount".tr.toString(),
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    ),
                                                                                  ]),
                                                                                ]),
                                                                                for (var i = 0; i < ctr.sendInvoices!.length; i++)
                                                                                  pw.TableRow(children: [
                                                                                    pw.Column(children: [
                                                                                      pw.Text("${((ctr.sendInvoices!.length - 1) - i + 1)}"),
                                                                                    ]),
                                                                                    pw.Column(children: [
                                                                                      pw.Text(ctr.sendInvoices![i].createdDate.toString()),
                                                                                    ]),
                                                                                    pw.Column(children: [
                                                                                      pw.Text(ctr.sendInvoices![i].customer?.name.toString() ?? '', textDirection: pw.TextDirection.rtl),
                                                                                    ]),
                                                                                    pw.Column(children: [
                                                                                      pw.Text(ctr.sendInvoices![i].note ?? ''),
                                                                                    ]),
                                                                                    pw.Column(children: [
                                                                                      pw.Text(ctr.sendInvoices![i].amount.toString()),
                                                                                    ]),
                                                                                  ]),
                                                                                pw.TableRow(children: [
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      "",
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    )
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      "",
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    ),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      "",
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    ),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      "Total".tr.toString(),
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    ),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      total2.toString(),
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    ),
                                                                                  ]),
                                                                                ]),
                                                                              ]),
                                                                              //  pw.Table(children: <>)
                                                                            ]; // Center
                                                                          }));
                                                                }
                                                                List<int>
                                                                    bytes =
                                                                    await pdf
                                                                        .save();
                                                                AnchorElement(
                                                                    href:
                                                                        'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
                                                                  ..setAttribute(
                                                                      'download',
                                                                      'report.pdf')
                                                                  ..click();

                                                                Get.back();
                                                              }
                                                            },
                                                            child: Image.asset(
                                                              R.images.pdfIcon,
                                                              width: 60,
                                                              height: 60,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  R.images.icon1,
                                                  width: 20,
                                                  height: 20,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    'Share Report'.tr,
                                                    style: TextStyle(
                                                        color: R.colors.black,
                                                        fontSize: 10),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 60,
                                          // width: Get.width * 0.25,
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: R.colors.grey,
                                                  width: 1)),
                                          child: GestureDetector(
                                            onTap: () {
                                              _shareQrCode();
                                            },
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  R.images.icon3,
                                                  width: 20,
                                                  height: 20,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    'Share QR code'.tr,
                                                    style: TextStyle(
                                                        color: R.colors.black,
                                                        fontSize: 10),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width: Get.width > 750
                                      ? Get.width * 0.3
                                      : Get.width * 0.50,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: R.colors.grey, width: 1)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            R.images.icon2,
                                            width: 25,
                                            height: 25,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Total Invoices Yearly'.tr,
                                                    style: TextStyle(
                                                        color: R.colors.black,
                                                        fontSize: 12),
                                                  ),
                                                  Text(
                                                    " : ${ctr.totalInvoicesYearly}",
                                                    style: TextStyle(
                                                        color: R.colors.black,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Total Expenses Yearly'.tr,
                                                    style: TextStyle(
                                                        color: R.colors.black,
                                                        fontSize: 12),
                                                  ),
                                                  Text(
                                                    " : ${ctr.totalExpansesYearly}",
                                                    style: TextStyle(
                                                        color: R.colors.black,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Get.bottomSheet(
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                  color: R.colors.white,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10))),
                                              child: Column(children: [
                                                Expanded(
                                                    child:
                                                        SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                Text("From".tr),
                                                          ),
                                                          const SizedBox(
                                                            width: 20,
                                                          ),
                                                          Expanded(
                                                            child:
                                                                Text("To".tr),
                                                          ),
                                                        ],
                                                      ),

                                                      // Text("Day".tr),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(child:
                                                              StatefulBuilder(
                                                            builder: (BuildContext
                                                                    context,
                                                                StateSetter
                                                                    setState) {
                                                              return GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  DateTime?
                                                                      pickedDate =
                                                                      await showDatePicker(
                                                                          context:
                                                                              context,
                                                                          initialDate:
                                                                              day,
                                                                          firstDate: DateTime(
                                                                              1950),
                                                                          //DateTime.now() - not to allow to choose before today.
                                                                          lastDate:
                                                                              DateTime.now());

                                                                  if (pickedDate !=
                                                                      null) {
                                                                    day =
                                                                        pickedDate;
                                                                    setState(
                                                                        () {});
                                                                    // Get.back();
                                                                    ctr
                                                                        .getHome(
                                                                            ctr.selectedBudgetId
                                                                                .value,
                                                                            day == DateTime.now()
                                                                                ? null
                                                                                : day.toIso8601String(),
                                                                            today == DateTime.now() ? null : today.toIso8601String())
                                                                        .then((value) {
                                                                      expenseTypes
                                                                          .clear();
                                                                      for (var expanse
                                                                          in ctr
                                                                              .expenseTypes) {
                                                                        // debugPrint(expanse.invoiceSumAmount.toString());
                                                                        if (expanse.invoiceSumAmount !=
                                                                                null &&
                                                                            expanse.invoiceSumAmount! >
                                                                                0) {
                                                                          expenseTypes
                                                                              .add(expanse);
                                                                        }
                                                                      }
                                                                    });
                                                                  }
                                                                },
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(8),
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: R
                                                                              .colors
                                                                              .black,
                                                                          width:
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                          "${day.day}-${day.month}-${day.year}"),
                                                                      Icon(
                                                                        Icons
                                                                            .arrow_drop_down,
                                                                        color: R
                                                                            .colors
                                                                            .black,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          )),
                                                          const SizedBox(
                                                            width: 20,
                                                          ),
                                                          Expanded(child:
                                                              StatefulBuilder(
                                                            builder: (BuildContext
                                                                    context,
                                                                StateSetter
                                                                    setState) {
                                                              return GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  DateTime?
                                                                      pickedDate =
                                                                      await showDatePicker(
                                                                          context:
                                                                              context,
                                                                          initialDate:
                                                                              today,
                                                                          firstDate: DateTime(
                                                                              1950),
                                                                          //DateTime.now() - not to allow to choose before today.
                                                                          lastDate:
                                                                              DateTime.now());

                                                                  if (pickedDate !=
                                                                      null) {
                                                                    setState(
                                                                        () {});
                                                                    today =
                                                                        pickedDate;

                                                                    // Get.back();
                                                                    ctr
                                                                        .getHome(
                                                                            ctr.selectedBudgetId
                                                                                .value,
                                                                            day == DateTime.now()
                                                                                ? null
                                                                                : day.toIso8601String(),
                                                                            today == DateTime.now() ? null : today.toIso8601String())
                                                                        .then((value) {
                                                                      expenseTypes
                                                                          .clear();
                                                                      for (var expanse
                                                                          in ctr
                                                                              .expenseTypes) {
                                                                        // debugPrint(expanse.invoiceSumAmount.toString());
                                                                        if (expanse.invoiceSumAmount !=
                                                                                null &&
                                                                            expanse.invoiceSumAmount! >
                                                                                0) {
                                                                          expenseTypes
                                                                              .add(expanse);
                                                                        }
                                                                      }
                                                                    });
                                                                  }
                                                                },
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(8),
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: R
                                                                              .colors
                                                                              .black,
                                                                          width:
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                          "${today.day}-${today.month}-${today.year}"),
                                                                      Icon(
                                                                        Icons
                                                                            .arrow_drop_down,
                                                                        color: R
                                                                            .colors
                                                                            .black,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          )),
                                                        ],
                                                      ),
                                                      //                                               SizedBox(height: 10,),

                                                      //                                               const SizedBox(height: 10,),
                                                      //                                               Text("Month".tr),
                                                      //                                               const SizedBox(height: 10,),
                                                      //                                               Row(
                                                      //                                                 children: [
                                                      //                                                   Expanded(
                                                      //                                                     child: StatefulBuilder(builder: ( BuildContext context, StateSetter setState) {
                                                      //                                                       return GestureDetector(
                                                      //                                                       onTap: () async {
                                                      //                                                      final selected = await showMonthPicker(
                                                      //                                                         context: context,
                                                      //                                                         initialDate: month,
                                                      //                                                         firstDate: DateTime(1970),
                                                      //                                                         lastDate: DateTime(2050)
                                                      //                                                       );                                                if(selected != null){

                                                      //                                                         month = selected;
                                                      //                                                         setState(() {

                                                      //                                                                         });
                                                      //                                                       }
                                                      //                                                       // Get.back();
                                                      //                                                                         ctr.getHome(ctr.selectedBudgetId.value, day.day == DateTime.now().day ? null : day.day, month.month == DateTime.now().month ? null : month.month, date.year == DateTime.now().year ? null : date.year ,today.day == DateTime.now().day ? null : today.day, tomonth.month == DateTime.now().month ? null : tomonth.month, todate.year == DateTime.now().year ? null : todate.year).then((value){
                                                      //                                                                           expenseTypes.clear();
                                                      //                                                          for (var expanse in ctr.expenseTypes) {
                                                      //                                                           // debugPrint(expanse.invoiceSumAmount.toString());
                                                      //                                                         if (expanse.invoiceSumAmount != null && expanse.invoiceSumAmount! > 0 ) {
                                                      //                                                           expenseTypes.add(expanse);
                                                      //                                                         }
                                                      //                                                       }

                                                      //                                                                         });

                                                      //                                                       },
                                                      //                                                       child:  Container(
                                                      //                                                         padding: const EdgeInsets.all(8),
                                                      //                                                         decoration: BoxDecoration(
                                                      //                                                           border: Border.all(color: R.colors.black,width: 1),
                                                      //                                                           borderRadius: BorderRadius.circular(10)
                                                      //                                                         ),
                                                      //                                                         child: Row(
                                                      //                                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      //                                                           children: [
                                                      //                                                             Text("${month.month}"),
                                                      //                                                             Icon(Icons.arrow_drop_down,color: R.colors.black,),
                                                      //                                                           ],
                                                      //                                                         ),
                                                      //                                                       ),
                                                      //                                                     );
                                                      //                                                     },)
                                                      //                                                   ),
                                                      //                                                   SizedBox(width: 20,),
                                                      //                                                   Expanded(
                                                      //                                                 child: StatefulBuilder(builder: ( BuildContext context, StateSetter setState) {
                                                      //                                                   return GestureDetector(
                                                      //                                                   onTap: () async {
                                                      //                                                  final selected = await showMonthPicker(
                                                      //                                                     context: context,
                                                      //                                                     initialDate: tomonth,
                                                      //                                                     firstDate: DateTime(1970),
                                                      //                                                     lastDate: DateTime(2050)
                                                      //                                                   );                                                if(selected != null){

                                                      //                                                     tomonth = selected;
                                                      //                                                     setState(() {

                                                      //                                                                         });
                                                      //                                                   }
                                                      //                                                   // Get.back();
                                                      //                                                                     ctr.getHome(ctr.selectedBudgetId.value, day.day == DateTime.now().day ? null : day.day, month.month == DateTime.now().month ? null : month.month, date.year == DateTime.now().year ? null : date.year ,today.day == DateTime.now().day ? null : today.day, tomonth.month == DateTime.now().month ? null : tomonth.month, todate.year == DateTime.now().year ? null : todate.year).then((value){
                                                      //                                                                       expenseTypes.clear();
                                                      //                                                      for (var expanse in ctr.expenseTypes) {
                                                      //                                                       // debugPrint(expanse.invoiceSumAmount.toString());
                                                      //                                                     if (expanse.invoiceSumAmount != null && expanse.invoiceSumAmount! > 0 ) {
                                                      //                                                       expenseTypes.add(expanse);
                                                      //                                                     }
                                                      //                                                   }

                                                      //                                                                     });

                                                      //                                                   },
                                                      //                                                   child:  Container(
                                                      //                                                     padding: const EdgeInsets.all(8),
                                                      //                                                     decoration: BoxDecoration(
                                                      //                                                       border: Border.all(color: R.colors.black,width: 1),
                                                      //                                                       borderRadius: BorderRadius.circular(10)
                                                      //                                                     ),
                                                      //                                                     child: Row(
                                                      //                                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      //                                                       children: [
                                                      //                                                         Text("${tomonth.month}"),
                                                      //                                                         Icon(Icons.arrow_drop_down,color: R.colors.black,),
                                                      //                                                       ],
                                                      //                                                     ),
                                                      //                                                   ),
                                                      //                                                 );
                                                      //                                                 },)
                                                      //                                               ),
                                                      //                                                 ],
                                                      //                                               ),
                                                      //                                               SizedBox(height: 10,),

                                                      // //
                                                      //                                               Text("Year".tr),
                                                      //                                               const SizedBox(height: 10,),
                                                      //                                               Row(
                                                      //                                                 children: [
                                                      //                                                   Expanded(
                                                      //                                                     child: StatefulBuilder(builder: ( BuildContext context, StateSetter setState) {
                                                      //                                                       return GestureDetector(
                                                      //                                                       onTap: () async {
                                                      //                                                        showDialog(
                                                      //                                                           context: context,
                                                      //                                                           builder: (BuildContext context) {

                                                      //                                                             return AlertDialog(
                                                      //                                                               // title: Text("Select Year"),
                                                      //                                                               content: Container( // Need to use container to add size constraint.
                                                      //                                                                 width: 300,
                                                      //                                                                 height: 300,
                                                      //                                                                 child: YearPicker(
                                                      //                                                                   firstDate: DateTime(DateTime.now().year - 100, 1),
                                                      //                                                                   lastDate: DateTime(DateTime.now().year , 1),
                                                      //                                                                   initialDate: DateTime.now(),
                                                      //                                                                   // save the selected date to _selectedDate DateTime variable.
                                                      //                                                                   // It's used to set the previous selected date when
                                                      //                                                                   // re-showing the dialog.
                                                      //                                                                   selectedDate: date,
                                                      //                                                                   onChanged: (DateTime dateTime) {
                                                      //                                                                     // close the dialog when year is selected.

                                                      //                                                                       date = dateTime;

                                                      //                                                                     Navigator.pop(context);
                                                      //                                                       setState(() {

                                                      //                                                                         });
                                                      //                                                                     // Get.back();
                                                      //                                                                         ctr.getHome(ctr.selectedBudgetId.value, day.day == DateTime.now().day ? null : day.day, month.month == DateTime.now().month ? null : month.month, date.year == DateTime.now().year ? null : date.year ,today.day == DateTime.now().day ? null : today.day, tomonth.month == DateTime.now().month ? null : tomonth.month, todate.year == DateTime.now().year ? null : todate.year).then((value){
                                                      //                                                                           expenseTypes.clear();
                                                      //                                                          for (var expanse in ctr.expenseTypes) {
                                                      //                                                           // debugPrint(expanse.invoiceSumAmount.toString());
                                                      //                                                         if (expanse.invoiceSumAmount != null && expanse.invoiceSumAmount! > 0 ) {
                                                      //                                                           expenseTypes.add(expanse);
                                                      //                                                         }
                                                      //                                                       }

                                                      //                                                                         });

                                                      //                                                                     // Do something with the dateTime selected.
                                                      //                                                                     // Remember that you need to use dateTime.year to get the year
                                                      //                                                                   },
                                                      //                                                                 ),
                                                      //                                                               ),
                                                      //                                                             );
                                                      //                                                           },
                                                      //                                                         );

                                                      //                                                       },
                                                      //                                                       child:  Container(
                                                      //                                                         padding: const EdgeInsets.all(8),
                                                      //                                                         decoration: BoxDecoration(
                                                      //                                                           border: Border.all(color: R.colors.black,width: 1),
                                                      //                                                           borderRadius: BorderRadius.circular(10)
                                                      //                                                         ),
                                                      //                                                         child: Row(
                                                      //                                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      //                                                           children: [
                                                      //                                                             Text("${date.year}".tr),
                                                      //                                                             Icon(Icons.arrow_drop_down,color: R.colors.black,),
                                                      //                                                           ],
                                                      //                                                         ),
                                                      //                                                       ),
                                                      //                                                     );
                                                      //                                                     },)
                                                      //                                                   ),
                                                      //                                                   SizedBox(width: 20,),
                                                      //                                                     Expanded(
                                                      //                                                 child: StatefulBuilder(builder: ( BuildContext context, StateSetter setState) {
                                                      //                                                   return GestureDetector(
                                                      //                                                   onTap: () async {
                                                      //                                                    showDialog(
                                                      //                                                       context: context,
                                                      //                                                       builder: (BuildContext context) {

                                                      //                                                         return AlertDialog(
                                                      //                                                           // title: Text("Select Year"),
                                                      //                                                           content: Container( // Need to use container to add size constraint.
                                                      //                                                             width: 300,
                                                      //                                                             height: 300,
                                                      //                                                             child: YearPicker(
                                                      //                                                               firstDate: DateTime(DateTime.now().year - 100, 1),
                                                      //                                                               lastDate: DateTime(DateTime.now().year , 1),
                                                      //                                                               initialDate: DateTime.now(),
                                                      //                                                               // save the selected date to _selectedDate DateTime variable.
                                                      //                                                               // It's used to set the previous selected date when
                                                      //                                                               // re-showing the dialog.
                                                      //                                                               selectedDate: todate,
                                                      //                                                               onChanged: (DateTime dateTime) {
                                                      //                                                                 // close the dialog when year is selected.

                                                      //                                                                   todate = dateTime;
                                                      //                                                                 setState(() {

                                                      //                                                                         });
                                                      //                                                                 Navigator.pop(context);

                                                      //                                                                 // Get.back();
                                                      //                                                                     ctr.getHome(ctr.selectedBudgetId.value, day.day == DateTime.now().day ? null : day.day, month.month == DateTime.now().month ? null : month.month, date.year == DateTime.now().year ? null : date.year ,today.day == DateTime.now().day ? null : today.day, tomonth.month == DateTime.now().month ? null : tomonth.month, todate.year == DateTime.now().year ? null : todate.year).then((value){
                                                      //                                                                       expenseTypes.clear();
                                                      //                                                      for (var expanse in ctr.expenseTypes) {
                                                      //                                                       // debugPrint(expanse.invoiceSumAmount.toString());
                                                      //                                                     if (expanse.invoiceSumAmount != null && expanse.invoiceSumAmount! > 0 ) {
                                                      //                                                       expenseTypes.add(expanse);
                                                      //                                                     }
                                                      //                                                   }

                                                      //                                                                     });

                                                      //                                                                 // Do something with the dateTime selected.
                                                      //                                                                 // Remember that you need to use dateTime.year to get the year
                                                      //                                                               },
                                                      //                                                             ),
                                                      //                                                           ),
                                                      //                                                         );
                                                      //                                                       },
                                                      //                                                     );

                                                      //                                                   },
                                                      //                                                   child:  Container(
                                                      //                                                     padding: const EdgeInsets.all(8),
                                                      //                                                     decoration: BoxDecoration(
                                                      //                                                       border: Border.all(color: R.colors.black,width: 1),
                                                      //                                                       borderRadius: BorderRadius.circular(10)
                                                      //                                                     ),
                                                      //                                                     child: Row(
                                                      //                                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      //                                                       children: [
                                                      //                                                         Text("${todate.year}".tr),
                                                      //                                                         Icon(Icons.arrow_drop_down,color: R.colors.black,),
                                                      //                                                       ],
                                                      //                                                     ),
                                                      //                                                   ),
                                                      //                                                 );
                                                      //                                                 },)
                                                      //                                               ),
                                                      //                                                 ],
                                                      //                                               ),

                                                      const SizedBox(
                                                        height: 20,
                                                      ),

                                                      Row(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              // print(GetStorage().read("user_token"));

                                                              ctr
                                                                  .getHome(
                                                                      ctr.selectedBudgetId
                                                                          .value,
                                                                      day == DateTime.now()
                                                                          ? null
                                                                          : day
                                                                              .toIso8601String(),
                                                                      today == DateTime.now()
                                                                          ? null
                                                                          : today
                                                                              .toIso8601String())
                                                                  .then(
                                                                      (value) {
                                                                expenseTypes
                                                                    .clear();
                                                                for (var expanse
                                                                    in ctr
                                                                        .expenseTypes) {
                                                                  // debugPrint(expanse.invoiceSumAmount.toString());
                                                                  if (expanse.invoiceSumAmount !=
                                                                          null &&
                                                                      expanse.invoiceSumAmount! >
                                                                          0) {
                                                                    expenseTypes
                                                                        .add(
                                                                            expanse);
                                                                  }
                                                                }
                                                                Get.back();
                                                              });
                                                            },
                                                            child: Container(
                                                              width: 100,
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 10),
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  color: R
                                                                      .colors
                                                                      .blue),
                                                              child: Center(
                                                                child: Text(
                                                                    'Show'.tr),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              // print(GetStorage().read("user_token"));
                                                              Get.back();
                                                              setState(() {
                                                                date = DateTime
                                                                    .now();
                                                                todate =
                                                                    DateTime
                                                                        .now();
                                                                month = DateTime
                                                                    .now();
                                                                tomonth =
                                                                    DateTime
                                                                        .now();
                                                                day = DateTime
                                                                    .now();
                                                                today = DateTime
                                                                    .now();
                                                              });
                                                              ctr
                                                                  .getHome(
                                                                      ctr.selectedBudgetId
                                                                          .value,
                                                                      null,
                                                                      null)
                                                                  .then(
                                                                      (value) {
                                                                expenseTypes
                                                                    .clear();
                                                                for (var expanse
                                                                    in ctr
                                                                        .expenseTypes) {
                                                                  // debugPrint(expanse.invoiceSumAmount.toString());
                                                                  if (expanse.invoiceSumAmount !=
                                                                          null &&
                                                                      expanse.invoiceSumAmount! >
                                                                          0) {
                                                                    expenseTypes
                                                                        .add(
                                                                            expanse);
                                                                  }
                                                                }
                                                              });
                                                            },
                                                            child: Container(
                                                              width: 100,
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 10),
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  color: R
                                                                      .colors
                                                                      .blue),
                                                              child: Center(
                                                                child: Text(
                                                                    'Reset'.tr),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ))
                                              ]),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 50,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: R.colors.lightBlue3,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Text(ctr.expanse.value,style: TextStyle(color: R.colors.black),),
                                              Icon(
                                                Icons.search,
                                                color: R.colors.black,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          if (Get.width <= 750)
                            Column(
                              children: [
                                SizedBox(
                                  width: Get.width,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 60,
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: R.colors.grey,
                                                  width: 1)),
                                          child: GestureDetector(
                                            onTap: () {
                                              Get.bottomSheet(
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(20),
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
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () async {
                                                              // debugPrint("here");
                                                              await ctr.genrateReport(
                                                                  ctr.selectedBudgetId
                                                                      .value,
                                                                  day.toIso8601String(),
                                                                  today.toIso8601String());
                                                              //                                                              await invCtr.getInvoiceList('').then((value){
                                                              //   invoices = value;
                                                              //   return null;
                                                              // });
                                                              // debugPrint(invoices?.data.toString());
                                                              // Get.snackbar("enter func","",backgroundColor: R.colors.blue);
                                                              // debugPrint(invoices?.data?.length.toString());
                                                              final xcel
                                                                      .Workbook
                                                                  workbook =
                                                                  xcel.Workbook();
                                                              final xcel
                                                                      .Worksheet
                                                                  sheet =
                                                                  workbook
                                                                      .worksheets[0];
                                                              if (ctr
                                                                  .receivedInvoices!
                                                                  .isNotEmpty) {
                                                                // Get.snackbar("enter invoices","",backgroundColor: R.colors.blue);

                                                                sheet
                                                                    .getRangeByIndex(
                                                                        1, 1)
                                                                    .setText(
                                                                        "Inv number"
                                                                            .tr);
                                                                sheet
                                                                    .getRangeByIndex(
                                                                        1, 2)
                                                                    .setText(
                                                                        "Created at"
                                                                            .tr);
                                                                sheet
                                                                    .getRangeByIndex(
                                                                        1, 3)
                                                                    .setText(
                                                                        "Customer"
                                                                            .tr);
                                                                sheet
                                                                    .getRangeByIndex(
                                                                        1, 4)
                                                                    .setText(
                                                                        "Description"
                                                                            .tr);
                                                                sheet
                                                                    .getRangeByIndex(
                                                                        1, 5)
                                                                    .setText(
                                                                        "Amount"
                                                                            .tr);
                                                                for (var i = 0;
                                                                    i <
                                                                        ctr.receivedInvoices!
                                                                            .length;
                                                                    i++) {
                                                                  final item =
                                                                      ctr.receivedInvoices![
                                                                          i];
                                                                  var id =
                                                                      (ctr.receivedInvoices!.length -
                                                                              1) -
                                                                          i;
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          i + 2,
                                                                          1)
                                                                      .setText((id +
                                                                              1)
                                                                          .toString());
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          i + 2,
                                                                          2)
                                                                      .setText(item
                                                                          .createdDate
                                                                          .toString());
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          i + 2,
                                                                          3)
                                                                      .setText(item
                                                                          .customer
                                                                          ?.name
                                                                          .toString());
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          i + 2,
                                                                          4)
                                                                      .setText(
                                                                          item.note ??
                                                                              '');
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          i + 2,
                                                                          5)
                                                                      .setText(item
                                                                          .amount
                                                                          .toString());
                                                                }
                                                                var total = ctr
                                                                    .receivedInvoices!
                                                                    .fold(
                                                                        0,
                                                                        (sum, item) =>
                                                                            sum +
                                                                            int.parse(item.amount.toString()));
                                                                sheet
                                                                    .getRangeByIndex(
                                                                        ctr.receivedInvoices!.length +
                                                                            2,
                                                                        4)
                                                                    .setText(
                                                                        "Total"
                                                                            .tr);
                                                                sheet
                                                                    .getRangeByIndex(
                                                                        ctr.receivedInvoices!.length +
                                                                            2,
                                                                        5)
                                                                    .setText(total
                                                                        .toString());

                                                                if (ctr
                                                                    .sendInvoices!
                                                                    .isNotEmpty) {
                                                                  var ind = ctr
                                                                          .receivedInvoices!
                                                                          .length +
                                                                      6;
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          ind,
                                                                          1)
                                                                      .setText(
                                                                          "Inv number"
                                                                              .tr);
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          ind,
                                                                          2)
                                                                      .setText(
                                                                          "Created at"
                                                                              .tr);
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          ind,
                                                                          3)
                                                                      .setText(
                                                                          "Customer"
                                                                              .tr);
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          ind,
                                                                          4)
                                                                      .setText(
                                                                          "Description"
                                                                              .tr);
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          ind,
                                                                          5)
                                                                      .setText(
                                                                          "Amount"
                                                                              .tr);
                                                                  for (var i =
                                                                          0;
                                                                      i <
                                                                          ctr.sendInvoices!
                                                                              .length;
                                                                      i++) {
                                                                    final item =
                                                                        ctr.sendInvoices![
                                                                            i];
                                                                    var id =
                                                                        (ctr.sendInvoices!.length -
                                                                                1) -
                                                                            i;
                                                                    sheet
                                                                        .getRangeByIndex(
                                                                            i +
                                                                                2 +
                                                                                ind,
                                                                            1)
                                                                        .setText((id +
                                                                                1)
                                                                            .toString());
                                                                    sheet
                                                                        .getRangeByIndex(
                                                                            i +
                                                                                2 +
                                                                                ind,
                                                                            2)
                                                                        .setText(item
                                                                            .createdDate
                                                                            .toString());
                                                                    sheet
                                                                        .getRangeByIndex(
                                                                            i +
                                                                                2 +
                                                                                ind,
                                                                            3)
                                                                        .setText(item
                                                                            .customer
                                                                            ?.name
                                                                            .toString());
                                                                    sheet
                                                                        .getRangeByIndex(
                                                                            i +
                                                                                2 +
                                                                                ind,
                                                                            4)
                                                                        .setText(item.note ??
                                                                            '');
                                                                    sheet
                                                                        .getRangeByIndex(
                                                                            i +
                                                                                2 +
                                                                                ind,
                                                                            5)
                                                                        .setText(item
                                                                            .amount
                                                                            .toString());
                                                                  }
                                                                  var total = ctr
                                                                      .sendInvoices!
                                                                      .fold(
                                                                          0,
                                                                          (sum, item) =>
                                                                              sum +
                                                                              int.parse(item.amount.toString()));
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          ctr.sendInvoices!.length +
                                                                              2 +
                                                                              ind,
                                                                          4)
                                                                      .setText(
                                                                          "Total"
                                                                              .tr);
                                                                  sheet
                                                                      .getRangeByIndex(
                                                                          ctr.sendInvoices!.length +
                                                                              2 +
                                                                              ind,
                                                                          5)
                                                                      .setText(total
                                                                          .toString());
                                                                }
                                                                final List<int>
                                                                    bytes =
                                                                    workbook
                                                                        .saveAsStream();
                                                                workbook
                                                                    .dispose();
                                                                //  FileStorage.writeCounter(bytes, "geeksforgeeks.xlsx", context);
                                                                AnchorElement(
                                                                    href:
                                                                        'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
                                                                  ..setAttribute(
                                                                      'download',
                                                                      'report.xlsx')
                                                                  ..click();

                                                                Get.back();
                                                              }
                                                            },
                                                            child: Image.asset(
                                                              R.images
                                                                  .excelIcon,
                                                              width: 60,
                                                              height: 60,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 20,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              // debugPrint("here");
                                                              await ctr.genrateReport(
                                                                  ctr.selectedBudgetId
                                                                      .value,
                                                                  day.toIso8601String(),
                                                                  today.toIso8601String());
                                                              // print(ctr.receivedInvoices.toString());
                                                              //                                                              await invCtr.getInvoiceList('').then((value){
                                                              //   invoices = value;
                                                              //   return null;
                                                              // });
                                                              // debugPrint(invoices?.data.toString());
                                                              // Get.snackbar("enter func","",backgroundColor: R.colors.blue);
                                                              // A Suls Regular.ttf
                                                              var total = ctr
                                                                  .receivedInvoices
                                                                  ?.fold(
                                                                      0,
                                                                      (sum, item) =>
                                                                          sum +
                                                                          int.parse(item
                                                                              .amount
                                                                              .toString()));
                                                              var total2 = ctr
                                                                  .sendInvoices
                                                                  ?.fold(
                                                                      0,
                                                                      (sum, item) =>
                                                                          sum +
                                                                          int.parse(item
                                                                              .amount
                                                                              .toString()));
                                                              final font =
                                                                  await rootBundle
                                                                      .load(
                                                                          "assets/fonts/arabic.ttf");
                                                              final ttf =
                                                                  pw.Font.ttf(
                                                                      font);
                                                              // final data = await rootBundle.load("assets/fonts/arabic.ttf");

                                                              //   final  dataint = data.buffer.asUint8List(data.offsetInBytes,data.lengthInBytes);

                                                              //   final  PdfFont  font  =  pw.PdfTrueTypeFont (date,12);
                                                              final pdf =
                                                                  pw.Document();
                                                              if (ctr
                                                                  .receivedInvoices!
                                                                  .isNotEmpty) {
                                                                // Get.snackbar("enter invoices","",backgroundColor: R.colors.blue);

                                                                pdf.addPage(pw
                                                                    .MultiPage(
                                                                        pageFormat:
                                                                            PdfPageFormat
                                                                                .a4,
                                                                        theme: pw.ThemeData
                                                                            .withFont(
                                                                          base:
                                                                              ttf,
                                                                        ),
                                                                        build: (pw.Context
                                                                            context) {
                                                                          return <pw
                                                                              .Widget>[
                                                                            pw.Table(children: [
                                                                              pw.TableRow(children: [
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    "Inv number".tr,
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  )
                                                                                ]),
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    "Created at".tr.toString(),
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  ),
                                                                                ]),
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    "Customer".tr.toString(),
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  ),
                                                                                ]),
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    "Description".tr.toString(),
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  ),
                                                                                ]),
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    "Amount".tr.toString(),
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  ),
                                                                                ]),
                                                                              ]),
                                                                              for (var i = 0; i < ctr.receivedInvoices!.length; i++)
                                                                                pw.TableRow(children: [
                                                                                  pw.Column(children: [
                                                                                    pw.Text("${((ctr.receivedInvoices!.length - 1) - i + 1)}"),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(ctr.receivedInvoices![i].createdDate.toString()),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(ctr.receivedInvoices![i].customer?.name.toString() ?? '', textDirection: pw.TextDirection.rtl),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(ctr.receivedInvoices![i].note ?? ''),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(ctr.receivedInvoices![i].amount.toString()),
                                                                                  ]),
                                                                                ]),
                                                                              pw.TableRow(children: [
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    "",
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  )
                                                                                ]),
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    "",
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  ),
                                                                                ]),
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    "",
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  ),
                                                                                ]),
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    "Total".tr.toString(),
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  ),
                                                                                ]),
                                                                                pw.Column(children: [
                                                                                  pw.Text(
                                                                                    total.toString(),
                                                                                    textDirection: pw.TextDirection.rtl,
                                                                                  ),
                                                                                ]),
                                                                              ]),
                                                                            ]),
                                                                            //  pw.Table(children: <>)
                                                                          ]; // Center
                                                                        })); // Page
                                                                if (ctr
                                                                    .sendInvoices!
                                                                    .isNotEmpty) {
                                                                  pdf.addPage(pw
                                                                      .MultiPage(
                                                                          pageFormat: PdfPageFormat
                                                                              .a4,
                                                                          theme: pw.ThemeData
                                                                              .withFont(
                                                                            base:
                                                                                ttf,
                                                                          ),
                                                                          build:
                                                                              (pw.Context context) {
                                                                            return <pw.Widget>[
                                                                              pw.Table(children: [
                                                                                pw.TableRow(children: [
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      "Inv number".tr,
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    )
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      "Created at".tr.toString(),
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    ),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      "Customer".tr.toString(),
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    ),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      "Description".tr.toString(),
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    ),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      "Amount".tr.toString(),
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    ),
                                                                                  ]),
                                                                                ]),
                                                                                for (var i = 0; i < ctr.sendInvoices!.length; i++)
                                                                                  pw.TableRow(children: [
                                                                                    pw.Column(children: [
                                                                                      pw.Text("${((ctr.sendInvoices!.length - 1) - i + 1)}"),
                                                                                    ]),
                                                                                    pw.Column(children: [
                                                                                      pw.Text(ctr.sendInvoices![i].createdDate.toString()),
                                                                                    ]),
                                                                                    pw.Column(children: [
                                                                                      pw.Text(ctr.sendInvoices![i].customer?.name.toString() ?? '', textDirection: pw.TextDirection.rtl),
                                                                                    ]),
                                                                                    pw.Column(children: [
                                                                                      pw.Text(ctr.sendInvoices![i].note ?? ''),
                                                                                    ]),
                                                                                    pw.Column(children: [
                                                                                      pw.Text(ctr.sendInvoices![i].amount.toString()),
                                                                                    ]),
                                                                                  ]),
                                                                                pw.TableRow(children: [
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      "",
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    )
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      "",
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    ),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      "",
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    ),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      "Total".tr.toString(),
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    ),
                                                                                  ]),
                                                                                  pw.Column(children: [
                                                                                    pw.Text(
                                                                                      total2.toString(),
                                                                                      textDirection: pw.TextDirection.rtl,
                                                                                    ),
                                                                                  ]),
                                                                                ]),
                                                                              ]),
                                                                              //  pw.Table(children: <>)
                                                                            ]; // Center
                                                                          }));
                                                                }
                                                                List<int>
                                                                    bytes =
                                                                    await pdf
                                                                        .save();
                                                                AnchorElement(
                                                                    href:
                                                                        'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
                                                                  ..setAttribute(
                                                                      'download',
                                                                      'report.pdf')
                                                                  ..click();

                                                                Get.back();
                                                              }
                                                            },
                                                            child: Image.asset(
                                                              R.images.pdfIcon,
                                                              width: 60,
                                                              height: 60,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  R.images.icon1,
                                                  width: 20,
                                                  height: 20,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    'Share Report'.tr,
                                                    style: TextStyle(
                                                        color: R.colors.black,
                                                        fontSize: 10),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 60,
                                          // width: Get.width * 0.25,
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: R.colors.grey,
                                                  width: 1)),
                                          child: GestureDetector(
                                            onTap: () {
                                              _shareQrCode();
                                            },
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  R.images.icon3,
                                                  width: 20,
                                                  height: 20,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    'Share QR code'.tr,
                                                    style: TextStyle(
                                                        color: R.colors.black,
                                                        fontSize: 10),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: Get.width,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: R.colors.grey, width: 1)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            R.images.icon2,
                                            width: 25,
                                            height: 25,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Total Invoices Yearly'.tr,
                                                    style: TextStyle(
                                                        color: R.colors.black,
                                                        fontSize: 12),
                                                  ),
                                                  Text(
                                                    " : ${ctr.totalInvoicesYearly}",
                                                    style: TextStyle(
                                                        color: R.colors.black,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Total Expenses Yearly'.tr,
                                                    style: TextStyle(
                                                        color: R.colors.black,
                                                        fontSize: 12),
                                                  ),
                                                  Text(
                                                    " : ${ctr.totalExpansesYearly}",
                                                    style: TextStyle(
                                                        color: R.colors.black,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Get.bottomSheet(
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                  color: R.colors.white,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10))),
                                              child: Column(children: [
                                                Expanded(
                                                    child:
                                                        SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                Text("From".tr),
                                                          ),
                                                          const SizedBox(
                                                            width: 20,
                                                          ),
                                                          Expanded(
                                                            child:
                                                                Text("To".tr),
                                                          ),
                                                        ],
                                                      ),

                                                      // Text("Day".tr),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(child:
                                                              StatefulBuilder(
                                                            builder: (BuildContext
                                                                    context,
                                                                StateSetter
                                                                    setState) {
                                                              return GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  DateTime?
                                                                      pickedDate =
                                                                      await showDatePicker(
                                                                          context:
                                                                              context,
                                                                          initialDate:
                                                                              day,
                                                                          firstDate: DateTime(
                                                                              1950),
                                                                          //DateTime.now() - not to allow to choose before today.
                                                                          lastDate:
                                                                              DateTime.now());

                                                                  if (pickedDate !=
                                                                      null) {
                                                                    day =
                                                                        pickedDate;
                                                                    setState(
                                                                        () {});
                                                                    // Get.back();
                                                                    ctr
                                                                        .getHome(
                                                                            ctr.selectedBudgetId
                                                                                .value,
                                                                            day == DateTime.now()
                                                                                ? null
                                                                                : day.toIso8601String(),
                                                                            today == DateTime.now() ? null : today.toIso8601String())
                                                                        .then((value) {
                                                                      expenseTypes
                                                                          .clear();
                                                                      for (var expanse
                                                                          in ctr
                                                                              .expenseTypes) {
                                                                        // debugPrint(expanse.invoiceSumAmount.toString());
                                                                        if (expanse.invoiceSumAmount !=
                                                                                null &&
                                                                            expanse.invoiceSumAmount! >
                                                                                0) {
                                                                          expenseTypes
                                                                              .add(expanse);
                                                                        }
                                                                      }
                                                                    });
                                                                  }
                                                                },
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(8),
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: R
                                                                              .colors
                                                                              .black,
                                                                          width:
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                          "${day.day}-${day.month}-${day.year}"),
                                                                      Icon(
                                                                        Icons
                                                                            .arrow_drop_down,
                                                                        color: R
                                                                            .colors
                                                                            .black,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          )),
                                                          const SizedBox(
                                                            width: 20,
                                                          ),
                                                          Expanded(child:
                                                              StatefulBuilder(
                                                            builder: (BuildContext
                                                                    context,
                                                                StateSetter
                                                                    setState) {
                                                              return GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  DateTime?
                                                                      pickedDate =
                                                                      await showDatePicker(
                                                                          context:
                                                                              context,
                                                                          initialDate:
                                                                              today,
                                                                          firstDate: DateTime(
                                                                              1950),
                                                                          //DateTime.now() - not to allow to choose before today.
                                                                          lastDate:
                                                                              DateTime.now());

                                                                  if (pickedDate !=
                                                                      null) {
                                                                    today =
                                                                        pickedDate;
                                                                    setState(
                                                                        () {});
                                                                    // Get.back();
                                                                    ctr
                                                                        .getHome(
                                                                            ctr.selectedBudgetId
                                                                                .value,
                                                                            day == DateTime.now()
                                                                                ? null
                                                                                : day.toIso8601String(),
                                                                            today == DateTime.now() ? null : today.toIso8601String())
                                                                        .then((value) {
                                                                      expenseTypes
                                                                          .clear();
                                                                      for (var expanse
                                                                          in ctr
                                                                              .expenseTypes) {
                                                                        // debugPrint(expanse.invoiceSumAmount.toString());
                                                                        if (expanse.invoiceSumAmount !=
                                                                                null &&
                                                                            expanse.invoiceSumAmount! >
                                                                                0) {
                                                                          expenseTypes
                                                                              .add(expanse);
                                                                        }
                                                                      }
                                                                    });
                                                                  }
                                                                },
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(8),
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: R
                                                                              .colors
                                                                              .black,
                                                                          width:
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                          "${today.day}-${today.month}-${today.year}"),
                                                                      Icon(
                                                                        Icons
                                                                            .arrow_drop_down,
                                                                        color: R
                                                                            .colors
                                                                            .black,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          )),
                                                        ],
                                                      ),
                                                      //                                               SizedBox(height: 10,),

                                                      //                                               const SizedBox(height: 10,),
                                                      //                                               Text("Month".tr),
                                                      //                                               const SizedBox(height: 10,),
                                                      //                                               Row(
                                                      //                                                 children: [
                                                      //                                                   Expanded(
                                                      //                                                     child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                                      //                                                       return GestureDetector(
                                                      //                                                       onTap: () async {
                                                      //                                                      final selected = await showMonthPicker(
                                                      //                                                         context: context,
                                                      //                                                         initialDate: month,
                                                      //                                                         firstDate: DateTime(1970),
                                                      //                                                         lastDate: DateTime(2050)
                                                      //                                                       );                                                if(selected != null){

                                                      //                                                         month = selected;
                                                      //                                                         setState(() {

                                                      //                                                                         });
                                                      //                                                       }
                                                      //                                                       // Get.back();
                                                      //                                                                         ctr.getHome(ctr.selectedBudgetId.value, day.day == DateTime.now().day ? null : day.day, month.month == DateTime.now().month ? null : month.month, date.year == DateTime.now().year ? null : date.year ,today.day == DateTime.now().day ? null : today.day, tomonth.month == DateTime.now().month ? null : tomonth.month, todate.year == DateTime.now().year ? null : todate.year).then((value){
                                                      //                                                                           expenseTypes.clear();
                                                      //                                                          for (var expanse in ctr.expenseTypes) {
                                                      //                                                           // debugPrint(expanse.invoiceSumAmount.toString());
                                                      //                                                         if (expanse.invoiceSumAmount != null && expanse.invoiceSumAmount! > 0 ) {
                                                      //                                                           expenseTypes.add(expanse);
                                                      //                                                         }
                                                      //                                                       }

                                                      //                                                                         });

                                                      //                                                       },
                                                      //                                                       child:  Container(
                                                      //                                                         padding: const EdgeInsets.all(8),
                                                      //                                                         decoration: BoxDecoration(
                                                      //                                                           border: Border.all(color: R.colors.black,width: 1),
                                                      //                                                           borderRadius: BorderRadius.circular(10)
                                                      //                                                         ),
                                                      //                                                         child: Row(
                                                      //                                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      //                                                           children: [
                                                      //                                                             Text("${month.month}"),
                                                      //                                                             Icon(Icons.arrow_drop_down,color: R.colors.black,),
                                                      //                                                           ],
                                                      //                                                         ),
                                                      //                                                       ),
                                                      //                                                     );
                                                      //                                                     },)
                                                      //                                                   ),
                                                      //                                                   SizedBox(width: 20,),
                                                      //                                                   Expanded(
                                                      //                                                 child: StatefulBuilder(builder: (BuildContext context, StateSetter  setState) {
                                                      //                                                   return GestureDetector(
                                                      //                                                   onTap: () async {
                                                      //                                                  final selected = await showMonthPicker(
                                                      //                                                     context: context,
                                                      //                                                     initialDate: tomonth,
                                                      //                                                     firstDate: DateTime(1970),
                                                      //                                                     lastDate: DateTime(2050)
                                                      //                                                   );                                                if(selected != null){

                                                      //                                                     tomonth = selected;
                                                      //                                                     setState(() {

                                                      //                                                                         });
                                                      //                                                   }
                                                      //                                                   // Get.back();
                                                      //                                                                     ctr.getHome(ctr.selectedBudgetId.value, day.day == DateTime.now().day ? null : day.day, month.month == DateTime.now().month ? null : month.month, date.year == DateTime.now().year ? null : date.year ,today.day == DateTime.now().day ? null : today.day, tomonth.month == DateTime.now().month ? null : tomonth.month, todate.year == DateTime.now().year ? null : todate.year).then((value){
                                                      //                                                                       expenseTypes.clear();
                                                      //                                                      for (var expanse in ctr.expenseTypes) {
                                                      //                                                       // debugPrint(expanse.invoiceSumAmount.toString());
                                                      //                                                     if (expanse.invoiceSumAmount != null && expanse.invoiceSumAmount! > 0 ) {
                                                      //                                                       expenseTypes.add(expanse);
                                                      //                                                     }
                                                      //                                                   }

                                                      //                                                                     });

                                                      //                                                   },
                                                      //                                                   child:  Container(
                                                      //                                                     padding: const EdgeInsets.all(8),
                                                      //                                                     decoration: BoxDecoration(
                                                      //                                                       border: Border.all(color: R.colors.black,width: 1),
                                                      //                                                       borderRadius: BorderRadius.circular(10)
                                                      //                                                     ),
                                                      //                                                     child: Row(
                                                      //                                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      //                                                       children: [
                                                      //                                                         Text("${tomonth.month}"),
                                                      //                                                         Icon(Icons.arrow_drop_down,color: R.colors.black,),
                                                      //                                                       ],
                                                      //                                                     ),
                                                      //                                                   ),
                                                      //                                                 );
                                                      //                                                 },)
                                                      //                                               ),
                                                      //                                                 ],
                                                      //                                               ),
                                                      //                                               SizedBox(height: 10,),

                                                      // //
                                                      //                                               Text("Year".tr),
                                                      //                                               const SizedBox(height: 10,),
                                                      //                                               Row(
                                                      //                                                 children: [
                                                      //                                                   Expanded(
                                                      //                                                     child: StatefulBuilder(builder: ( BuildContext context, StateSetter setState ) {
                                                      //                                                       return GestureDetector(
                                                      //                                                       onTap: () async {
                                                      //                                                        showDialog(
                                                      //                                                           context: context,
                                                      //                                                           builder: (BuildContext context) {

                                                      //                                                             return AlertDialog(
                                                      //                                                               // title: Text("Select Year"),
                                                      //                                                               content: Container( // Need to use container to add size constraint.
                                                      //                                                                 width: 300,
                                                      //                                                                 height: 300,
                                                      //                                                                 child: YearPicker(
                                                      //                                                                   firstDate: DateTime(DateTime.now().year - 100, 1),
                                                      //                                                                   lastDate: DateTime(DateTime.now().year , 1),
                                                      //                                                                   initialDate: DateTime.now(),
                                                      //                                                                   // save the selected date to _selectedDate DateTime variable.
                                                      //                                                                   // It's used to set the previous selected date when
                                                      //                                                                   // re-showing the dialog.
                                                      //                                                                   selectedDate: date,
                                                      //                                                                   onChanged: (DateTime dateTime) {
                                                      //                                                                     // close the dialog when year is selected.

                                                      //                                                                       date = dateTime;
                                                      //                                                                     setState(() {

                                                      //                                                                         });
                                                      //                                                                     Navigator.pop(context);

                                                      //                                                                     // Get.back();
                                                      //                                                                         ctr.getHome(ctr.selectedBudgetId.value, day.day == DateTime.now().day ? null : day.day, month.month == DateTime.now().month ? null : month.month, date.year == DateTime.now().year ? null : date.year ,today.day == DateTime.now().day ? null : today.day, tomonth.month == DateTime.now().month ? null : tomonth.month, todate.year == DateTime.now().year ? null : todate.year).then((value){
                                                      //                                                                           expenseTypes.clear();
                                                      //                                                          for (var expanse in ctr.expenseTypes) {
                                                      //                                                           // debugPrint(expanse.invoiceSumAmount.toString());
                                                      //                                                         if (expanse.invoiceSumAmount != null && expanse.invoiceSumAmount! > 0 ) {
                                                      //                                                           expenseTypes.add(expanse);
                                                      //                                                         }
                                                      //                                                       }

                                                      //                                                                         });

                                                      //                                                                     // Do something with the dateTime selected.
                                                      //                                                                     // Remember that you need to use dateTime.year to get the year
                                                      //                                                                   },
                                                      //                                                                 ),
                                                      //                                                               ),
                                                      //                                                             );
                                                      //                                                           },
                                                      //                                                         );

                                                      //                                                       },
                                                      //                                                       child:  Container(
                                                      //                                                         padding: const EdgeInsets.all(8),
                                                      //                                                         decoration: BoxDecoration(
                                                      //                                                           border: Border.all(color: R.colors.black,width: 1),
                                                      //                                                           borderRadius: BorderRadius.circular(10)
                                                      //                                                         ),
                                                      //                                                         child: Row(
                                                      //                                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      //                                                           children: [
                                                      //                                                             Text("${date.year}".tr),
                                                      //                                                             Icon(Icons.arrow_drop_down,color: R.colors.black,),
                                                      //                                                           ],
                                                      //                                                         ),
                                                      //                                                       ),
                                                      //                                                     );
                                                      //                                                     },)
                                                      //                                                   ),
                                                      //                                                   SizedBox(width: 20,),
                                                      //                                                     Expanded(
                                                      //                                                 child: StatefulBuilder(builder: ( BuildContext context, StateSetter setState) {
                                                      //                                                   return GestureDetector(
                                                      //                                                   onTap: () async {
                                                      //                                                    showDialog(
                                                      //                                                       context: context,
                                                      //                                                       builder: (BuildContext context) {

                                                      //                                                         return AlertDialog(
                                                      //                                                           // title: Text("Select Year"),
                                                      //                                                           content: Container( // Need to use container to add size constraint.
                                                      //                                                             width: 300,
                                                      //                                                             height: 300,
                                                      //                                                             child: YearPicker(
                                                      //                                                               firstDate: DateTime(DateTime.now().year - 100, 1),
                                                      //                                                               lastDate: DateTime(DateTime.now().year , 1),
                                                      //                                                               initialDate: DateTime.now(),
                                                      //                                                               // save the selected date to _selectedDate DateTime variable.
                                                      //                                                               // It's used to set the previous selected date when
                                                      //                                                               // re-showing the dialog.
                                                      //                                                               selectedDate: todate,
                                                      //                                                               onChanged: (DateTime dateTime) {
                                                      //                                                                 // close the dialog when year is selected.

                                                      //                                                                   todate = dateTime;
                                                      //                                                                 setState(() {

                                                      //                                                                         });
                                                      //                                                                 Navigator.pop(context);

                                                      //                                                                 // Get.back();
                                                      //                                                                     ctr.getHome(ctr.selectedBudgetId.value, day.day == DateTime.now().day ? null : day.day, month.month == DateTime.now().month ? null : month.month, date.year == DateTime.now().year ? null : date.year ,today.day == DateTime.now().day ? null : today.day, tomonth.month == DateTime.now().month ? null : tomonth.month, todate.year == DateTime.now().year ? null : todate.year).then((value){
                                                      //                                                                       expenseTypes.clear();
                                                      //                                                      for (var expanse in ctr.expenseTypes) {
                                                      //                                                       // debugPrint(expanse.invoiceSumAmount.toString());
                                                      //                                                     if (expanse.invoiceSumAmount != null && expanse.invoiceSumAmount! > 0 ) {
                                                      //                                                       expenseTypes.add(expanse);
                                                      //                                                     }
                                                      //                                                   }

                                                      //                                                                     });

                                                      //                                                                 // Do something with the dateTime selected.
                                                      //                                                                 // Remember that you need to use dateTime.year to get the year
                                                      //                                                               },
                                                      //                                                             ),
                                                      //                                                           ),
                                                      //                                                         );
                                                      //                                                       },
                                                      //                                                     );

                                                      //                                                   },
                                                      //                                                   child:  Container(
                                                      //                                                     padding: const EdgeInsets.all(8),
                                                      //                                                     decoration: BoxDecoration(
                                                      //                                                       border: Border.all(color: R.colors.black,width: 1),
                                                      //                                                       borderRadius: BorderRadius.circular(10)
                                                      //                                                     ),
                                                      //                                                     child: Row(
                                                      //                                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      //                                                       children: [
                                                      //                                                         Text("${todate.year}".tr),
                                                      //                                                         Icon(Icons.arrow_drop_down,color: R.colors.black,),
                                                      //                                                       ],
                                                      //                                                     ),
                                                      //                                                   ),
                                                      //                                                 );
                                                      //                                                 },)
                                                      //                                               ),
                                                      //                                                 ],
                                                      //                                               ),

                                                      const SizedBox(
                                                        height: 20,
                                                      ),

                                                      Row(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              // print(GetStorage().read("user_token"));

                                                              ctr
                                                                  .getHome(
                                                                      ctr.selectedBudgetId
                                                                          .value,
                                                                      day == DateTime.now()
                                                                          ? null
                                                                          : day
                                                                              .toIso8601String(),
                                                                      today == DateTime.now()
                                                                          ? null
                                                                          : today
                                                                              .toIso8601String())
                                                                  .then(
                                                                      (value) {
                                                                expenseTypes
                                                                    .clear();
                                                                for (var expanse
                                                                    in ctr
                                                                        .expenseTypes) {
                                                                  // debugPrint(expanse.invoiceSumAmount.toString());
                                                                  if (expanse.invoiceSumAmount !=
                                                                          null &&
                                                                      expanse.invoiceSumAmount! >
                                                                          0) {
                                                                    expenseTypes
                                                                        .add(
                                                                            expanse);
                                                                  }
                                                                }
                                                                Get.back();
                                                              });
                                                            },
                                                            child: Container(
                                                              width: 100,
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 10),
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  color: R
                                                                      .colors
                                                                      .blue),
                                                              child: Center(
                                                                child: Text(
                                                                    'Show'.tr),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 20,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              // print(GetStorage().read("user_token"));
                                                              Get.back();
                                                              setState(() {
                                                                date = DateTime
                                                                    .now();
                                                                todate =
                                                                    DateTime
                                                                        .now();
                                                                month = DateTime
                                                                    .now();
                                                                tomonth =
                                                                    DateTime
                                                                        .now();
                                                                day = DateTime
                                                                    .now();
                                                                today = DateTime
                                                                    .now();
                                                              });
                                                              ctr
                                                                  .getHome(
                                                                      ctr.selectedBudgetId
                                                                          .value,
                                                                      null,
                                                                      null)
                                                                  .then(
                                                                      (value) {
                                                                expenseTypes
                                                                    .clear();
                                                                for (var expanse
                                                                    in ctr
                                                                        .expenseTypes) {
                                                                  // debugPrint(expanse.invoiceSumAmount.toString());
                                                                  if (expanse.invoiceSumAmount !=
                                                                          null &&
                                                                      expanse.invoiceSumAmount! >
                                                                          0) {
                                                                    expenseTypes
                                                                        .add(
                                                                            expanse);
                                                                  }
                                                                }
                                                              });
                                                            },
                                                            child: Container(
                                                              width: 100,
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 10),
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  color: R
                                                                      .colors
                                                                      .blue),
                                                              child: Center(
                                                                child: Text(
                                                                    'Reset'.tr),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ))
                                              ]),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 50,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: R.colors.lightBlue3,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Text(ctr.expanse.value,style: TextStyle(color: R.colors.black),),
                                              Icon(
                                                Icons.search,
                                                color: R.colors.black,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(
                            height: 15,
                          ),
                          Center(
                            child: SizedBox(
                              width: Get.width > 750
                                  ? Get.width * 0.15
                                  : Get.width * 0.40,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                // crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      // width: Get.width * 0.35,
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: R.colors.grey, width: 1)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Screenshot(
                                              controller: screenshotController,
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    width: 80,
                                                    height: 80,
                                                    child: Container(
                                                      color: R.colors.white,
                                                   /*   child: mageView(
                                                        data: ctr.qrCode.value,
                                                        version:
                                                            QrVersions.auto,
                                                        size: 100.0,
                                                      ),*/
                                                      // QrImage(
                                                      //           data: ctr.qrCode.value,
                                                      //           version: QrVersions.auto,
                                                      //           size: 100.0,
                                                      //         ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    '${ctr.selectedBudgetName}',
                                                    //  textDirection: TextDirection.rtl ,
                                                    // - ${'QR code'.tr

                                                    style: TextStyle(
                                                      color: R.colors.grey,
                                                    ),
                                                  ),
                                                  // const SizedBox(
                                                  //   height: 5,
                                                  // ),
                                                  // Text(
                                                  //   'Username #1',
                                                  //   style: TextStyle(color: R.colors.black),
                                                  // ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                ],
                                              )),
                                          //  SizedBox(
                                          //   width: 100,
                                          //   height: 100,
                                          //   child: Screenshot(
                                          //     controller: screenshotController,
                                          //     child: Container(
                                          //       color: R.colors.white,
                                          //       child: QrImage(
                                          //                 data: ctr.qrCode.value,
                                          //                 version: QrVersions.auto,
                                          //                 size: 100.0,
                                          //               ),
                                          //     ),
                                          //   ),
                                          // ),

                                          Text(
                                            ctr.qrCode.value,
                                            textDirection: TextDirection.ltr,
                                            style: TextStyle(
                                                color: R.colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // const SizedBox(
                                  //   width: 10,
                                  // ),
                                  // Expanded(
                                  //   flex: 3,
                                  //   child: SizedBox(
                                  //      width: Get.width,
                                  //     child: Column(
                                  //       children: [
                                  //         Container(
                                  //           padding: const EdgeInsets.all(8),
                                  //           decoration: BoxDecoration(
                                  //               borderRadius: BorderRadius.circular(10),
                                  //               border: Border.all(
                                  //                   color: R.colors.grey, width: 1)),
                                  //           child: Column(
                                  //             children: [
                                  //               Row(
                                  //                 children: [
                                  //                   // Image.asset(
                                  //                   //   R.images.icon2,
                                  //                   //   width: 25,
                                  //                   //   height: 25,
                                  //                   // ),
                                  //                   // const SizedBox(
                                  //                   //   width: 5,
                                  //                   // ),
                                  //                   Column(
                                  //                     crossAxisAlignment:
                                  //                         CrossAxisAlignment.start,
                                  //                     children: [
                                  //                       Text("Daily".tr),
                                  //                       SizedBox(height: 5,),
                                  //                       Row(
                                  //                         children: [

                                  //                           Text(
                                  //                             'Total Invoices'.tr,
                                  //                             style: TextStyle(
                                  //                                 color: R.colors.black,
                                  //                                 fontSize: 12),
                                  //                           ),
                                  //                           Text(
                                  //                             " : ${ctr.totalInvoicesDaily.value}",
                                  //                             style: TextStyle(
                                  //                                 color: R.colors.black,
                                  //                                 fontSize: 12),
                                  //                           ),
                                  //                         ],
                                  //                       ),
                                  //                       const SizedBox(
                                  //                         height: 5,
                                  //                       ),
                                  //                       Row(
                                  //                         children: [
                                  //                           Text(
                                  //                             'Total Expenses'.tr,
                                  //                             style: TextStyle(
                                  //                                 color: R.colors.black,
                                  //                                 fontSize: 12),
                                  //                           ),
                                  //                           Text(
                                  //                             " : ${ctr.totalExpansesDaily.value}",
                                  //                             style: TextStyle(
                                  //                                 color: R.colors.black,
                                  //                                 fontSize: 12),
                                  //                           ),
                                  //                         ],
                                  //                       ),
                                  //                       SizedBox(height: 5,),
                                  //                        Text("Monthly".tr),
                                  //                       SizedBox(height: 5,),
                                  //                       Row(
                                  //                         children: [

                                  //                           Text(
                                  //                             'Total Invoices'.tr,
                                  //                             style: TextStyle(
                                  //                                 color: R.colors.black,
                                  //                                 fontSize: 12),
                                  //                           ),
                                  //                           Text(
                                  //                             " : ${ctr.totalInvoicesMontly.value}",
                                  //                             style: TextStyle(
                                  //                                 color: R.colors.black,
                                  //                                 fontSize: 12),
                                  //                           ),
                                  //                         ],
                                  //                       ),
                                  //                       const SizedBox(
                                  //                         height: 5,
                                  //                       ),
                                  //                       Row(
                                  //                         children: [
                                  //                           Text(
                                  //                             'Total Expenses'.tr,
                                  //                             style: TextStyle(
                                  //                                 color: R.colors.black,
                                  //                                 fontSize: 12),
                                  //                           ),
                                  //                           Text(
                                  //                             " : ${ctr.totalExpansesMontly.value}",
                                  //                             style: TextStyle(
                                  //                                 color: R.colors.black,
                                  //                                 fontSize: 12),
                                  //                           ),
                                  //                         ],
                                  //                       ),
                                  //                     ],
                                  //                   )
                                  //                 ],
                                  //               ),
                                  //             ],
                                  //           ),
                                  //         ),
                                  //         const SizedBox(
                                  //           height: 8,
                                  //         ),

                                  //       ],
                                  //     ),
                                  //   ),
                                  // )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (kIsWeb == false) ...[
                  Container(
                    width: Get.width,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: R.colors.grey, width: 1)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              R.images.icon2,
                              width: 25,
                              height: 25,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Total Invoices Yearly'.tr,
                                      style: TextStyle(
                                          color: R.colors.black, fontSize: 12),
                                    ),
                                    Text(
                                      " : ${ctr.totalInvoicesYearly}",
                                      style: TextStyle(
                                          color: R.colors.black, fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Total Expenses Yearly'.tr,
                                      style: TextStyle(
                                          color: R.colors.black, fontSize: 12),
                                    ),
                                    Text(
                                      " : ${ctr.totalExpansesYearly}",
                                      style: TextStyle(
                                          color: R.colors.black, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.bottomSheet(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                    color: R.colors.white,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10))),
                                child: Column(children: [
                                  Expanded(
                                      child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text("From".tr),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Expanded(
                                              child: Text("To".tr),
                                            ),
                                          ],
                                        ),

                                        // Text("Day".tr),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: StatefulBuilder(
                                                builder: (BuildContext context,
                                                    StateSetter setState) {
                                                  return GestureDetector(
                                                    onTap: () async {
                                                      DateTime? pickedDate =
                                                          await showDatePicker(
                                                              context: context,
                                                              initialDate: day,
                                                              firstDate:
                                                                  DateTime(
                                                                      1950),
                                                              //DateTime.now() - not to allow to choose before today.
                                                              lastDate: DateTime
                                                                  .now());

                                                      if (pickedDate != null) {
                                                        day = pickedDate;
                                                        setState(() {});
                                                        // Get.back();
                                                        ctr
                                                            .getHome(
                                                                ctr.selectedBudgetId
                                                                    .value,
                                                                day ==
                                                                        DateTime
                                                                            .now()
                                                                    ? null
                                                                    : day
                                                                        .toIso8601String(),
                                                                today ==
                                                                        DateTime
                                                                            .now()
                                                                    ? null
                                                                    : today
                                                                        .toIso8601String())
                                                            .then((value) {
                                                          expenseTypes.clear();
                                                          for (var expanse in ctr
                                                              .expenseTypes) {
                                                            // debugPrint(expanse.invoiceSumAmount.toString());
                                                            if (expanse.invoiceSumAmount !=
                                                                    null &&
                                                                expanse.invoiceSumAmount! >
                                                                    0) {
                                                              expenseTypes
                                                                  .add(expanse);
                                                            }
                                                          }
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: R
                                                                  .colors.black,
                                                              width: 1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                              "${day.day}-${day.month}-${day.year}"),
                                                          Icon(
                                                            Icons
                                                                .arrow_drop_down,
                                                            color:
                                                                R.colors.black,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Expanded(child: StatefulBuilder(
                                              builder: (BuildContext context,
                                                  StateSetter setState) {
                                                return GestureDetector(
                                                  onTap: () async {
                                                    DateTime? pickedDate =
                                                        await showDatePicker(
                                                            context: context,
                                                            initialDate: today,
                                                            firstDate:
                                                                DateTime(1950),
                                                            //DateTime.now() - not to allow to choose before today.
                                                            lastDate:
                                                                DateTime.now());

                                                    if (pickedDate != null) {
                                                      today = pickedDate;
                                                      setState(() {});
                                                      // Get.back();
                                                      ctr
                                                          .getHome(
                                                              ctr.selectedBudgetId
                                                                  .value,
                                                              day ==
                                                                      DateTime
                                                                          .now()
                                                                  ? null
                                                                  : day
                                                                      .toIso8601String(),
                                                              today ==
                                                                      DateTime
                                                                          .now()
                                                                  ? null
                                                                  : today
                                                                      .toIso8601String())
                                                          .then((value) {
                                                        expenseTypes.clear();
                                                        for (var expanse in ctr
                                                            .expenseTypes) {
                                                          // debugPrint(expanse.invoiceSumAmount.toString());
                                                          if (expanse.invoiceSumAmount !=
                                                                  null &&
                                                              expanse.invoiceSumAmount! >
                                                                  0) {
                                                            expenseTypes
                                                                .add(expanse);
                                                          }
                                                        }
                                                      });
                                                    }
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                R.colors.black,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                            "${today.day}-${today.month}-${today.year}"),
                                                        Icon(
                                                          Icons.arrow_drop_down,
                                                          color: R.colors.black,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            )),
                                          ],
                                        ),
                                        //                                               SizedBox(height: 10,),

                                        //                                               const SizedBox(height: 10,),
                                        //                                               Text("Month".tr),
                                        //                                               const SizedBox(height: 10,),
                                        //                                               Row(
                                        //                                                 children: [
                                        //                                                   Expanded(
                                        //                                                     child: StatefulBuilder(builder: ( BuildContext context, StateSetter setState) {
                                        //                                                       return GestureDetector(
                                        //                                                       onTap: () async {
                                        //                                                      final selected = await showMonthPicker(
                                        //                                                         context: context,
                                        //                                                         initialDate: month,
                                        //                                                         firstDate: DateTime(1970),
                                        //                                                         lastDate: DateTime(2050)
                                        //                                                       );                                                if(selected != null){

                                        //                                                         month = selected;
                                        //                                                         setState(() {

                                        //                                                                         });
                                        //                                                       }
                                        //                                                       // Get.back();
                                        //                                                                         ctr.getHome(ctr.selectedBudgetId.value, day.day == DateTime.now().day ? null : day.day, month.month == DateTime.now().month ? null : month.month, date.year == DateTime.now().year ? null : date.year ,today.day == DateTime.now().day ? null : today.day, tomonth.month == DateTime.now().month ? null : tomonth.month, todate.year == DateTime.now().year ? null : todate.year).then((value){
                                        //                                                                           expenseTypes.clear();
                                        //                                                          for (var expanse in ctr.expenseTypes) {
                                        //                                                           // debugPrint(expanse.invoiceSumAmount.toString());
                                        //                                                         if (expanse.invoiceSumAmount != null && expanse.invoiceSumAmount! > 0 ) {
                                        //                                                           expenseTypes.add(expanse);
                                        //                                                         }
                                        //                                                       }

                                        //                                                                         });

                                        //                                                       },
                                        //                                                       child:  Container(
                                        //                                                         padding: const EdgeInsets.all(8),
                                        //                                                         decoration: BoxDecoration(
                                        //                                                           border: Border.all(color: R.colors.black,width: 1),
                                        //                                                           borderRadius: BorderRadius.circular(10)
                                        //                                                         ),
                                        //                                                         child: Row(
                                        //                                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //                                                           children: [
                                        //                                                             Text("${month.month}"),
                                        //                                                             Icon(Icons.arrow_drop_down,color: R.colors.black,),
                                        //                                                           ],
                                        //                                                         ),
                                        //                                                       ),
                                        //                                                     );
                                        //                                                     },)
                                        //                                                   ),
                                        //                                                   SizedBox(width: 20,),
                                        //                                                   Expanded(
                                        //                                                 child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                        //                                                   return GestureDetector(
                                        //                                                   onTap: () async {
                                        //                                                  final selected = await showMonthPicker(
                                        //                                                     context: context,
                                        //                                                     initialDate: tomonth,
                                        //                                                     firstDate: DateTime(1970),
                                        //                                                     lastDate: DateTime(2050)
                                        //                                                   );                                                if(selected != null){

                                        //                                                     tomonth = selected;
                                        //                                                     setState(() {

                                        //                                                                         });
                                        //                                                   }
                                        //                                                   // Get.back();
                                        //                                                                     ctr.getHome(ctr.selectedBudgetId.value, day.day == DateTime.now().day ? null : day.day, month.month == DateTime.now().month ? null : month.month, date.year == DateTime.now().year ? null : date.year ,today.day == DateTime.now().day ? null : today.day, tomonth.month == DateTime.now().month ? null : tomonth.month, todate.year == DateTime.now().year ? null : todate.year).then((value){
                                        //                                                                       expenseTypes.clear();
                                        //                                                      for (var expanse in ctr.expenseTypes) {
                                        //                                                       // debugPrint(expanse.invoiceSumAmount.toString());
                                        //                                                     if (expanse.invoiceSumAmount != null && expanse.invoiceSumAmount! > 0 ) {
                                        //                                                       expenseTypes.add(expanse);
                                        //                                                     }
                                        //                                                   }

                                        //                                                                     });

                                        //                                                   },
                                        //                                                   child:  Container(
                                        //                                                     padding: const EdgeInsets.all(8),
                                        //                                                     decoration: BoxDecoration(
                                        //                                                       border: Border.all(color: R.colors.black,width: 1),
                                        //                                                       borderRadius: BorderRadius.circular(10)
                                        //                                                     ),
                                        //                                                     child: Row(
                                        //                                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //                                                       children: [
                                        //                                                         Text("${tomonth.month}"),
                                        //                                                         Icon(Icons.arrow_drop_down,color: R.colors.black,),
                                        //                                                       ],
                                        //                                                     ),
                                        //                                                   ),
                                        //                                                 );
                                        //                                                 },)
                                        //                                               ),
                                        //                                                 ],
                                        //                                               ),
                                        //                                               SizedBox(height: 10,),

                                        // //
                                        //                                               Text("Year".tr),
                                        //                                               const SizedBox(height: 10,),
                                        //                                               Row(
                                        //                                                 children: [
                                        //                                                   Expanded(
                                        //                                                     child: StatefulBuilder(builder: (BuildContext context,StateSetter setState) {
                                        //                                                       return GestureDetector(
                                        //                                                       onTap: () async {
                                        //                                                        showDialog(
                                        //                                                           context: context,
                                        //                                                           builder: (BuildContext context) {

                                        //                                                             return AlertDialog(
                                        //                                                               // title: Text("Select Year"),
                                        //                                                               content: Container( // Need to use container to add size constraint.
                                        //                                                                 width: 300,
                                        //                                                                 height: 300,
                                        //                                                                 child: YearPicker(
                                        //                                                                   firstDate: DateTime(DateTime.now().year - 100, 1),
                                        //                                                                   lastDate: DateTime(DateTime.now().year , 1),
                                        //                                                                   initialDate: DateTime.now(),
                                        //                                                                   // save the selected date to _selectedDate DateTime variable.
                                        //                                                                   // It's used to set the previous selected date when
                                        //                                                                   // re-showing the dialog.
                                        //                                                                   selectedDate: date,
                                        //                                                                   onChanged: (DateTime dateTime) {
                                        //                                                                     // close the dialog when year is selected.

                                        //                                                                       date = dateTime;
                                        //                                                                     setState(() {

                                        //                                                                         });
                                        //                                                                     Navigator.pop(context);

                                        //                                                                     // Get.back();
                                        //                                                                         ctr.getHome(ctr.selectedBudgetId.value, day.day == DateTime.now().day ? null : day.day, month.month == DateTime.now().month ? null : month.month, date.year == DateTime.now().year ? null : date.year ,today.day == DateTime.now().day ? null : today.day, tomonth.month == DateTime.now().month ? null : tomonth.month, todate.year == DateTime.now().year ? null : todate.year).then((value){
                                        //                                                                           expenseTypes.clear();
                                        //                                                          for (var expanse in ctr.expenseTypes) {
                                        //                                                           // debugPrint(expanse.invoiceSumAmount.toString());
                                        //                                                         if (expanse.invoiceSumAmount != null && expanse.invoiceSumAmount! > 0 ) {
                                        //                                                           expenseTypes.add(expanse);
                                        //                                                         }
                                        //                                                       }

                                        //                                                                         });

                                        //                                                                     // Do something with the dateTime selected.
                                        //                                                                     // Remember that you need to use dateTime.year to get the year
                                        //                                                                   },
                                        //                                                                 ),
                                        //                                                               ),
                                        //                                                             );
                                        //                                                           },
                                        //                                                         );

                                        //                                                       },
                                        //                                                       child:  Container(
                                        //                                                         padding: const EdgeInsets.all(8),
                                        //                                                         decoration: BoxDecoration(
                                        //                                                           border: Border.all(color: R.colors.black,width: 1),
                                        //                                                           borderRadius: BorderRadius.circular(10)
                                        //                                                         ),
                                        //                                                         child: Row(
                                        //                                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //                                                           children: [
                                        //                                                             Text("${date.year}".tr),
                                        //                                                             Icon(Icons.arrow_drop_down,color: R.colors.black,),
                                        //                                                           ],
                                        //                                                         ),
                                        //                                                       ),
                                        //                                                     );
                                        //                                                     },)
                                        //                                                   ),
                                        //                                                   SizedBox(width: 20,),
                                        //                                                     Expanded(
                                        //                                                 child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                        //                                                   return GestureDetector(
                                        //                                                   onTap: () async {
                                        //                                                    showDialog(
                                        //                                                       context: context,
                                        //                                                       builder: (BuildContext context) {

                                        //                                                         return AlertDialog(
                                        //                                                           // title: Text("Select Year"),
                                        //                                                           content: Container( // Need to use container to add size constraint.
                                        //                                                             width: 300,
                                        //                                                             height: 300,
                                        //                                                             child: YearPicker(
                                        //                                                               firstDate: DateTime(DateTime.now().year - 100, 1),
                                        //                                                               lastDate: DateTime(DateTime.now().year , 1),
                                        //                                                               initialDate: DateTime.now(),
                                        //                                                               // save the selected date to _selectedDate DateTime variable.
                                        //                                                               // It's used to set the previous selected date when
                                        //                                                               // re-showing the dialog.
                                        //                                                               selectedDate: todate,
                                        //                                                               onChanged: (DateTime dateTime) {
                                        //                                                                 // close the dialog when year is selected.

                                        //                                                                   todate = dateTime;
                                        //                                                                 setState(() {

                                        //                                                                         });
                                        //                                                                 Navigator.pop(context);

                                        //                                                                 // Get.back();
                                        //                                                                     ctr.getHome(ctr.selectedBudgetId.value, day.day == DateTime.now().day ? null : day.day, month.month == DateTime.now().month ? null : month.month, date.year == DateTime.now().year ? null : date.year ,today.day == DateTime.now().day ? null : today.day, tomonth.month == DateTime.now().month ? null : tomonth.month, todate.year == DateTime.now().year ? null : todate.year).then((value){
                                        //                                                                       expenseTypes.clear();
                                        //                                                      for (var expanse in ctr.expenseTypes) {
                                        //                                                       // debugPrint(expanse.invoiceSumAmount.toString());
                                        //                                                     if (expanse.invoiceSumAmount != null && expanse.invoiceSumAmount! > 0 ) {
                                        //                                                       expenseTypes.add(expanse);
                                        //                                                     }
                                        //                                                   }

                                        //                                                                     });

                                        //                                                                 // Do something with the dateTime selected.
                                        //                                                                 // Remember that you need to use dateTime.year to get the year
                                        //                                                               },
                                        //                                                             ),
                                        //                                                           ),
                                        //                                                         );
                                        //                                                       },
                                        //                                                     );

                                        //                                                   },
                                        //                                                   child:  Container(
                                        //                                                     padding: const EdgeInsets.all(8),
                                        //                                                     decoration: BoxDecoration(
                                        //                                                       border: Border.all(color: R.colors.black,width: 1),
                                        //                                                       borderRadius: BorderRadius.circular(10)
                                        //                                                     ),
                                        //                                                     child: Row(
                                        //                                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //                                                       children: [
                                        //                                                         Text("${todate.year}".tr),
                                        //                                                         Icon(Icons.arrow_drop_down,color: R.colors.black,),
                                        //                                                       ],
                                        //                                                     ),
                                        //                                                   ),
                                        //                                                 );
                                        //                                                 },)
                                        //                                               ),
                                        //                                                 ],
                                        //                                               ),

                                        const SizedBox(
                                          height: 20,
                                        ),

                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                // print(GetStorage().read("user_token"));

                                                ctr
                                                    .getHome(
                                                        ctr.selectedBudgetId
                                                            .value,
                                                        day == DateTime.now()
                                                            ? null
                                                            : day
                                                                .toIso8601String(),
                                                        today == DateTime.now()
                                                            ? null
                                                            : today
                                                                .toIso8601String())
                                                    .then((value) {
                                                  expenseTypes.clear();
                                                  for (var expanse
                                                      in ctr.expenseTypes) {
                                                    // debugPrint(expanse.invoiceSumAmount.toString());
                                                    if (expanse.invoiceSumAmount !=
                                                            null &&
                                                        expanse.invoiceSumAmount! >
                                                            0) {
                                                      expenseTypes.add(expanse);
                                                    }
                                                  }
                                                  Get.back();
                                                });
                                              },
                                              child: Container(
                                                width: 100,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 10),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: R.colors.blue),
                                                child: Center(
                                                  child: Text('Show'.tr),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                // print(GetStorage().read("user_token"));
                                                Get.back();
                                                setState(() {
                                                  date = DateTime.now();
                                                  todate = DateTime.now();
                                                  month = DateTime.now();
                                                  tomonth = DateTime.now();
                                                  day = DateTime.now();
                                                  today = DateTime.now();
                                                });
                                                ctr
                                                    .getHome(
                                                        ctr.selectedBudgetId
                                                            .value,
                                                        null,
                                                        null)
                                                    .then((value) {
                                                  expenseTypes.clear();
                                                  for (var expanse
                                                      in ctr.expenseTypes) {
                                                    // debugPrint(expanse.invoiceSumAmount.toString());
                                                    if (expanse.invoiceSumAmount !=
                                                            null &&
                                                        expanse.invoiceSumAmount! >
                                                            0) {
                                                      expenseTypes.add(expanse);
                                                    }
                                                  }
                                                });
                                              },
                                              child: Container(
                                                width: 100,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 10),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: R.colors.blue),
                                                child: Center(
                                                  child: Text('Reset'.tr),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ))
                                ]),
                              ),
                            );
                          },
                          child: Container(
                            width: 50,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              color: R.colors.lightBlue3,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Text(ctr.expanse.value,style: TextStyle(color: R.colors.black),),
                                Icon(
                                  Icons.search,
                                  color: R.colors.black,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: Get.width,
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              // width: Get.width * 0.35,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: R.colors.grey, width: 1)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Screenshot(
                                      controller: screenshotController,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: 80,
                                            height: 80,
                                            child: Container(
                                              color: R.colors.white,
                                           /*   child: QrImageView(
                                                data: ctr.qrCode.value,
                                                version: QrVersions.auto,
                                                size: 100.0,
                                              ),*/
                                              // QrImage(
                                              //           data: ctr.qrCode.value,
                                              //           version: QrVersions.auto,
                                              //           size: 100.0,
                                              //         ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            '${ctr.selectedBudgetName}',
                                            // textDirection: TextDirection.rtl ,
                                            // - ${'QR code'.tr
                                            style:
                                                TextStyle(color: R.colors.grey),
                                          ),
                                          // const SizedBox(
                                          //   height: 5,
                                          // ),
                                          // Text(
                                          //   'Username #1',
                                          //   style: TextStyle(color: R.colors.black),
                                          // ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                        ],
                                      )),
                                  //  SizedBox(
                                  //   width: 100,
                                  //   height: 100,
                                  //   child: Screenshot(
                                  //     controller: screenshotController,
                                  //     child: Container(
                                  //       color: R.colors.white,
                                  //       child: QrImage(
                                  //                 data: ctr.qrCode.value,
                                  //                 version: QrVersions.auto,
                                  //                 size: 100.0,
                                  //               ),
                                  //     ),
                                  //   ),
                                  // ),

                                  Text(
                                    ctr.qrCode.value,
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(color: R.colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              width: Get.width,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: R.colors.grey, width: 1)),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            // Image.asset(
                                            //   R.images.icon2,
                                            //   width: 25,
                                            //   height: 25,
                                            // ),
                                            // const SizedBox(
                                            //   width: 5,
                                            // ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("Daily".tr),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Total Invoices'.tr,
                                                      style: TextStyle(
                                                          color: R.colors.black,
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      " : ${ctr.totalInvoicesDaily.value}",
                                                      style: TextStyle(
                                                          color: R.colors.black,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Total Expenses'.tr,
                                                      style: TextStyle(
                                                          color: R.colors.black,
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      " : ${ctr.totalExpansesDaily.value}",
                                                      style: TextStyle(
                                                          color: R.colors.black,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text("Monthly".tr),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Total Invoices'.tr,
                                                      style: TextStyle(
                                                          color: R.colors.black,
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      " : ${ctr.totalInvoicesMontly.value}",
                                                      style: TextStyle(
                                                          color: R.colors.black,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Total Expenses'.tr,
                                                      style: TextStyle(
                                                          color: R.colors.black,
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      " : ${ctr.totalExpansesMontly.value}",
                                                      style: TextStyle(
                                                          color: R.colors.black,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  SizedBox(
                                    width: Get.width,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: R.colors.grey,
                                                    width: 1)),
                                            child: GestureDetector(
                                              onTap: () {
                                                Get.bottomSheet(
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              topRight: Radius
                                                                  .circular(
                                                                      10)),
                                                      color: R.colors.white,
                                                    ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () async {
                                                                // Generate report using selected budget ID and dates
                                                                await ctr.genrateReport(
                                                                  ctr.selectedBudgetId.value,
                                                                  day.toIso8601String(),
                                                                  today.toIso8601String(),
                                                                );

                                                                // Create a new Excel workbook
                                                                final xcel.Workbook workbook = xcel.Workbook();
                                                                final xcel.Worksheet sheet = workbook.worksheets[0];

                                                                // Check if there are any received invoices
                                                                if (ctr.receivedInvoices!.isNotEmpty) {
                                                                  // Set column headers for received invoices
                                                                  sheet.getRangeByIndex(1, 1).setText("Inv number".tr);
                                                                  sheet.getRangeByIndex(1, 2).setText("Created at".tr);
                                                                  sheet.getRangeByIndex(1, 3).setText("Customer".tr);
                                                                  sheet.getRangeByIndex(1, 4).setText("Description".tr);
                                                                  sheet.getRangeByIndex(1, 5).setText("Amount".tr);

                                                                  // Populate received invoices data
                                                                  for (var i = 0; i < ctr.receivedInvoices!.length; i++) {
                                                                    final item = ctr.receivedInvoices![i];
                                                                    var id = (ctr.receivedInvoices!.length - 1) - i;
                                                                    sheet.getRangeByIndex(i + 2, 1).setText((id + 1).toString());
                                                                    sheet.getRangeByIndex(i + 2, 2).setText(item.createdDate.toString());
                                                                    sheet.getRangeByIndex(i + 2, 3).setText(item.customer?.name.toString());
                                                                    sheet.getRangeByIndex(i + 2, 4).setText(item.note ?? '');
                                                                    sheet.getRangeByIndex(i + 2, 5).setText(item.amount.toString());
                                                                  }

                                                                  // Calculate the total for received invoices
                                                                  var total = ctr.receivedInvoices!.fold(0, (sum, item) => sum + int.parse(item.amount.toString()));
                                                                  sheet.getRangeByIndex(ctr.receivedInvoices!.length + 2, 4).setText("Total".tr);
                                                                  sheet.getRangeByIndex(ctr.receivedInvoices!.length + 2, 5).setText(total.toString());
                                                                }

                                                                // Check if there are any sent invoices
                                                                if (ctr.sendInvoices!.isNotEmpty) {
                                                                  var ind = ctr.receivedInvoices!.length + 6;

                                                                  // Set column headers for sent invoices
                                                                  sheet.getRangeByIndex(ind, 1).setText("Inv number".tr);
                                                                  sheet.getRangeByIndex(ind, 2).setText("Created at".tr);
                                                                  sheet.getRangeByIndex(ind, 3).setText("Customer".tr);
                                                                  sheet.getRangeByIndex(ind, 4).setText("Description".tr);
                                                                  sheet.getRangeByIndex(ind, 5).setText("Amount".tr);

                                                                  // Populate sent invoices data
                                                                  for (var i = 0; i < ctr.sendInvoices!.length; i++) {
                                                                    final item = ctr.sendInvoices![i];
                                                                    var id = (ctr.sendInvoices!.length - 1) - i;
                                                                    sheet.getRangeByIndex(i + 2 + ind, 1).setText((id + 1).toString());
                                                                    sheet.getRangeByIndex(i + 2 + ind, 2).setText(item.createdDate.toString());
                                                                    sheet.getRangeByIndex(i + 2 + ind, 3).setText(item.customer?.name.toString());
                                                                    sheet.getRangeByIndex(i + 2 + ind, 4).setText(item.note ?? '');
                                                                    sheet.getRangeByIndex(i + 2 + ind, 5).setText(item.amount.toString());
                                                                  }

                                                                  // Calculate the total for sent invoices
                                                                  var total = ctr.sendInvoices!.fold(0, (sum, item) => sum + int.parse(item.amount.toString()));
                                                                  sheet.getRangeByIndex(ctr.sendInvoices!.length + 2 + ind, 4).setText("Total".tr);
                                                                  sheet.getRangeByIndex(ctr.sendInvoices!.length + 2 + ind, 5).setText(total.toString());
                                                                }

                                                                // Save the Excel file to bytes
                                                                final List<int> bytes = workbook.saveAsStream();

                                                                // Get the directory to save the file
                                                                final directory = (await getApplicationDocumentsDirectory()).path;
                                                                String fileName = DateTime.now().microsecondsSinceEpoch.toString();
                                                                final file = File('$directory/$fileName.xlsx');

                                                                // Write the Excel data to the file
                                                                await file.writeAsBytes(bytes, flush: true);

                                                                try {
                                                                  // Share the file using ShareXFiles
                                                                  Share.shareXFiles([XFile(file.path)]);
                                                                } catch (error) {
                                                                  // Handle sharing error
                                                                  Get.snackbar("Error", error.toString(), backgroundColor: R.colors.blue);
                                                                }

                                                                // Go back to the previous screen
                                                                Get.back();
                                                              },

                                                              child:
                                                                  Image.asset(
                                                                R.images
                                                                    .excelIcon,
                                                                width: 60,
                                                                height: 60,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 20,
                                                            ),
                                                            GestureDetector(
                                                              onTap: () async {
                                                                try {
                                                                  await ctr.genrateReport(ctr.selectedBudgetId.value, day.toIso8601String(), today.toIso8601String());

                                                                  // Calculating totals
                                                                  var totalReceived = ctr.receivedInvoices?.fold(0, (sum, item) => sum + int.parse(item.amount.toString())) ?? 0;
                                                                  var totalSent = ctr.sendInvoices?.fold(0, (sum, item) => sum + int.parse(item.amount.toString())) ?? 0;

                                                                  // Load custom font
                                                                  final fontData = await rootBundle.load("assets/fonts/arabic.ttf");
                                                                  final ttf = pw.Font.ttf(fontData);

                                                                  final pdf = pw.Document();

                                                                  // Generate received invoices page
                                                                  if (ctr.receivedInvoices != null && ctr.receivedInvoices!.isNotEmpty) {
                                                                    pdf.addPage(
                                                                      pw.MultiPage(
                                                                        pageFormat: PdfPageFormat.a4,
                                                                        theme: pw.ThemeData.withFont(base: ttf),
                                                                        build: (pw.Context context) {
                                                                          return <pw.Widget>[
                                                                            pw.Table(children: [
                                                                              pw.TableRow(children: [
                                                                                pw.Text("Inv number", textDirection: pw.TextDirection.rtl),
                                                                                pw.Text("Created at", textDirection: pw.TextDirection.rtl),
                                                                                pw.Text("Customer", textDirection: pw.TextDirection.rtl),
                                                                                pw.Text("Description", textDirection: pw.TextDirection.rtl),
                                                                                pw.Text("Amount", textDirection: pw.TextDirection.rtl),
                                                                              ]),
                                                                              for (var i = 0; i < ctr.receivedInvoices!.length; i++)
                                                                                pw.TableRow(children: [
                                                                                  pw.Text("${ctr.receivedInvoices!.length - i}"),
                                                                                  pw.Text(ctr.receivedInvoices![i].createdDate.toString()),
                                                                                  pw.Text(ctr.receivedInvoices![i].customer?.name ?? '', textDirection: pw.TextDirection.rtl),
                                                                                  pw.Text(ctr.receivedInvoices![i].note ?? ''),
                                                                                  pw.Text(ctr.receivedInvoices![i].amount.toString()),
                                                                                ]),
                                                                              pw.TableRow(children: [
                                                                                pw.Text(""),
                                                                                pw.Text(""),
                                                                                pw.Text(""),
                                                                                pw.Text("Total", textDirection: pw.TextDirection.rtl),
                                                                                pw.Text(totalReceived.toString(), textDirection: pw.TextDirection.rtl),
                                                                              ]),
                                                                            ])
                                                                          ];
                                                                        },
                                                                      ),
                                                                    );
                                                                  }

                                                                  // Generate sent invoices page
                                                                  if (ctr.sendInvoices != null && ctr.sendInvoices!.isNotEmpty) {
                                                                    pdf.addPage(
                                                                      pw.MultiPage(
                                                                        pageFormat: PdfPageFormat.a4,
                                                                        theme: pw.ThemeData.withFont(base: ttf),
                                                                        build: (pw.Context context) {
                                                                          return <pw.Widget>[
                                                                            pw.Table(children: [
                                                                              pw.TableRow(children: [
                                                                                pw.Text("Inv number", textDirection: pw.TextDirection.rtl),
                                                                                pw.Text("Created at", textDirection: pw.TextDirection.rtl),
                                                                                pw.Text("Customer", textDirection: pw.TextDirection.rtl),
                                                                                pw.Text("Description", textDirection: pw.TextDirection.rtl),
                                                                                pw.Text("Amount", textDirection: pw.TextDirection.rtl),
                                                                              ]),
                                                                              for (var i = 0; i < ctr.sendInvoices!.length; i++)
                                                                                pw.TableRow(children: [
                                                                                  pw.Text("${ctr.sendInvoices!.length - i}"),
                                                                                  pw.Text(ctr.sendInvoices![i].createdDate.toString()),
                                                                                  pw.Text(ctr.sendInvoices![i].customer?.name ?? '', textDirection: pw.TextDirection.rtl),
                                                                                  pw.Text(ctr.sendInvoices![i].note ?? ''),
                                                                                  pw.Text(ctr.sendInvoices![i].amount.toString()),
                                                                                ]),
                                                                              pw.TableRow(children: [
                                                                                pw.Text(""),
                                                                                pw.Text(""),
                                                                                pw.Text(""),
                                                                                pw.Text("Total", textDirection: pw.TextDirection.rtl),
                                                                                pw.Text(totalSent.toString(), textDirection: pw.TextDirection.rtl),
                                                                              ]),
                                                                            ])
                                                                          ];
                                                                        },
                                                                      ),
                                                                    );
                                                                  }

                                                                  // Save PDF to temporary directory and share
                                                                  final output = await getTemporaryDirectory();
                                                                  final fileName = "${DateTime.now().microsecondsSinceEpoch}.pdf";
                                                                  final file = File("${output.path}/$fileName");
                                                                  await file.writeAsBytes(await pdf.save());

                                                                  // Sharing the generated PDF
                                                                  await Share.shareXFiles([XFile(file.path)]);
                                                                } catch (error) {
                                                                  Get.snackbar("Error", error.toString(), backgroundColor: Colors.blue);
                                                                }
                                                              },
                                                              child:
                                                                  Image.asset(
                                                                R.images
                                                                    .pdfIcon,
                                                                width: 60,
                                                                height: 60,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    R.images.icon1,
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      'Share Report'.tr,
                                                      style: TextStyle(
                                                          color: R.colors.black,
                                                          fontSize: 10),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Container(
                                            // width: Get.width * 0.25,
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: R.colors.grey,
                                                    width: 1)),
                                            child: GestureDetector(
                                              onTap: () {
                                                _shareQrCode();
                                              },
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    R.images.icon3,
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      'Share QR code'.tr,
                                                      style: TextStyle(
                                                          color: R.colors.black,
                                                          fontSize: 10),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        )),
      ),
    );
  }

  InkWell customSimpleButton(Function()? onPress) {
    return InkWell(
      onTap: onPress,
      child: Container(
        width: Get.width,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: R.colors.themeColor),
        child: Center(
            child: Text(
          'Add'.tr,
          style: TextStyle(color: R.colors.white),
        )),
      ),
    );
  }
}

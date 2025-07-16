import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sarf/controllers/members/members_controller.dart';
import 'package:sarf/model/members/members_list_model.dart';
import 'package:sarf/src/baseview/members/qr_code_scanner.dart';
import 'package:sarf/src/utils/routes_name.dart';

import '../../../resources/resources.dart';
import '../../widgets/custom_appbar.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  MembersController ctr = Get.put<MembersController>(MembersController());
  TextEditingController searchValue = TextEditingController();
  Timer? searchOnStoppedTyping;
  Future<MembersList?>? membersList;
  String membersLenght = '';

  _onChangeHandler(value) {
    searchValue.selection =
        TextSelection.collapsed(offset: searchValue.text.length);
    const duration = Duration(
        milliseconds:
            1000); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping?.cancel()); // clear timer
    }
    setState(() => searchOnStoppedTyping = Timer(duration, () {
          search(value);
        }));
  }

  search(value) {
    // setState(() {
    //    membersLenght = '(0)';
    // });
    FocusScope.of(context).unfocus();
    //print('hello world from search . the value is $value');
    if (value.isEmpty) {
      membersList = ctr.getMembersList('');
      membersList?.then((value) {
        setState(() {
          membersLenght = '(${value?.data?.length ?? 0})';
        });
      });
    }

    membersList = ctr.getMembersList(searchValue.text);
    membersList?.then((value) {
      setState(() {
        membersLenght = '(${value?.data?.length ?? 0})';
      });
    });

    //print(ctr.mobile1.text);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadMembers();
    });
  }

  @override
  void dispose() {
    searchOnStoppedTyping?.cancel();
    super.dispose();
  }

  Future<void> loadMembers() async {
    debugPrint('[Members] Starting loadMembers()');

    try {
      // Show loading indicator
      EasyLoading.instance
        ..indicatorType = EasyLoadingIndicatorType.circle
        ..userInteractions = false;
      EasyLoading.show(status: 'Loading members...');
      debugPrint('[Members] Showing loading indicator');

      debugPrint('[Members] Fetching members list...');
      membersList = ctr.getMembersList('');

      await membersList?.then((value) {
        debugPrint('[Members] Successfully fetched members list');
        debugPrint('[Members] Received ${value?.data?.length ?? 0} members');

        if (mounted) {
          setState(() {
            membersLenght = '(${value?.data?.length ?? 0})';
            debugPrint('[Members] Updated members count: $membersLenght');
          });
        } else {
          debugPrint('[Members] Widget not mounted - skipping UI update');
        }
      }).catchError((error, stackTrace) {
        debugPrint('[Members] Error fetching members list: $error');
        debugPrint('[Members] Stack trace: $stackTrace');

        if (mounted) {
          setState(() {
            membersLenght = '(0)';
            debugPrint('[Members] Reset members count due to error');
          });
        }
      });

      debugPrint('[Members] Members list request completed');
    } catch (e, stackTrace) {
      debugPrint('[Members] Unexpected error in loadMembers(): $e');
      debugPrint('[Members] Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          membersLenght = '(0)';
        });
      }
    } finally {
      // Dismiss loader in all cases
      if (EasyLoading.isShow) {
        await EasyLoading.dismiss();
        debugPrint('[Members] Loading indicator dismissed');
      }
      debugPrint('[Members] loadMembers() completed');
    }
  }
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
        backgroundColor: R.colors.lightGrey,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            customAppBar(
                'Members List'.tr, false, true, membersLenght, false, () {}),
            //appbarSearch(),

            Transform(
              transform: Matrix4.translationValues(0, -20, 0),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: kIsWeb == true ? Get.width * 0.11 : 0),
                child: Container(
                  //margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  padding: const EdgeInsets.symmetric(
                      horizontal: kIsWeb == true ? 0 : 12, vertical: 8),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: R.colors.lightBlue2,
                                border: Border.all(
                                    color: R.colors.lightBlue, width: 1)),
                            child: TextFormField(
                              onTap: () {
                                searchValue.selection = TextSelection.collapsed(
                                    offset: searchValue.text.length);
                              },
                              controller: searchValue,
                              onChanged: _onChangeHandler,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.only(bottom: 5),
                                hintText: 'Search here'.tr,
                                hintStyle: TextStyle(color: R.colors.grey),
                                focusedBorder: InputBorder.none,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const QRScannerScreen(
                                  invoice: false,
                                ));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: R.colors.lightBlue2,
                                border: Border.all(
                                    color: R.colors.lightBlue, width: 1)),
                            child: Center(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.qr_code,
                                    color: R.colors.blue,
                                    //size: 25.sp,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'SCAN'.tr,
                                    style: TextStyle(
                                      color: R.colors.blue,
                                      //fontSize: 25.sp
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Transform(
                transform: Matrix4.translationValues(0, -15, 0),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: kIsWeb == true ? Get.width * 0.11 : 0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: budgetName(),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: FutureBuilder<MembersList?>(
                            future: membersList,
                            builder: (contaxt, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return SizedBox();
                                // Center(child:SizedBox(height: 100,width: 100,child: CircularProgressIndicator(color: R.colors.blue),));
                              }
                              if (snapshot.hasData) {
                                List<SingleMember?> data =
                                    snapshot.data!.data!.toList();
                                if (data.isNotEmpty) {
                                  return GridView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: kIsWeb == true ? 0 : 12),
                                      gridDelegate:
                                          SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        childAspectRatio: kIsWeb == true
                                            ? Get.width > 1150
                                                ? 5
                                                : (MediaQuery.of(context)
                                                        .size
                                                        .width) /
                                                    (MediaQuery.of(context)
                                                            .size
                                                            .height /
                                                        2)
                                            : 1.8,
                                        mainAxisSpacing: 15,
                                        crossAxisSpacing: 10,
                                      ),
                                      itemCount: data.length,
                                      itemBuilder: (context, index) {
                                        var singleData = data[index];
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: GestureDetector(
                                            onTap: () {
                                              ctr.selectExpanseTypeID =
                                                  singleData.id.toString();
                                              Get.toNamed(RoutesName.cityList);
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                // borderRadius: BorderRadius.circular(10),
                                                color: Colors.white,
                                                border: Border(
                                                    left: BorderSide(
                                                        color:
                                                            R.colors.lightBlue3,
                                                        width: 5)),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Type'.tr,
                                                    style: TextStyle(
                                                        color: R.colors.grey,
                                                        fontSize: 12),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Flexible(
                                                      child: Text(
                                                    "${GetStorage().read('lang') == 'en' ? singleData?.expenseName ?? '' : singleData?.expenseNameAr ?? ''} ",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: R.colors.black,
                                                        fontSize: 16),
                                                  )),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.groups,
                                                            color: R.colors
                                                                .themeColor,
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            singleData!
                                                                .membersCount
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: R.colors
                                                                    .themeColor,
                                                                fontSize: 14),
                                                          ),
                                                          const SizedBox(
                                                            width: 2,
                                                          ),
                                                          Text(
                                                            'Members'.tr,
                                                            style: TextStyle(
                                                                color: R.colors
                                                                    .themeColor,
                                                                fontSize: 14),
                                                          ),
                                                        ],
                                                      ),
                                                      Icon(
                                                        Icons.arrow_forward_ios,
                                                        color: R.colors.black,
                                                        size: 15,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                }
                              }
                              return Center(child: Text('No Data'.tr));
                            }),
                      ),
                    ],
                  ),
                ),
              ),

              // GridView.builder(
              //           padding: const EdgeInsets.symmetric(horizontal: 12),
              //           gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              //             maxCrossAxisExtent: MediaQuery.of(context).size.width / 2,
              //             childAspectRatio: 1.8,
              //             mainAxisSpacing: 15,
              //             crossAxisSpacing: 10,

              //           ),
              //           itemCount: 30,
              //            itemBuilder: (context,index){
              //             return ClipRRect(
              //               borderRadius: BorderRadius.circular(10),
              //               child: GestureDetector(
              //                 onTap: (){
              //                   Get.toNamed(RoutesName.cityList);
              //                 },
              //                 child: Container(
              //                   padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              //                   decoration: BoxDecoration(
              //                    // borderRadius: BorderRadius.circular(10),
              //                     color: Colors.white,
              //                     border: Border(left: BorderSide(color: R.colors.lightBlue3,width: 5)),
              //                   ),
              //                   child: Column(
              //                     crossAxisAlignment: CrossAxisAlignment.start,
              //                     children: [
              //                       Text('Type'.tr,style: TextStyle(color: R.colors.grey,fontSize: 12),),
              //                       const SizedBox(height: 5,),
              //                       Text('مأكولات ومشروبات',style: TextStyle(color: R.colors.black,fontSize: 16),),
              //                       const SizedBox(height: 5,),
              //                       Row(
              //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                         children: [
              //                           Row(
              //                             children: [
              //                               Icon(Icons.groups,color: R.colors.themeColor,),
              //                               SizedBox(width: 5,),
              //                               Text('25 Members',style: TextStyle(color: R.colors.themeColor,fontSize: 14),),
              //                             ],
              //                           ),
              //                           Icon(Icons.arrow_forward_ios,color: R.colors.black,size: 15,),
              //                         ],
              //                       ),
              //                     ],
              //                   ),
              //                 ),
              //               ),
              //             );
              //     }),
            ),
          ],
        ),
      ),
    );
  }
}

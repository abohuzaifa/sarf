import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sarf/constant/api_links.dart';
import 'package:sarf/controllers/common/profile_controller.dart';
import 'package:sarf/controllers/members/members_controller.dart';
import 'package:sarf/src/baseview/members/chat/view/chat_view.dart';
import 'package:sarf/src/baseview/members/qr_code_scanner.dart';
import 'package:sarf/src/baseview/members/single_member_detail.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../model/members/members_list_new_model.dart';
import '../../../resources/resources.dart';
import '../../../services/notification_services.dart';
import '../../widgets/custom_appbar.dart';

class MembersListScreen extends StatefulWidget {
  const MembersListScreen({super.key});

  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> {
  MembersController ctr = Get.find<MembersController>();

  TextEditingController searchValue = TextEditingController();
  Timer? searchOnStoppedTyping;
  Future<ListMembersNewList?>? cityList;
  String membersLenght = "";
  ProfileController ctrProfile = Get.find<ProfileController>();
  NotificationServices notificationServices = NotificationServices();

  _onChangeHandler(value ) {
        const duration = Duration(milliseconds:1000); // set the duration that you want call search() after that.
        if (searchOnStoppedTyping != null) {
            setState(() => searchOnStoppedTyping?.cancel()); // clear timer
        }
        setState(() => searchOnStoppedTyping =  Timer(duration, () => search(value)));
    }

    search(value) {
      FocusScope.of(context).unfocus();
        //print('hello world from search . the value is $value');
        if(value.isEmpty){
          
            cityList = ctr.getMembersNewList(ctr.selectExpanseTypeID, ctr.selectCityID, '');
            cityList?.then((value){
              setState(() {
                membersLenght = '(${value?.data?.length ?? 0})';
              });
            });
          
        }
        
          cityList = ctr.getMembersNewList(ctr.selectExpanseTypeID, ctr.selectCityID, searchValue.text);
          cityList?.then((value){
              setState(() {
                membersLenght = '(${value?.data?.length ?? 0})';
              });
            });
        //print(ctr.mobile1.text);
        
    }

     static void navigateTo(double lat, double lng) async {
   
   if (await canLaunchUrl(Uri.parse("google.navigation:q=$lat,$lng&mode=d"))) {
      await launchUrl (Uri.parse("google.navigation:q=$lat,$lng&mode=d"));
   } else {
    Get.snackbar('Error'.tr, 'Could not launch'.tr);
      throw 'Could not launch ${Uri.parse("google.navigation:q=$lat,$lng&mode=d")}';
   }
}
@override
void initState() {
    super.initState();
    loadMembers();

}
@override
void dispose(){
  searchOnStoppedTyping?.cancel();
  super.dispose();
}

  Future<void> loadMembers() async {
    debugPrint('[Members] Starting loadMembers()');

    try {
      // Load profile first
      debugPrint('[Members] Initiating profile load...');
      await ctrProfile.getProfile().then((value) {
        debugPrint('[Members] Profile load completed');
        debugPrint('[Members] Profile name: ${ctrProfile.profileModel?.user?.name ?? 'Not available'}');
      }).catchError((error) {
        debugPrint('[Members] Error loading profile: $error');
      });

      // Load member list
      debugPrint('[Members] Initiating members list load...');
      debugPrint('[Members] Parameters:');
      debugPrint('[Members] - Expense Type ID: ${ctr.selectExpanseTypeID}');
      debugPrint('[Members] - City ID: ${ctr.selectCityID}');

      cityList = ctr.getMembersNewList(ctr.selectExpanseTypeID, ctr.selectCityID, '');

      cityList?.then((value) {
        debugPrint('[Members] Members list load completed');
        debugPrint('[Members] Found ${value?.data?.length ?? 0} members');

        setState(() {
          membersLenght = '(${value?.data?.length ?? 0})';
          debugPrint('[Members] Updated UI with members count: $membersLenght');
        });
      }).catchError((error) {
        debugPrint('[Members] Error loading members list: $error');
        setState(() {
          membersLenght = '(0)';
          debugPrint('[Members] Reset members count due to error');
        });
      });
    } catch (e, stackTrace) {
      debugPrint('[Members] Unhandled error in loadMembers(): $e');
      debugPrint('[Members] Stack trace: $stackTrace');
      setState(() {
        membersLenght = '(0)';
      });
    } finally {
      debugPrint('[Members] loadMembers() completed');
    }
  }

  void launchWhatsApp(String phone) async {
  final Uri whatsApp = Uri.parse("https://wa.me/$phone/?text=Hi");

    await launchUrl(whatsApp,mode: LaunchMode.externalApplication).catchError((erorr){
      // debugPrint(erorr.toString());
      Get.snackbar('Error'.tr, 'Could not launch'.tr);
    });
}


void launchUrls(String url) async {
  

  
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication).catchError((erorr){
      // debugPrint(erorr.toString());
      Get.snackbar('Error'.tr, 'Could not launch'.tr);
    });
  
}

launchPhone({required Uri u}) async {
  if (await canLaunchUrl(u)) {
    await launchUrl(u);
  } else {
    Get.snackbar('Error'.tr, 'Could not launch'.tr);
    throw 'Could not launch $u';
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.colors.lightGrey,
      body:  Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            customAppBar('Members List'.tr,true,true,membersLenght,false,(){}),
           // appbarSearch(),
           Transform(
          transform: Matrix4.translationValues(0, -20, 0),
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: kIsWeb == true ? Get.width * 0.11 : 0),
            child: Container(
              //margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              padding: const EdgeInsets.symmetric(horizontal: kIsWeb == true ? 0 :  12, vertical: 8),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: Container(
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 0),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color: R.colors.lightBlue2,
                                    border: Border.all(color: R.colors.lightBlue,width: 1) ),
                                    child:
                                    TextFormField(
                                       onTap: (){
                                          searchValue.selection = TextSelection.collapsed(offset: searchValue.text.length);
                                        },
                                      controller: searchValue,
                                      onChanged: _onChangeHandler,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(bottom: 5),
                                        hintText: 'Search here'.tr,
                                        hintStyle: TextStyle(color: R.colors.grey),
                                        focusedBorder: InputBorder.none,
                                        border: InputBorder.none,

                                      ),
                                    ),
                                  ),),
                                  const SizedBox(width: 10,),
                                  GestureDetector(
                                    onTap: (){
                                      Get.to(() => const QRScannerScreen(invoice: false,) );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color: R.colors.lightBlue2,border: Border.all(color: R.colors.lightBlue,width: 1)),
                                      child: Center(child: Row(
                                        children: [
                                              Icon(
                                                Icons.qr_code,
                                                color: R.colors.blue,
                                                //size: 25.sp,
                                              ),
                                              const SizedBox(width: 5,),
                                              Text('SCAN'.tr,style: TextStyle(color: R.colors.blue,
                                              //fontSize: 25.sp
                                              ),)
                                        ],
                                      ),),
                                    ),
                                  )
                  ],
                ),
              ),
            ),
          ),
        ),
            const SizedBox(height: 10,),
            Expanded(child:
            Transform(
              transform: Matrix4.translationValues(0, -20, 0),
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: kIsWeb == true ? Get.width > 750 ? Get.width * 0.11 : 0  : 0),
                child: Column(
                  children: [
                    Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: budgetName(),
                        ),
                        const SizedBox(height: 10,),
                    Expanded(
                      child: FutureBuilder<ListMembersNewList?>(
                      future: cityList,
                      builder: (contaxt,snapshot){
                        if(snapshot.connectionState == ConnectionState.waiting){
                          // return SizedBox();
                          Center(child:SizedBox(height: 100,width: 100,child: CircularProgressIndicator(color: R.colors.blue),));
                        }
                        if(snapshot.hasData){

                          List<Data> data = snapshot.data!.data!;
                          if(data.isNotEmpty){
                           return ListView.builder(
                        padding:  EdgeInsets.symmetric(horizontal: kIsWeb == true ? Get.width > 750 ? 0 : 12 : 12),
                        itemCount: data.length,
                        shrinkWrap: true,
                        itemBuilder: (context,index){
                          var singleData = data[index];
                        return GestureDetector(
                          onTap: () => Get.to(() =>  SingleMemberDetails(title: singleData.name ?? '',id: singleData.id.toString(),)),
                          child: Container(
                            width: Get.width,
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: R.colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:  [
                                Container(
                                  padding: const EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: R.colors.blackSecondery,width: 1)
                                  ),
                                  child: singleData.photo != null? CircleAvatar(radius: 25,backgroundImage: NetworkImage("${ApiLinks.assetBasePath}${singleData.photo}"),)  : Container(width: 40,height: 40,)
                                  //Image.network("${ApiLinks.assetBasePath}${singleData.photo}",width: 40,height: 40,fit: BoxFit.cover,)
                                  // CircleAvatar(
                                  //   radius: 25,
                                  //   backgroundImage: singleData.photo != null? Image(image: Net,)  :AssetImage(R.images.pharmacy),
                                  // ),
                                ),
                                const SizedBox(width: 10,),
                                Expanded(child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(singleData.name ?? '',style: TextStyle(color: R.colors.black,fontSize: 16),),
                                    const SizedBox(height: 5,),
                                    Text(singleData.userDetail?.location ?? '',style: TextStyle(color: R.colors.grey,fontSize: 12),),
                                    const SizedBox(height: 8,),
                                    Row(
                                      children: [
                                        Text('Total Invoices'.tr,style: TextStyle(color: R.colors.grey,fontSize: 14),),
                                        const SizedBox(width: 10,),
                                        Text("${singleData.invoicesCount ?? 0}",style: TextStyle(color: R.colors.black,fontSize: 14),),
                                      ],
                                    ),
                                    const SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        Text('Total Expenses'.tr,style: TextStyle(color: R.colors.grey,fontSize: 14),),
                                        const SizedBox(width: 10,),
                                        Text(  "${singleData.invoicesSumAmount ?? 0}",style: TextStyle(color: R.colors.black,fontSize: 14),),
                                      ],
                                    ),
                                     const SizedBox(height: 10,),
                              Divider(
                                color: R.colors.grey,
                                thickness: 1,
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: GestureDetector(
                                    onTap: (){
                                      // print(singleData.userDetail?.locationLat);
                                      double lat = 0.0;
                                      double lng = 0.0;
                                      if(singleData.userDetail?.locationLat != null){
                                        lat = double.parse(singleData.userDetail!.locationLat!);
                                      }
                                      if(singleData.userDetail?.locationLng != null){
                                        lng = double.parse(singleData.userDetail!.locationLng!);
                                      }
                                      if(
                                        singleData.userDetail?.locationLng == null || singleData.userDetail?.locationLat == null
                                      ){
                                        // print("here");
                                        Get.snackbar("Error".tr, 'No Direction'.tr);
                                        return;
                                      }
                                      if(singleData.userDetail?.locationLng != null && singleData.userDetail?.locationLat != null ){
                                        navigateTo(lat, lng);
                                      }

                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on_sharp,size: 20,color: R.colors.black,),
                                        const SizedBox(width: 8,),
                                        Flexible(
                                          child: Text(singleData.userDetail?.location ?? '',
                                          style:TextStyle(color: R.colors.black,fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                                  const SizedBox(width: 3,),
                                  GestureDetector(
                                    onTap: (){
                                      // print(singleData.userDetail?.location);
                                      double lat = 0.0;
                                      double lng = 0.0;
                                      if(singleData.userDetail?.locationLat != null){
                                        lat = double.parse(singleData.userDetail!.locationLat!);
                                      }
                                      if(singleData.userDetail?.locationLng != null){
                                        lng = double.parse(singleData.userDetail!.locationLng!);
                                      }
                                      if(
                                        singleData.userDetail?.locationLng == null || singleData.userDetail?.locationLat == null
                                      ){
                                        // print("here");
                                        Get.snackbar("Error".tr, 'No Direction'.tr);
                                        return;
                                      }
                                      if(singleData.userDetail?.locationLng != null && singleData.userDetail?.locationLat != null ){
                                        navigateTo(lat, lng);
                                      }

                                    },
                                    child: Row(
                                      children: [
                                        Text('Directions'.tr,
                                          style:TextStyle(color: R.colors.themeColor,fontSize: 14,fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(width: 5,),
                                          Icon(Icons.directions,color: R.colors.themeColor,size: 20,),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: (){
                                                launchUrls('https://twitter.com/${singleData.userDetail?.twitterLink}');
                                              },
                                              child: Image.asset(R.images.twitter,width: 30,height: 30,)),
                                            const SizedBox(width: 5,),
                                            GestureDetector(
                                              onTap: (){
                                                launchUrls('https://instagram.com/${singleData.userDetail?.instaLink}');
                                                //ctr.memDetails.value.data?.userDetail?.whatsapp
                                              },
                                              child: Image.asset(R.images.insta,width: 30,height: 30,)),
                                            const SizedBox(width: 5,),
                                            GestureDetector(
                                              onTap: (){
                                                launchUrls('${singleData.userDetail?.website}');
                                              },
                                              child: Image.asset(R.images.web,width: 30,height: 30,)),
                                            const SizedBox(width: 5,),
                                            GestureDetector(
                                              onTap: (){
                                                //print("aaaaaaaaaaaaa${ctr.memDetails.value.data?.userDetail?.whatsapp}");
                                                launchWhatsApp(singleData.userDetail?.whatsapp ?? "");
                                              },
                                              child: Image.asset(R.images.whatsapp,width: 30,height: 30,)),
                                            const SizedBox(width: 5,),
                                            GestureDetector(
                                              onTap: (){
                                                final Uri teleLaunchUri = Uri(
                                                                              scheme: 'tel',
                                                                              path: "${singleData.userDetail?.contactNo}", // your number
                                                                            );
                                                launchPhone(u: teleLaunchUri);
                                              },
                                              child: Image.asset(R.images.call,width: 30,height: 30,)),
                                            const SizedBox(width: 5,),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () async{
                                            var fcm = '';
                                          await notificationServices.getDeviceToken().then((value) => fcm = value);
                                           Get.to(() => ChatScreen(title: singleData.name!,email: singleData.mobile.toString(),
                                          otherUserPhoto: singleData.photo ?? '',
                                          curretUserPhoto: ctrProfile.profileModel?.user?.photo ?? '',
                                          userFcm: singleData.androidDeviceId == '' ? singleData.iosDeviceId ?? '' : singleData.androidDeviceId ?? ''  ,
                                          currentFcm: fcm,
                                          )); },
                                          child: SizedBox(
                                            height: 40,
                                            child: Row(children: [
                                              Text('Chat'.tr,style: TextStyle(color: R.colors.themeColor,fontSize: 14),),
                                              const SizedBox(width: 4,),
                                              Icon(Icons.chat,color: R.colors.themeColor,size: 15,),
                                            ],),
                                          ),
                                        )

                                    ],)
                                  ],
                                )),
                              ],
                            ),
                          ),
                        );
                      });
                          }
                        }
                        return Center(child:Text('No Data'.tr));
                      }),
                    ),
                  ],
                ),
              ),
            ),
            )
            // Expanded(child: GridView.builder(
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
                              
            //                 },
            //                 child: Container(
            //                   padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            //                   decoration: const BoxDecoration(
            //                    // borderRadius: BorderRadius.circular(10),
            //                     color: Colors.white,
            //                    // border: Border(left: BorderSide(color: R.colors.lightBlue3,width: 5)),
            //                   ),
            //                   child: Column(
            //                     crossAxisAlignment: CrossAxisAlignment.start,
            //                     children: [
            //                       Text('City',style: TextStyle(color: R.colors.grey,fontSize: 12),),
            //                       const SizedBox(height: 5,),
            //                       Text('Madinah',style: TextStyle(color: R.colors.black,fontSize: 16),),
            //                       const SizedBox(height: 5,),
            //                       Row(
            //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                         children: [
            //                           Row(
            //                             children: [
            //                               Icon(Icons.groups,color: R.colors.themeColor,),
            //                               const SizedBox(width: 5,),
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
            //     })),
          ],
        ),
      
    );
  }

  
}
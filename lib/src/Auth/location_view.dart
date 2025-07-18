import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:sarf/controllers/common/profile_controller.dart';

import '../../constant/global_constants.dart';
import '../../controllers/auth/registration_controller.dart';
import '../../resources/resources.dart';
import '../widgets/custom_appbar.dart';

class LocationView extends StatefulWidget {
  const LocationView({super.key});

  @override
  State<LocationView> createState() => _LocationViewState();
}

class _LocationViewState extends State<LocationView> {
  RegistrationController registrationController =
  Get.find<RegistrationController>();
  ProfileController? profileController;
  String label = '';
  String address = '';
  String lat = '';
  String lng = '';
  var locationLatGiven;
  var locationLngGiven;

  late final String screenDecider;
  late final bool isFromRegistration;

  CameraPosition? cameraPosition;
  List<Marker> marker = [];
  GoogleMapController? mapController;
  LatLng startLocation = LatLng(0, 0);
  String location = "Search".tr;
  bool hasValidLocation = false;

  @override
  void initState() {
    super.initState();

    debugPrint('[LocationView] initState called');
    debugPrint('[LocationView] Get.arguments: ${Get.arguments}');

    // Initialize screen decider
    screenDecider = (Get.arguments != null &&
        Get.arguments['Screen'] == 'From Profile Screen')
        ? 'From Profile Screen'
        : 'From Register Screen';

    isFromRegistration = screenDecider == 'From Register Screen';
    debugPrint('[LocationView] Screen decider: $screenDecider');

    // Only initialize profile controller if coming from profile screen
    if (!isFromRegistration) {
      profileController = Get.put<ProfileController>(ProfileController());
    }

    // Check if we have valid location arguments
    if (Get.arguments != null &&
        Get.arguments['lat'] != null &&
        Get.arguments['lng'] != null) {
      debugPrint(
          '[LocationView] Initializing with provided location: lat=${Get.arguments['lat']}, lng=${Get.arguments['lng']}');
      startLocation = LatLng(Get.arguments['lat'], Get.arguments['lng']);
      cameraPosition = CameraPosition(
        target: startLocation,
        zoom: 20.0,
      );
      hasValidLocation = true;
    } else {
      debugPrint('[LocationView] No location provided, getting current position');
      _determinePosition().then((position) {
        debugPrint(
            '[LocationView] Got current position: lat=${position.latitude}, lng=${position.longitude}');
        setState(() {
          startLocation = LatLng(position.latitude, position.longitude);
          cameraPosition = CameraPosition(
            target: startLocation,
            zoom: 20.0,
          );
          hasValidLocation = true;
        });
      }).catchError((error) {
        debugPrint('[LocationView] Error getting position: $error');
        setState(() {
          startLocation = const LatLng(0, 0);
          cameraPosition = CameraPosition(
            target: startLocation,
            zoom: 20.0,
          );
        });
      });
    }
  }

  Future<Position> _determinePosition() async {
    debugPrint('[LocationView] Determining position...');
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('[LocationView] Location services are disabled');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      debugPrint('[LocationView] Requesting location permission');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('[LocationView] Location permission denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('[LocationView] Location permission permanently denied');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    debugPrint('[LocationView] Getting current position...');
    return await Geolocator.getCurrentPosition();
  }

  void handleTap(LatLng argument) async {
    debugPrint('[LocationView] Map tapped at: $argument');
    await placemarkFromCoordinates(argument.latitude, argument.longitude)
        .then((value) {
      List<Placemark> placemarks = value;
      if (mounted) {
        debugPrint(
            '[LocationView] Found placemark: ${placemarks.first.toJson()}');
        setState(() {
          marker = [];
          marker.add(Marker(
            markerId: MarkerId(argument.toString()),
            position: argument,
          ));
          location =
          "${placemarks.first.administrativeArea},${placemarks.first.subAdministrativeArea},${placemarks.first.subLocality}, ${placemarks.first.thoroughfare}, ${placemarks.first.street}, ${placemarks.first.country}";
          address = location;
          lat = argument.latitude.toString();
          lng = argument.longitude.toString();
        });
        debugPrint('[LocationView] Updated location: $location');
        debugPrint('[LocationView] Updated coordinates: lat=$lat, lng=$lng');
      }
    }).catchError((error) {
      debugPrint('[LocationView] Error getting placemark: $error');
    });
  }

  void _saveLocationAndHandleNavigation() {
    debugPrint('[LocationView] Done button tapped');
    debugPrint('[LocationView] Selected location: $location');
    debugPrint('[LocationView] Selected coordinates: lat=$lat, lng=$lng');

    if (address.isEmpty || lat.isEmpty || lng.isEmpty) {
      debugPrint('[LocationView] No location selected - showing error');
      Get.snackbar('Error', 'Please select a location');
      return;
    }

    if (isFromRegistration) {
      debugPrint('[LocationView] Saving to registration controller');
      registrationController.location.value = location;
      registrationController.location_lat.value = lat;
      registrationController.location_lng.value = lng;
      debugPrint('[LocationView] Registration controller updated');
      // No navigation back for registration screen
      Get.back();
    } else {
      debugPrint('[LocationView] Saving to profile controller');
      profileController?.location.value = location;
      profileController?.location_lat.value = lat;
      profileController?.location_lng.value = lng;
      debugPrint('[LocationView] Profile controller updated - going back');
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[LocationView] Building widget');
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (hasValidLocation)
              Stack(
                children: [
                  GoogleMap(
                    zoomGesturesEnabled: true,
                    initialCameraPosition: cameraPosition!,
                    myLocationButtonEnabled: false,
                    myLocationEnabled: false,
                    zoomControlsEnabled: false,
                    padding: const EdgeInsets.only(top: 130),
                    mapType: MapType.normal,
                    onMapCreated: (controller) {
                      debugPrint('[LocationView] Map created');
                      setState(() {
                        mapController = controller;
                        marker.add(Marker(
                            markerId: const MarkerId('default'),
                            position: startLocation));
                      });
                      handleTap(startLocation);
                    },
                    onTap: handleTap,
                    markers: Set.from(marker),
                    onCameraMove: (CameraPosition cameraPositiona) {
                      cameraPosition = cameraPositiona;
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: InkWell(
                        onTap: _saveLocationAndHandleNavigation,
                        child: Container(
                          width: Get.width - 40,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: R.colors.themeColor),
                          child: Center(
                              child: Text(
                                'Done'.tr,
                                style: TextStyle(color: R.colors.white),
                              )),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Center(
                child: CircularProgressIndicator(),
              ),
            customAppBar('Select Location'.tr, true, true, '', false, () {}),
            if (hasValidLocation)
              Container(
                margin: const EdgeInsets.only(top: 75),
                child: InkWell(
                  onTap: () async {
                    debugPrint('[LocationView] Search location tapped');
                    var place = await PlacesAutocomplete.show(
                        context: context,
                        apiKey: googleMapsKey,
                        mode: Mode.overlay,
                        types: [],
                        strictbounds: false,
                        onError: (err) {
                          debugPrint(
                              '[LocationView] PlacesAutocomplete error: ${err.errorMessage}');
                        }).then((value) async {
                      if (value != null) {
                        debugPrint(
                            '[LocationView] Place selected: ${value.description}');
                        final plist = GoogleMapsPlaces(
                          apiKey: googleMapsKey,
                          apiHeaders:
                          await const GoogleApiHeaders().getHeaders(),
                        );
                        String placeid = value.placeId ?? "0";
                        debugPrint(
                            '[LocationView] Getting place details for ID: $placeid');
                        final detail = await plist.getDetailsByPlaceId(placeid);
                        final geometry = detail.result.geometry!;
                        final lat = geometry.location.lat;
                        final lang = geometry.location.lng;
                        var newlatlang = LatLng(lat, lang);
                        debugPrint(
                            '[LocationView] Place coordinates: lat=$lat, lng=$lang');

                        mapController?.animateCamera(
                            CameraUpdate.newCameraPosition(
                                CameraPosition(target: newlatlang, zoom: 17)));
                        setState(() {
                          marker.clear();
                          location = value.description.toString();
                          marker.add(Marker(
                              markerId: MarkerId('$newlatlang'),
                              position: newlatlang));
                          address = location;
                          this.lat = lat.toString();
                          lng = lang.toString();
                        });
                        debugPrint(
                            '[LocationView] Map updated with new location');
                        Get.back();
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Container(
                      height: 40,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: R.colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: R.colors.lightGrey,
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width - 40,
                        child: Text(
                          location.tr,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
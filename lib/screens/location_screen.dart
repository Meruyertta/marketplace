import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';
import 'package:marketplace/screens/home_screen.dart';
import 'package:marketplace/screens/welcome_screen.dart';
import 'package:marketplace/services/firebase_service.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';

import '../providers/auth_provider.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  static const String id = 'home-screen';

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String countryValue="";
  String? stateValue = "";
  String? cityValue = "";
  String manualAddress = "";
  String _address = "";

  bool _loading = false;

  FirebaseService _service = FirebaseService();

  Location location = new Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  Future<LocationData?> getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();
    print('location in location_screen'+_locationData.toString());

    final geoCode = GeoCode();

    var addresses = await geoCode.reverseGeocoding(
        latitude: _locationData.latitude!, longitude: _locationData.longitude!);

    var addressData = addresses;

    setState(() {
      // _address=addresses.city!.toString()+' '+addresses.countryName!.toString();
      _address = addressData.streetAddress.toString() +
          ', ' +
          addresses.city.toString() +
          ', ' +
          addresses.region.toString() +
          ', ' +
          addresses.countryName.toString();
      countryValue = addressData.countryName!;
    });
    print(_locationData);

    return _locationData;
  }

  @override
  Widget build(BuildContext context) {
    ProgressDialog progressDialog = ProgressDialog(
      context: context,
      textColor: Colors.black,
      backgroundColor: Colors.white,
      loadingText: 'Fetching location...',
      progressIndicatorColor: Theme.of(context).primaryColor,
    );

    showBottomScreen(context) {
      getLocation().then((location) {
        if (location != null) {
          progressDialog.dismiss();
          //only after fetching location the bottom screen will be opened
          showModalBottomSheet(
              isScrollControlled: true,
              enableDrag: true,
              context: context,
              builder: (context) {
                return Column(
                  children: [
                    SizedBox(height: 25),
                    AppBar(
                      automaticallyImplyLeading: false,
                      iconTheme: IconThemeData(
                        color: Colors.black,
                      ),
                      elevation: 1,
                      backgroundColor: Colors.white,
                      title: Row(children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.clear),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Location', style: TextStyle(color: Colors.black))
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: SizedBox(
                          height: 40,
                          child: TextFormField(
                              decoration: InputDecoration(
                            hintText: 'Search city, area or neighbourhood',
                            hintStyle: TextStyle(color: Colors.grey),
                            icon: Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Icon(Icons.search),
                            ),
                          )),
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        progressDialog.show();
                        getLocation().then((value) {
                          if (value != null) {
                            _service.updateUser({
                              'location': GeoPoint(value.latitude!,
                                  value.longitude!),
                              'address': _address
                            }, context).then((value) {
                              progressDialog.dismiss();
                              Navigator.pushNamed(context, HomeScreen.id);
                            });
                          }
                        });
                        //save address to firebase
                      },
                      horizontalTitleGap: 0.0,
                      leading:
                          Icon(Icons.my_location_rounded, color: Colors.blue),
                      title: Text('Use current location',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          location == null ? 'Fetching location' : _address,
                          style: TextStyle(fontSize: 12)),
                    ),
                    Container(
                      color: Colors.grey.shade300,
                      width: MediaQuery.of(context).size.width, //screen size
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('CHOOSE CITY',
                            style: TextStyle(
                                color: Colors.blueGrey.shade900, fontSize: 12)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CSCPicker(
                        layout: Layout.vertical,
                        flagState: CountryFlag.DISABLE,
                        dropdownDecoration:
                            BoxDecoration(shape: BoxShape.rectangle),
                        defaultCountry: DefaultCountry.Kazakhstan,
                        onCountryChanged: (value) {
                          setState(() {
                            countryValue = value;

                          });
                        },
                        onStateChanged: (value) {
                          setState(() {
                            stateValue = value;
                            print(stateValue);
                          });
                        },
                        onCityChanged: (value) {
                          setState(() {
                            cityValue = value;
                            manualAddress =
                                '$cityValue, $stateValue, $countryValue';
                            print(manualAddress);
                          });

                          if (value != null) {
                            _service.updateUser({
                              'address': manualAddress,
                              'state': stateValue,
                              'city': cityValue,
                              'country': countryValue,
                            }, context).then((value) {
                              //after updating location data to firestore,
                              //will move on to home screen
                              Navigator.pushNamed(context, HomeScreen.id);
                            });
                          }

                          print("_address:"+_address);
                        },
                      ),
                    ),
                  ],
                );
              });
        } else {
          progressDialog.dismiss();
        }
      });
    }

    // final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Image.asset('images/location.png'),
            SizedBox(
              height: 20,
            ),
            Text(
              'Where do you want\nto buy/sell products?',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'To enjoy all that we have to offer you\nwe need to know where to look for them',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: _loading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            label: Padding(
                              padding:
                                  const EdgeInsets.only(top: 15, bottom: 15),
                              child: Text('Around me', style: TextStyle()),
                            ),
                            icon: Icon(CupertinoIcons.location_fill),
                            onPressed: () {
                              progressDialog.show();
                              setState(() {
                                _loading = true;
                              });
                              getLocation().then((value) {
                                if (value != null) {
                                  Navigator.pushReplacement(
                                    context, MaterialPageRoute(
                                    builder: (BuildContext context)=>
                                        HomeScreen(
                                          locationData: _locationData,
                                        ),
                                  ),
                                  );
                                }
                              });
                            },
                          ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                progressDialog.show();
                showBottomScreen(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 2))),
                  child: Text(
                    'Set location manually',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}

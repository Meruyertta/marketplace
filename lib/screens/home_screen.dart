import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:location/location.dart';
import 'package:marketplace/screens/location_screen.dart';
import 'package:marketplace/screens/welcome_screen.dart';
import 'package:marketplace/widgets/custom_appBar.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.locationData}) : super(key: key);

 final  LocationData locationData;
  static const String id='home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
   String address='Kazakhstan';


   Future<String?> getAddress() async{
     final geoCode = GeoCode();
     var addresses=await geoCode.reverseGeocoding(latitude: widget.locationData.latitude!, longitude: widget.locationData.longitude!);
     var country=addresses.countryName;
     setState(() {
       address=country!;
     });

     return country;
   }

   @override
   void initState() {
    // TODO: implement initState
     getAddress();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: SafeArea(child: CustomAppBar()),
        
      ),
      body:Center(
        child: ElevatedButton(
          child:Text('Go to welcome page'),
          onPressed:(){
            FirebaseAuth.instance.signOut().then((value) {
              Navigator.pushReplacementNamed(context, WelcomeScreen.id);
            });
            // Navigator.pushReplacementNamed(context, LocationScreen.id);
          }
        ),
      )
    );
  }
}

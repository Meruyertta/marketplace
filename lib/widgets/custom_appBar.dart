import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marketplace/services/firebase_service.dart';

import '../screens/location_screen.dart';

class CustomAppBar extends StatelessWidget {
   CustomAppBar({Key? key}) : super(key: key);

  FirebaseService _service=FirebaseService();


  @override
  Widget build(BuildContext context) {

    return FutureBuilder<DocumentSnapshot>(
      future: _service.users.doc(_service.user?.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Address not selected");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

          if(data['address']==null){
            //then will check next data
            if(data['state']==null){
             GeoPoint latLong=data['location'];
             _service.getAddress(latLong.latitude, latLong.longitude).then((address) {
               appBar(address,context);
             });
            }
          }else{
            return appBar(data['state'],context);
          }

          return appBar('Update location', context);
        }

        return Text("Fetching location...");
      },
    );
  }

  Widget appBar(address,context){
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.0,
      title: InkWell(
        onTap: (){
          print('location screen should be opened');
          Navigator.of(context).pushReplacementNamed(LocationScreen.id);
        },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            // child: Padding(
              // padding: const EdgeInsets.only(top:8, bottom:8),
              child: Row(
                children: [
                  Icon(CupertinoIcons.location_solid,color: Colors.black,size: 18),
                  SizedBox(width:5),
                  Text(address, style: TextStyle(color: Colors.black,fontSize:16,fontWeight: FontWeight.w600),textAlign: TextAlign.start,),
                  Icon(Icons.keyboard_arrow_down_outlined,color: Colors.black,size:25),
                ],
              ),
            ),

        // ),
      ),
    );
  }
}

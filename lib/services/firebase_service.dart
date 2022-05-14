import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';

import '../screens/home_screen.dart';
class FirebaseService{
  CollectionReference users=FirebaseFirestore.instance.collection('users');
  User? user=FirebaseAuth.instance.currentUser;

  Future<void> updateUser(Map<String,dynamic>data,context) {
    return users
        .doc(user?.uid)
        .update(data)
        .then((value) => Navigator.pushNamed(context, HomeScreen.id))
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update location'),
            ),
          );
    });
  }

  Future<String?> getAddress(lat,long) async{
    final geoCode = GeoCode();

    var addresses = await geoCode.reverseGeocoding(
        latitude: lat, longitude:long);

    var addressData = addresses;

    return addressData.city;
  }

}
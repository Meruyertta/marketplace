import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:marketplace/providers/auth_provider.dart';
import 'package:marketplace/screens/home_screen.dart';
import 'package:marketplace/screens/location_screen.dart';
import 'package:marketplace/screens/onboard_screen.dart';
import 'package:marketplace/screens/register_screen.dart';
import 'package:marketplace/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:marketplace/screens/splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // runApp(const MyApp());
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create:(_)=>AuthProvider(),
    )
  ],
    child: MyApp(),
  ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
          fontFamily:'Poppins'
      ),
      initialRoute: SplashScreen.id,
      routes:{
        LocationScreen.id:(context)=>LocationScreen(),
        WelcomeScreen.id:(context)=>WelcomeScreen(),
        SplashScreen.id:(context)=>SplashScreen(),
      },
    );
  }
}


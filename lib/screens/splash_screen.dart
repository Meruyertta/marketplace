import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marketplace/screens/onboard_screen.dart';
import 'package:marketplace/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'location_screen.dart';

class SplashScreen extends StatefulWidget {
    const SplashScreen({Key? key}) : super(key: key);

    static const String id='splash-screen';

    @override
    State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
    @override
    void initState() {
        Timer(
            Duration(
                seconds: 4,
        ),(){
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if(user==null){
           Navigator.pushReplacementNamed(context, WelcomeScreen.id);
        }else {
            Navigator.pushReplacementNamed(context, LocationScreen.id);
        }
    });
    }
        );
        super.initState();
    }
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Center(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
        children: [
        Image.asset('images/logo.png'),
        Text('OLX', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))
        ],
        )
        )
        );
    }
}


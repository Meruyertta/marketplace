import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marketplace/screens/welcome_screen.dart';
import 'package:marketplace/services/user_services.dart';

import '../screens/home_screen.dart';
import '../screens/location_screen.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String smsOtp = '';
  String verificationId = '';
  String error = '';
  UserServices _userServices = UserServices();

  Future<void> verifyPhone(BuildContext context, String number) async {
    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential credential) async {
      await _auth.signInWithCredential(credential);
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
      print(e.code);
    };

    final PhoneCodeSent codeSent =
        (String verificationId, int? resendToken) async {
      this.verificationId = verificationId;

      //dialog to enter received sms

      smsOtpDialog(context, number);
    };

    try {
      _auth.verifyPhoneNumber(
        phoneNumber: number,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId = verificationId;
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future smsOtpDialog(BuildContext context, String number) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              children: [
                Text('Verification Code'),
                SizedBox(height: 20),
                Text('Enter 6 digit code received by sms',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            content: Container(
                height: 85,
                child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    onChanged: (value) {
                      this.smsOtp = value;
                    })),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                            verificationId: verificationId, smsCode: smsOtp);
                    final User? user =
                        (await _auth.signInWithCredential(credential)).user;

                    //create user data in firestore after user registered s
                    _createUser(id: user!.uid, number: user.phoneNumber);

                    //navigate to Home page after login
                    if (user != null) {
                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(
                          context, LocationScreen.id);
                      print('Login success');
                    } else {
                      print('Login failed');
                    }
                  } catch (e) {
                    this.error = 'Invalid code';
                    print(e.toString());
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  'DONE',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          );
        });
  }

  void _createUser({required String id, required String? number}) {
    _userServices.createUser({
      'id': id,
      'number': number,
    });
  }
}

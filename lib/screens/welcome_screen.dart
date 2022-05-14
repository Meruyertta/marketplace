import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marketplace/screens/location_screen.dart';
import 'package:marketplace/screens/onboard_screen.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({Key? key}) : super(key: key);

  static const String id='welcome-screen';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    bool _validPhoneNumber = false;
    var _phoneNumberController = TextEditingController();

    void showBottomSheet(context) {
      showModalBottomSheet(
        context: context,
        builder: (context) =>
            StatefulBuilder(builder: (context, StateSetter myState) {
          return Container(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: auth.error == 'Invalid code' ? true : false,
                    child: Container(
                      child: Column(
                        children: [
                          Text(auth.error,style: TextStyle(color:
                          Colors.red, fontSize:15)),
                          SizedBox(height: 3),
                        ],
                      ),
                    ),
                  ),
                  Text('LOGIN',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('We will send confirmation code to your phone',
                      style: TextStyle(fontSize: 12)),
                  SizedBox(height: 30),
                  TextField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                      prefixText: '+7',
                      labelText: '10 digit mobile number',
                    ),
                    autofocus: true,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    onChanged: (value) {
                      if (value.length == 10) {
                        myState(() {
                          _validPhoneNumber = true;
                        });
                      } else {
                        myState(() {
                          _validPhoneNumber = false;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: AbsorbPointer(
                          absorbing: _validPhoneNumber ? false : true,
                          child: TextButton(
                            child: Text(
                              _validPhoneNumber
                                  ? 'CONTINUE'
                                  : "ENTER PHONE NUMBER",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              String number =
                                  '+7${_phoneNumberController.text}';
                              auth.verifyPhone(context, number).then((value) {
                                _phoneNumberController.clear();
                              });
                            },
                            style: TextButton.styleFrom(
                                backgroundColor: _validPhoneNumber
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade500),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }),
      );
    }

    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        children: [
          Positioned(
            right: 0.0,
            top: 10.0,
            child: TextButton(
              onPressed: () {},
              child: Text('SKIP', style: TextStyle(color: Colors.green)),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: OnBoardScreen(),
              ),
              Text('Buy or sell things easily!'),
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(LocationScreen.id);
                },
                child: Text('Set Delivery Location',
                    style: TextStyle(color: Colors.white)),
                style: TextButton.styleFrom(backgroundColor: Colors.green),
              ),
              SizedBox(height: 20),
              TextButton(
                child: RichText(
                  text: TextSpan(
                      text: 'Already a Customer?',
                      style: TextStyle(color: Colors.deepOrange),
                      children: [
                        TextSpan(
                            text: 'Login',
                            style: TextStyle(fontWeight: FontWeight.bold))
                      ]),
                ),
                onPressed: () {
                  showBottomSheet(context);
                },
              )
            ],
          )
        ],
      ),
    ));
  }
}

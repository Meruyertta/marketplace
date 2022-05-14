import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/widgets.dart';

import '../constants.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardScreen> createState() => _OnBoardScreenState();
}

final _controller= PageController(
  initialPage: 0,
);
int _currentPage=0;

List<Widget> _pages=[
  Column(
    children: [
      Expanded(child: Image.asset('images/enteraddress.png')),
      Text('Set Your Delivery Location', style: kPageViewTextStyle, textAlign: TextAlign.center,),
    ],
  ),
  Column(
    children: [
      Expanded(child: Image.asset('images/orderfood.png')),
      Text('Order the delivery',style: kPageViewTextStyle, textAlign: TextAlign.center ),
    ],
  ),
  Column(
    children: [
      Expanded(child: Image.asset('images/deliverfood.png',)),
      Text('Quick Deliver ',style: kPageViewTextStyle, textAlign: TextAlign.center),
    ],
  ),
];


class _OnBoardScreenState extends State<OnBoardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller:_controller,
              children: _pages,
                onPageChanged:(index){
                setState(() {
                  _currentPage=index;
                });
                },
            ),
          ),
    SizedBox(height: 20),
    DotsIndicator(
    dotsCount: _pages.length,
    position: _currentPage.toDouble(),
    decorator: DotsDecorator(
    spacing: const EdgeInsets.all(10.0),
      activeColor: Colors.green
    ),
    ),
          SizedBox(height:20),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:Move/Helpers/constant.dart';
import 'package:Move/Models/review_model.dart';
import 'package:Move/Models/card_model.dart';
import 'package:Move/Models/price_model.dart';
import 'package:Move/Pages/App/app_provider.dart';
import 'package:Move/Pages/TermsSectionPage/index.dart';
import 'package:Move/Pages/UnlockPage/jumping_dot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UnLock extends StatefulWidget {
  const UnLock({super.key, required this.isMore});

  final bool isMore;
  @override
  State<UnLock> createState() => _UnLock();
}

class _UnLock extends State<UnLock> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget headerSection = Container(
      padding: EdgeInsets.only(
        top: 12,
        bottom: 12,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            child: Image.asset('assets/images/escunlock.png'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.isMore ? "Proccessing" : 'Unlocking eScooter',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: ColorConstants.cPrimaryTitleColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    fontFamily: 'Montserrat-SemiBold'),
              ),
              Container(
                padding: EdgeInsets.only(top: 10, left: 5),
                child: JumpingDots(
                  color: Colors.black,
                  radius: 3,
                  innerPadding: 2,
                  numberOfDots: 3,
                ),
              ),
            ],
          ),

          // Container(
          //   alignment: Alignment.topLeft,
          //   padding:const EdgeInsets.only(top:10, left:35, right: 30),
          //   child: Text(
          //     style: TextStyle(color:Colors.grey, fontSize: 16),
          //     'keep your phone near the eScooter to \n unlock it and start a ride.'
          //   ),
          // )
        ],
      ),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Container(
        color: Colors.white,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Expanded(
                child: headerSection,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

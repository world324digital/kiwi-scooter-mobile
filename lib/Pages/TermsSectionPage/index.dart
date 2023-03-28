import 'package:Move/Helpers/constant.dart';
import 'package:Move/Helpers/helperUtility.dart';
import 'package:Move/Models/term_model.dart';
import 'package:Move/Pages/App/app_provider.dart';
import 'package:Move/Pages/TermsSectionPage/drink.dart';
import 'package:Move/Pages/TermsSectionPage/helmet.dart';
import 'package:Move/Pages/TermsSectionPage/prohibit.dart';
import 'package:Move/Pages/TermsSectionPage/term_item.dart';
import 'package:Move/Pages/TermsSectionPage/terms_service.dart';
import 'package:Move/Routes/routes.dart';
import 'package:Move/Services/firebase_service.dart';
import 'package:Move/Widgets/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';

class TermsSectionPage extends StatefulWidget {
  TermsSectionPage({
    super.key,
    required this.data,
  });
  dynamic data;

  @override
  State<TermsSectionPage> createState() => _TermsSectionPage();
}

class _TermsSectionPage extends State<TermsSectionPage> {
  final _pageController = PageController();

  int pageIndex = 0;
  bool isLoading = true;
  bool isError = false;
  List<TermsModel> termSections = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(microseconds: 500), () async {
      getTerms();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void nextPage() {
    _pageController.nextPage(
        duration: Duration(milliseconds: 400), curve: Curves.easeIn);
  }

  /*****************
   * @Auth leopard.live0122@gmail.com
   * @Date 2022.12.18
   * @Desc Get Term Lists from Firebase
   */

  Future<void> getTerms() async {
    setState(() {
      isLoading = true;
      isError = false;
    });
    try {
      FirebaseService service = FirebaseService();
      termSections = await service.getTerms();
      print("====================");
      print(termSections[0].img);
      setState(() {
        isLoading = false;
        isError = false;
      });
    } catch (e) {
      print("REIVEW GET ERROR:::::::::::::::::?");

      print(e.toString());
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  List<Widget> termsList(List<TermsModel> lists) {
    List<Widget> termsWidget = [
      TermsService(onNext: () {
        nextPage();
      })
    ];
    for (int i = 0; i < lists.length; i++) {
      termsWidget.add(
        TermItem(
          onNext: () {
            if (i == lists.length - 1) {
              if (widget.data["viaPayment"] == true) {
                HelperUtility.goPage(
                    context: context, routeName: Routes.RIDE_HOME);
              } else {
                print("here is false part");
                // Alert.showMessage(
                //     type: TypeAlert.warning,
                //     title: "Warning",
                //     message: "You must make a payment");
                // HelperUtility.goPage(context: context, routeName: Routes.HOME);
                Navigator.of(context).pop();
              }
            } else {
              nextPage();
            }
          },
          termItem: lists[i],
        ),
      );
    }

    return termsWidget;
  }

  @override
  Widget build(BuildContext context) {
    _buildPageView() {
      return Container(
        height: MediaQuery.of(context).size.height,
        child: PageView.builder(
          // physics: NeverScrollableScrollPhysics(),
          itemCount: termsList(termSections).length,
          controller: _pageController,
          itemBuilder: (BuildContext context, int index) {
            return termsList(termSections)[index];
          },
          onPageChanged: (index) {
            // pageIndex = pageIndex + 1;
            setState(() {
              pageIndex = index;
            });
          },
        ),
      );
    }

    _buildIndicator() {
      return Positioned(
        left: 0.0,
        right: 0.0,
        bottom: pageIndex == 0 ? 250 : 140,
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            DotsIndicator(
              dotsCount: termsList(termSections).length,
              position: pageIndex.toDouble(),
              decorator: DotsDecorator(
                  color: Color(0xFFB5B5B5),
                  activeColor: ColorConstants.cPrimaryBtnColor,
                  size: const Size(8.0, 4.0),
                  activeSize: const Size(32.0, 4.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  spacing: EdgeInsets.symmetric(horizontal: 2)),
            ),
          ],
        ),
      );
    }

    _buildBody() {
      return Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              _buildPageView(),
              _buildIndicator(),
            ],
          ),
        ],
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : _buildBody(),
      ),
    );
  }
}

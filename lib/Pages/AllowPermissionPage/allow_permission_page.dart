import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Pages/AllowPermissionPage/screens/allow_location_page.dart';
// import 'package:KiwiCity/Pages/AllowPermissionPage/screens/allow_notification_page.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AllowPermissionPage extends StatefulWidget {
  const AllowPermissionPage({
    super.key,
    required this.data,
  });

  final dynamic data;

  @override
  State<AllowPermissionPage> createState() => _AllowPermissionPage();
}

class _AllowPermissionPage extends State<AllowPermissionPage> {
  final _pageController = PageController();

  late int pageIndex;

  @override
  void initState() {
    super.initState();
    pageIndex = widget.data['index'];
  }

  @override
  void dispose() {
    super.dispose();
  }

  void nextPage() {
    _pageController.nextPage(
        duration: Duration(milliseconds: 400), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> sliderPages = [
      AllowLocationPage(onNext: () {
        nextPage();
      }),
      // const AllowNotificationPage(),
    ];
    _buildPageView() {
      return Container(
        height: MediaQuery.of(context).size.height,
        child: PageView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: sliderPages.length,
          controller: _pageController,
          itemBuilder: (BuildContext context, int index) {
            if (pageIndex == 1) {
              return sliderPages[1];
            } else {
              return sliderPages[index];
            }
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
        bottom: 200.0,
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            DotsIndicator(
              dotsCount: sliderPages.length,
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
        body: _buildBody(),
      ),
    );
  }
}

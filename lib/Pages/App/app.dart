import 'package:Move/Pages/App/app_provider.dart';
import 'package:Move/Pages/SplashPage/splash_page.dart';
import 'package:Move/Routes/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/dropdown_alert.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      //color set to transperent or set your own color
      statusBarIconBrightness: Brightness.dark,
      //set brightness for icons, like dark background light icons
    ));

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppProvider(),
        ),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: ScreenUtilInit(
          designSize: Size(375, 812),
          builder: ((context, child) => Phoenix(
                child: MaterialApp(
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaleFactor: 1.0,
                      ), //set desired text scale factor here
                      child: Stack(
                        children: [child!, DropdownAlert()],
                      ),
                    );
                  },
                  debugShowCheckedModeBanner: false,
                  title: 'Move',
                  theme: ThemeData(
                    textTheme: const TextTheme(
                      headline5: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                      headline6: TextStyle(
                        fontFamily: 'Montserrat-Medium',
                        color: Color.fromRGBO(102, 102, 102, 1),
                        fontSize: 14,
                      ),
                      bodyText1: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700),
                      bodyText2: TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'Montserrat',
                        fontStyle: FontStyle.normal,
                        color: Color.fromRGBO(102, 102, 102, 1),
                      ),
                    ),
                  ),
                  home: Directionality(
                    // add this
                    textDirection: TextDirection.ltr,

                    child: SplashPage(),
                  ),
                  onGenerateRoute: RouteGenerator.generateRoute,
                ),
              )),
          // child: ,
        ),
      ),
    );
  }
}

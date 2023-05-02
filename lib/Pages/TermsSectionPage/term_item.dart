import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Models/term_model.dart';
import 'package:KiwiCity/Widgets/primaryButton.dart';
import 'package:KiwiCity/Widgets/terms.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:KiwiCity/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TermItem extends StatefulWidget {
  TermItem({super.key, required this.onNext, required this.termItem});
  final Function onNext;
  TermsModel termItem;

  @override
  State<TermItem> createState() => _TermItem();
}

class _TermItem extends State<TermItem> {
  String localeString = 'en';
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      localeString = prefs.getString('locale')!;
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    getLocale();
    var termItem = widget.termItem;
    String title = termItem.enTitle;
    String description = termItem.enDescription;
    if (localeString == 'el') {
      title = termItem.elTitle;
      description = termItem.elDescription;
    } else if (localeString == 'lv') {
      title = termItem.lvTitle;
      description = termItem.lvDescription;
    }
    String imageUrl = 'assets/images/' + termItem.img;
    Widget headerSection = Container(
      padding: EdgeInsets.only(top: 60, bottom: 20),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            // child: CachedNetworkImage(
            //   imageUrl: termItem.img,
            //   placeholder: (context, url) => CircularProgressIndicator(
            //       color: ColorConstants.cPrimaryBtnColor),
            //   errorWidget: (context, url, error) => Icon(Icons.error),
            // ),
            child: Image.asset(imageUrl),
            // child: Image.network(termItem.img),
            // child: Image.network(
            //   termItem.img,
            //   fit: BoxFit.fill,
            //   loadingBuilder: (BuildContext context, Widget child,
            //       ImageChunkEvent? loadingProgress) {
            //     if (loadingProgress == null) return child;
            //     return Center(
            //       child: CircularProgressIndicator(
            //         value: loadingProgress.expectedTotalBytes != null
            //             ? loadingProgress.cumulativeBytesLoaded /
            //                 loadingProgress.expectedTotalBytes!
            //             : null,
            //       ),
            //     );
            //   },
            // ),
          ),
          TermsTitle(text: title),
          TermsContent(text: description),
        ],
      ),
    );
    Widget allowSection = Center(
        child: Align(
      alignment: Alignment.bottomCenter,
      child: Column(children: <Widget>[
        PrimaryButton(
            context: context,
            onTap: () {
              return widget.onNext();
            },
            title: AppLocalizations.of(context).okay)
      ]),
    ));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Container(
        color: Colors.white,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    headerSection,
                  ],
                ),
              ),
              allowSection,
              SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }
}

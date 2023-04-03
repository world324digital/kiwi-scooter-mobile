import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Models/term_model.dart';
import 'package:KiwiCity/Widgets/primaryButton.dart';
import 'package:KiwiCity/Widgets/terms.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TermItem extends StatefulWidget {
  TermItem({super.key, required this.onNext, required this.termItem});
  final Function onNext;
  TermsModel termItem;

  @override
  State<TermItem> createState() => _TermItem();
}

class _TermItem extends State<TermItem> {
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
    var termItem = widget.termItem;
    Widget headerSection = Container(
      padding: EdgeInsets.only(top: 60, bottom: 20),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            child: CachedNetworkImage(
              imageUrl: termItem.img,
              placeholder: (context, url) => CircularProgressIndicator(
                  color: ColorConstants.cPrimaryBtnColor),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
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
          TermsTitle(text: termItem.title),
          TermsContent(text: termItem.description),
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
            title: "Okay")
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

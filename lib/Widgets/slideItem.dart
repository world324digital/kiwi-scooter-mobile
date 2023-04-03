import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Models/price_model.dart';
import 'package:flutter/material.dart';

import '../Helpers/helperUtility.dart';

Widget SlideItem(
    {required BuildContext context,
    required PriceModel priceModel,
    Color? color = ColorConstants.cPrimaryBtnColor}) {
  var platform = Theme.of(context).platform;
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Container(
      // height: HelperUtility.screenHeight(context) * 0.45,
      width: HelperUtility.screenWidth(context) * 0.8,
      decoration: BoxDecoration(
        color: ColorConstants.cPrimaryBtnColor,
        border: Border.all(color: ColorConstants.cPrimaryBtnColor, width: 1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        top: platform == TargetPlatform.iOS ? 60 : 40),
                    child: Text(
                      '${priceModel.usageTime} ${priceModel.usageTimeUnit}',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: FontStyles.fBold,
                        fontWeight: FontWeight.w600,
                        height: 0.85,
                        letterSpacing: -0.01,
                        color: ColorConstants.cPrimaryTitleColor,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                child: getImage(priceModel),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      '\$ ${priceModel.totalCost.toStringAsFixed(2)} USD or',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontFamily: 'Montserrat-Medium',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        bottom: platform == TargetPlatform.iOS ? 60 : 30),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: '\$${priceModel.cost.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: ColorConstants.cPrimaryBtnColor,
                              fontFamily: FontStyles.fSemiBold,
                              fontSize: 32,
                              height: 1,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.01,
                            ),
                          ),
                          TextSpan(
                              text: '  USD / min',
                              style: TextStyle(
                                  color: ColorConstants.cTxtColor2,
                                  fontSize: 14,
                                  fontFamily: 'Montserrat-Medium')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ]),
      ),
    ),
  );
}

Widget getImage(PriceModel price) {
  switch (price.usageTimeUnit) {
    case "minutes":
      return Image.asset(
        "assets/images/30min.png",
        fit: BoxFit.fill,
      );

    case "hour":
      return Image.asset(
        "assets/images/1hour.png",
        fit: BoxFit.fill,
      );

    case "hours":
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Container(
              height: 68,
              width: 68,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/images/clock2.png",
                  ),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: Container(
              height: 68,
              width: 68,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/images/clock2.png",
                  ),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: Container(
              height: 68,
              width: 68,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/images/clock2.png",
                  ),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ],
      );
    case "day":
      return Image.asset(
        "assets/images/clock4.png",
        height: 68,
        width: 68,
        fit: BoxFit.fill,
      );
    default:
      return Image.asset(
        "assets/images/clock1.png",
        height: 84,
        width: 84,
        fit: BoxFit.fill,
      );
  }
}

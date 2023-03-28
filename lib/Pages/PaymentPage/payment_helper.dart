import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('  '); // Add double spaces.
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

class CardMonthInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != newText.length) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

enum CardType {
  Master,
  Visa,
  Verve,
  Discover,
  AmericanExpress,
  DinersClub,
  Jcb,
  Others,
  Invalid
}

class CardUtils {
  static CardType getCardTypeFrmNumber(String input) {
    CardType cardType;
    String card;
    if (input.startsWith(RegExp(
        r'((5[1-5])|(222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720))'))) {
      cardType = CardType.Master;
      card = "Master";
    } else if (input.startsWith(RegExp(r'[4]'))) {
      cardType = CardType.Visa;
      card = "Visa";
    } else if (input.startsWith(RegExp(r'((506(0|1))|(507(8|9))|(6500))'))) {
      cardType = CardType.Verve;
      card = "Verve";
    } else if (input.startsWith(RegExp(r'((34)|(37))'))) {
      cardType = CardType.AmericanExpress;
      card = "AmericanExpress";
    } else if (input.startsWith(RegExp(r'((6[45])|(6011))'))) {
      cardType = CardType.Discover;
      card = "Discover";
    } else if (input.startsWith(RegExp(r'((30[0-5])|(3[89])|(36)|(3095))'))) {
      cardType = CardType.DinersClub;
      card = "DinersClub";
    } else if (input.startsWith(RegExp(r'(352[89]|35[3-8][0-9])'))) {
      cardType = CardType.Jcb;
      card = "Jcb";
    } else if (input.length <= 8) {
      cardType = CardType.Others;
      card = "Others";
    } else {
      cardType = CardType.Invalid;
      card = "Invalid";
    }
    return cardType;
  }

  static String getCardTypeName(CardType cardType) {
    String typeName = "Others";
    switch (cardType) {
      case CardType.Master:
        typeName = 'Master';
        break;
      case CardType.Visa:
        typeName = 'Visa';
        break;

      case CardType.AmericanExpress:
        typeName = 'AmericanExpress';
        break;

      // case CardType.Verve:
      //   typeName = 'Verve';
      //   break;
      // case CardType.Discover:
      //   typeName = 'Discover';
      //   break;
      // case CardType.DinersClub:
      //   typeName = 'DinersClub';
      //   break;
      // case CardType.Jcb:
      //   typeName = 'Jcb';
      //   break;
      case CardType.Others:
        typeName = "Others";
        break;
      default:
        typeName = "Invalid";
        break;
    }
    return typeName;
  }

  static Widget? getCardIcon(String typeName) {
    String img = "";
    Icon? icon;
    switch (typeName) {
      case "Master":
        img = 'mastercard.png';
        break;
      case "Visa":
        img = 'visaicon.png';
        break;
      case "AmericanExpress":
        img = 'american_express.png';
        break;
      // case "Verve":
      //   img = 'verve.png';
      //   break;
      // case "Discover":
      //   img = 'discover.png';
      //   break;
      // case "DinersClub":
      //   img = 'dinners_club.png';
      //   break;
      // case "Jcb":
      //   img = 'jcb.png';
      //   break;
      case "ApplePay":
        img = 'apple-pay.png';
        break;
      case "GooglePay":
        img = 'google-pay.png';
        break;
      case "Others":
        icon = const Icon(
          Icons.credit_card,
          size: 24.0,
          color: Color(0xFFB8B5C3),
        );
        break;
      // default:
      //   img = "visa.png";
      //   icon = const Icon(
      //     Icons.warning,
      //     size: 24.0,
      //     color: Color(0xFFB8B5C3),
      //   );

      //   break;
    }
    Widget? widget = Image.asset(
      'assets/images/cardIcons/$img',
      width: 40,
    );
    if (img.isNotEmpty) {
      widget = Image.asset(
        'assets/images/cardIcons/$img',
        width: 40,
      );
    } else {
      widget = icon;
    }
    return widget;
  }

// delete double spaces
  static String getCleanedNumber(String text) {
    RegExp regExp = RegExp(r"[^0-9]");
    return text.replaceAll(regExp, '');
  }
}

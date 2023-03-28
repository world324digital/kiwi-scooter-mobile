import 'package:flutter/material.dart';

class ApplePayButtonWidget extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  const ApplePayButtonWidget({
    Key? key,
    this.children = const [],
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 4),
          if (padding != null)
            Padding(
              padding: padding!,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            )
          else
            ...children,
        ],
      ),
    );
  }
}

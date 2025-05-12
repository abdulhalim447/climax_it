import 'package:flutter/material.dart';

class CustomCircularIndicator extends StatelessWidget {
  final double size; // Allows you to control the size if needed

  const CustomCircularIndicator({Key? key, this.size = 45}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Responsive sizing (optional)
    final double spinnerSize = size;
    final double logoSize = spinnerSize * 0.5;

    return Center(
      child: SizedBox(
        width: spinnerSize,
        height: spinnerSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: spinnerSize,
              height: spinnerSize,
              child: CircularProgressIndicator(
                color: Colors.blue,
                // Customize color
              ),
            ),
            SizedBox(
              width: logoSize,
              height: logoSize,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

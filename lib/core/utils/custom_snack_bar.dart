import 'package:flutter/material.dart';
import 'package:math_house_parent_new/core/utils/app_colors.dart';

void showTopSnackBar(BuildContext context, String message, Color color) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 8, // فوق كل حاجة
      left: 16,
      right: 16,
      child: Material(
        color: color,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message, style: TextStyle(color: Colors.white)),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}

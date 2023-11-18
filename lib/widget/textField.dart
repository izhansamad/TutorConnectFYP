import 'package:flutter/material.dart';
import 'package:tutor_connect_app/core/colors.dart';

import '../core/text_style.dart';

Widget textField({
  required String hintTxt,
  required TextEditingController controller,
  bool isObs = false,
  bool isEnabled = true,
  TextInputType? keyBordType,
  String? Function(String?)? validator,
  IconData? icon,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 20.0,
      vertical: 8.0,
    ),
    child: Expanded(
      child: Container(
        height: 60.0,
        padding: EdgeInsets.only(left: 20.0, right: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: controller,
                textAlignVertical: TextAlignVertical.center,
                obscureText: isObs,
                enabled: isEnabled,
                validator: validator,
                keyboardType: keyBordType,
                decoration: InputDecoration(
                  helperText: ' ',
                  contentPadding: EdgeInsets.only(bottom: 3),
                  border: InputBorder.none,
                  hintText: hintTxt,
                  hintStyle: hintStyle,
                ),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(
              icon,
              color: primaryColor,
            )
          ],
        ),
      ),
    ),
  );
}

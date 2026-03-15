import 'package:flutter/material.dart';

// 色定義
const kSengokuGold = Color(0xFFC5A059);
const kUrushiBlack = Color(0xFF1A1A1A);
const kOffWhite = Color(0xFFFDFCF8);
const kIshigakiGrey = Color(0xFF4A4A4A);
const kBannerYellow = Color(0xFFFFD54F);
const kUnselectedGrey = Color(0xFFB0B0B0);
const kVisitedGreen = Colors.green;
const kUnvisitedRed = Colors.red;

// 共通パーツ
class ShiroSearchField extends StatelessWidget {
  final String hintText;
  final bool readOnly;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final VoidCallback? onTap;

  const ShiroSearchField({
    super.key,
    required this.hintText,
    this.readOnly = false,
    this.controller,
    this.suffixIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: readOnly ? Colors.grey[50] : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black12),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black12),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: kSengokuGold),
        ),
      ),
    );
  }
}

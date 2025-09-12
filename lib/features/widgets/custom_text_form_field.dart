import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';

class CustomTextFormField extends StatefulWidget {
  Color? filledColor;
  Color borderColor;
  TextStyle? hintStyle;
  String? hintText;
  Widget? label;
  TextStyle? labelStyle;
  Widget? prefixIcon;
  Widget? suffixIcon;
  TextEditingController? controller;
  String? Function(String?)? validator;
  TextInputType? keyboardType;
  bool isObscureText;
  bool isPassword;
  TextStyle? textStyle;
  bool readonly;
  final Function(String)? onChanged;

  CustomTextFormField({
    super.key,
    this.controller,
    this.validator,
    this.hintText,
    this.hintStyle,
    this.textStyle,
    this.label,
    this.labelStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.isObscureText = false,
    this.isPassword = false,
    this.filledColor = AppColors.white,
    this.keyboardType = TextInputType.text,
    this.borderColor = AppColors.white,
    this.readonly = false,
    this.onChanged,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: widget.onChanged,
      style: widget.textStyle,
      obscureText: widget.isObscureText,
      keyboardType: widget.keyboardType,
      controller: widget.controller,
      validator: widget.validator,
      readOnly: widget.readonly,
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.filledColor,
        hintText: widget.hintText,
        hintStyle: widget.hintStyle,
        label: widget.label,
        labelStyle: widget.labelStyle,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  widget.isObscureText = !widget.isObscureText;
                  setState(() {});
                },
                icon: Icon(
                  widget.isObscureText
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
              )
            : widget.suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: widget.borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: widget.borderColor, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.red),
        ),
      ),
    );
  }
}

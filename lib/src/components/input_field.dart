import 'package:flutter/material.dart';

import '../utils/color_const.dart';

class InputField extends StatefulWidget {
  const InputField({
    Key? key,
    this.hintText,
    this.initialValue,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.errorText,
    this.onChanged,
    this.controller,
    this.validator,
    this.autoFocus = false,
    this.enabled = true,
    this.suffixIcon,
    this.fillColor,
    this.borderRadius,
    this.borderColor,
  }) : super(key: key);

  final String? hintText, errorText, initialValue;
  final bool obscureText, autoFocus;
  final Function? onChanged, validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final IconButton? suffixIcon;
  final TextEditingController? controller;
  final bool? enabled;
  final Color? fillColor, borderColor;
  final double? borderRadius;

  @override
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      validator: widget.validator as String? Function(String?)?,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      onChanged: widget.onChanged as void Function(String)?,
      autofocus: widget.autoFocus,
      enabled: widget.enabled,
      style: Theme.of(context).textTheme.labelLarge?.apply(color: textColor),
      decoration: InputDecoration(
        suffixIcon: widget.suffixIcon,
        contentPadding: const EdgeInsets.all(15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(color: widget.borderColor ?? Colors.transparent, width: 0.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(color: widget.borderColor ?? Colors.transparent, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(color: widget.borderColor ?? Colors.transparent, width: 0.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(color: widget.borderColor ?? Colors.transparent, width: 0.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(color: widget.borderColor ?? Colors.transparent, width: 0.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 10),
          borderSide: BorderSide(color: widget.borderColor ?? Colors.transparent, width: 0.5),
        ),
        filled: true,
        fillColor: widget.fillColor ?? bgColor.withOpacity(0.1),
        hintStyle: const TextStyle(color: Colors.grey),
        errorStyle: TextStyle(color: Colors.red[600], fontWeight: FontWeight.bold, fontSize: 10),
        hintText: widget.hintText,
        // errorText: widget.errorText,
      ),
    );
  }
}

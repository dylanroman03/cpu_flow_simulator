import 'package:flutter/material.dart';

InputDecoration customInputDecoration(bool hasError) {
  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: hasError ? Colors.red : Colors.black),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: hasError ? Colors.red : Colors.black),
    ),
  );
}

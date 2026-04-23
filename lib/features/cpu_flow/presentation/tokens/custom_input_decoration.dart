import 'package:cpu_flow_simulator/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

InputDecoration customInputDecoration({required bool hasError}) {
  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: AppTheme.inputFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: hasError ? AppTheme.inputError : AppTheme.inputBorder,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: hasError ? AppTheme.inputError : AppTheme.inputFocus,
        width: 1.5,
      ),
    ),
    errorStyle: const TextStyle(height: 0, fontSize: 0),
  );
}

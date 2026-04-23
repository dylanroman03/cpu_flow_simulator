import 'package:cpu_flow_simulator/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/presentation/cpu_flow_screen.dart';

void main() {
  runApp(const CpuFlowApp());
}

class CpuFlowApp extends StatelessWidget {
  const CpuFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CPU Flow Simulator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const CpuFlowScreen(),
    );
  }
}

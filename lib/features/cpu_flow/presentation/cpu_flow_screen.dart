import 'dart:developer';

import 'package:cpu_flow_simulator/core/theme/app_theme.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/process.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/schedule_slice.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/simulation_result.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/use_cases/order_by_fifo_use_case.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/use_cases/order_by_round_robin_use_case.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/use_cases/order_by_sjf_use_case.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/presentation/widgets/process_input_table.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/presentation/widgets/slice_queue_table.dart';
import 'package:cpu_flow_simulator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _SchedulingAlgorithm { fifo, sjf, roundRobin }

class CpuFlowScreen extends StatefulWidget {
  const CpuFlowScreen({super.key});

  @override
  State<CpuFlowScreen> createState() => _CpuFlowScreenState();
}

class _CpuFlowScreenState extends State<CpuFlowScreen> {
  static const double _controlHeight = 35;

  bool enabledRun = false;
  bool showAnimations = true;

  List<Process> processes = <Process>[];
  List<ScheduleSlice> slices = <ScheduleSlice>[];
  SimulationResult? simulationResult;

  final _fifoUseCase = OrderByFifoUseCase();
  final _sjfUseCase = OrderBySjfUseCase();
  final _roundRobinUseCase = OrderByRoundRobinUseCase();
  final TextEditingController _quantumController = TextEditingController(
    text: '3',
  );
  _SchedulingAlgorithm _selectedAlgorithm = _SchedulingAlgorithm.roundRobin;

  void _runSimulation() {
    final l10n = context.l10n;

    if (processes.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.noProcessesSnack)));
      return;
    }

    try {
      switch (_selectedAlgorithm) {
        case _SchedulingAlgorithm.fifo:
          final result = _fifoUseCase.call(processes);
          setState(() {
            slices = result.slices;
            simulationResult = result;
          });
          break;
        case _SchedulingAlgorithm.sjf:
          final result = _sjfUseCase.call(processes);
          setState(() {
            slices = result.slices;
            simulationResult = result;
          });
          break;
        case _SchedulingAlgorithm.roundRobin:
          final int quantum = int.tryParse(_quantumController.text) ?? 0;
          if (quantum <= 0) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.quantumInvalidSnack)));
            return;
          }
          final result = _roundRobinUseCase.call(processes, quantum);
          setState(() {
            slices = result.slices;
            simulationResult = result;
          });
          break;
      }
    } catch (_) {
      log("error _");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.simulationErrorSnack)));
    }
  }

  @override
  void dispose() {
    _quantumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 1020;

            final inputPanel = Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.cardBorder),
                boxShadow: const [
                  BoxShadow(
                    color: AppTheme.softShadow,
                    blurRadius: 16,
                    offset: Offset(0, 7),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: ProcessInputTable(
                  initialValues: processes,
                  onChanged: (value) {
                    setState(() {
                      processes = value.processes;
                      enabledRun = !value.hasError && processes.isNotEmpty;
                    });
                  },
                ),
              ),
            );

            final queuePanel = Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.cardBorder),
                boxShadow: const [
                  BoxShadow(
                    color: AppTheme.softShadow,
                    blurRadius: 16,
                    offset: Offset(0, 7),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        l10n.processCount(processes.length),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _buildAlgorithmSelector(),
                      if (_selectedAlgorithm == _SchedulingAlgorithm.roundRobin)
                        _buildQuantumInput(),
                      Switch(
                        value: showAnimations,
                        onChanged: (value) {
                          setState(() {
                            showAnimations = value;
                          });
                        },
                      ),
                      Text(
                        l10n.animationLabel,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: _controlHeight - 2,
                        child: ElevatedButton(
                          onPressed: enabledRun ? _runSimulation : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.play_arrow),
                              Text(l10n.runButton),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: AppTheme.divider, height: 1),
                  const SizedBox(height: 14),
                  if (simulationResult != null) ...[
                    _buildMetricsSummary(simulationResult!, l10n),
                    const SizedBox(height: 14),
                  ],
                  Expanded(
                    child: SliceQueueTable(
                      slices: slices,
                      showAnimations: showAnimations,
                    ),
                  ),
                ],
              ),
            );

            if (isWide) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 5, child: inputPanel),
                    const SizedBox(width: 18),
                    Expanded(flex: 7, child: queuePanel),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(flex: 7, child: inputPanel),
                  const SizedBox(height: 14),
                  Expanded(flex: 8, child: queuePanel),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAlgorithmSelector() {
    return SizedBox(
      height: _controlHeight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.roundedCornerRadius),
          border: Border.all(color: AppTheme.selectorBorder),
        ),
        child: DropdownButton<_SchedulingAlgorithm>(
          value: _selectedAlgorithm,
          borderRadius: BorderRadius.circular(AppTheme.roundedCornerRadius),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          iconEnabledColor: AppTheme.selectorIcon,
          underline: const SizedBox.shrink(),
          onChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _selectedAlgorithm = value;
            });
          },
          items: const [
            DropdownMenuItem(
              value: _SchedulingAlgorithm.fifo,
              child: Text('FIFO'),
            ),
            DropdownMenuItem(
              value: _SchedulingAlgorithm.sjf,
              child: Text('SJF'),
            ),
            DropdownMenuItem(
              value: _SchedulingAlgorithm.roundRobin,
              child: Text('Round Robin'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantumInput() {
    return SizedBox(
      width: 130,
      height: _controlHeight,
      child: TextField(
        controller: _quantumController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          labelText: context.l10n.quantumLabel,
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(
            color: AppTheme.quantumLabel,
            fontWeight: FontWeight.w700,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.roundedCornerRadius),
            borderSide: const BorderSide(color: AppTheme.selectorBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.roundedCornerRadius),
            borderSide: const BorderSide(
              color: AppTheme.primaryButton,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsSummary(SimulationResult result, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.roundedCornerRadius),
        border: Border.all(color: AppTheme.selectorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.metricsTitle,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetricChip(
                label: l10n.totalTimeLabel,
                value: '${result.totalTime} ms',
              ),
              _buildMetricChip(
                label: l10n.averageWaitingTimeLabel,
                value: '${result.averageWaitingTime.toStringAsFixed(2)} ms',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.inputFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

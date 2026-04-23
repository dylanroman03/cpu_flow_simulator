import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/process.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/schedule_slice.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/use_cases/order_by_fifo_use_case.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/use_cases/order_by_round_robin_use_case.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/use_cases/order_by_sjf_use_case.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/presentation/widgets/process_input_table.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/presentation/widgets/slice_queue_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _SchedulingAlgorithm { fifo, sjf, roundRobin }

class CpuFlowScreen extends StatefulWidget {
  const CpuFlowScreen({super.key});

  @override
  State<CpuFlowScreen> createState() => _CpuFlowScreenState();
}

class _CpuFlowScreenState extends State<CpuFlowScreen> {
  List<Process> processes = <Process>[];
  List<ScheduleSlice> slices = <ScheduleSlice>[];

  final _fifoUseCase = OrderByFifoUseCase();
  final _sjfUseCase = OrderBySjfUseCase();
  final _roundRobinUseCase = OrderByRoundRobinUseCase();
  final TextEditingController _quantumController = TextEditingController(
    text: '3',
  );
  _SchedulingAlgorithm _selectedAlgorithm = _SchedulingAlgorithm.roundRobin;

  @override
  void dispose() {
    _quantumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003743),
      appBar: AppBar(
        title: const Text('CPU Flow - Cola de Ejecucion'),
        backgroundColor: const Color(0xFF138CE8),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: ProcessInputTable(
                  initialValues: processes,
                  onChanged: (value) {
                    setState(() {
                      processes = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Procesos validos: ${processes.length}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildAlgorithmSelector(),
                      const SizedBox(width: 8),
                      if (_selectedAlgorithm == _SchedulingAlgorithm.roundRobin)
                        _buildQuantumInput(),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _runSimulation,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Ejecutar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),
                  Expanded(child: SliceQueueTable(slices: slices)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlgorithmSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<_SchedulingAlgorithm>(
        value: _selectedAlgorithm,
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
          DropdownMenuItem(value: _SchedulingAlgorithm.sjf, child: Text('SJF')),
          DropdownMenuItem(
            value: _SchedulingAlgorithm.roundRobin,
            child: Text('Round Robin'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantumInput() {
    return SizedBox(
      width: 90,
      child: TextField(
        controller: _quantumController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          labelText: 'Q',
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void _runSimulation() {
    if (processes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un proceso valido.')),
      );
      return;
    }

    try {
      switch (_selectedAlgorithm) {
        case _SchedulingAlgorithm.fifo:
          final result = _fifoUseCase.call(processes);
          setState(() {
            slices = result.slices;
          });
          break;
        case _SchedulingAlgorithm.sjf:
          final result = _sjfUseCase.call(processes);
          setState(() {
            slices = result.slices;
          });
          break;
        case _SchedulingAlgorithm.roundRobin:
          final int quantum = int.tryParse(_quantumController.text) ?? 0;
          if (quantum <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('El quantum debe ser mayor a 0.')),
            );
            return;
          }
          final result = _roundRobinUseCase.call(processes, quantum);
          setState(() {
            slices = result.slices;
          });
          break;
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo ejecutar la simulacion con estos datos.'),
        ),
      );
    }
  }
}

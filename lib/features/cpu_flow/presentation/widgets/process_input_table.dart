import 'package:cpu_flow_simulator/core/validators/validators.dart';
import 'package:cpu_flow_simulator/core/theme/app_theme.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/process.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/presentation/tokens/custom_input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProcessResponse {
  ProcessResponse({required this.processes, required this.hasError});

  final List<Process> processes;
  final bool hasError;
}

class ProcessInputTable extends StatefulWidget {
  const ProcessInputTable({
    super.key,
    this.onChanged,
    this.initialValues = const <Process>[],
  });

  final ValueChanged<ProcessResponse>? onChanged;
  final List<Process> initialValues;

  @override
  State<ProcessInputTable> createState() => _ProcessInputTableState();
}

class _ProcessInputTableState extends State<ProcessInputTable> {
  final List<_ProcessRowDraft> _rows = <_ProcessRowDraft>[];
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    for (final process in widget.initialValues) {
      _rows.add(
        _ProcessRowDraft(
          arriveTime: process.arriveTime.toString(),
          cpuTime: process.cpuTime.toString(),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyChanged());
  }

  void _addRow() {
    setState(() {
      _rows.add(_ProcessRowDraft(arriveTime: '0', cpuTime: '1'));
    });
    _notifyChanged();
  }

  void _removeRow(int index) {
    setState(() {
      final row = _rows.removeAt(index);
      row.dispose();
    });
    _notifyChanged();
  }

  void _notifyChanged() {
    final List<Process> validProcesses = <Process>[];

    for (int i = 0; i < _rows.length; i++) {
      final int? arriveTime = int.tryParse(_rows[i].arriveTimeController.text);
      final int? cpuTime = int.tryParse(_rows[i].cpuTimeController.text);

      if (arriveTime == null || cpuTime == null) {
        continue;
      }
      if (arriveTime < 0 || cpuTime <= 0) {
        continue;
      }

      validProcesses.add(
        Process(id: 'P${i + 1}', arriveTime: arriveTime, cpuTime: cpuTime),
      );
    }

    setState(() {
      _hasError = validProcesses.length != _rows.length;
    });

    widget.onChanged?.call(
      ProcessResponse(processes: validProcesses, hasError: _hasError),
    );
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tabla de procesos',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _addRow,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [const Icon(Icons.add), const Text('Agregar')],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(fontWeight: FontWeight.w700),
              dataTextStyle: const TextStyle(fontWeight: FontWeight.w600),
              dividerThickness: 0.4,
              columns: const [
                DataColumn(label: Text('Proceso')),
                DataColumn(label: Text('Llegada')),
                DataColumn(label: Text('CPU (ms)')),
                DataColumn(label: Text('')),
              ],
              rows: [
                for (int i = 0; i < _rows.length; i++)
                  DataRow(
                    cells: [
                      DataCell(Text('P${i + 1}')),
                      DataCell(
                        SizedBox(
                          width: 110,
                          child: TextField(
                            controller: _rows[i].arriveTimeController,
                            keyboardType: TextInputType.number,
                            inputFormatters: const [
                              _MinIntInputFormatter(minValue: 0),
                            ],
                            onChanged: (_) {
                              setState(() {});
                              _notifyChanged();
                            },
                            decoration: customInputDecoration(
                              hasError: !Validators.isArrivalValidText(
                                _rows[i].arriveTimeController.text,
                              ),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 110,
                          child: TextField(
                            controller: _rows[i].cpuTimeController,
                            keyboardType: TextInputType.number,
                            inputFormatters: const [
                              _MinIntInputFormatter(minValue: 1),
                            ],
                            onChanged: (_) {
                              setState(() {});
                              _notifyChanged();
                            },
                            decoration: customInputDecoration(
                              hasError: !Validators.isCpuValidText(
                                _rows[i].cpuTimeController.text,
                              ),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          onPressed: _rows.length == 1
                              ? null
                              : () => _removeRow(i),
                          icon: const Icon(Icons.delete_outline),
                          color: AppTheme.deleteIcon,
                          tooltip: 'Eliminar proceso',
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_hasError)
            const Text(
              'Error: Asegúrate de que todos los campos sean válidos.',
              style: TextStyle(color: AppTheme.inputError, fontSize: 12),
            )
          else
            const Text(
              'Nota: solo se toman filas con llegada >= 0 y CPU > 0.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class _ProcessRowDraft {
  _ProcessRowDraft({required String arriveTime, required String cpuTime})
    : arriveTimeController = TextEditingController(text: arriveTime),
      cpuTimeController = TextEditingController(text: cpuTime);

  final TextEditingController arriveTimeController;
  final TextEditingController cpuTimeController;

  void dispose() {
    arriveTimeController.dispose();
    cpuTimeController.dispose();
  }
}

class _MinIntInputFormatter extends TextInputFormatter {
  const _MinIntInputFormatter({required this.minValue});

  final int minValue;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    if (!RegExp(r'^\d+$').hasMatch(text)) {
      return oldValue;
    }

    final int? value = int.tryParse(text);
    if (value == null || value < minValue) {
      return oldValue;
    }

    return newValue;
  }
}

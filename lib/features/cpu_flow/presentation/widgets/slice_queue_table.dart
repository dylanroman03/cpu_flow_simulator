import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/schedule_slice.dart';
import 'package:flutter/material.dart';

class SliceQueueTable extends StatelessWidget {
  const SliceQueueTable({super.key, required this.slices});

  final List<ScheduleSlice> slices;

  static const double _cellMinWidth = 72;
  static const double _cellHeight = 82;

  @override
  Widget build(BuildContext context) {
    final int totalTime = slices.isEmpty
        ? 0
        : slices.map((slice) => slice.endTime).reduce((a, b) => a > b ? a : b);

    if (totalTime == 0) {
      return const Center(
        child: Text(
          'Sin ejecucion para mostrar',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      );
    }

    final List<_CellData> cells = List<_CellData>.generate(totalTime, (time) {
      final ScheduleSlice? activeSlice = _findSliceAt(time);
      return _CellData(time: time, processId: activeSlice?.processId);
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final int columnsPerRow = (constraints.maxWidth / _cellMinWidth)
            .floor()
            .clamp(1, cells.length);
        final int rows = (cells.length / columnsPerRow).ceil();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cola de ejecucion',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              for (int row = 0; row < rows; row++)
                _buildRow(
                  cells.skip(row * columnsPerRow).take(columnsPerRow).toList(),
                  columnsPerRow,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(List<_CellData> rowCells, int columnsPerRow) {
    final int fillers = columnsPerRow - rowCells.length;

    return SizedBox(
      height: _cellHeight,
      child: Row(
        children: [
          for (final cell in rowCells)
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _colorForProcessId(cell.processId),
                  border: Border.all(color: Colors.white38, width: 1),
                ),
                child: Text(
                  '${cell.time}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          for (int i = 0; i < fillers; i++) const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  ScheduleSlice? _findSliceAt(int time) {
    for (final slice in slices) {
      if (time >= slice.startTime && time < slice.endTime) {
        return slice;
      }
    }
    return null;
  }

  Color _colorForProcessId(String? processId) {
    if (processId == null) {
      return const Color(0xFF0B5261);
    }

    const palette = <Color>[
      Color(0xFFFF9800),
      Color(0xFFF5009B),
      Color(0xFF1E88E5),
      Color(0xFF8A00F4),
      Color(0xFF4CAF50),
      Color(0xFFE53935),
      Color(0xFF00ACC1),
      Color(0xFF6D4C41),
      Color(0xFF3949AB),
      Color(0xFF00897B),
      Color(0xFF5D4037),
    ];

    final int index =
        processId.codeUnits.fold<int>(0, (sum, char) => sum + char) %
        palette.length;
    return palette[index];
  }
}

class _CellData {
  const _CellData({required this.time, required this.processId});

  final int time;
  final String? processId;
}

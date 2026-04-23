import 'package:cpu_flow_simulator/core/theme/app_theme.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/schedule_slice.dart';
import 'package:flutter/material.dart';

class SliceQueueTable extends StatelessWidget {
  const SliceQueueTable({super.key, required this.slices});

  final List<ScheduleSlice> slices;

  static const double _cellMinWidth = 74;
  static const double _cellHeight = 88;

  @override
  Widget build(BuildContext context) {
    final int totalTime = slices.isEmpty
        ? 0
        : slices.map((slice) => slice.endTime).reduce((a, b) => a > b ? a : b);

    if (totalTime == 0) {
      return const Center(
        child: Text(
          'Sin ejecucion para mostrar',
          style: TextStyle(
            color: AppTheme.queueEmptyText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final List<_CellData> cells = List<_CellData>.generate(totalTime, (time) {
      final ScheduleSlice? activeSlice = _findSliceAt(time);
      return _CellData(time: time, processId: activeSlice?.processId);
    });

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cola de ejecucion',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Cada bloque representa 1 ms de CPU.',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cells.map(_buildCell).toList(growable: false),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(_CellData cell) {
    return SizedBox(
      width: _cellMinWidth,
      height: _cellHeight,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _colorForProcessId(cell.processId),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.queueCellBorder, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${cell.time}',
              style: const TextStyle(
                color: AppTheme.queueTimeText,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              cell.processId ?? 'Idle',
              style: const TextStyle(
                color: AppTheme.queueProcessText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.25,
              ),
            ),
          ],
        ),
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
      return AppTheme.queueIdleBackground;
    }
    return AppTheme.queueProcessColorForId(processId);
  }
}

class _CellData {
  const _CellData({required this.time, required this.processId});

  final int time;
  final String? processId;
}

import 'dart:ui' show PathMetric;

import 'package:cpu_flow_simulator/core/theme/app_theme.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/schedule_slice.dart';
import 'package:flutter/material.dart';

class SliceQueueTable extends StatefulWidget {
  const SliceQueueTable({
    super.key,
    required this.slices,
    this.showAnimations = true,
  });

  final List<ScheduleSlice> slices;
  final bool showAnimations;

  @override
  State<SliceQueueTable> createState() => _SliceQueueTableState();
}

class _SliceQueueTableState extends State<SliceQueueTable>
    with SingleTickerProviderStateMixin {
  static const Duration _cellRevealDelay = Duration(milliseconds: 420);
  static const Duration _cellRevealDuration = Duration(milliseconds: 360);

  static const double _cellMinWidth = 74;
  static const double _cellHeight = 88;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant SliceQueueTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slices != widget.slices ||
        oldWidget.showAnimations != widget.showAnimations) {
      _syncAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    final int totalTime = widget.slices.isEmpty
        ? 0
        : widget.slices
              .map((slice) => slice.endTime)
              .reduce((a, b) => a > b ? a : b);

    _controller.stop();

    if (!widget.showAnimations || totalTime == 0) {
      _controller.duration = _cellRevealDuration;
      _controller.value = 1;
      return;
    }

    final Duration totalDuration = Duration(
      milliseconds:
          _cellRevealDelay.inMilliseconds * (totalTime - 1) +
          _cellRevealDuration.inMilliseconds,
    );

    _controller
      ..duration = totalDuration
      ..value = 0;
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final int totalTime = widget.slices.isEmpty
        ? 0
        : widget.slices
              .map((slice) => slice.endTime)
              .reduce((a, b) => a > b ? a : b);

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
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int index = 0; index < cells.length; index++)
                    _AnimatedQueueCell(
                      progress: _cellProgress(index),
                      child: _buildCell(cells[index]),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  double _cellProgress(int index) {
    if (!widget.showAnimations) {
      return 1;
    }

    final int totalDurationMillis = _controller.duration?.inMilliseconds ?? 1;
    final double start =
        (_cellRevealDelay.inMilliseconds * index) / totalDurationMillis;
    final double end =
        ((_cellRevealDelay.inMilliseconds * index) +
            _cellRevealDuration.inMilliseconds) /
        totalDurationMillis;
    final double currentValue = _controller.value;

    if (currentValue <= start) {
      return 0;
    }
    if (currentValue >= end) {
      return 1;
    }

    final double normalized = (currentValue - start) / (end - start);
    return Curves.easeOutCubic.transform(normalized.clamp(0.0, 1.0));
  }

  Widget _buildCell(_CellData cell) {
    final bool isNoneProcess = cell.processId == 'none';
    final Widget content = Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _colorForProcessId(cell.processId),
        borderRadius: BorderRadius.circular(12),
        border: isNoneProcess
            ? null
            : Border.all(color: AppTheme.queueCellBorder, width: 1),
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
    );

    return SizedBox(
      width: _cellMinWidth,
      height: _cellHeight,
      child: isNoneProcess ? _DashedCellBorder(child: content) : content,
    );
  }

  ScheduleSlice? _findSliceAt(int time) {
    for (final slice in widget.slices) {
      if (time >= slice.startTime && time < slice.endTime) {
        return slice;
      }
    }
    return null;
  }

  Color _colorForProcessId(String? processId) {
    if (processId == null || processId == 'none') {
      return Colors.white;
    }
    return AppTheme.queueProcessColorForId(processId);
  }
}

class _AnimatedQueueCell extends StatelessWidget {
  const _AnimatedQueueCell({required this.progress, required this.child});

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: progress,
      child: Transform.translate(
        offset: Offset(0, 14 * (1 - progress)),
        child: child,
      ),
    );
  }
}

class _DashedCellBorder extends StatelessWidget {
  const _DashedCellBorder({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRoundedBorderPainter(
        color: AppTheme.queueCellBorder,
        radius: 12,
        strokeWidth: 1,
        dashLength: 6,
        gapLength: 4,
      ),
      child: child,
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  const _DashedRoundedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final Path dashedPath = _buildDashedPath(Path()..addRRect(rrect));
    canvas.drawPath(dashedPath, paint);
  }

  Path _buildDashedPath(Path source) {
    final Path dashedPath = Path();

    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = (distance + dashLength)
            .clamp(0, metric.length)
            .toDouble();
        dashedPath.addPath(metric.extractPath(distance, next), Offset.zero);
        distance += dashLength + gapLength;
      }
    }

    return dashedPath;
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        radius != oldDelegate.radius ||
        strokeWidth != oldDelegate.strokeWidth ||
        dashLength != oldDelegate.dashLength ||
        gapLength != oldDelegate.gapLength;
  }
}

class _CellData {
  const _CellData({required this.time, required this.processId});

  final int time;
  final String? processId;
}

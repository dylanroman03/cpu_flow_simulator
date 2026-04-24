import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/schedule_slice.dart';

class SimulationResult {
  final List<ScheduleSlice> slices;
  final int totalTime;
  final double averageWaitingTime;

  const SimulationResult({
    required this.slices,
    required this.totalTime,
    required this.averageWaitingTime,
  }) : assert(totalTime >= 0),
       assert(averageWaitingTime >= 0);

  const SimulationResult.empty()
    : slices = const <ScheduleSlice>[],
      totalTime = 0,
      averageWaitingTime = 0;
}

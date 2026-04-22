import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/process.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/process_runtime.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/schedule_slice.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/simulation_result.dart';

class OrderByFifoUseCase {
  SimulationResult call(List<Process> processes) {
    final List<Process> sortedProcess = List<Process>.from(processes)
      ..sort((a, b) => a.arriveTime.compareTo(b.arriveTime));

    List<ScheduleSlice> slices = [];
    List<ProcessRuntime> processRuntimes = [];
    int currentTime = 0;

    for (var process in sortedProcess) {
      ScheduleSlice slice = ScheduleSlice(
        processId: process.id,
        startTime: currentTime,
        endTime: currentTime + process.cpuTime,
      );

      ProcessRuntime runtime = ProcessRuntime.fromProcess(process).copyWith(
        remainingTime: 0,
        waitingTime: slice.startTime - process.arriveTime,
        firstStartTime: slice.startTime,
        finishTime: slice.endTime,
      );

      slices.add(slice);
      processRuntimes.add(runtime);
      currentTime = slice.endTime;
    }

    final avarageWaitingTime =
        processRuntimes.map((p) => p.waitingTime).reduce((a, b) => a + b) /
        processRuntimes.length;

    return SimulationResult(
      slices: slices,
      totalTime: currentTime,
      averageWaitingTime: avarageWaitingTime.toDouble(),
    );
  }
}

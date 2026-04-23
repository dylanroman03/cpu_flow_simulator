import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/process.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/process_runtime.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/schedule_slice.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/simulation_result.dart';

class OrderBySjfUseCase {
  SimulationResult call(List<Process> processes) {
    List<Process> sortedProcess = List<Process>.from(processes)
      ..sort((a, b) => a.arriveTime.compareTo(b.arriveTime));

    int currentTime = 0;
    List<ScheduleSlice> slices = [];
    List<ProcessRuntime> processRuntimes = [];

    while (sortedProcess.isNotEmpty) {
      final availableProcesses = sortedProcess
          .where((p) => p.arriveTime <= currentTime)
          .toList();

      if (availableProcesses.isEmpty) {
        final int nextArriveTime = sortedProcess
            .map((p) => p.arriveTime)
            .reduce((a, b) => a < b ? a : b);

        slices.add(
          ScheduleSlice(
            processId: 'none',
            startTime: currentTime,
            endTime: nextArriveTime,
          ),
        );
        currentTime = nextArriveTime;
        continue;
      }

      availableProcesses.sort((a, b) => a.cpuTime.compareTo(b.cpuTime));
      final processToRun = availableProcesses.first;

      ScheduleSlice slice = ScheduleSlice(
        processId: processToRun.id,
        startTime: currentTime,
        endTime: currentTime + processToRun.cpuTime,
      );

      ProcessRuntime runtime = ProcessRuntime.fromProcess(processToRun)
          .copyWith(
            remainingTime: 0,
            waitingTime: slice.startTime - processToRun.arriveTime,
            firstStartTime: slice.startTime,
            finishTime: slice.endTime,
          );

      slices.add(slice);
      processRuntimes.add(runtime);
      sortedProcess.remove(processToRun);

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

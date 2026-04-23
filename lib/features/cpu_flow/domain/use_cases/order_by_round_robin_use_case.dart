import 'dart:collection';
import 'dart:math';

import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/process.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/process_runtime.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/schedule_slice.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/simulation_result.dart';

class OrderByRoundRobinUseCase {
  SimulationResult call(List<Process> processes, int quantum) {
    if (quantum <= 0) {
      throw ArgumentError.value(quantum, 'quantum', 'must be greater than 0');
    }

    List<ProcessRuntime> pending =
        processes.map((process) => ProcessRuntime.fromProcess(process)).toList()
          ..sort((a, b) => a.arriveTime.compareTo(b.arriveTime));

    Queue<ProcessRuntime> readyQueue = Queue<ProcessRuntime>();
    List<ScheduleSlice> slices = [];
    List<ProcessRuntime> completed = [];

    int currentTime = 0;

    List<ProcessRuntime> availableProcesses = availableProcess(
      pending,
      currentTime,
    );
    updateQueue(readyQueue, availableProcesses);
    updatePending(pending, availableProcesses);

    while (pending.isNotEmpty || readyQueue.isNotEmpty) {
      if (readyQueue.isEmpty) {
        final int nextArriveTime = pending
            .map((process) => process.arriveTime)
            .reduce((a, b) => a < b ? a : b);

        slices.add(
          ScheduleSlice(
            processId: 'none',
            startTime: currentTime,
            endTime: nextArriveTime,
          ),
        );
        currentTime = nextArriveTime;

        availableProcesses = availableProcess(pending, currentTime);
        updateQueue(readyQueue, availableProcesses);
        updatePending(pending, availableProcesses);
        continue;
      }

      final processToRun = readyQueue.removeFirst();
      int timeIn = min(quantum, processToRun.remainingTime);

      ScheduleSlice slice = ScheduleSlice(
        processId: processToRun.processId,
        startTime: currentTime,
        endTime: currentTime + timeIn,
      );

      final updatedRemainingTime = processToRun.remainingTime - timeIn;
      final newProcess = processToRun.copyWith(
        remainingTime: updatedRemainingTime,
        finishTime: updatedRemainingTime == 0
            ? slice.endTime
            : processToRun.finishTime,
      );

      slices.add(slice);
      currentTime = slice.endTime;

      availableProcesses = availableProcess(pending, currentTime);
      updateQueue(readyQueue, availableProcesses);
      updatePending(pending, availableProcesses);

      if (newProcess.remainingTime > 0) {
        readyQueue.add(newProcess);
      } else {
        completed.add(newProcess);
      }
    }

    final totalWaitingTime = completed.fold<int>(0, (sum, runtime) {
      final completionTime = runtime.finishTime ?? currentTime;
      final waitingTime = completionTime - runtime.arriveTime - runtime.cpuTime;
      return sum + waitingTime;
    });

    final averageWaitingTime = totalWaitingTime / completed.length;

    return SimulationResult(
      slices: slices,
      totalTime: currentTime,
      averageWaitingTime: averageWaitingTime,
    );
  }

  void updateQueue(
    Queue<ProcessRuntime> readyQueue,
    List<ProcessRuntime> availableProcesses,
  ) {
    readyQueue.addAll(availableProcesses);
  }

  void updatePending(
    List<ProcessRuntime> pending,
    List<ProcessRuntime> availableProcesses,
  ) {
    for (var process in availableProcesses) {
      pending.remove(process);
    }
  }

  List<ProcessRuntime> availableProcess(
    List<ProcessRuntime> sortedProcess,
    int currentTime,
  ) {
    List<ProcessRuntime> availableProcesses = List<ProcessRuntime>.from(
      sortedProcess.where((p) => p.arriveTime <= currentTime),
    );

    return availableProcesses;
  }
}

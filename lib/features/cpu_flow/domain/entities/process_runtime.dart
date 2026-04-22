import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/process.dart';

class ProcessRuntime {
  final String processId;
  final int arriveTime;
  final int cpuTime;
  final int remainingTime;
  final int waitingTime;
  final int? firstStartTime;
  final int? finishTime;

  const ProcessRuntime({
    required this.processId,
    required this.arriveTime,
    required this.cpuTime,
    required this.remainingTime,
    required this.waitingTime,
    this.firstStartTime,
    this.finishTime,
  }) : assert(arriveTime >= 0),
       assert(cpuTime > 0),
       assert(remainingTime >= 0),
       assert(waitingTime >= 0);

  bool get isCompleted => remainingTime == 0;

  ProcessRuntime copyWith({
    String? processId,
    int? arriveTime,
    int? cpuTime,
    int? remainingTime,
    int? waitingTime,
    int? firstStartTime,
    int? finishTime,
  }) => ProcessRuntime(
    processId: processId ?? this.processId,
    arriveTime: arriveTime ?? this.arriveTime,
    cpuTime: cpuTime ?? this.cpuTime,
    remainingTime: remainingTime ?? this.remainingTime,
    waitingTime: waitingTime ?? this.waitingTime,
    firstStartTime: firstStartTime ?? this.firstStartTime,
    finishTime: finishTime ?? this.finishTime,
  );

  factory ProcessRuntime.fromProcess(Process process) => ProcessRuntime(
    processId: process.id,
    arriveTime: process.arriveTime,
    cpuTime: process.cpuTime,
    remainingTime: process.cpuTime,
    waitingTime: 0,
  );
}

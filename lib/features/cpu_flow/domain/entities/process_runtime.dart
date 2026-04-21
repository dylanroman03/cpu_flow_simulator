class ProcessRuntime {
  final String processId;
  final int remainingTime;
  final int waitingTime;
  final int? firstStartTime;
  final int? finishTime;

  const ProcessRuntime({
    required this.processId,
    required this.remainingTime,
    required this.waitingTime,
    this.firstStartTime,
    this.finishTime,
  }) : assert(remainingTime >= 0),
       assert(waitingTime >= 0);

  bool get isCompleted => remainingTime == 0;

  ProcessRuntime copyWith({
    String? processId,
    int? remainingTime,
    int? waitingTime,
    int? firstStartTime,
    int? finishTime,
  }) => ProcessRuntime(
    processId: processId ?? this.processId,
    remainingTime: remainingTime ?? this.remainingTime,
    waitingTime: waitingTime ?? this.waitingTime,
    firstStartTime: firstStartTime ?? this.firstStartTime,
    finishTime: finishTime ?? this.finishTime,
  );
}

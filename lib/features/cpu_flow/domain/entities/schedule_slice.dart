class ScheduleSlice {
  final String processId;
  final int startTime;
  final int endTime;

  const ScheduleSlice({
    required this.processId,
    required this.startTime,
    required this.endTime,
  }) : assert(startTime >= 0),
       assert(endTime > startTime);

  int get duration => endTime - startTime;
}

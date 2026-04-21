class Process {
  final String id;
  final int arriveTime;
  final int cpuTime;

  const Process({
    required this.id,
    required this.arriveTime,
    required this.cpuTime,
  }) : assert(arriveTime >= 0),
       assert(cpuTime > 0);

  Process copyWith({String? id, int? arriveTime, int? cpuTime}) => Process(
    id: id ?? this.id,
    arriveTime: arriveTime ?? this.arriveTime,
    cpuTime: cpuTime ?? this.cpuTime,
  );
}

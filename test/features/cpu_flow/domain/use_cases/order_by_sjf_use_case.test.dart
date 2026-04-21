import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/process.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/use_cases/order_by_sjf_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderBySjfUseCase', () {
    test('debe ordenar por SJF no expropiativo con los datos del ejemplo', () {
      final useCase = OrderBySjfUseCase();

      final processes = <Process>[
        const Process(id: 'P1', arriveTime: 0, cpuTime: 7),
        const Process(id: 'P2', arriveTime: 2, cpuTime: 4),
        const Process(id: 'P3', arriveTime: 4, cpuTime: 1),
        const Process(id: 'P4', arriveTime: 5, cpuTime: 4),
      ];

      final result = useCase(processes);

      expect(result.slices.length, 4);

      expect(result.slices[0].processId, 'P1');
      expect(result.slices[0].startTime, 0);
      expect(result.slices[0].endTime, 7);

      expect(result.slices[1].processId, 'P3');
      expect(result.slices[1].startTime, 7);
      expect(result.slices[1].endTime, 8);

      expect(result.slices[2].processId, 'P2');
      expect(result.slices[2].startTime, 8);
      expect(result.slices[2].endTime, 12);

      expect(result.slices[3].processId, 'P4');
      expect(result.slices[3].startTime, 12);
      expect(result.slices[3].endTime, 16);

      expect(result.totalTime, 16);
      expect(result.averageWaitingTime, closeTo(4.0, 0.0001));
    });
  });
}

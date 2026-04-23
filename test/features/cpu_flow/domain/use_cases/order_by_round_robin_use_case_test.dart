import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/process.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/use_cases/order_by_round_robin_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderByRoundRobinUseCase', () {
    test('genera el timeline esperado con los datos del ejemplo (q=3)', () {
      final useCase = OrderByRoundRobinUseCase();
      const quantum = 3;

      final processes = <Process>[
        const Process(id: 'P1', arriveTime: 0, cpuTime: 7),
        const Process(id: 'P2', arriveTime: 2, cpuTime: 4),
        const Process(id: 'P3', arriveTime: 4, cpuTime: 1),
        const Process(id: 'P4', arriveTime: 5, cpuTime: 4),
      ];

      final result = useCase.call(processes, quantum);

      expect(result.slices.length, 8);

      expect(result.slices[0].processId, 'P1');
      expect(result.slices[0].startTime, 0);
      expect(result.slices[0].endTime, 3);

      expect(result.slices[1].processId, 'P2');
      expect(result.slices[1].startTime, 3);
      expect(result.slices[1].endTime, 6);

      expect(result.slices[2].processId, 'P1');
      expect(result.slices[2].startTime, 6);
      expect(result.slices[2].endTime, 9);

      expect(result.slices[3].processId, 'P3');
      expect(result.slices[3].startTime, 9);
      expect(result.slices[3].endTime, 10);

      expect(result.slices[4].processId, 'P4');
      expect(result.slices[4].startTime, 10);
      expect(result.slices[4].endTime, 13);

      expect(result.slices[5].processId, 'P2');
      expect(result.slices[5].startTime, 13);
      expect(result.slices[5].endTime, 14);

      expect(result.slices[6].processId, 'P1');
      expect(result.slices[6].startTime, 14);
      expect(result.slices[6].endTime, 15);

      expect(result.slices[7].processId, 'P4');
      expect(result.slices[7].startTime, 15);
      expect(result.slices[7].endTime, 16);

      expect(result.totalTime, 16);
      expect(result.averageWaitingTime, closeTo(7.0, 0.0001));
    });

    test('genera slices none cuando hay huecos sin procesos en cola', () {
      final useCase = OrderByRoundRobinUseCase();
      const quantum = 2;

      final processes = <Process>[
        const Process(id: 'P1', arriveTime: 3, cpuTime: 3),
        const Process(id: 'P2', arriveTime: 10, cpuTime: 2),
      ];

      final result = useCase.call(processes, quantum);

      expect(result.slices.length, 5);

      expect(result.slices[0].processId, 'none');
      expect(result.slices[0].startTime, 0);
      expect(result.slices[0].endTime, 3);

      expect(result.slices[1].processId, 'P1');
      expect(result.slices[1].startTime, 3);
      expect(result.slices[1].endTime, 5);

      expect(result.slices[2].processId, 'P1');
      expect(result.slices[2].startTime, 5);
      expect(result.slices[2].endTime, 6);

      expect(result.slices[3].processId, 'none');
      expect(result.slices[3].startTime, 6);
      expect(result.slices[3].endTime, 10);

      expect(result.slices[4].processId, 'P2');
      expect(result.slices[4].startTime, 10);
      expect(result.slices[4].endTime, 12);

      expect(result.totalTime, 12);
      expect(result.averageWaitingTime, closeTo(0.0, 0.0001));
    });
  });
}

import 'package:cpu_flow_simulator/features/cpu_flow/domain/entities/process.dart';
import 'package:cpu_flow_simulator/features/cpu_flow/domain/use_cases/order_by_fifo_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderByFifoUseCase', () {
    test('genera el timeline FIFO esperado con los datos del ejemplo', () {
      final useCase = OrderByFifoUseCase();

      final processes = <Process>[
        const Process(id: 'P1', arriveTime: 0, cpuTime: 6),
        const Process(id: 'P2', arriveTime: 4, cpuTime: 3),
        const Process(id: 'P3', arriveTime: 6, cpuTime: 4),
        const Process(id: 'P4', arriveTime: 7, cpuTime: 1),
      ];

      final result = useCase.call(processes);

      expect(result.slices.length, 4);

      expect(result.slices[0].processId, 'P1');
      expect(result.slices[0].startTime, 0);
      expect(result.slices[0].endTime, 6);

      expect(result.slices[1].processId, 'P2');
      expect(result.slices[1].startTime, 6);
      expect(result.slices[1].endTime, 9);

      expect(result.slices[2].processId, 'P3');
      expect(result.slices[2].startTime, 9);
      expect(result.slices[2].endTime, 13);

      expect(result.slices[3].processId, 'P4');
      expect(result.slices[3].startTime, 13);
      expect(result.slices[3].endTime, 14);

      expect(result.totalTime, 14);
      expect(result.averageWaitingTime, closeTo(2.75, 0.0001));
    });

    test('genera slices none cuando hay huecos sin procesos', () {
      final useCase = OrderByFifoUseCase();

      final processes = <Process>[
        const Process(id: 'P1', arriveTime: 3, cpuTime: 2),
        const Process(id: 'P2', arriveTime: 8, cpuTime: 1),
      ];

      final result = useCase.call(processes);

      expect(result.slices.length, 4);

      expect(result.slices[0].processId, 'none');
      expect(result.slices[0].startTime, 0);
      expect(result.slices[0].endTime, 3);

      expect(result.slices[1].processId, 'P1');
      expect(result.slices[1].startTime, 3);
      expect(result.slices[1].endTime, 5);

      expect(result.slices[2].processId, 'none');
      expect(result.slices[2].startTime, 5);
      expect(result.slices[2].endTime, 8);

      expect(result.slices[3].processId, 'P2');
      expect(result.slices[3].startTime, 8);
      expect(result.slices[3].endTime, 9);

      expect(result.totalTime, 9);
      expect(result.averageWaitingTime, closeTo(0.0, 0.0001));
    });
  });
}

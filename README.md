# CPU Flow Simulator

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[![Open Live Demo](https://img.shields.io/badge/Open-Live%20Demo-0A66C2?style=for-the-badge)](https://dylanroman03.github.io/cpu_flow_simulator/)

Visual CPU scheduling simulator for learning Operating Systems concepts without doing everything by hand.

The idea of this project started in class: in my OS course we had to solve scheduling exercises manually, and I wanted to build an interactive page that shows the same process visually.

## Try It

Open the website here: https://dylanroman03.github.io/cpu_flow_simulator/


## What It Does

- Lets you define processes with arrival time and CPU burst time.
- Runs simulations with different scheduling algorithms.
- Visualizes the execution queue over time.
- Computes per-process metrics and average waiting time.
- Supports both Spanish and English UI.

## Supported Algorithms

- `FIFO` (First In, First Out)
- `SJF` (Shortest Job First, non-preemptive)
- `Round Robin` (with configurable quantum)

## Tech Stack

- `Flutter` + `Dart`
- Feature-based architecture (`domain` and `presentation`)
- UI designed for process execution visualization

## Run Locally

Requirements:

- Flutter SDK installed
- Dart SDK (included with Flutter)

Steps:

```bash
flutter pub get
flutter run
```

To run specifically on web:

```bash
flutter run -d chrome
```

## Project Structure

```text
lib/
	core/
	features/
		cpu_flow/
			domain/
			presentation/
	l10n/
```

## Academic Purpose

This project is designed as a learning aid to:

- Understand differences between scheduling algorithms.
- See the impact of quantum in Round Robin.
- Compare waiting times and execution order.

## Contributing

If you want to contribute, open an issue or submit a pull request.

Useful contribution ideas:

- Add more algorithms.
- Improve metrics and visualizations.
- Add more unit tests.
- Improve accessibility and user experience.
- Whatever you think would be cool to have.

## License

This project is open source under the MIT License.
See [LICENSE](LICENSE) for details.

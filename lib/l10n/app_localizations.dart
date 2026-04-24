import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final AppLocalizations? localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    return localizations ?? AppLocalizations(const Locale('es'));
  }

  bool get isSpanish => locale.languageCode.toLowerCase() == 'es';

  String get appTitle =>
      isSpanish ? 'CPU Flow Simulator' : 'CPU Flow Simulator';

  String get screenTitle => isSpanish
      ? 'CPU Flow Simulator - Cola de Ejecución'
      : 'CPU Flow Simulator - Execution Queue';

  String get processTableTitle =>
      isSpanish ? 'Tabla de procesos' : 'Process table';

  String get addButton => isSpanish ? 'Agregar' : 'Add';

  String get processColumn => isSpanish ? 'Proceso' : 'Process';

  String get arrivalColumn => isSpanish ? 'Llegada' : 'Arrival';

  String get cpuColumn => isSpanish ? 'CPU (ms)' : 'CPU (ms)';

  String get removeProcessTooltip =>
      isSpanish ? 'Eliminar proceso' : 'Remove process';

  String get processTableError => isSpanish
      ? 'Error: Asegúrate de que todos los campos sean válidos.'
      : 'Error: Make sure all fields are valid.';

  String get processTableNote => isSpanish
      ? 'Nota: solo se toman filas con llegada >= 0 y CPU > 0.'
      : 'Note: only rows with arrival >= 0 and CPU > 0 are used.';

  String get queueEmpty =>
      isSpanish ? 'Sin ejecucion para mostrar' : 'No execution to show';

  String get queueTitle => isSpanish ? 'Cola de ejecucion' : 'Execution queue';

  String get queueSubtitle => isSpanish
      ? 'Cada bloque representa 1 ms de CPU.'
      : 'Each block represents 1 ms of CPU time.';

  String get metricsTitle => isSpanish ? 'Metricas' : 'Metrics';

  String get totalTimeLabel => isSpanish ? 'Tiempo total' : 'Total time';

  String get averageWaitingTimeLabel =>
      isSpanish ? 'Espera promedio' : 'Average waiting';

  String get validProcessesPrefix =>
      isSpanish ? 'Procesos validos' : 'Valid processes';

  String get animationLabel => isSpanish ? 'Animaciones' : 'Animations';

  String get runButton => isSpanish ? 'Ejecutar' : 'Run';

  String get fifo => 'FIFO';

  String get sjf => 'SJF';

  String get roundRobin => isSpanish ? 'Round Robin' : 'Round Robin';

  String get quantumLabel => 'Q';

  String get noProcessesSnack => isSpanish
      ? 'Agrega al menos un proceso valido.'
      : 'Add at least one valid process.';

  String get quantumInvalidSnack => isSpanish
      ? 'El quantum debe ser mayor a 0.'
      : 'Quantum must be greater than 0.';

  String get simulationErrorSnack => isSpanish
      ? 'No se pudo ejecutar la simulacion con estos datos.'
      : 'The simulation could not be executed with these inputs.';

  String processCount(int count) =>
      isSpanish ? 'Procesos validos: $count' : 'Valid processes: $count';

  String algorithmLabel(String label) => label;

  String get idleLabel => isSpanish ? 'Idle' : 'Idle';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

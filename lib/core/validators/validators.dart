class Validators {
  static bool isArrivalValidText(String text) {
    final int? value = int.tryParse(text);
    return value != null && value >= 0;
  }

  static bool isCpuValidText(String text) {
    final int? value = int.tryParse(text);
    return value != null && value > 0;
  }
}

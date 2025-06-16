class TestExecutionEntity {
  final String reagentName;
  final DateTime startTime;
  final int timerDuration;
  final String? selectedColor;
  final String? notes;
  final bool isTimerRunning;
  final int remainingTime;
  final bool isCompleted;

  const TestExecutionEntity({
    required this.reagentName,
    required this.startTime,
    required this.timerDuration,
    this.selectedColor,
    this.notes,
    this.isTimerRunning = false,
    required this.remainingTime,
    this.isCompleted = false,
  });

  TestExecutionEntity copyWith({
    String? reagentName,
    DateTime? startTime,
    int? timerDuration,
    String? selectedColor,
    String? notes,
    bool? isTimerRunning,
    int? remainingTime,
    bool? isCompleted,
  }) {
    return TestExecutionEntity(
      reagentName: reagentName ?? this.reagentName,
      startTime: startTime ?? this.startTime,
      timerDuration: timerDuration ?? this.timerDuration,
      selectedColor: selectedColor ?? this.selectedColor,
      notes: notes ?? this.notes,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      remainingTime: remainingTime ?? this.remainingTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

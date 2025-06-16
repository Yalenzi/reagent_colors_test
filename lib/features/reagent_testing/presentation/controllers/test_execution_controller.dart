import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reagent_entity.dart';
import '../../domain/entities/test_execution_entity.dart';
import '../states/test_execution_state.dart';

class TestExecutionController extends StateNotifier<TestExecutionState> {
  TestExecutionController() : super(const TestExecutionInitial());

  Timer? _timer;

  void initializeTest(ReagentEntity reagent) {
    final testExecution = TestExecutionEntity(
      reagentName: reagent.reagentName,
      startTime: DateTime.now(),
      timerDuration: reagent.testDuration * 60, // Convert minutes to seconds
      remainingTime: reagent.testDuration * 60,
    );

    state = TestExecutionLoaded(testExecution: testExecution);
  }

  void startTimer() {
    if (state is TestExecutionLoaded) {
      final currentState = state as TestExecutionLoaded;
      final testExecution = currentState.testExecution;

      if (testExecution.isTimerRunning) return;

      final updatedExecution = testExecution.copyWith(isTimerRunning: true);
      state = TestExecutionLoaded(testExecution: updatedExecution);

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (state is TestExecutionLoaded) {
          final currentExecution = (state as TestExecutionLoaded).testExecution;

          if (currentExecution.remainingTime <= 0) {
            _stopTimer();
            return;
          }

          final newRemainingTime = currentExecution.remainingTime - 1;
          final updatedExecution = currentExecution.copyWith(
            remainingTime: newRemainingTime,
          );

          if (newRemainingTime <= 0) {
            final completedExecution = updatedExecution.copyWith(
              isTimerRunning: false,
              isCompleted: true,
            );
            state = TestExecutionLoaded(testExecution: completedExecution);
            _stopTimer();
          } else {
            state = TestExecutionLoaded(testExecution: updatedExecution);
          }
        }
      });
    }
  }

  void pauseTimer() {
    if (state is TestExecutionLoaded) {
      final currentState = state as TestExecutionLoaded;
      _timer?.cancel();
      final updatedExecution = currentState.testExecution.copyWith(
        isTimerRunning: false,
      );
      state = TestExecutionLoaded(testExecution: updatedExecution);
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void selectColor(String color) {
    if (state is TestExecutionLoaded) {
      final currentState = state as TestExecutionLoaded;
      final updatedExecution = currentState.testExecution.copyWith(
        selectedColor: color,
      );
      state = TestExecutionLoaded(testExecution: updatedExecution);
    }
  }

  void updateNotes(String notes) {
    if (state is TestExecutionLoaded) {
      final currentState = state as TestExecutionLoaded;
      final updatedExecution = currentState.testExecution.copyWith(
        notes: notes,
      );
      state = TestExecutionLoaded(testExecution: updatedExecution);
    }
  }

  void resetTimer() {
    if (state is TestExecutionLoaded) {
      final currentState = state as TestExecutionLoaded;
      final testExecution = currentState.testExecution;
      _stopTimer();
      final resetExecution = testExecution.copyWith(
        remainingTime: testExecution.timerDuration,
        isTimerRunning: false,
        isCompleted: false,
      );
      state = TestExecutionLoaded(testExecution: resetExecution);
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

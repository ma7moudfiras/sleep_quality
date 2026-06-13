import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sleep_api.dart';
import '../../domain/sleep_log.dart';

final logsProvider = FutureProvider<List<SleepLog>>((ref) async {
  return ref.watch(sleepApiProvider).getLogs();
});

final predictionProvider = FutureProvider<PredictionResult>((ref) async {
  return ref.watch(sleepApiProvider).getPrediction();
});

final chartsProvider = FutureProvider<ChartsData>((ref) async {
  return ref.watch(sleepApiProvider).getCharts();
});

final insightsProvider = FutureProvider<InsightsData>((ref) async {
  return ref.watch(sleepApiProvider).getInsights();
});

final weeklyReportProvider = FutureProvider<WeeklyReport>((ref) async {
  return ref.watch(sleepApiProvider).getWeeklyReport();
});

final systemStatusProvider = FutureProvider<SystemStatus>((ref) async {
  return ref.watch(sleepApiProvider).getSystemStatus();
});

final logSubmitControllerProvider =
    StateNotifierProvider<LogSubmitController, AsyncValue<void>>((ref) {
  return LogSubmitController(ref);
});

class LogSubmitController extends StateNotifier<AsyncValue<void>> {
  LogSubmitController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  Future<void> submit(SleepLogInput input) async {
    state = const AsyncLoading();
    try {
      await _ref.read(sleepApiProvider).createLog(input);
      _invalidateReadModels(_ref);
      state = const AsyncData(null);
    } on DioException catch (error, stackTrace) {
      state = AsyncError(_messageFromDio(error), stackTrace);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

final feedbackControllerProvider = StateNotifierProvider<FeedbackController,
    AsyncValue<FeedbackResult?>>((ref) {
  return FeedbackController(ref);
});

class FeedbackController extends StateNotifier<AsyncValue<FeedbackResult?>> {
  FeedbackController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  Future<FeedbackResult> saveFeedback({
    required int logId,
    required String actualEnergyLevel,
    bool autoRetrain = true,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await _ref.read(sleepApiProvider).saveFeedback(
            logId: logId,
            actualEnergyLevel: actualEnergyLevel,
            autoRetrain: autoRetrain,
          );
      _invalidateReadModels(_ref);
      state = AsyncData(result);
      return result;
    } on DioException catch (error, stackTrace) {
      final message = _messageFromDio(error);
      state = AsyncError(message, stackTrace);
      throw Exception(message);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final retrainControllerProvider =
    StateNotifierProvider<RetrainController, AsyncValue<RetrainResult?>>((ref) {
  return RetrainController(ref);
});

class RetrainController extends StateNotifier<AsyncValue<RetrainResult?>> {
  RetrainController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  Future<void> retrain() async {
    state = const AsyncLoading();
    try {
      final result = await _ref.read(sleepApiProvider).retrainModel();
      _invalidateReadModels(_ref);
      state = AsyncData(result);
    } on DioException catch (error, stackTrace) {
      state = AsyncError(_messageFromDio(error), stackTrace);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

final whatIfControllerProvider =
    StateNotifierProvider<WhatIfController, AsyncValue<WhatIfResult?>>((ref) {
  return WhatIfController(ref);
});

class WhatIfController extends StateNotifier<AsyncValue<WhatIfResult?>> {
  WhatIfController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  Future<void> run(WhatIfInput input) async {
    state = const AsyncLoading();
    try {
      final result = await _ref.read(sleepApiProvider).runWhatIf(input);
      state = AsyncData(result);
    } on DioException catch (error, stackTrace) {
      state = AsyncError(_messageFromDio(error), stackTrace);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

void _invalidateReadModels(Ref ref) {
  ref.invalidate(logsProvider);
  ref.invalidate(predictionProvider);
  ref.invalidate(chartsProvider);
  ref.invalidate(insightsProvider);
  ref.invalidate(weeklyReportProvider);
  ref.invalidate(systemStatusProvider);
}

String _messageFromDio(DioException error) {
  final data = error.response?.data;
  if (data is Map<String, dynamic> && data['detail'] != null) {
    return data['detail'].toString();
  }
  return error.message ?? 'Request failed';
}

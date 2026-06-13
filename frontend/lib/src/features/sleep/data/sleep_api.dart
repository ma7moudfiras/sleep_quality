import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../domain/sleep_log.dart';

final sleepApiProvider = Provider<SleepApi>((ref) {
  return SleepApi(ref.watch(dioProvider));
});

class SleepApi {
  SleepApi(this._dio);

  final Dio _dio;

  Future<SleepLog> createLog(SleepLogInput input) async {
    final response = await _dio.post('/log', data: input.toJson());
    return SleepLog.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<SleepLog>> getLogs() async {
    final response = await _dio.get('/logs');
    final data = response.data as List<dynamic>;
    return data
        .map((item) => SleepLog.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<FeedbackResult> saveFeedback({
    required int logId,
    required String actualEnergyLevel,
    bool autoRetrain = true,
  }) async {
    final response = await _dio.patch(
      '/logs/$logId/feedback',
      data: {
        'actual_energy_level': actualEnergyLevel,
        'auto_retrain': autoRetrain,
      },
    );
    return FeedbackResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PredictionResult> getPrediction() async {
    final response = await _dio.get('/predict');
    return PredictionResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ChartsData> getCharts() async {
    final response = await _dio.get('/charts');
    return ChartsData.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RetrainResult> retrainModel() async {
    final response = await _dio.post('/retrain');
    return RetrainResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<InsightsData> getInsights() async {
    final response = await _dio.get('/insights');
    return InsightsData.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WeeklyReport> getWeeklyReport() async {
    final response = await _dio.get('/weekly-report');
    return WeeklyReport.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WhatIfResult> runWhatIf(WhatIfInput input) async {
    final response = await _dio.post('/what-if', data: input.toJson());
    return WhatIfResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SystemStatus> getSystemStatus() async {
    final response = await _dio.get('/system-status');
    return SystemStatus.fromJson(response.data as Map<String, dynamic>);
  }
}

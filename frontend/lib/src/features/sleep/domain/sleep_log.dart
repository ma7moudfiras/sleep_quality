class SleepLog {
  const SleepLog({
    required this.id,
    required this.logDate,
    required this.sleepHours,
    required this.bedtimeHour,
    required this.wakeHour,
    required this.mood,
    required this.activityLevel,
    this.predictedEnergyLevel,
    this.actualEnergyLevel,
    required this.createdAt,
  });

  final int id;
  final String logDate;
  final double sleepHours;
  final double bedtimeHour;
  final double wakeHour;
  final int mood;
  final int activityLevel;
  final String? predictedEnergyLevel;
  final String? actualEnergyLevel;
  final String createdAt;

  factory SleepLog.fromJson(Map<String, dynamic> json) {
    return SleepLog(
      id: json['id'] as int,
      logDate: json['log_date'] as String,
      sleepHours: (json['sleep_hours'] as num).toDouble(),
      bedtimeHour: (json['bedtime_hour'] as num).toDouble(),
      wakeHour: (json['wake_hour'] as num).toDouble(),
      mood: json['mood'] as int,
      activityLevel: json['activity_level'] as int,
      predictedEnergyLevel: json['predicted_energy_level'] as String?,
      actualEnergyLevel: json['actual_energy_level'] as String?,
      createdAt: json['created_at'] as String,
    );
  }
}

class SleepLogInput {
  const SleepLogInput({
    required this.logDate,
    required this.sleepHours,
    required this.bedtimeHour,
    required this.wakeHour,
    required this.mood,
    required this.activityLevel,
    this.actualEnergyLevel,
  });

  final String logDate;
  final double sleepHours;
  final double bedtimeHour;
  final double wakeHour;
  final int mood;
  final int activityLevel;
  final String? actualEnergyLevel;

  Map<String, dynamic> toJson() {
    return {
      'log_date': logDate,
      'sleep_hours': sleepHours,
      'bedtime_hour': bedtimeHour,
      'wake_hour': wakeHour,
      'mood': mood,
      'activity_level': activityLevel,
      if (actualEnergyLevel != null) 'actual_energy_level': actualEnergyLevel,
    };
  }
}

class FeedbackResult {
  const FeedbackResult({
    required this.status,
    required this.message,
    required this.log,
    required this.retrained,
    this.retrainResult,
  });

  final String status;
  final String message;
  final SleepLog log;
  final bool retrained;
  final RetrainResult? retrainResult;

  factory FeedbackResult.fromJson(Map<String, dynamic> json) {
    final retrainRaw = json['retrain_result'];
    return FeedbackResult(
      status: json['status'] as String,
      message: json['message'] as String,
      log: SleepLog.fromJson(json['log'] as Map<String, dynamic>),
      retrained: json['retrained'] as bool,
      retrainResult: retrainRaw == null
          ? null
          : RetrainResult.fromJson(retrainRaw as Map<String, dynamic>),
    );
  }
}

class PredictionResult {
  const PredictionResult({
    required this.prediction,
    required this.confidence,
    required this.tip,
    required this.explanation,
    required this.sourceLogId,
    required this.modelStatus,
  });

  final String prediction;
  final double confidence;
  final String tip;
  final List<String> explanation;
  final int sourceLogId;
  final String modelStatus;

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final rawExplanation = json['explanation'] as List<dynamic>? ?? const [];
    return PredictionResult(
      prediction: json['prediction'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      tip: json['tip'] as String,
      explanation: rawExplanation.map((item) => item.toString()).toList(),
      sourceLogId: json['source_log_id'] as int,
      modelStatus: json['model_status'] as String,
    );
  }
}

class ChartPointModel {
  const ChartPointModel({required this.date, required this.value});

  final String date;
  final double value;

  factory ChartPointModel.fromJson(Map<String, dynamic> json) {
    return ChartPointModel(
      date: json['date'] as String,
      value: (json['value'] as num).toDouble(),
    );
  }
}

class ChartsData {
  const ChartsData({
    required this.sleepTrend,
    required this.energyTrend,
    required this.moodTrend,
    required this.activityTrend,
  });

  final List<ChartPointModel> sleepTrend;
  final List<ChartPointModel> energyTrend;
  final List<ChartPointModel> moodTrend;
  final List<ChartPointModel> activityTrend;

  factory ChartsData.fromJson(Map<String, dynamic> json) {
    List<ChartPointModel> parseList(String key) {
      final raw = json[key] as List<dynamic>;
      return raw
          .map((item) => ChartPointModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return ChartsData(
      sleepTrend: parseList('sleep_trend'),
      energyTrend: parseList('energy_trend'),
      moodTrend: parseList('mood_trend'),
      activityTrend: parseList('activity_trend'),
    );
  }
}

class RetrainResult {
  const RetrainResult({
    required this.status,
    required this.message,
    required this.seedRows,
    required this.userTrainingRows,
    required this.totalTrainingRows,
    required this.modelStatus,
  });

  final String status;
  final String message;
  final int seedRows;
  final int userTrainingRows;
  final int totalTrainingRows;
  final String modelStatus;

  factory RetrainResult.fromJson(Map<String, dynamic> json) {
    return RetrainResult(
      status: json['status'] as String,
      message: json['message'] as String,
      seedRows: json['seed_rows'] as int,
      userTrainingRows: json['user_training_rows'] as int,
      totalTrainingRows: json['total_training_rows'] as int,
      modelStatus: json['model_status'] as String,
    );
  }
}

class WeeklyReport {
  const WeeklyReport({
    required this.daysCount,
    required this.averageSleep,
    required this.averageMood,
    required this.averageActivity,
    this.mostCommonEnergy,
    this.bestSleepDay,
    this.worstSleepDay,
    required this.sleepDebt,
    required this.streakDays,
  });

  final int daysCount;
  final double averageSleep;
  final double averageMood;
  final double averageActivity;
  final String? mostCommonEnergy;
  final String? bestSleepDay;
  final String? worstSleepDay;
  final double sleepDebt;
  final int streakDays;

  factory WeeklyReport.fromJson(Map<String, dynamic> json) {
    return WeeklyReport(
      daysCount: json['days_count'] as int,
      averageSleep: (json['average_sleep'] as num).toDouble(),
      averageMood: (json['average_mood'] as num).toDouble(),
      averageActivity: (json['average_activity'] as num).toDouble(),
      mostCommonEnergy: json['most_common_energy'] as String?,
      bestSleepDay: json['best_sleep_day'] as String?,
      worstSleepDay: json['worst_sleep_day'] as String?,
      sleepDebt: (json['sleep_debt'] as num).toDouble(),
      streakDays: json['streak_days'] as int,
    );
  }
}

class InsightsData {
  const InsightsData({
    required this.sleepConsistencyScore,
    required this.sleepDebtThisWeek,
    required this.averageSleep,
    required this.averageMood,
    required this.averageActivity,
    this.mostCommonEnergy,
    this.bestSleepDay,
    this.worstSleepDay,
    required this.streakDays,
    required this.personalizationLevel,
    required this.modelStatus,
    required this.recommendation,
    required this.dataQualityWarnings,
    required this.latestExplanation,
  });

  final int sleepConsistencyScore;
  final double sleepDebtThisWeek;
  final double averageSleep;
  final double averageMood;
  final double averageActivity;
  final String? mostCommonEnergy;
  final String? bestSleepDay;
  final String? worstSleepDay;
  final int streakDays;
  final String personalizationLevel;
  final String modelStatus;
  final String recommendation;
  final List<String> dataQualityWarnings;
  final List<String> latestExplanation;

  factory InsightsData.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(String key) {
      final raw = json[key] as List<dynamic>? ?? const [];
      return raw.map((item) => item.toString()).toList();
    }

    return InsightsData(
      sleepConsistencyScore: json['sleep_consistency_score'] as int,
      sleepDebtThisWeek: (json['sleep_debt_this_week'] as num).toDouble(),
      averageSleep: (json['average_sleep'] as num).toDouble(),
      averageMood: (json['average_mood'] as num).toDouble(),
      averageActivity: (json['average_activity'] as num).toDouble(),
      mostCommonEnergy: json['most_common_energy'] as String?,
      bestSleepDay: json['best_sleep_day'] as String?,
      worstSleepDay: json['worst_sleep_day'] as String?,
      streakDays: json['streak_days'] as int,
      personalizationLevel: json['personalization_level'] as String,
      modelStatus: json['model_status'] as String,
      recommendation: json['recommendation'] as String,
      dataQualityWarnings: parseStringList('data_quality_warnings'),
      latestExplanation: parseStringList('latest_explanation'),
    );
  }
}

class WhatIfInput {
  const WhatIfInput({
    required this.sleepHours,
    required this.bedtimeHour,
    required this.wakeHour,
    required this.mood,
    required this.activityLevel,
  });

  final double sleepHours;
  final double bedtimeHour;
  final double wakeHour;
  final int mood;
  final int activityLevel;

  Map<String, dynamic> toJson() {
    return {
      'sleep_hours': sleepHours,
      'bedtime_hour': bedtimeHour,
      'wake_hour': wakeHour,
      'mood': mood,
      'activity_level': activityLevel,
    };
  }
}

class BaselinePrediction {
  const BaselinePrediction({
    required this.sourceLogId,
    required this.prediction,
    required this.confidence,
  });

  final int sourceLogId;
  final String prediction;
  final double confidence;

  factory BaselinePrediction.fromJson(Map<String, dynamic> json) {
    return BaselinePrediction(
      sourceLogId: json['source_log_id'] as int,
      prediction: json['prediction'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}

class WhatIfResult {
  const WhatIfResult({
    required this.scenarioPrediction,
    required this.scenarioConfidence,
    required this.tip,
    required this.explanation,
    this.baseline,
    required this.modelStatus,
  });

  final String scenarioPrediction;
  final double scenarioConfidence;
  final String tip;
  final List<String> explanation;
  final BaselinePrediction? baseline;
  final String modelStatus;

  factory WhatIfResult.fromJson(Map<String, dynamic> json) {
    final baselineRaw = json['baseline'];
    final rawExplanation = json['explanation'] as List<dynamic>? ?? const [];
    return WhatIfResult(
      scenarioPrediction: json['scenario_prediction'] as String,
      scenarioConfidence: (json['scenario_confidence'] as num).toDouble(),
      tip: json['tip'] as String,
      explanation: rawExplanation.map((item) => item.toString()).toList(),
      baseline: baselineRaw == null
          ? null
          : BaselinePrediction.fromJson(baselineRaw as Map<String, dynamic>),
      modelStatus: json['model_status'] as String,
    );
  }
}

class SystemStatus {
  const SystemStatus({
    required this.apiRunning,
    required this.runtimeBaseDir,
    required this.dataDir,
    required this.databaseExists,
    required this.modelExists,
    required this.logsCount,
    required this.userTrainingRows,
    this.latestLogId,
    this.latestLogDate,
    this.latestPrediction,
    this.latestActualEnergy,
    required this.modelStatus,
    required this.readyForPrediction,
  });

  final bool apiRunning;
  final String runtimeBaseDir;
  final String dataDir;
  final bool databaseExists;
  final bool modelExists;
  final int logsCount;
  final int userTrainingRows;
  final int? latestLogId;
  final String? latestLogDate;
  final String? latestPrediction;
  final String? latestActualEnergy;
  final String modelStatus;
  final bool readyForPrediction;

  factory SystemStatus.fromJson(Map<String, dynamic> json) {
    return SystemStatus(
      apiRunning: json['api_running'] as bool? ?? false,
      runtimeBaseDir: json['runtime_base_dir'] as String? ?? '',
      dataDir: json['data_dir'] as String? ?? '',
      databaseExists: json['database_exists'] as bool? ?? false,
      modelExists: json['model_exists'] as bool? ?? false,
      logsCount: json['logs_count'] as int? ?? 0,
      userTrainingRows: json['user_training_rows'] as int? ?? 0,
      latestLogId: json['latest_log_id'] as int?,
      latestLogDate: json['latest_log_date'] as String?,
      latestPrediction: json['latest_prediction'] as String?,
      latestActualEnergy: json['latest_actual_energy'] as String?,
      modelStatus: json['model_status'] as String? ?? 'unknown',
      readyForPrediction: json['ready_for_prediction'] as bool? ?? false,
    );
  }
}

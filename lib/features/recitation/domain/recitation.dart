import 'package:qurani/core/reference/quran_reference_data.dart';

enum RecitationType {
  newMemorization('new_memorization'),
  revision('revision');

  const RecitationType(this.storageValue);

  final String storageValue;

  static RecitationType fromStorage(String value) {
    return switch (value) {
      'new_memorization' => RecitationType.newMemorization,
      'revision' => RecitationType.revision,
      _ => throw StateError('Unsupported recitation type: $value'),
    };
  }
}

enum RecitationEvaluation {
  talqin('talqin', 'تلقين'),
  excellent('excellent', 'ممتاز'),
  veryGood('very_good', 'جيد جدًا'),
  good('good', 'جيد'),
  acceptable('acceptable', 'مقبول'),
  weak('weak', 'ضعيف');

  const RecitationEvaluation(this.storageValue, this.arabicLabel);

  final String storageValue;
  final String arabicLabel;

  static RecitationEvaluation fromStorage(String value) {
    return switch (value) {
      'talqin' => RecitationEvaluation.talqin,
      'excellent' => RecitationEvaluation.excellent,
      'very_good' => RecitationEvaluation.veryGood,
      'good' => RecitationEvaluation.good,
      'acceptable' => RecitationEvaluation.acceptable,
      'weak' => RecitationEvaluation.weak,
      _ => throw StateError('Unsupported recitation evaluation: $value'),
    };
  }
}

final class RecitationWriteData {
  const RecitationWriteData({
    required this.type,
    required this.actualRange,
    required this.facesQuarterAchieved,
    required this.evaluation,
    this.errorCount = 0,
    this.note,
    this.plannedRange,
  });

  final RecitationType type;
  final QuranRange actualRange;
  final int facesQuarterAchieved;
  final RecitationEvaluation evaluation;
  final int errorCount;
  final String? note;
  final QuranRange? plannedRange;

  bool get isNewMemorization => type == RecitationType.newMemorization;

  bool get isRevision => type == RecitationType.revision;

  double get achievedFaces => facesQuarterAchieved / 4;
}

final class RecitationDerivedTotals {
  const RecitationDerivedTotals({
    required this.newMemorizationQuarterFaces,
    required this.revisionQuarterFaces,
  });

  final int newMemorizationQuarterFaces;
  final int revisionQuarterFaces;

  int get calculatedProgressQuarterFaces => newMemorizationQuarterFaces;

  int get totalRecordedQuarterFaces =>
      newMemorizationQuarterFaces + revisionQuarterFaces;

  double get calculatedProgressFaces => calculatedProgressQuarterFaces / 4;

  double get revisionFaces => revisionQuarterFaces / 4;

  double get totalRecordedFaces => totalRecordedQuarterFaces / 4;
}

final class RecitationRecord {
  const RecitationRecord({
    required this.id,
    required this.dayId,
    required this.studentId,
    required this.type,
    required this.actualRange,
    required this.facesQuarterAchieved,
    required this.evaluation,
    required this.errorCount,
    required this.note,
    required this.plannedRange,
  });

  final int id;
  final int dayId;
  final int studentId;
  final RecitationType type;
  final QuranRange actualRange;
  final int facesQuarterAchieved;
  final RecitationEvaluation evaluation;
  final int errorCount;
  final String? note;
  final QuranRange? plannedRange;

  bool get isNewMemorization => type == RecitationType.newMemorization;

  bool get isRevision => type == RecitationType.revision;

  double get achievedFaces => facesQuarterAchieved / 4;
}

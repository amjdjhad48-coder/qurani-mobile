import 'package:qurani/core/reference/quran_reference_data.dart';
import 'package:qurani/features/recitation/domain/recitation.dart';

enum RecitationValidationIssue {
  actualRange,
  plannedRange,
  facesQuarterAchieved,
  errorCount,
}

final class RecitationValidationException implements Exception {
  const RecitationValidationException({
    required this.issue,
    required this.message,
  });

  final RecitationValidationIssue issue;
  final String message;

  @override
  String toString() {
    return 'RecitationValidationException($issue): $message';
  }
}

final class RecitationValidator {
  const RecitationValidator();

  RecitationWriteData validateAndNormalize(RecitationWriteData data) {
    _validateRange(
      data.actualRange,
      issue: RecitationValidationIssue.actualRange,
    );

    final plannedRange = data.plannedRange;

    if (plannedRange != null) {
      _validateRange(
        plannedRange,
        issue: RecitationValidationIssue.plannedRange,
      );
    }

    if (data.facesQuarterAchieved <= 0) {
      throw const RecitationValidationException(
        issue: RecitationValidationIssue.facesQuarterAchieved,
        message: 'Achieved quarter-face units must be greater than zero.',
      );
    }

    if (data.errorCount < 0) {
      throw const RecitationValidationException(
        issue: RecitationValidationIssue.errorCount,
        message: 'Error count must not be negative.',
      );
    }

    final trimmedNote = data.note?.trim();
    final normalizedNote = trimmedNote == null || trimmedNote.isEmpty
        ? null
        : trimmedNote;

    return RecitationWriteData(
      type: data.type,
      actualRange: data.actualRange,
      facesQuarterAchieved: data.facesQuarterAchieved,
      evaluation: data.evaluation,
      errorCount: data.errorCount,
      note: normalizedNote,
      plannedRange: plannedRange,
    );
  }

  void _validateRange(
    QuranRange range, {
    required RecitationValidationIssue issue,
  }) {
    _validatePosition(range.start, issue: issue, positionName: 'start');

    _validatePosition(range.end, issue: issue, positionName: 'end');

    if (QuranReferenceData.comparePositions(range.start, range.end) > 0) {
      throw RecitationValidationException(
        issue: issue,
        message: 'Quran range start must not be after its end.',
      );
    }
  }

  void _validatePosition(
    QuranPosition position, {
    required RecitationValidationIssue issue,
    required String positionName,
  }) {
    if (position.surahNumber < 1 ||
        position.surahNumber > QuranReferenceData.surahCount) {
      throw RecitationValidationException(
        issue: issue,
        message: '$positionName surah number is outside 1..114.',
      );
    }

    final surah = QuranReferenceData.surahByNumber(position.surahNumber);

    if (position.ayahNumber < 1 || position.ayahNumber > surah.ayahCount) {
      throw RecitationValidationException(
        issue: issue,
        message:
            '$positionName ayah ${position.ayahNumber} is outside '
            'surah ${position.surahNumber}.',
      );
    }
  }
}

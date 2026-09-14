import 'package:qurani/features/recitation/domain/recitation.dart';

abstract interface class RecitationRepository {
  Future<RecitationRecord> create({
    required int dayId,
    required int studentId,
    required RecitationWriteData data,
  });

  Future<RecitationRecord> update({
    required int recitationId,
    required RecitationWriteData data,
  });

  Future<void> deleteById(int recitationId);

  Future<RecitationRecord?> findById(int recitationId);

  Future<List<RecitationRecord>> listForDayStudent({
    required int dayId,
    required int studentId,
  });

  Future<RecitationDerivedTotals> totalsForStudent({
    required int halaqahId,
    required int studentId,
  });

  Future<RecitationDerivedTotals> totalsForDayStudent({
    required int dayId,
    required int studentId,
  });
}

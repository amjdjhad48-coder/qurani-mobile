import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/students/domain/phone_number_policy.dart';
import 'package:qurani/features/students/domain/student.dart';
import 'package:qurani/features/students/domain/student_repository.dart';

final class StudentService {
  const StudentService({
    required StudentRepository repository,
    required PhoneNumberPolicy phoneNumberPolicy,
    required Clock clock,
  }) : this._(repository, phoneNumberPolicy, clock);

  const StudentService._(
    this._repository,
    this._phoneNumberPolicy,
    this._clock,
  );

  final StudentRepository _repository;
  final PhoneNumberPolicy _phoneNumberPolicy;
  final Clock _clock;

  Future<StudentRecord> create(CreateStudentRequest request) async {
    final studentName = _requiredText(request.studentName, 'studentName');
    final fatherName = _requiredText(request.fatherName, 'fatherName');
    final previousMemorizationText = _requiredText(
      request.previousMemorizationText,
      'previousMemorizationText',
    );

    final phone = _phoneNumberPolicy.normalize(
      country: request.guardianCountry,
      input: request.guardianPhoneInput,
    );

    final supportStudentNumber = _optionalText(request.supportStudentNumber);

    final supportStatus = await _repository.supportStatusForHalaqah(
      request.halaqahId,
    );

    _validateSupportStudentNumber(
      isActive: true,
      supportStatus: supportStatus,
      supportStudentNumber: supportStudentNumber,
    );

    return _repository.create(
      halaqahId: request.halaqahId,
      activeFromDate: _localDateText(_clock.todayLocal()),
      data: StudentWriteData(
        studentName: studentName,
        fatherName: fatherName,
        ageYears: request.ageYears,
        guardianCountryCode: phone.countryCode,
        guardianNationalNumber: phone.nationalNumber,
        previousMemorizationText: previousMemorizationText,
        note: _optionalText(request.note),
        supportStudentNumber: supportStudentNumber,
      ),
    );
  }

  Future<StudentRecord> edit(EditStudentRequest request) async {
    final existing = await _repository.findById(request.studentId);

    if (existing == null) {
      throw StateError('Student ${request.studentId} was not found.');
    }

    final studentName = _requiredText(request.studentName, 'studentName');
    final fatherName = _requiredText(request.fatherName, 'fatherName');
    final previousMemorizationText = _requiredText(
      request.previousMemorizationText,
      'previousMemorizationText',
    );

    final phone = _phoneNumberPolicy.normalize(
      country: request.guardianCountry,
      input: request.guardianPhoneInput,
    );

    final supportStudentNumber = _optionalText(request.supportStudentNumber);

    final supportStatus = await _repository.supportStatusForHalaqah(
      existing.halaqahId,
    );

    _validateSupportStudentNumber(
      isActive: existing.isActive,
      supportStatus: supportStatus,
      supportStudentNumber: supportStudentNumber,
    );

    return _repository.update(
      studentId: request.studentId,
      data: StudentWriteData(
        studentName: studentName,
        fatherName: fatherName,
        ageYears: request.ageYears,
        guardianCountryCode: phone.countryCode,
        guardianNationalNumber: phone.nationalNumber,
        previousMemorizationText: previousMemorizationText,
        note: _optionalText(request.note),
        supportStudentNumber: supportStudentNumber,
      ),
    );
  }

  Future<StudentProgressPlanRecord?> getProgressPlan(int studentId) async {
    final student = await _repository.findById(studentId);

    if (student == null) {
      throw StateError('Student $studentId was not found.');
    }

    return _repository.progressPlanForStudent(studentId);
  }

  Future<StudentProgressPlanRecord> updateProgressPlan(
    UpdateStudentProgressPlanRequest request,
  ) async {
    final student = await _repository.findById(request.studentId);

    if (student == null) {
      throw StateError('Student ${request.studentId} was not found.');
    }

    final currentJuz = request.currentJuz;

    if (currentJuz != null && (currentJuz < 1 || currentJuz > 30)) {
      throw ArgumentError.value(
        currentJuz,
        'currentJuz',
        'Current juz must be between 1 and 30.',
      );
    }

    final dailyPlanText = _optionalText(request.dailyPlanText);

    return _repository.saveProgressPlan(
      studentId: request.studentId,
      currentJuz: currentJuz,
      dailyPlanText: dailyPlanText,
    );
  }

  Future<String> supportStatusForHalaqah(int halaqahId) {
    return _repository.supportStatusForHalaqah(halaqahId);
  }

  Future<List<StudentRecord>> search({
    required int halaqahId,
    String query = '',
    bool includeArchived = false,
  }) {
    return _repository.search(
      halaqahId: halaqahId,
      query: query.trim(),
      includeArchived: includeArchived,
    );
  }

  Future<List<StudentRecord>> searchArchived({
    required int halaqahId,
    String query = '',
  }) async {
    final students = await _repository.search(
      halaqahId: halaqahId,
      query: query.trim(),
      includeArchived: true,
    );

    return students
        .where((student) => !student.isActive)
        .toList(growable: false);
  }

  Future<List<StudentActivityPeriodRecord>> activityPeriodsForStudent(
    int studentId,
  ) {
    return _repository.activityPeriodsForStudent(studentId);
  }

  Future<List<StudentRecord>> reorderActiveStudents({
    required int halaqahId,
    required List<int> orderedStudentIds,
  }) {
    return _repository.reorderActiveStudents(
      halaqahId: halaqahId,
      orderedStudentIds: List<int>.unmodifiable(orderedStudentIds),
    );
  }

  Future<StudentRecord> archive(int studentId) async {
    final student = await _repository.findById(studentId);

    if (student == null) {
      throw StateError('Student $studentId was not found.');
    }

    if (!student.isActive) {
      throw StateError('Student $studentId is already archived.');
    }

    final periods = await _repository.activityPeriodsForStudent(studentId);

    final openPeriods = periods
        .where((period) => period.isOpen)
        .toList(growable: false);

    if (openPeriods.length != 1) {
      throw StateError(
        'Active student must have exactly one open activity period.',
      );
    }

    final today = _localDateText(_clock.todayLocal());
    final openPeriod = openPeriods.single;

    if (today.compareTo(openPeriod.activeFromDate) < 0) {
      throw StateError(
        'Student cannot be archived before the activity period start.',
      );
    }

    return _repository.archive(
      studentId: studentId,
      openActivityPeriodId: openPeriod.id,
      activeToDate: today,
      archivedAtUtc: _clock.nowUtc(),
    );
  }

  Future<StudentRecord> reactivate(int studentId) async {
    final student = await _repository.findById(studentId);

    if (student == null) {
      throw StateError('Student $studentId was not found.');
    }

    if (student.isActive) {
      throw StateError('Student $studentId is already active.');
    }

    final supportStatus = await _repository.supportStatusForHalaqah(
      student.halaqahId,
    );

    _validateSupportStudentNumber(
      isActive: true,
      supportStatus: supportStatus,
      supportStudentNumber: student.supportStudentNumber,
    );

    final periods = await _repository.activityPeriodsForStudent(studentId);

    if (periods.isEmpty) {
      throw StateError('Archived student has no activity period history.');
    }

    final openPeriods = periods
        .where((period) => period.isOpen)
        .toList(growable: false);

    if (openPeriods.isNotEmpty) {
      throw StateError(
        'Archived student must not have an open activity period.',
      );
    }

    final latest = periods.last;
    final latestEnd = latest.activeToDate;

    if (latestEnd == null) {
      throw StateError('Archived student activity history is inconsistent.');
    }

    final today = _localDateText(_clock.todayLocal());

    if (latestEnd.compareTo(today) > 0) {
      throw StateError(
        'Student cannot be reactivated before the latest activity period end.',
      );
    }

    final reopenSameDay = latestEnd == today;

    return _repository.reactivate(
      studentId: studentId,
      activeFromDate: today,
      periodIdToReopen: reopenSameDay ? latest.id : null,
    );
  }

  void _validateSupportStudentNumber({
    required bool isActive,
    required String supportStatus,
    required String? supportStudentNumber,
  }) {
    if (isActive &&
        supportStatus == 'enabled' &&
        supportStudentNumber == null) {
      throw ArgumentError(
        'Active student requires support student number '
        'while support is enabled.',
      );
    }
  }

  String _requiredText(String value, String fieldName) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(value, fieldName, 'Must not be empty.');
    }

    return normalized;
  }

  String? _optionalText(String? value) {
    if (value == null) {
      return null;
    }

    final normalized = value.trim();

    return normalized.isEmpty ? null : normalized;
  }

  String _localDateText(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/core/shared/core_providers.dart';
import 'package:qurani/features/setup/application/runtime_lock_service.dart';
import 'package:qurani/features/setup/application/setup_providers.dart';
import 'package:qurani/features/setup/data/drift_runtime_database_opener.dart';
import 'package:qurani/features/students/application/student_service.dart';
import 'package:qurani/features/students/application/support_program_service.dart';
import 'package:qurani/features/students/data/drift_student_repository.dart';
import 'package:qurani/features/students/data/drift_support_program_repository.dart';
import 'package:qurani/features/students/domain/phone_number_policy.dart';

final class StudentRuntimeContext {
  const StudentRuntimeContext({
    required this.halaqahId,
    required this.service,
    this.supportProgramService,
  });

  final int halaqahId;
  final StudentService service;
  final SupportProgramService? supportProgramService;
}

final studentRuntimeContextProvider =
    FutureProvider.autoDispose<StudentRuntimeContext>((ref) async {
      final coordinator = await ref.watch(
        runtimeLockCoordinatorProvider.future,
      );

      if (coordinator is! RuntimeDatabaseSessionAccess) {
        throw StateError(
          'Runtime lock coordinator does not expose the open database session.',
        );
      }

      final sessionAccess = coordinator as RuntimeDatabaseSessionAccess;
      final handle = sessionAccess.requireOpenDatabaseHandle();

      if (handle is! DriftRuntimeDatabaseHandle) {
        throw StateError(
          'Runtime database handle is not the production Drift handle.',
        );
      }

      final database = handle.database;

      final halaqahs = await database.select(database.halaqahs).get();

      if (halaqahs.length != 1) {
        throw StateError(
          'Qurani v1 requires exactly one configured halaqah at runtime.',
        );
      }

      final clock = ref.watch(clockProvider);

      return StudentRuntimeContext(
        halaqahId: halaqahs.single.id,
        service: StudentService(
          repository: DriftStudentRepository(database),
          phoneNumberPolicy: const PhoneNumberPolicy(),
          clock: clock,
        ),
        supportProgramService: SupportProgramService(
          DriftSupportProgramRepository(database),
          clock,
        ),
      );
    });

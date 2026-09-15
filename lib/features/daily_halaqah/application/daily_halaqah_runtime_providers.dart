import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/core/shared/core_providers.dart';
import 'package:qurani/features/daily_halaqah/application/close_halaqah_day_core.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_read_service.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_service.dart';
import 'package:qurani/features/daily_halaqah/application/halaqah_holiday_service.dart';
import 'package:qurani/features/daily_halaqah/data/drift_daily_halaqah_repository.dart';
import 'package:qurani/features/parent_follow_up/application/end_day_and_prepare_parent_follow_ups.dart';
import 'package:qurani/features/parent_follow_up/application/parent_follow_up_dispatch_service.dart';
import 'package:qurani/features/parent_follow_up/application/parent_follow_up_recipient_policy.dart';
import 'package:qurani/features/parent_follow_up/application/parent_follow_up_service.dart';
import 'package:qurani/features/parent_follow_up/data/android_parent_follow_up_external_gateway.dart';
import 'package:qurani/features/parent_follow_up/data/drift_parent_follow_up_repository.dart';
import 'package:qurani/features/recitation/application/recitation_service.dart';
import 'package:qurani/features/recitation/data/drift_recitation_repository.dart';
import 'package:qurani/features/setup/application/runtime_lock_service.dart';
import 'package:qurani/features/setup/application/setup_providers.dart';
import 'package:qurani/features/setup/data/drift_runtime_database_opener.dart';
import 'package:qurani/features/students/application/student_service.dart';
import 'package:qurani/features/students/data/drift_student_repository.dart';
import 'package:qurani/features/students/domain/phone_number_policy.dart';

final class DailyHalaqahRuntimeContext {
  const DailyHalaqahRuntimeContext({
    required this.halaqahId,
    required this.halaqahName,
    required this.teacherName,
    required this.clock,
    required this.service,
    required this.readService,
    required this.holidayService,
    required this.closeDayCore,
    this.recitationService,
    this.endDayAndPrepareParentFollowUps,
    this.parentFollowUpService,
    this.parentFollowUpDispatchService,
    this.studentService,
  });

  final int halaqahId;
  final String halaqahName;
  final String teacherName;
  final Clock clock;
  final DailyHalaqahService service;
  final DailyHalaqahReadService readService;
  final HalaqahHolidayService holidayService;

  // Retained as a compatibility fallback for older P4/P5 test fixtures.
  // Production supplies the Package 6 atomic end-day service below.
  final CloseHalaqahDayCore closeDayCore;

  // Nullable only to preserve existing P4/P5 test fixtures.
  // Production always supplies this service.
  final RecitationService? recitationService;

  // Nullable only to preserve pre-P6 manually-constructed test fixtures.
  // Production always supplies these Package 6 services.
  final EndDayAndPrepareParentFollowUps? endDayAndPrepareParentFollowUps;
  final ParentFollowUpService? parentFollowUpService;
  final ParentFollowUpDispatchService? parentFollowUpDispatchService;

  // Nullable only for old manually-constructed Daily fixtures.
  // Production supplies the existing StudentService so an invalid
  // guardian phone can be fixed through StudentFormScreen.
  final StudentService? studentService;
}

final dailyHalaqahRuntimeContextProvider =
    FutureProvider.autoDispose<DailyHalaqahRuntimeContext>((ref) async {
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

      final halaqah = halaqahs.single;
      final repository = DriftDailyHalaqahRepository(database);
      final parentFollowUpRepository = DriftParentFollowUpRepository(database);
      final clock = ref.watch(clockProvider);

      final recitationService = RecitationService(
        repository: DriftRecitationRepository(database),
        dailyHalaqahRepository: repository,
        clock: clock,
      );

      final parentFollowUpService = ParentFollowUpService(
        repository: parentFollowUpRepository,
      );

      final studentService = StudentService(
        repository: DriftStudentRepository(database),
        phoneNumberPolicy: const PhoneNumberPolicy(),
        clock: clock,
      );

      final parentFollowUpDispatchService = ParentFollowUpDispatchService(
        parentFollowUpService: parentFollowUpService,
        recipientPolicy: const ParentFollowUpRecipientPolicy(),
        externalGateway: AndroidParentFollowUpExternalGateway(),
      );

      return DailyHalaqahRuntimeContext(
        halaqahId: halaqah.id,
        halaqahName: halaqah.halaqahName,
        teacherName: halaqah.teacherName,
        clock: clock,
        service: DailyHalaqahService(repository: repository, clock: clock),
        readService: DailyHalaqahReadService(repository),
        holidayService: HalaqahHolidayService(repository),
        closeDayCore: CloseHalaqahDayCore(repository),
        recitationService: recitationService,
        endDayAndPrepareParentFollowUps: EndDayAndPrepareParentFollowUps(
          repository: parentFollowUpRepository,
        ),
        parentFollowUpService: parentFollowUpService,
        parentFollowUpDispatchService: parentFollowUpDispatchService,
        studentService: studentService,
      );
    });

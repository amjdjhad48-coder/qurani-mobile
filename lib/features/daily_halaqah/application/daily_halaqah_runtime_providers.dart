import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/core/shared/core_providers.dart';
import 'package:qurani/features/daily_halaqah/application/close_halaqah_day_core.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_read_service.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_service.dart';
import 'package:qurani/features/daily_halaqah/application/halaqah_holiday_service.dart';
import 'package:qurani/features/daily_halaqah/data/drift_daily_halaqah_repository.dart';
import 'package:qurani/features/recitation/application/recitation_service.dart';
import 'package:qurani/features/recitation/data/drift_recitation_repository.dart';
import 'package:qurani/features/setup/application/runtime_lock_service.dart';
import 'package:qurani/features/setup/application/setup_providers.dart';
import 'package:qurani/features/setup/data/drift_runtime_database_opener.dart';

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
  });

  final int halaqahId;
  final String halaqahName;
  final String teacherName;
  final Clock clock;
  final DailyHalaqahService service;
  final DailyHalaqahReadService readService;
  final HalaqahHolidayService holidayService;
  final CloseHalaqahDayCore closeDayCore;

  // Nullable only to preserve existing P4 test fixtures during the P5 UI
  // transition. The production provider below always supplies this service.
  final RecitationService? recitationService;
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
      final clock = ref.watch(clockProvider);

      final recitationService = RecitationService(
        repository: DriftRecitationRepository(database),
        dailyHalaqahRepository: repository,
        clock: clock,
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
      );
    });

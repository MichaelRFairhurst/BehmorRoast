import 'package:behmor_roast/src/behmor/constants.dart';
import 'package:behmor_roast/src/roast/models/roast_config.dart';
import 'package:behmor_roast/src/roast/models/roast_log.dart';
import 'package:behmor_roast/src/roast/services/roast_profile_service.dart';
import 'package:behmor_roast/src/timer/models/projection.dart';
import 'package:behmor_roast/src/timer/models/roast_timeline.dart';
import 'package:collection/collection.dart';

class ProjectionService {
  Projection createProjections({
    required RoastConfig roastConfig,
    required List<RoastLog> roastLogs,
    required Duration? elapsed,
    RoastTimeline? copyOfRoast,
  }) {
    double? currentTemp;
    double? copyRoastTempDiff;
    double? temp30s;
    double? temp60s;
    Duration? roastTime;
    Duration? timeRemaining;
    Duration? timeToOverheat;
    final tempLogs = roastLogs
        .where((log) => log.temp != null && log.phase == null)
        .toList();
    final phaseLogs = roastLogs.where((log) => log.phase != null).toList();

    if (elapsed != null && tempLogs.isNotEmpty) {
      final temp = tempLogs.last.temp!;
      final ror = tempLogs.last.rateOfRise!;
      final lastTime = tempLogs.last.time;
      final since = elapsed - lastTime;
      final sinceMinutes = since.inMilliseconds / 1000.0 / 60.0;

      currentTemp = temp + sinceMinutes * ror;
      temp30s = currentTemp + ror / 2;
      temp60s = currentTemp + ror;

      final overheatMinutes = (overheatTemp - currentTemp) / ror;
      if (ror > 0 && overheatMinutes < 3.0 && overheatMinutes > 0) {
        timeToOverheat = Duration(seconds: (overheatMinutes * 60).round());
      }
    }

    if (elapsed != null && phaseLogs.isNotEmpty) {
      final firstCrackStart = phaseLogs
          .firstWhereOrNull((log) => log.phase == RoastPhase.firstCrackStart);
      if (firstCrackStart != null) {
        final inverseRatio = 1.0 / (1.0 - roastConfig.targetDevelopment);
        roastTime = firstCrackStart.time * inverseRatio;
        timeRemaining = roastTime - elapsed;
      }
    }

    if (elapsed != null && currentTemp != null && copyOfRoast != null) {
      final tempIterator =
          RoastProfileService().iterateProfile(copyOfRoast.rawLogs);
      final copyTemp = tempIterator.getTemp(elapsed);
      if (copyTemp != null) {
        copyRoastTempDiff = currentTemp - copyTemp;
      }
    }

    return Projection(
      roastTime: roastTime,
      timeRemaining: timeRemaining,
      timeToOverheat: timeToOverheat,
      currentTemp: currentTemp,
      copyRoastTempDiff: copyRoastTempDiff,
      temp30s: temp30s,
      temp60s: temp60s,
    );
  }
}

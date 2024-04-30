import 'package:behmor_roast/src/roast/models/control_log.dart';
import 'package:behmor_roast/src/roast/models/roast_log.dart';
import 'package:behmor_roast/src/roast/models/temp_log.dart';
import 'package:behmor_roast/src/roast/services/roast_profile_service.dart';
import 'package:behmor_roast/src/timer/models/roast_timeline.dart';

class RoastLogService {
  List<RoastLog> aggregate(RoastTimeline timeline, {RoastTimeline? copy}) {
    final result = <RoastLog>[];

    TempLog? previousTemp;

    final logs = timeline.rawLogs;
    final copyTempIterator = copy == null
        ? null
        : RoastProfileService().iterateProfile(copy.rawLogs);

    for (final log in logs) {
      if (log is TempLog) {
        if (previousTemp == null) {
          result.add(RoastLog(
              time: log.time,
              temp: log.temp,
              tempDiff: copyTempIterator?.getTempDiff(log)));
        } else {
          final duration = log.time - previousTemp.time;
          final rise = log.temp - previousTemp.temp;
          result.add(RoastLog(
            time: log.time,
            temp: log.temp,
            rateOfRise: rise / (duration.inMilliseconds / 1000.0 / 60.0),
            tempDiff: copyTempIterator?.getTempDiff(log),
          ));
        }
        previousTemp = log;
      }

      if (log is ControlLog) {
        result.add(RoastLog(
            time: log.time,
            control: log.control,
            timeDiff: log.instructionTimeDiff));
      }
    }

    if (timeline.preheatStart != null && timeline.preheatEnd != null) {
      final preheatGap = timeline.preheatGap;
      if (preheatGap == null) {
        result.add(RoastLog(
            time: timeline.preheatEnd!,
            temp: timeline.preheatTemp,
            phase: RoastPhase.preheat));
      } else {
        result.add(RoastLog(
            time: preheatGap * -1,
            temp: timeline.preheatTemp,
            phase: RoastPhase.preheat));
      }
    }

    if (timeline.dryEnd != null) {
      result.add(RoastLog(
        time: timeline.dryEnd!,
        phase: RoastPhase.dryEnd,
        timeDiff: copy == null ? null : copy.dryEnd! - timeline.dryEnd!,
      ));
    }

    if (timeline.firstCrackStart != null) {
      result.add(RoastLog(
        time: timeline.firstCrackStart!,
        phase: RoastPhase.firstCrackStart,
        timeDiff: copy == null
            ? null
            : copy.firstCrackStart! - timeline.firstCrackStart!,
      ));
    }

    if (timeline.firstCrackEnd != null) {
      result.add(RoastLog(
        time: timeline.firstCrackEnd!,
        phase: RoastPhase.firstCrackEnd,
        timeDiff:
            copy == null ? null : copy.firstCrackEnd! - timeline.firstCrackEnd!,
      ));
    }

    if (timeline.secondCrackStart != null) {
      result.add(RoastLog(
        time: timeline.secondCrackStart!,
        phase: RoastPhase.secondCrackStart,
        timeDiff: copy == null
            ? null
            : copy.secondCrackStart! - timeline.secondCrackStart!,
      ));
    }

    if (timeline.done != null) {
      result.add(RoastLog(
        time: timeline.done!,
        phase: RoastPhase.done,
        timeDiff: copy == null ? null : copy.done! - timeline.done!,
      ));
    }

    result.sort((a, b) => a.time.compareTo(b.time));

    return result;
  }
}

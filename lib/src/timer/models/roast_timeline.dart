import 'package:behmor_roast/src/roast/models/base_log.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'roast_timeline.freezed.dart';

enum RoastState {
  waiting,
  preheating,
  preheatDone,
  roasting,
  done,
}

@freezed
class RoastTimeline with _$RoastTimeline {
  const RoastTimeline._();

  const factory RoastTimeline({
    required List<BaseLog> rawLogs,
    DateTime? preheatStart,
    Duration? preheatEnd,
    DateTime? startTime,
    Duration? dryEnd,
    Duration? firstCrackStart,
    Duration? firstCrackEnd,
    Duration? secondCrackStart,
    Duration? done,
  }) = _RoastTimeline;

  RoastTimeline addLog(BaseLog log) => copyWith(
        rawLogs: rawLogs.toList()..add(log),
      );

  RoastState get roastState {
    if (done != null) {
      return RoastState.done;
    }

    if (startTime != null) {
      return RoastState.roasting;
    }

    if (preheatEnd != null) {
      return RoastState.preheatDone;
    }

    if (preheatStart != null) {
      return RoastState.preheating;
    }

    return RoastState.waiting;
  }
}
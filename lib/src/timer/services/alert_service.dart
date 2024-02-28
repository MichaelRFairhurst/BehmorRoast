import 'package:behmor_roast/src/roast/models/roast_log.dart';
import 'package:behmor_roast/src/timer/models/alert.dart';
import 'package:behmor_roast/src/timer/models/projection.dart';

const _smokeSuppressorTime = Duration(seconds: 7 * 60 + 45);
// Technically, this is 75% of roast time. This is correct for 1lb P5 roasts.
const _pressStartTime = Duration(seconds: 13 * 60 + 30);

class AlertService {
  List<Alert> getAlerts({
    required List<RoastLog> roastLogs,
	required Projection projections,
    required Duration elapsed,
  }) {
	final results = <Alert>[];
	final timeToOverheat = projections.timeToOverheat;

	if (timeToOverheat != null) {
	  final severity = timeToOverheat < const Duration(seconds: 60)
		  ? Severity.warning
		  : Severity.alert;
	  results.add(Alert(
		kind: AlertKind.willOverheat,
		severity: severity,
		message: 'Roaster projected to overheat in'
		  ' ${timeToOverheat.inSeconds} seconds',
	  ));
	}

    final timePastPressStart = elapsed - _pressStartTime;
	if (!timePastPressStart.isNegative
		&& timePastPressStart < const Duration(seconds: 30)) {
	  results.add(const Alert(
	    kind: AlertKind.smokeSuppressor,
		severity: Severity.warning,
		message: 'Press START, or the roaster will automatically off!',
	  ));
	}

	final timeToSmoke = _smokeSuppressorTime - elapsed;
    if (timeToSmoke < const Duration(seconds: 45) && !timeToSmoke.isNegative) {
	  results.add(Alert(
	    kind: AlertKind.smokeSuppressor,
		severity: Severity.alert,
		message: 'Smoke suppressor turns on in ${timeToSmoke.inSeconds}'
		    ' seconds, and roast temps will quickly fall.',
	  ));
	}

    return results;
  }
}

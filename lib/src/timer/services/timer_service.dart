import 'dart:async';

import 'package:flutter_beep/flutter_beep.dart';

class TimerService {
  DateTime? _startTime;
  DateTime? _stopTime;
  final _running = StreamController<bool>()..add(false);
  final _checkTemp = StreamController<Duration>.broadcast();
  final _seconds = StreamController<Duration>.broadcast();

  void start() {
    _startTime = DateTime.now();
    _running.add(true);
	_fireSeconds();
  }

  void _fireSeconds() async {
    while (_stopTime == null) {
	  final now = elapsed()!;
      _seconds.add(now);

      if (now.inSeconds % 15 == 0) {
		FlutterBeep.beep();
		_checkTemp.add(now);
	  }

      final millisToNext = 1000 - (now.inMilliseconds % 1000);
      await Future.delayed(Duration(milliseconds: millisToNext));
    }
  }

  void stop() {
    _stopTime = DateTime.now();
    _running.add(false);
  }

  Duration? elapsed() {
    if (_startTime == null) {
      return null;
    }

    if (_stopTime != null) {
      return _stopTime!.difference(_startTime!);
    }

    return DateTime.now().difference(_startTime!);
  }

  Stream<bool> get running => _running.stream;
  Stream<Duration> get checkTemp => _checkTemp.stream;
  Stream<Duration> get seconds => _seconds.stream;
}

import 'dart:async';

import 'package:flutter_beep/flutter_beep.dart';

class TimerService {
  DateTime? _startTime;
  DateTime? _stopTime;
  int? _tempCheckInterval;
  final _checkTemp = StreamController<Duration>();
  final _seconds = StreamController<Duration?>();

  void start(int? tempCheckInterval) {
    _startTime = DateTime.now();
    _tempCheckInterval = tempCheckInterval;
    _fireSeconds();
  }

  void reset() {
    _startTime = null;
    _stopTime = null;
    _seconds.add(null);
  }

  void _fireSeconds() async {
    while (_stopTime == null) {
      final now = elapsed();

      if (now == null) {
        return;
      }

      if (_tempCheckInterval != null &&
          now.inSeconds % _tempCheckInterval! == 0) {
        FlutterBeep.beep();
        _checkTemp.add(now);
      }
      _seconds.add(now);

      final millisToNext = 1000 - (now.inMilliseconds % 1000);
      await Future.delayed(Duration(milliseconds: millisToNext));
    }
  }

  void stop() {
    _stopTime = DateTime.now();
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

  Stream<Duration> get checkTemp => _checkTemp.stream;
  Stream<Duration?> get seconds => _seconds.stream;
  DateTime? get startTime => _startTime;
}

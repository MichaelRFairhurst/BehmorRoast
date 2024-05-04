import 'package:behmor_roast/src/config/theme.dart';
import 'package:behmor_roast/src/roast/models/control_log.dart';
import 'package:behmor_roast/src/timer/models/roast_timeline.dart';
import 'package:behmor_roast/src/timer/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ControlButton extends ConsumerWidget {
  final Control control;
  final bool? disabled;
  final void Function()? onPressed;
  final Duration? instructionTimeDiff;

  const ControlButton({
    required this.control,
    this.disabled,
    this.onPressed,
    this.instructionTimeDiff,
    super.key,
  });

  bool isDisabled(WidgetRef ref) {
    if (disabled != null) {
      return disabled!;
    }

    final controls =
        ref.watch(roastTimelineProvider).rawLogs.whereType<ControlLog?>();
    final running = ref.watch(roastStateProvider) == RoastState.roasting;

    final pwrLevel = controls
        .cast<ControlLog?>()
        .lastWhere((c) => c?.control != Control.d, orElse: () => null)
        ?.control;

    return !running || pwrLevel == control;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        minimumSize: const Size(30, 30),
        padding: const EdgeInsets.all(0),
        disabledBackgroundColor: RoastAppTheme.lime.withOpacity(0.75),
      ),
      onPressed: isDisabled(ref)
          ? null
          : () {
              final tService = ref.read(roastTimerProvider);
              final now = tService.elapsed() ?? const Duration(seconds: 0);
              final newLog = ControlLog(
                time: now,
                control: control,
                instructionTimeDiff: instructionTimeDiff,
              );

              ref
                  .read(roastTimelineProvider.notifier)
                  .update((state) => state.addLog(newLog));

              if (onPressed != null) {
                onPressed!();
              }
            },
      child: Text(control.toString().replaceAll('Control.', '').toUpperCase()),
    );
  }
}

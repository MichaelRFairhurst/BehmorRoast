import 'package:behmor_roast/src/config/theme.dart';
import 'package:behmor_roast/src/timer/models/temp_log.dart';
import 'package:behmor_roast/src/timer/widgets/check_temp_widget.dart';
import 'package:behmor_roast/src/timer/widgets/controls_widget.dart';
import 'package:behmor_roast/src/timer/widgets/projections_widget.dart';
import 'package:behmor_roast/src/timer/widgets/temp_log_widget.dart';
import 'package:behmor_roast/src/timer/widgets/time_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:behmor_roast/src/timer/providers.dart';

class TimerPage extends ConsumerWidget {
  const TimerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tService = ref.watch(timerServiceProvider);
    final running = ref.watch(timerRunningProvider).value ?? false;
    final showTempInput = ref.watch(showTempInputProvider);
    final logs = ref.watch(roastLogsProvider);

    Widget? fab;
	if (!running && tService.elapsed() == null) {
      fab = FloatingActionButton(
        child: const Icon(Icons.play_circle),
        onPressed: () {
          tService.start();
        },
      );
	} else if (!running) {
      fab = ElevatedButton.icon(
        icon: const Icon(Icons.save),
        label: const Text('Save'),
        onPressed: () {
        },
      );
	}

    return Scaffold(
      appBar: AppBar(
        title: const Text("Roast Controls"),
      ),
      body: Column(
	    crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
		    decoration: const BoxDecoration(
			  color: RoastAppTheme.metalLight,
			  //border: Border(bottom: BorderSide(color: RoastAppTheme.capuccino, width: 1.0)),
			  boxShadow: [BoxShadow(
			    color: RoastAppTheme.capuccino,
				offset: Offset(0, 0),
				blurRadius: 2.0,
			  )],
			),
			padding: const EdgeInsets.only(bottom: 4.0),
			margin: const EdgeInsets.only(bottom: 4.0),
		    child: const ControlsWidget(),
		  ),
          const Expanded(
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: [
                SliverToBoxAdapter(
	              child: TempLogWidget(),
                ),
	            SliverToBoxAdapter(
	              child: ProjectionsWidget(),
	            ),
              ],
            ),
          ),
          if (showTempInput)
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16.0),
		      decoration: const BoxDecoration(
			    color: RoastAppTheme.metalLight,
			    //border: Border(top: BorderSide(color: RoastAppTheme.capuccinoLight, width: 1.0)),
			    boxShadow: [BoxShadow(
			      color: RoastAppTheme.capuccino,
			      offset: Offset(0, 0),
			      blurRadius: 2.0,
			    )],
			  ),
              child: CheckTempWidget(
                label: logs.isEmpty ? 'Enter starting temperature:' : 'Enter current temperature',
                onSubmit: (val) {
                  ref.read(temperatureLogsProvider.notifier)
                    .update((logs) => logs.toList()..add(TempLog(
                       temp: val, time: tService.elapsed()!)
                  ));
                  ref.read(showTempInputProvider.notifier).state = false;
                },
              ),
            ),
        ],
      ),
      floatingActionButton: fab,
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: TimeWidget(timerService: tService),
        ),
      ),
    );
  }
}

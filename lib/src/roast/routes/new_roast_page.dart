import 'package:behmor_roast/src/config/routes.dart';
import 'package:behmor_roast/src/config/theme.dart';
import 'package:behmor_roast/src/roast/models/bean.dart';
import 'package:behmor_roast/src/roast/models/roast.dart';
import 'package:behmor_roast/src/roast/models/roast_config.dart';
import 'package:behmor_roast/src/roast/providers.dart';
import 'package:behmor_roast/src/roast/widgets/bean_select.dart';
import 'package:behmor_roast/src/roast/widgets/temp_interval_select.dart';
import 'package:behmor_roast/src/timer/models/roast_timeline.dart';
import 'package:behmor_roast/src/timer/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NewRoastPage extends ConsumerStatefulWidget {
  const NewRoastPage({Key? key}) : super(key: key);

  @override
  NewRoastPageState createState() => NewRoastPageState();
}

class NewRoastPageState extends ConsumerState<NewRoastPage> {
  final number = TextEditingController(text: '1');
  final weight = TextEditingController(text: '300');
  final devel = TextEditingController(text: '20');
  final roastFormKey = GlobalKey<FormState>();
  int tempInterval = 30;

  Bean? selectedBean;
  bool beanErr = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Start a New Roast"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: roastFormKey,
          child: CustomScrollView(
            slivers: [
              const SliverPadding(padding: EdgeInsets.only(top: 16.0)),
              if (beanErr)
                SliverToBoxAdapter(
                  child: Text(
                    'Select a bean:',
                    style:
                        RoastAppTheme.materialTheme.textTheme.caption!.copyWith(
                      color: RoastAppTheme.materialTheme.errorColor,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: BeanSelect(
                  selectedBean: selectedBean,
                  onChanged: (bean) {
                    setState(() {
                      selectedBean = bean;
                    });
                  },
                ),
              ),
              /*const SliverPadding(padding: EdgeInsets.only(top: 10)),
              const SliverToBoxAdapter(
                child: Text('Roast number'),
              ),
              SliverToBoxAdapter(
                child: TextFormField(
                    controller: number,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (int.tryParse(value ?? '') == null) {
                        return 'Enter a valid roast number';
                      }

                      return null;
                    }),
              ),*/
              const SliverPadding(padding: EdgeInsets.only(top: 10)),
              const SliverToBoxAdapter(
                child: Text('Weight (g)'),
              ),
              SliverToBoxAdapter(
                child: TextFormField(
                    controller: weight,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      suffixText: 'g',
                    ),
                    validator: (value) {
                      if (double.tryParse(value ?? '') == null) {
                        return 'Enter a valid weight';
                      }

                      return null;
                    }),
              ),
              const SliverPadding(padding: EdgeInsets.only(top: 10)),
              const SliverToBoxAdapter(
                child: Text('Target Development (%)'),
              ),
              SliverToBoxAdapter(
                child: TextFormField(
                    controller: devel,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      suffixText: '%',
                    ),
                    validator: (value) {
                      if (double.tryParse(value ?? '') == null) {
                        return 'Enter a valid development percentage';
                      }

                      return null;
                    }),
              ),
              const SliverPadding(padding: EdgeInsets.only(top: 10)),
              SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Check roaster temperature:'),
                    TempIntervalSelect(
                      value: tempInterval,
                      onChanged: (val) {
                        setState(() {
                          tempInterval = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      label: const Icon(Icons.navigate_next),
                      icon: const Text('Begin roast'),
                      onPressed: () {
                        final formValid = roastFormKey.currentState!.validate();
                        if (selectedBean == null) {
                          setState(() {
                            beanErr = true;
                          });
                        } else {
                          setState(() {
                            beanErr = false;
                          });
                        }

                        if (!beanErr && formValid) {
                          final roast = Roast(
                            beanId: selectedBean!.id!,
                            roasted: DateTime.now(), // Replaced later.
                            roastNumber: int.parse(number.text),
                            weightIn: double.parse(weight.text),
                            weightOut: double.parse(weight.text),
                            config: RoastConfig(
                              tempInterval: tempInterval,
                              targetDevelopment: double.parse(devel.text) / 100,
                            ),
                          );
                          ref.read(roastProvider.notifier).state = roast;
                          ref.read(roastTimelineProvider.notifier).state =
                              const RoastTimeline(rawLogs: []);
                          ref.read(roastTimerProvider).reset();
                          ref.read(preheatTimerProvider).reset();
                          context.replace(Routes.timer);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

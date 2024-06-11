import 'dart:async';

import 'package:behmor_roast/src/roast/models/bean.dart';
import 'package:behmor_roast/src/roast/providers.dart';
import 'package:behmor_roast/src/roast/services/bean_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:behmor_roast/src/roast/routes/overview_page.dart';

class FakeBeanService implements BeanService {
  final _beans = <Bean>[];
  final _ctrl = StreamController<List<Bean>>();

  FakeBeanService();

  void _load(List<Bean> beans) {
    _beans
      ..clear()
      ..addAll(beans);
    _ctrl.add(_beans);
  }

  @override
  Future<Bean> add(Bean bean) {
    _beans.add(bean);
    _ctrl.add(_beans);
    return Future.value(bean);
  }

  @override
  Stream<List<Bean>> get beans => _ctrl.stream;

  @override
  Future<void> update(Bean bean) {
    throw UnimplementedError();
  }

  @override
  Continent continentOf(Bean bean) => Continent.africa;
}

const beginYourFirstRoast = 'Begin your first roast';
const yourCoffee = 'Your Coffee:';

void main() {
  testWidgets('Loads with no roasts yet screen', (WidgetTester tester) async {
    final beanService = FakeBeanService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          beanServiceProvider.overrideWithValue(beanService),
        ],
        child: const MaterialApp(
          home: OverviewPage(),
        ),
      ),
    );

    beanService._load([]);
    await tester.pump();

    expect(find.text(beginYourFirstRoast), findsOneWidget);
    expect(find.text(yourCoffee), findsNothing);
    expect(
        tester
            .state<ScaffoldState>(find.byType(Scaffold))
            .hasFloatingActionButton,
        false);
  });

  testWidgets('Loads with some roasts', (WidgetTester tester) async {
    final beanService = FakeBeanService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          beanServiceProvider.overrideWithValue(beanService),
        ],
        child: const MaterialApp(
          home: OverviewPage(),
        ),
      ),
    );

    beanService._load(
      const [
        Bean(
          id: '1',
          ownerId: 'ownerId',
          name: 'bean 1',
        ),
        Bean(
          id: '2',
          ownerId: 'ownerId',
          name: 'My other bean',
        ),
      ],
    );

    await tester.pumpAndSettle();

    expect(find.text(beginYourFirstRoast), findsNothing);
    expect(find.text(yourCoffee), findsOneWidget);
    expect(find.text('bean 1'), findsOneWidget);
    expect(find.text('My other bean'), findsOneWidget);
    expect(
        tester
            .state<ScaffoldState>(find.byType(Scaffold))
            .hasFloatingActionButton,
        true);
    expect(find.textContaining('archived'), findsNothing);
  });

  testWidgets('Loads with archived roasts', (WidgetTester tester) async {
    final beanService = FakeBeanService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          beanServiceProvider.overrideWithValue(beanService),
        ],
        child: const MaterialApp(
          home: OverviewPage(),
        ),
      ),
    );

    beanService._load(
      const [
        Bean(
          id: '1',
          ownerId: 'ownerId',
          name: 'bean 1',
        ),
        Bean(
          id: '2',
          ownerId: 'ownerId',
          name: 'My other bean',
          archived: true,
        ),
      ],
    );

    await tester.pumpAndSettle();

    // Check 1 archived hidden bean
    expect(find.text(beginYourFirstRoast), findsNothing);
    expect(find.text(yourCoffee), findsOneWidget);
    expect(find.text('bean 1'), findsOneWidget);
    expect(find.textContaining('1 archived'), findsOneWidget);
    expect(find.text('My other bean'), findsNothing);

    // Add another archived bean
    beanService.add(const Bean(
        id: '3', ownerId: 'ownerId', name: 'new bean', archived: true));

    await tester.pumpAndSettle();

    // Check 2 archived hidden beans
    expect(find.textContaining('2 archived'), findsOneWidget);
    expect(find.text('My other bean'), findsNothing);
    expect(find.text('new bean'), findsNothing);

    // Hit expand
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    // Check all beans are now visible
    expect(find.text('bean 1'), findsOneWidget);
    expect(find.textContaining('Hide archived'), findsOneWidget);
    expect(find.text('My other bean'), findsOneWidget);

    // Hit collapse
    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pumpAndSettle();

    // Check 2 archived hidden beans
    expect(find.text('bean 1'), findsOneWidget);
    expect(find.textContaining('2 archived'), findsOneWidget);
    expect(find.text('My other bean'), findsNothing);
    expect(find.text('new bean'), findsNothing);
  });
}

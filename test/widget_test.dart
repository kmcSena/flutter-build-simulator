import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_build_simulator/main.dart';

void main() {
  testWidgets('starts with rabbit tank best match and can transform', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BuildSimulatorApp());
    expect(find.text('ベストマッチ！'), findsOneWidget);

    await tester.ensureVisible(find.text('変身！'));
    await tester.tap(find.text('変身！'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('ラビットタンクフォーム'), findsOneWidget);
    expect(find.text('ベストマッチ！'), findsOneWidget);
  });

  testWidgets('scratch driver reports unsupported and disables transform', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BuildSimulatorApp());
    await tester.tap(find.text('スクラッシュドライバー'));
    await tester.pumpAndSettle();

    expect(find.text('現在のフルボトル構成には対応していません'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('mismatched bottles show the trial form', (tester) async {
    tester.view.physicalSize = const Size(1280, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BuildSimulatorApp());
    expect(find.text('¥5,200'), findsOneWidget);
    await tester.ensureVisible(find.text('ダイヤモンド'));
    await tester.tap(find.text('ダイヤモンド'));
    await tester.pumpAndSettle();
    expect(find.text('トライアルフォーム'), findsNWidgets(2));
    expect(find.text('¥5,300'), findsOneWidget);

    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.text('ハザードオン！'), findsOneWidget);
    expect(find.text('¥7,100'), findsOneWidget);
  });

  testWidgets('hazard best match loads its hazard form image', (tester) async {
    tester.view.physicalSize = const Size(1280, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BuildSimulatorApp());
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('変身！'));
    await tester.tap(find.text('変身！'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('スーパーベストマッチ！'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/forms/rabbit_tank_hazard.png',
      ),
      findsOneWidget,
    );
  });

  testWidgets('layout fits a narrow phone viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BuildSimulatorApp());
    await tester.pumpAndSettle();

    expect(find.text('変身研究ラボ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

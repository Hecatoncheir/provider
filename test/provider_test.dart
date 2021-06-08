import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/dependencies.dart';
import 'package:provider/provider.dart';

class TestClass {
  String text;
  TestClass(this.text);
}

void main() {
  testWidgets('Provider', (tester) async {
    final testWidget = Provider(
      dependencies: [
        TestClass('provided widget text'),
      ],
      child: Builder(
        builder: (BuildContext context) {
          return Text(
            Provider.of<TestClass>(context, aspect: TestClass).text,
          );
        },
      ),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: testWidget),
    ));

    await tester.pump();

    expect(find.text('provided widget text'), findsOneWidget);
  });

  testWidgets('Provider update dependencies', (tester) async {
    final testWidget = Provider(
      dependencies: [
        TestClass('test text'),
      ],
      child: Builder(
        builder: (BuildContext context) {
          final testClass = Provider.of<TestClass>(context, aspect: TestClass);
          return Text(testClass.text);
        },
      ),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: testWidget),
    ));

    await tester.pump();

    expect(find.text('test text'), findsOneWidget);

    final ProviderState state = tester.state(find.byWidget(testWidget));

    state.updateDependenciesController.add([
      TestClass('provided widget text'),
    ]);

    await tester.pumpAndSettle();

    expect(find.text('test text'), findsNothing);
    expect(find.text('provided widget text'), findsOneWidget);
  });

  testWidgets('Provider update dependencies', (tester) async {
    final testWidget = Provider(
      dependencies: [
        TestClass('test text'),
      ],
      child: Builder(
        builder: (BuildContext context) {
          final text = Provider.of<TestClass>(context, aspect: TestClass).text;

          return GestureDetector(
            onTap: () {
              final dependency = TestClass('Updated dependency text');
              Provider.updateDependency<TestClass>(context, dependency);
            },
            child: Text(text),
          );
        },
      ),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: testWidget),
    ));

    await tester.pump();

    expect(find.text('test text'), findsOneWidget);

    await tester.tap(find.text('test text'));

    await tester.pumpAndSettle();

    expect(find.text('test text'), findsNothing);
    expect(find.text('Updated dependency text'), findsOneWidget);
  });

  testWidgets('Provider add dependencies', (tester) async {
    final testWidget = Provider(
      dependencies: const [],
      child: Builder(
        builder: (BuildContext context) {
          TestClass? testClass;

          try {
            testClass = Provider.of<TestClass>(context, aspect: TestClass);
          } on NoDependencyFound catch (_) {}

          String text = 'test text';
          if (testClass != null) text = testClass.text;

          return Text(text);
        },
      ),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: testWidget),
    ));

    await tester.pump();

    expect(find.text('test text'), findsOneWidget);

    final Dependencies dependencies = tester.widget(find.byType(Dependencies));
    dependencies.addDependencies([
      TestClass('provided widget text'),
    ]);

    await tester.pumpAndSettle();

    expect(find.text('test text'), findsNothing);
    expect(find.text('provided widget text'), findsOneWidget);
  });

  testWidgets('Provider add dependencies', (tester) async {
    final testWidget = Provider(
      dependencies: const [],
      child: Builder(
        builder: (BuildContext context) {
          TestClass? testClass;

          try {
            testClass = Provider.of<TestClass>(context, aspect: TestClass);
          } on NoDependencyFound catch (_) {}

          String text = 'test text';
          if (testClass != null) text = testClass.text;

          return GestureDetector(
            onTap: () {
              final dependency = TestClass('Added dependency text');
              Provider.addDependency(context, dependency);
            },
            child: Text(text),
          );
        },
      ),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: testWidget),
    ));

    await tester.pump();

    expect(find.text('test text'), findsOneWidget);

    await tester.tap(find.text('test text'));

    await tester.pumpAndSettle();

    expect(find.text('test text'), findsNothing);
    expect(find.text('Added dependency text'), findsOneWidget);
  });
}

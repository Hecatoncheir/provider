import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/dependencies.dart';
import 'package:provider/provider.dart';

class TestClass {
  String text;
  TestClass(this.text);
}

void main() {
  testWidgets("Provider", (tester) async {
    final testWidget = Provider(
      dependencies: [
        TestClass("provided widget text"),
      ],
      child: Builder(
        builder: (BuildContext context) => Text(
          Provider.of(context, aspect: TestClass).find<TestClass>()!.text,
        ),
      ),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: testWidget),
    ));

    await tester.pump();

    expect(find.text("provided widget text"), findsOneWidget);
  });

  testWidgets("Provider change dependencies", (tester) async {
    final testWidget = Provider(
      dependencies: const [],
      child: Builder(
        builder: (BuildContext context) {
          String text = "test text";

          final testClass =
              Provider.of(context, aspect: TestClass).find<TestClass>();

          if (testClass != null) text = testClass.text;

          return Text(text);
        },
      ),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: testWidget),
    ));

    await tester.pump();

    expect(find.text("test text"), findsOneWidget);

    final ProviderState state = tester.state(find.byWidget(testWidget));

    state.addDependenciesController.add([
      TestClass("provided widget text"),
    ]);

    await tester.pumpAndSettle();

    expect(find.text("test text"), findsNothing);
    expect(find.text("provided widget text"), findsOneWidget);
  });

  testWidgets("Provider add dependencies", (tester) async {
    final testWidget = Provider(
      dependencies: const [],
      child: Builder(
        builder: (BuildContext context) {
          String text = "test text";

          final testClass =
              Provider.of(context, aspect: TestClass).find<TestClass>();

          if (testClass != null) text = testClass.text;

          return Text(text);
        },
      ),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: testWidget),
    ));

    await tester.pump();

    expect(find.text("test text"), findsOneWidget);

    final Dependencies dependencies = tester.widget(find.byType(Dependencies));
    dependencies.addDependencies([
      TestClass("provided widget text"),
    ]);

    await tester.pumpAndSettle();

    expect(find.text("test text"), findsNothing);
    expect(find.text("provided widget text"), findsOneWidget);
  });

  // testWidgets("Provider add dependencies", (tester) async {
  //   final testWidget = Provider(
  //     dependencies: const [],
  //     child: Builder(
  //       builder: (BuildContext context) {
  //         String text = "test text";
  //
  //         final testClass =
  //             Provider.of(context, aspect: TestClass).find<TestClass>();
  //
  //         if (testClass != null) text = testClass.text;
  //
  //         return GestureDetector(
  //           onTap: () {
  //             final dependency = TestClass("Added dependency text");
  //             Provider.of(context, aspect: TestClass)
  //                 .addDependencies([dependency]);
  //           },
  //           child: Text(text),
  //         );
  //       },
  //     ),
  //   );
  //
  //   await tester.pumpWidget(MaterialApp(
  //     home: Scaffold(body: testWidget),
  //   ));
  //
  //   await tester.pump();
  //
  //   expect(find.text("test text"), findsOneWidget);
  //
  //   await tester.tap(find.text("test text"));
  //
  //   await tester.pumpAndSettle();
  //
  //   expect(find.text("test text"), findsNothing);
  //   expect(find.text("Added dependency text"), findsOneWidget);
  // });
}

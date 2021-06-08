# Provider [![Actions Status](https://github.com/Hecatoncheir/provider/workflows/check/badge.svg)](https://github.com/Hecatoncheir/provider/actions)

### Use: 

```dart
final widget = Provider(
  dependencies: [
    TestClass("test text"),
  ],
  child: Text(Provider.of<TestClass>(context, aspect: TestClass).text),
);

```

### Update dependency: 
```dart
  final testWidget = Provider(
  dependencies: [
    TestClass("test text"),
  ],
  child: Builder(
    builder: (BuildContext context) {
      final text = Provider.of<TestClass>(context, aspect: TestClass).text;

      return GestureDetector(
        onTap: () {
          final dependency = TestClass("Updated dependency text");
          Provider.updateDependency<TestClass>(context, dependency);
        },
        child: Text(text),
      );
    },
  ),
);
```

### Add dependency:
```dart
    final testWidget = Provider(
  dependencies: const [],
  child: Builder(
    builder: (BuildContext context) {
      TestClass? testClass;

      try {
        testClass = Provider.of<TestClass>(context, aspect: TestClass);
      } on NoDependencyFound catch (_) {}

      String text = "test text";
      if (testClass != null) text = testClass.text;

      return GestureDetector(
        onTap: () {
          final dependency = TestClass("Added dependency text");
          Provider.addDependency(context, dependency);
        },
        child: Text(text),
      );
    },
  ),
);
```

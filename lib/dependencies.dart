import 'dart:async';

import 'package:flutter/widgets.dart';

class NoDependencyFound implements Exception {}

class Dependencies extends InheritedModel<Type> {
  final List dependencies;
  final StreamController<List> _addDependenciesController;
  final StreamController<List> _removeDependenciesController;
  final StreamController<List> _updateDependenciesController;

  const Dependencies({
    required this.dependencies,
    required Widget child,
    required StreamController<List> addDependenciesController,
    required StreamController<List> removeDependenciesController,
    required StreamController<List> updateDependenciesController,
    Key? key,
  })  : _addDependenciesController = addDependenciesController,
        _removeDependenciesController = removeDependenciesController,
        _updateDependenciesController = updateDependenciesController,
        super(key: key, child: child);

  T find<T>({bool throwException = false}) {
    T? dependency;

    for (final dep in dependencies) {
      if (dep.runtimeType != T) continue;
      dependency = dep;
      break;
    }

    if (dependency == null) throw NoDependencyFound();
    return dependency;
  }

  void addDependencies(List dependencies) =>
      _addDependenciesController.add(dependencies);

  void removeDependencies(List dependencies) =>
      _removeDependenciesController.add(dependencies);

  void updateDependencies(List dependencies) =>
      _updateDependenciesController.add(dependencies);

  @override
  bool updateShouldNotify(covariant Dependencies oldWidget) {
    if (oldWidget.dependencies != dependencies) return true;
    return false;
  }

  @override
  bool updateShouldNotifyDependent(
    covariant Dependencies oldWidget,
    Set dependencies,
  ) {
    for (final dep in dependencies) {
      if (this.dependencies.contains(dep) &&
          oldWidget.dependencies[dep] != this.dependencies[dep]) return true;
    }

    return false;
  }
}

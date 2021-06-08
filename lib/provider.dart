import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import 'dependencies.dart';

class NoProviderFound implements Exception {}

class Provider extends StatefulWidget {
  final Logger log;

  final List dependencies;
  final Widget child;

  Provider({
    required this.dependencies,
    required this.child,
  }) : log = Logger("Provider");

  static T of<T>(BuildContext context, {Type? aspect}) {
    final Dependencies? dependencies =
        InheritedModel.inheritFrom<Dependencies>(context, aspect: aspect);

    if (dependencies == null) throw NoProviderFound();

    return dependencies.find<T>(throwException: true);
  }

  static void updateDependency<OldDependencyType>(
    BuildContext context,
    Object newDependency,
  ) {
    final Dependencies? dependencies =
        InheritedModel.inheritFrom<Dependencies>(context);

    if (dependencies == null) throw NoProviderFound();

    final deps = List.from(dependencies.dependencies);

    final dependency =
        deps.firstWhere((dep) => dep.runtimeType == OldDependencyType);

    final indexOfDependency = deps.indexOf(dependency);
    deps[indexOfDependency] = newDependency;

    dependencies.updateDependencies(deps);
  }

  static void addDependency(
    BuildContext context,
    Object newDependency,
  ) {
    final Dependencies? dependencies =
        InheritedModel.inheritFrom<Dependencies>(context);

    if (dependencies == null) throw NoProviderFound();

    final deps = List.from(dependencies.dependencies)..add(newDependency);

    dependencies.addDependencies(deps);
  }

  @override
  ProviderState createState() => ProviderState();
}

class ProviderState extends State<Provider> {
  late int _dependenciesVersion;

  late List _dependencies;

  late final StreamController<List> addDependenciesController;
  late final Stream<List> addDependencies;
  late final StreamSubscription addDependenciesSubscription;

  late final StreamController<List> removeDependenciesController;
  late final Stream<List> removeDependencies;
  late final StreamSubscription removeDependenciesSubscription;

  late final StreamController<List> updateDependenciesController;
  late final Stream<List> updateDependencies;
  late final StreamSubscription updateDependenciesSubscription;

  late final StreamController<List> _readyForRenderController;
  late final Stream<List> _readyForRender;

  @override
  void initState() {
    super.initState();
    _dependenciesVersion = 0;
    _dependencies = List.from(widget.dependencies);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    addDependenciesController = StreamController<List>();
    addDependencies = addDependenciesController.stream.asBroadcastStream();

    addDependenciesSubscription = addDependencies.listen((dependencies) {
      _dependencies = _addDependencies(
        oldDependencies: _dependencies,
        newDependencies: dependencies,
      );

      _dependenciesVersion++;
      _readyForRenderController.add(_dependencies);
    });

    removeDependenciesController = StreamController<List>();
    removeDependencies =
        removeDependenciesController.stream.asBroadcastStream();

    removeDependenciesSubscription = removeDependencies.listen((dependencies) {
      _dependencies = _removeDependencies(
        oldDependencies: _dependencies,
        newDependencies: dependencies,
      );

      _dependenciesVersion++;
      _readyForRenderController.add(_dependencies);
    });

    updateDependenciesController = StreamController<List>();
    updateDependencies =
        updateDependenciesController.stream.asBroadcastStream();

    updateDependenciesSubscription = updateDependencies.listen((dependencies) {
      _dependencies = _updateDependencies(
        oldDependencies: _dependencies,
        newDependencies: dependencies,
      );

      _dependenciesVersion++;
      _readyForRenderController.add(_dependencies);
    });

    _readyForRenderController = StreamController<List>();
    _readyForRender = _readyForRenderController.stream;
  }

  List _addDependencies({
    required List oldDependencies,
    required List newDependencies,
  }) {
    final dependencies = [];
    dependencies..addAll(oldDependencies)..addAll(newDependencies);
    return dependencies;
  }

  List _removeDependencies({
    required List oldDependencies,
    required List newDependencies,
  }) {
    for (final dep in newDependencies) {
      oldDependencies.remove(dep);
    }

    return oldDependencies;
  }

  List _updateDependencies({
    required List oldDependencies,
    required List newDependencies,
  }) {
    final dependencies = [];

    for (final newDep in newDependencies) {
      final oldDep = oldDependencies.firstWhere(
          (oldDep) => oldDep.runtimeType == newDep.runtimeType,
          orElse: () => null);

      if (oldDep == null) {
        dependencies.add(oldDep);
      } else {
        dependencies.add(newDep);
      }
    }

    return dependencies;
  }

  @override
  void dispose() {
    // try {
    //   for (final dep in widget.dependencies) {
    //     dep.dispose();
    //   }
    //   // ignore: avoid_catching_errors
    // } on NoSuchMethodError catch (error) {
    //   widget.log.info(error);
    // } on Exception catch (exception) {
    //   widget.log.info(exception);
    // }

    addDependenciesSubscription.cancel();
    addDependenciesController.close();

    removeDependenciesSubscription.cancel();
    removeDependenciesController.close();

    updateDependenciesSubscription.cancel();
    updateDependenciesController.close();

    _readyForRenderController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List>(
      initialData: _dependencies,
      stream: _readyForRender,
      builder: (context, snapshot) {
        return Dependencies(
          key: Key("Version: " + _dependenciesVersion.toString()),
          dependencies: snapshot.data!,
          child: widget.child,
          addDependenciesController: addDependenciesController,
          removeDependenciesController: removeDependenciesController,
          updateDependenciesController: updateDependenciesController,
        );
      },
    );
  }
}

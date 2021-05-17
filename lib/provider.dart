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

  static Dependencies of(BuildContext context, {Type? aspect}) {
    final Dependencies? result =
        InheritedModel.inheritFrom<Dependencies>(context, aspect: aspect);
    if (result == null) throw NoProviderFound();
    return result;
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
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _dependencies = _addDependencies(
          allDependencies: _dependencies,
          dependencies: dependencies,
        );

        _dependenciesVersion++;
        _readyForRenderController.add(_dependencies);
      });
    });

    removeDependenciesController = StreamController<List>();
    removeDependencies =
        removeDependenciesController.stream.asBroadcastStream();

    removeDependenciesSubscription = removeDependencies.listen((dependencies) {
      _dependencies = _removeDependencies(
        allDependencies: _dependencies,
        dependencies: dependencies,
      );

      _dependenciesVersion++;
      _readyForRenderController.add(_dependencies);
    });

    updateDependenciesController = StreamController<List>();
    updateDependencies =
        updateDependenciesController.stream.asBroadcastStream();

    updateDependenciesSubscription = updateDependencies.listen((dependencies) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _dependencies = _updateDependencies(
          allDependencies: _dependencies,
          dependencies: dependencies,
        );

        _dependenciesVersion++;
        _readyForRenderController.add(_dependencies);
      });
    });

    _readyForRenderController = StreamController<List>();
    _readyForRender = _readyForRenderController.stream;
  }

  List _addDependencies({
    required List allDependencies,
    required List dependencies,
  }) {
    final dependenciesForUpdate = allDependencies
        .where((element) => dependencies.contains(element.runtimeType))
        .toList();

    final updatedDependencies = _updateDependencies(
      allDependencies: allDependencies,
      dependencies: dependenciesForUpdate,
    );

    updatedDependencies.addAll(dependencies);

    return allDependencies;
  }

  List _removeDependencies({
    required List allDependencies,
    required List dependencies,
  }) {
    for (final dep in dependencies) {
      allDependencies.remove(dep);
    }

    return allDependencies;
  }

  List _updateDependencies({
    required List allDependencies,
    required List dependencies,
  }) {
    for (final dep in dependencies) {
      final dependency = allDependencies.firstWhere(
          (element) => element.runtimeType == dep.runtimeType,
          orElse: () => null);

      if (dependency == null) {
        allDependencies.add(dependency);
      } else {
        allDependencies.remove(dependency);
      }
    }

    return allDependencies;
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

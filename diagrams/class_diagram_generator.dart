import 'dart:io';

import 'package:flutter/foundation.dart';

void main() {
  final Directory libDir = Directory('lib');
  final File output = File('diagram_with_widgets.puml');
  final StringBuffer buffer = StringBuffer();

  buffer.writeln('@startuml');
  buffer.writeln('skinparam classAttributeIconSize 0');

  final List<FileSystemEntity> files = libDir
      .listSync(recursive: true)
      .where((f) => f is File && f.path.endsWith('.dart'))
      .toList();

  final Set<String> classNames = {};
  final Set<String> mixinNames = {};
  final Set<String> viewModelNames = {};

  final Map<String, List<String>> classFields = {};
  final Map<String, List<String>> classMethods = {};
  final Map<String, Set<String>> relations = {};
  final Map<String, String> stereotypes = {};

  // Step 1: Detect classes and mixins
  for (final file in files) {
    final lines = File(file.path).readAsLinesSync();
    for (final line in lines) {
      final trimmed = line.trim();
      final classMatch = RegExp(r'class (\w+)').firstMatch(trimmed);
      if (classMatch != null) {
        classNames.add(classMatch.group(1)!);
      }
      final mixinMatch = RegExp(r'mixin (\w+)').firstMatch(trimmed);
      if (mixinMatch != null) {
        mixinNames.add(mixinMatch.group(1)!);
      }
    }
  }

  // Step 2: Parse class structures
  for (final file in files) {
    final lines = File(file.path).readAsLinesSync();
    String? currentClass;
    final List<String> bufferLines = [];

    for (final line in lines) {
      final trimmed = line.trim();

      // Widget --> ViewModel
      final baseWidgetVMMatch = RegExp(r'class (\w+)\s+extends\s+BaseWidget<(\w+)>').firstMatch(trimmed);
      if (baseWidgetVMMatch != null) {
        final widgetName = baseWidgetVMMatch.group(1)!;
        final viewModelName = baseWidgetVMMatch.group(2)!;
        stereotypes[widgetName] = 'Widget';
        stereotypes[viewModelName] = 'ViewModel';
        relations.putIfAbsent(widgetName, () => {}).add(viewModelName);
      }

      // State --> Widget
      final stateWidgetMatch = RegExp(r'class (\w+)\s+extends\s+State<(\w+)>').firstMatch(trimmed);
      if (stateWidgetMatch != null) {
        final stateClass = stateWidgetMatch.group(1)!;
        final widgetClass = stateWidgetMatch.group(2)!;
        stereotypes[stateClass] = 'State';
        relations.putIfAbsent(stateClass, () => {}).add(widgetClass);
      }

      // Class and optional inheritance / mixins
      final classMatch = RegExp(r'class (\w+)(?:\s+extends\s+(\w+))?(?:\s+with\s+([\w<>, ]+))?').firstMatch(trimmed);
      if (classMatch != null) {
        if (currentClass != null) {
          _processClass(
            currentClass,
            bufferLines,
            classFields,
            classMethods,
            relations,
            classNames,
            mixinNames,
          );
          bufferLines.clear();
        }

        currentClass = classMatch.group(1)!;
        final parent = classMatch.group(2);
        final mixins = classMatch.group(3);

        if (parent != null) {
          if ([
            'StatelessWidget',
            'StatefulWidget',
            'HookWidget',
            'Component',
            'PositionComponent',
            'SpriteComponent',
            'FlameGame',
          ].contains(parent)) {
            stereotypes[currentClass] = 'Widget';
          } else if (parent == 'BaseVM') {
            stereotypes[currentClass] = 'ViewModel';
            viewModelNames.add(currentClass);
          }

          if (classNames.contains(parent)) {
            relations.putIfAbsent(currentClass, () => {}).add(parent);
          }
        }

        if (mixins != null) {
          for (final mixin in mixins.split(',')) {
            final name = mixin.trim().split('<').first;
            if (mixinNames.contains(name)) {
              relations.putIfAbsent(currentClass, () => {}).add(name);
            }
          }
        }
      } else if (currentClass != null) {
        if (trimmed.contains('Widget build(')) {
          stereotypes[currentClass] = 'Widget';
        }
        bufferLines.add(trimmed);
      }
    }

    if (currentClass != null) {
      _processClass(
        currentClass,
        bufferLines,
        classFields,
        classMethods,
        relations,
        classNames,
        mixinNames,
      );
    }
  }

  // Step 3: Print all classes
  final Set<String> allNames = {
    ...classFields.keys,
    ...mixinNames,
    ...stereotypes.keys,
  };

  for (final className in allNames) {
    final stereotype = stereotypes[className] == 'Widget'
        ? ' <<Widget>>'
        : stereotypes[className] == 'ViewModel'
            ? ' <<ViewModel>>'
            : stereotypes[className] == 'State'
                ? ' <<State>>'
                : mixinNames.contains(className)
                    ? ' <<Mixin>>'
                    : '';

    buffer.writeln('class $className$stereotype {');

    if (classFields.containsKey(className)) {
      for (final field in classFields[className]!) {
        buffer.writeln('  $field');
      }
    }

    if (classMethods.containsKey(className)) {
      for (final method in classMethods[className]!) {
        buffer.writeln('  +$method');
      }
    }

    buffer.writeln('}');
  }

  // Step 4: Print relations
  final Set<String> drawn = {};
  for (final entry in relations.entries) {
    final from = entry.key;
    for (final to in entry.value) {
      if (allNames.contains(to)) {
        final relation = '$from --> $to';
        if (!drawn.contains(relation)) {
          buffer.writeln(relation);
          drawn.add(relation);
        }
      }
    }
  }

  buffer.writeln('@enduml');
  output.writeAsStringSync(buffer.toString());

  if (kDebugMode) {
    print('✅ Diagram updated and saved to diagram_with_widgets.puml');
  }
}

void _processClass(
  String className,
  List<String> lines,
  Map<String, List<String>> classFields,
  Map<String, List<String>> classMethods,
  Map<String, Set<String>> relations,
  Set<String> allClasses,
  Set<String> allMixins,
) {
  final fields = <String>[];
  final methods = <String>[];
  final related = <String>{};

  for (final line in lines) {
    final fieldMatch = RegExp(r'(?:final|late|static|const)?\s*([\w<>]+)\s+_?\w+\s*(=.*)?;').firstMatch(line);
    if (fieldMatch != null && !line.contains('(')) {
      final type = fieldMatch.group(1);
      final nameMatch = RegExp(r'(\w+)\s*(=.*)?;').firstMatch(line);
      final name = nameMatch?.group(1);
      if (type != null && name != null) {
        fields.add('$type $name');
        final cleanType = type.replaceAll(RegExp(r'[<>]'), '');
        if (allClasses.contains(cleanType) || allMixins.contains(cleanType)) {
          related.add(cleanType);
        }
      }
      continue;
    }

    final methodMatch = RegExp(r'(Future<[\w?]+>|Future|[\w?]+)\s+(\w+)\s*\(([^)]*)\)').firstMatch(line);
    if (methodMatch != null &&
        !line.contains(';') &&
        !line.startsWith('if') &&
        !line.startsWith('for')) {
      final returnType = methodMatch.group(1);
      final methodName = methodMatch.group(2);
      if (returnType != null && methodName != null) {
        methods.add('$returnType $methodName()');
      }
    }
  }

  classFields[className] = fields;
  classMethods[className] = methods;
  relations.putIfAbsent(className, () => {}).addAll(related);
}
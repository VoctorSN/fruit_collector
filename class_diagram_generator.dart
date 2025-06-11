import 'dart:io';

// Import Flutter foundation when running under Flutter (UI available);
// otherwise pull in our lightweight CLI stub.
import 'foundation_stub.dart' if (dart.library.ui) 'package:flutter/foundation.dart';

void main() {
  final Directory libDir = Directory('lib');
  final File output = File('diagram_with_widgets.puml');
  final StringBuffer buffer = StringBuffer();

  buffer.writeln('@startuml');
  buffer.writeln('skinparam classAttributeIconSize 0');

  final files = libDir.listSync(recursive: true).where((f) => f is File && f.path.endsWith('.dart')).toList();

  final classNames = <String>{};
  final mixinNames = <String>{};
  final classFields = <String, List<String>>{};
  final classMethods = <String, List<String>>{};
  final relations = <String, Set<String>>{};
  final stereotypes = <String, String>{};

  // Step 1: collect all class & mixin names
  for (var file in files) {
    for (var line in File(file.path).readAsLinesSync()) {
      final t = line.trim();
      final cm = RegExp(r'class (\w+)').firstMatch(t);
      if (cm != null) classNames.add(cm.group(1)!);
      final mm = RegExp(r'mixin (\w+)').firstMatch(t);
      if (mm != null) mixinNames.add(mm.group(1)!);
    }
  }

  // Step 2: para cada fichero, extraer cada clase
  for (var file in files) {
    final lines = File(file.path).readAsLinesSync();
    for (int i = 0; i < lines.length; i++) {
      final header = lines[i].trim();
      final hmatch = RegExp(r'^(?:class|mixin)\s+(\w+)').firstMatch(header);
      if (hmatch == null) continue;
      final className = hmatch.group(1)!;

      // 2.a) avanzar hasta la primera '{'
      int depth = 0;
      int j = i;
      while (j < lines.length) {
        depth += lines[j].split('{').length - 1;
        depth -= lines[j].split('}').length - 1;
        j++;
        if (depth > 0) break;
      }

      // 2.b) recopilar hasta que depth vuelva a 0
      final body = <String>[];
      while (j < lines.length && depth > 0) {
        final raw = lines[j];
        depth += raw.split('{').length - 1;
        depth -= raw.split('}').length - 1;
        if (depth > 0) {
          body.add(raw.trim());
        }
        j++;
      }

      // 2.c) procesar la clase extraída
      _processClass(className, body, classFields, classMethods, relations, classNames, mixinNames);

      // saltar el índice para evitar volver a procesar interior
      i = j;
    }
  }

  // Step 3 y 4: imprimir diagrama (igual que antes)...
  final allNames = {...classFields.keys, ...mixinNames, ...stereotypes.keys};

  for (final cn in allNames) {
    final stereo =
        stereotypes[cn] == 'Widget'
            ? ' <<Widget>>'
            : stereotypes[cn] == 'ViewModel'
            ? ' <<ViewModel>>'
            : stereotypes[cn] == 'State'
            ? ' <<State>>'
            : mixinNames.contains(cn)
            ? ' <<Mixin>>'
            : '';
    buffer.writeln('class $cn$stereo {');
    for (var f in classFields[cn] ?? []) buffer.writeln('  $f');
    for (var m in classMethods[cn] ?? []) buffer.writeln('  +$m');
    buffer.writeln('}');
  }

  final drawn = <String>{};
  for (var entry in relations.entries) {
    for (var to in entry.value) {
      if (allNames.contains(to)) {
        final rel = '${entry.key} --> $to';
        if (drawn.add(rel)) buffer.writeln(rel);
      }
    }
  }

  buffer.writeln('@enduml');
  output.writeAsStringSync(buffer.toString());
  if (kDebugMode) print('✅ Diagram updated and saved.');
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
  final List<String> fields = <String>[];
  final List<String> methods = <String>[];
  final Set<String> related = <String>{};
  bool inBlockComment = false;
  bool inStringLiteral = false; // track multiline strings
  int depth = 0; // 0 = class-level scope

  for (final String rawLine in lines) {
    // Toggle multiline string literal state
    if (rawLine.contains("'''") || rawLine.contains('"""')) {
      inStringLiteral = !inStringLiteral;
      continue;
    }
    if (inStringLiteral) continue;

    final String line = rawLine.trim();

    // Handle block comments
    if (line.startsWith('/*')) {
      inBlockComment = true;
    }
    if (inBlockComment) {
      if (line.endsWith('*/')) inBlockComment = false;
      continue;
    }

    // Skip unwanted patterns anywhere
    if (line.startsWith('//') ||
        line.startsWith('import ') ||
        line.contains(RegExp(r'\belse if\b')) ||
        line.startsWith('return ') ||
        line.startsWith('await ') ||
        line.startsWith('throw ') ||
        line.startsWith('const ') ||
        line.contains('?.')) {
      // skip this line
    } else if (depth == 0) {
      // Only detect fields and methods at class-level (depth == 0)

      // Field detection
      final RegExp fieldRegExp = RegExp(
        r'^(?:final|late|static)?\s*' + r'((?:Function(?:\([^)]*\))?|[\w<>\?\s,]+))' + r'\s+_?(\w+)\s*(?:=.*)?;',
      );
      final RegExpMatch? fieldMatch = fieldRegExp.firstMatch(line);
      if (fieldMatch != null) {
        final String typePart = fieldMatch.group(1)!.trim();
        final String name = fieldMatch.group(2)!;
        fields.add('$typePart $name');
        final String cleanType = typePart.replaceAll(RegExp(r'[<>\?\s,]'), '');
        if (allClasses.contains(cleanType) || allMixins.contains(cleanType)) {
          related.add(cleanType);
        }
        continue;
      }

      // Method detection including parameters
      final RegExp methodRegExp = RegExp(
        r'^(Future<[\w?]+>|Future|[\w?]+)\s+' + // return type
            r'(\w+)\s*\(([^)]*)\)', // name + params
      );
      final RegExpMatch? methodMatch = methodRegExp.firstMatch(line);
      if (methodMatch != null) {
        final String returnType = methodMatch.group(1)!;
        final String methodName = methodMatch.group(2)!;
        final String params = methodMatch.group(3)!.trim();
        final String signature = params.isEmpty ? '$returnType $methodName()' : '$returnType $methodName($params)';
        methods.add(signature);
      }
    }

    // Update nesting depth
    final int opens = rawLine.split('{').length - 1;
    final int closes = rawLine.split('}').length - 1;
    depth += opens - closes;
  }

  classFields[className] = fields;
  classMethods[className] = methods;
  relations.putIfAbsent(className, () => <String>{}).addAll(related);
}
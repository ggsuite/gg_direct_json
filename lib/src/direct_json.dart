// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:convert';
import 'dart:io';

/// Easily read and write values directly to and from JSON documents.
class DirectJson {
  /// Constructor.
  const DirectJson({this.prettyPrint = false});

  // ######################
  // Write
  // ######################

  // ...........................................................................
  /// Writes a value into a JSON document.
  ///
  /// - If the path does not exist, it will be created.
  /// - Throws when an existing value is not of type [T].
  void write<T>({
    required Map<String, dynamic> json,
    required Iterable<String> path,
    required T value,
  }) =>
      _write<T>(json, path, value);

// ...........................................................................
  /// Writes a value into a JSON document.
  ///
  /// - If the path does not exist, it will be created.
  /// - Throws when an existing value is not of type [T].
  /// - Returns the new JSON content.
  String writeString<T>({
    required String json,
    required String path,
    required T value,
  }) {
    final Map<String, dynamic> jsonMap =
        json.isEmpty ? {} : jsonDecode(json) as Map<String, dynamic>;

    _write<T>(jsonMap, path.split('/'), value);
    final result = _encoder.convert(jsonMap);
    return result;
  }

  // ...........................................................................
  /// Writes a value into a JSON file.
  ///
  /// - If the path does not exist, it will be created.
  /// - Creates the file when not existing.
  /// - Returns the new JSON content.
  Future<String> writeFile<T>({
    required File file,
    required String path,
    required T value,
  }) async {
    final json = (await file.exists()) ? await file.readAsString() : '';
    final result = writeString<T>(json: json, path: path, value: value);
    await file.writeAsString(result);
    return result;
  }

  // ######################
  // Read
  // ######################

  // ...........................................................................
  /// Reads a value from a JSON document.
  ///
  /// - Returns null if the value is not found.
  /// - Throws when value is not of type [T].
  T? read<T>({
    required Map<String, dynamic> json,
    required Iterable<String> path,
  }) =>
      _read<T>(json, path);

  // ...........................................................................
  /// Reads a value from a JSON file
  ///
  /// - Returns null if the value is not found.
  /// - Throws when value is not of type [T].
  /// - Throws when the file does not exist.
  Future<T?> readFile<T>({
    required File file,
    required String path,
  }) async {
    var json = await file.readAsString();
    if (json.isEmpty) {
      json = '{}';
    }
    return readString<T>(json: json, path: path);
  }

  // ...........................................................................
  /// Reads a value from a JSON document.
  ///
  /// - Returns null if the value is not found.
  /// - Throws when value is not of type [T].
  T? readString<T>({
    required String json,
    required String path,
  }) {
    final Map<String, dynamic> jsonMap =
        jsonDecode(json) as Map<String, dynamic>;

    return _read<T>(jsonMap, path.split('/'));
  }

  // ######################
  // Remove
  // ######################

  // ...........................................................................
  /// Removes a value from a JSON document.
  void remove({
    required Map<String, dynamic> json,
    required Iterable<String> path,
  }) =>
      _remove(json, path);

  // ...........................................................................
  /// Removes a value from a JSON document.
  String removeFromString({
    required String json,
    required String path,
  }) {
    final Map<String, dynamic> jsonMap =
        jsonDecode(json) as Map<String, dynamic>;

    _remove(jsonMap, path.split('/'));
    return _encoder.convert(jsonMap);
  }

  // ...........................................................................
  /// Removes a value from a JSON file.
  Future<String> removeFromFile({
    required File file,
    required String path,
  }) async {
    final json = await file.readAsString();
    final result = removeFromString(json: json, path: path);
    await file.writeAsString(result);
    return result;
  }

  // ...........................................................................
  /// Is the JSON document pretty printed?
  final bool prettyPrint;

  // ######################
  // Private
  // ######################
  JsonEncoder get _encoder =>
      prettyPrint ? const JsonEncoder.withIndent('  ') : const JsonEncoder();

  // ...........................................................................
  T? _read<T>(Map<String, dynamic> json, Iterable<String> path) {
    var node = json;
    for (var i = 0; i < path.length; i++) {
      final pathSegment = path.elementAt(i);
      if (!node.containsKey(pathSegment)) {
        return null;
      }
      if ((i == path.length - 1)) {
        final val = node[pathSegment];
        if (val is T == false) {
          throw Exception('Existing value is not of type $T.');
        }
        return node[pathSegment] as T;
      }
      node = node[pathSegment] as Map<String, dynamic>;
    }

    return null;
  }

  // ...........................................................................
  void _write<T>(
    Map<String, dynamic> json,
    Iterable<String> path,
    T value,
  ) {
    _checkType<T>(json, path);

    Map<String, dynamic> node = json;

    for (int i = 0; i < path.length; i++) {
      var pathSegment = path.elementAt(i);

      if (i == path.length - 1) {
        node[pathSegment] = value;
        break;
      }

      var childNode = node[pathSegment] as Map<String, dynamic>?;
      if (childNode == null) {
        childNode = {};
        node[pathSegment] = childNode;
      }
      node = childNode;
    }
  }

  // ...........................................................................
  void _remove(Map<String, dynamic> doc, Iterable<String> path) {
    var node = doc;
    for (int i = 0; i < path.length; i++) {
      final pathSegment = path.elementAt(i);
      if (!node.containsKey(pathSegment)) {
        break;
      }

      if (i == path.length - 1) {
        node.remove(pathSegment);
        break;
      }
      node = node[pathSegment] as Map<String, dynamic>;
    }
  }

  // ...........................................................................
  void _checkType<T>(
    Map<String, dynamic> json,
    Iterable<String> path,
  ) {
    _read<T>(json, path); // Will throw if existing value has a different type.
  }
}

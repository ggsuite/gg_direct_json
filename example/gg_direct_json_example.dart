#!/usr/bin/env dart
// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:gg_direct_json/gg_direct_json.dart';
import 'package:path/path.dart';

Future<void> main() async {
  print('Start with an given JSON document:');

  // ...........................................................................
  final df = DirectJson(
    json: {
      'a': 1,
      'b': {'c': 3},
    },
    prettyPrint: false,
  );

  // ...........................................................................
  print('Print the result');
  print(df.jsonString); // {"a":1,"b":{"c":3}}

  print('Write a new value into the JSON document:');
  df.set('/b/c', 4);
  print(df.jsonString); // {"a":1,"b":{"c":4}}

  df.set('b.c', 5);
  print(df.jsonString); // {"a":1,"b":{"c":5}}

  print('Read a value from the JSON document:');
  final val = df.get<int>('b/c');
  print(val); // 5

  final val2 = df.get<Map<String, dynamic>>('b');
  print(val2); // {c: 5}

  // ...........................................................................
  print('Directly update values in JSON strings');

  final result =
      DirectJson.writeToString(json: '{"a": 5, "b": 6}', path: '/b', value: 8);

  print(result); // {"a":5,"b":8}

  // ...........................................................................
  print('Directly maninpulate JSON files');

  final path = join(Directory.systemTemp.path, 'direct_json.json');
  var file = await File(path).writeAsString('{"a": 5, "b": 6}');

  await DirectJson.writeFile(
    file: file,
    path: '/b',
    value: 7,
  );

  final content = await file.readAsString();
  print(content); // {"a":5,"b":7}
}

/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>
  Copyright (C) 2013 Don Olmstead <don.j.olmstead@gmail.com>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/

library shader_format_test;

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre_asset_pack.dart';
import 'dart:json' as Json;

//---------------------------------------------------------------------
// Valid formats
//---------------------------------------------------------------------

String usePathString =
'''
{
  "name":"path",
  "path":"aShader.vert"
}
''';

void verifyUsePath(ShaderFormat value) {
  expect(value.name       , 'path');
  expect(value.isReference, false);
  expect(value.url        , 'aShader.vert');
  expect(value.source     , null);
  expect(value.hasSource  , false);
}

String useSourceString =
'''
{
  "name":"source",
  "source":"void main(){}"
}
''';

void verifyUseSource(ShaderFormat value) {
  expect(value.name       , 'source');
  expect(value.isReference, false);
  expect(value.url        , null);
  expect(value.source     , 'void main(){}');
  expect(value.hasSource  , true);
}

//---------------------------------------------------------------------
// ShaderFormat tests
//---------------------------------------------------------------------

ShaderFormat createShaderFormat(String value) {
  return new ShaderFormat.fromJson(Json.parse(value));
}

void testValues() {
  // Check for a Shader using a data uri
  ShaderFormat path = createShaderFormat(usePathString);

  verifyUsePath(path);

  // Check for a Shader using source code
  ShaderFormat source = createShaderFormat(useSourceString);

  verifyUseSource(source);
}

void testExceptions() {
  // Should throw if no name is provided
  String noName = '{"path":"aShader.vert"}';

  expect(() {
    ShaderFormat format = createShaderFormat(noName);
  }, throwsArgumentError);

  // Should throw if no data is provided
  String noSource = '{"name":"shader"}';

  expect(() {
    ShaderFormat format = createShaderFormat(noSource);
  }, throwsArgumentError);

  // Should throw if both source code and a data uri are provided
  String bothSourcePaths =
'''
{"name":"shader","path":"aShader.vert","source":"void main(){}"}
''';

  expect(() {
    ShaderFormat format = createShaderFormat(bothSourcePaths);
  }, throwsArgumentError);

  // Should throw if the names are not unique
  String repeatList =
      '''
[
  {"name":"repeat","source":"void main(){}"},
  {"name":"repeat","source":"void main(){}"}
]
      ''';

  expect(() {
    List list = Json.parse(repeatList);
    Map<String, ShaderFormat> formats = ShaderFormat.parseList(list);
  }, throwsArgumentError);
}

void testList() {
  String formatList = '[${usePathString},${useSourceString}]';

  List list = Json.parse(formatList);
  Map<String, ShaderFormat> formats = ShaderFormat.parseList(list);

  expect(formats.length, 2);
  expect(formats.containsKey('path')  , true);
  expect(formats.containsKey('source'), true);

  // Check for a Shader using a data uri
  ShaderFormat path = formats['path'];

  verifyUsePath(path);

  // Check for a Shader using source code
  ShaderFormat source = formats['source'];

  verifyUseSource(source);
}

void main() {
  test('values', testValues);
  test('exceptions', testExceptions);
  test('list', testList);
}

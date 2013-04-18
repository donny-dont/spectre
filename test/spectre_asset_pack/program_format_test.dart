/*
  Copyright (C) 2013 Spectre Authors

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

library program_format_test;

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_asset_pack.dart';
import 'dart:json' as Json;

//---------------------------------------------------------------------
// Valid formats
//---------------------------------------------------------------------

String referenceString =
'''
{
  "name":"referenceProgram",
  "attributes": [
    {
      "semantic":"POSITION",
      "symbol":"vPosition"
    },
    {
      "semantic":"COLOR",
      "symbol":"vColor"
    },
    {
      "semantic":"COLOR_2",
      "symbol":"vColor2"
    }
  ],
  "vertexShader":"vertShader",
  "fragmentShader":"fragShader"
}
''';

void verifyReferences(ProgramFormat value) {
  expect(value.name, 'referenceProgram');

  // Test the attributes
  ProgramAttribute position = value.attributes[0];

  expect(position.symbol    , 'vPosition');
  expect(position.usage     , InputElementUsage.Position);
  expect(position.usageIndex, 0);

  ProgramAttribute color0 = value.attributes[1];

  expect(color0.symbol    , 'vColor');
  expect(color0.usage     , InputElementUsage.Color);
  expect(color0.usageIndex, 0);

  ProgramAttribute color2 = value.attributes[2];

  expect(color2.symbol    , 'vColor2');
  expect(color2.usage     , InputElementUsage.Color);
  expect(color2.usageIndex, 2);

  // Test vertex shader
  ShaderFormat vertex = value.vertexShader;

  expect(vertex.name       , 'vertShader');
  expect(vertex.isReference, true);
  expect(vertex.url        , null);
  expect(vertex.source     , null);
  expect(vertex.hasSource  , false);

  // Test fragment shader
  ShaderFormat fragment = value.fragmentShader;

  expect(fragment.name       , 'fragShader');
  expect(fragment.isReference, true);
  expect(fragment.url        , null);
  expect(fragment.source     , null);
  expect(fragment.hasSource  , false);
}

String sourceString =
'''
{
  "name":"sourceProgram",
  "attributes": [
    {
      "semantic":"POSITION",
      "symbol":"vPosition"
    },
    {
      "semantic":"NORMAL",
      "symbol":"vNormal"
    },
    {
      "semantic":"TANGENT",
      "symbol":"vTangent"
    },
    {
      "semantic":"TEXCOORD",
      "symbol":"vTexCoord0"
    },
    {
      "semantic":"TEXCOORD_1",
      "symbol":"vTexCoord1"
    }
  ],
  "vertexShader": {
    "name":"vertShader",
    "source":"void main(){}"
  },
  "fragmentShader": {
    "name":"fragShader",
    "source":"void main(){}"
  }
}
''';

void verifySources(ProgramFormat value) {
  expect(value.name, 'sourceProgram');

  // Test the attributes
  ProgramAttribute position = value.attributes[0];

  expect(position.symbol    , 'vPosition');
  expect(position.usage     , InputElementUsage.Position);
  expect(position.usageIndex, 0);

  ProgramAttribute normal = value.attributes[1];

  expect(normal.symbol    , 'vNormal');
  expect(normal.usage     , InputElementUsage.Normal);
  expect(normal.usageIndex, 0);

  ProgramAttribute tangent = value.attributes[2];

  expect(tangent.symbol    , 'vTangent');
  expect(tangent.usage     , InputElementUsage.Tangent);
  expect(tangent.usageIndex, 0);

  ProgramAttribute texCoord0 = value.attributes[3];

  expect(texCoord0.symbol    , 'vTexCoord0');
  expect(texCoord0.usage     , InputElementUsage.TextureCoordinate);
  expect(texCoord0.usageIndex, 0);

  ProgramAttribute texCoord1 = value.attributes[4];

  expect(texCoord1.symbol    , 'vTexCoord1');
  expect(texCoord1.usage     , InputElementUsage.TextureCoordinate);
  expect(texCoord1.usageIndex, 1);

  // Test vertex shader
  ShaderFormat vertex = value.vertexShader;

  expect(vertex.name       , 'vertShader');
  expect(vertex.isReference, false);
  expect(vertex.url        , null);
  expect(vertex.source     , 'void main(){}');
  expect(vertex.hasSource  , true);

  // Test fragment shader
  ShaderFormat fragment = value.fragmentShader;

  expect(fragment.name       , 'fragShader');
  expect(fragment.isReference, false);
  expect(fragment.url        , null);
  expect(fragment.source     , 'void main(){}');
  expect(fragment.hasSource  , true);
}

//---------------------------------------------------------------------
// ProgramFormat tests
//---------------------------------------------------------------------

void testValues() {
  // Check for a ShaderProgram using references to vertex and fragment shaders
  ProgramFormat reference = new ProgramFormat.fromJson(Json.parse(referenceString));

  verifyReferences(reference);

  // Check for a ShaderProgram with inline vertex and fragment shaders
  ProgramFormat source = new ProgramFormat.fromJson(Json.parse(sourceString));

  verifySources(source);
}

void testExceptions() {
  // Should throw if no name is provided
  String noName =
'''
{
  "attributes":[],
  "vertexShader":"vertShader",
  "fragmentShader":"fragShader"
}
''';

  expect(() {
    ShaderFormat format = new ShaderFormat.fromJson(Json.parse(noName));
  }, throwsArgumentError);

  // Should throw if no vertex shader is provided
  String noVertex =
'''
{
  "name":"noVertex",
  "attributes":[],
  "fragmentShader":"fragShader"
}
''';

  expect(() {
    ProgramFormat format = new ProgramFormat.fromJson(Json.parse(noVertex));
  }, throwsArgumentError);

  // Should throw if an invalid shader is provided
  String invalidShader =
'''
{
  "name":"invalid",
  "attributes":[],
  "vertexShader":["wrong!"],
  "fragmentShader":"fragShader"
}
''';

  expect(() {
    ProgramFormat format = new ProgramFormat.fromJson(Json.parse(invalidShader));
  }, throwsArgumentError);

  // Should throw if the names are not unique
  String repeatList =
'''
[
  {
    "name":"repeat",
    "attributes":[],
    "vertexShader":"vertShader",
    "fragmentShader":"fragShader"
  },
  {
    "name":"repeat",
    "attributes":[],
    "vertexShader":"vertShader",
    "fragmentShader":"fragShader"
  }
]
''';

  expect(() {
    List list = Json.parse(repeatList);
    Map<String, ProgramFormat> formats = ProgramFormat.parseList(list);
  }, throwsArgumentError);
}

void testList() {
  String formatList = '[${referenceString},${sourceString}]';

  List list = Json.parse(formatList);
  Map<String, ProgramFormat> formats = ProgramFormat.parseList(list);

  expect(formats.length, 2);
  expect(formats.containsKey('referenceProgram'), true);
  expect(formats.containsKey('sourceProgram')   , true);

  // Check for a ShaderProgram using references to vertex and fragment shaders
  ProgramFormat reference = formats['referenceProgram'];

  verifyReferences(reference);

  // Check for a ShaderProgram with inline vertex and fragment shaders
  ProgramFormat source = formats['sourceProgram'];

  verifySources(source);
}

void main() {
  test('values', testValues);
  test('exceptions', testExceptions);
  test('list', testList);
}

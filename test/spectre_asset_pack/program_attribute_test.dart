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

library program_attribute_test;

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_asset_pack.dart';
import 'dart:json' as Json;

void testValues() {
  List names = [
      ['POSITION', InputElementUsage.Position],
      ['NORMAL'  , InputElementUsage.Normal],
      ['TANGENT' , InputElementUsage.Tangent],
      ['BINORMAL', InputElementUsage.Binormal],
      ['TEXCOORD', InputElementUsage.TextureCoordinate],
      ['COLOR'   , InputElementUsage.Color],
  ];

  names.forEach((value) {
    String semantic = value[0];
    int usage = value[1];

    String noIndexString = '{"semantic":"${semantic}","symbol":"vAttrib"}';
    ProgramAttribute noIndex = new ProgramAttribute.fromJson(Json.parse(noIndexString));

    expect(noIndex.symbol    , 'vAttrib');
    expect(noIndex.usage     , usage);
    expect(noIndex.usageIndex, 0);

    for (int i = 0; i < 8; ++i) {
      String withIndexString = '{"semantic":"${semantic}_${i}","symbol":"vAttrib"}';
      ProgramAttribute withIndex = new ProgramAttribute.fromJson(Json.parse(withIndexString));

      expect(withIndex.symbol    , 'vAttrib');
      expect(withIndex.usage     , usage);
      expect(withIndex.usageIndex, i);
    }
  });
}

void testExceptions() {
  // Should throw if no semantic is provided
  String noSemantic = '{"symbol":"vPosition"}';

  expect(() {
    ProgramAttribute format = new ProgramAttribute.fromJson(Json.parse(noSemantic));
  }, throwsArgumentError);

  // Should throw if no symbol is provided
  String noSymbol = '{"semantic":"POSITION"}';

  expect(() {
    ProgramAttribute format = new ProgramAttribute.fromJson(Json.parse(noSymbol));
  }, throwsArgumentError);

  // Should throw if the semantic is not supported
  String invalidSemantic = '{"semantic":"INVALID","symbol":"vInvalid"}';

  expect(() {
    ProgramAttribute format = new ProgramAttribute.fromJson(Json.parse(invalidSemantic));
  }, throwsArgumentError);

  // Should throw if the usage index is invalid
  String invalidIndex = '{"semantic":"TEXCOORD_A","symbol":"vTexCoordA"}';

  expect(() {
    ProgramAttribute format = new ProgramAttribute.fromJson(Json.parse(invalidIndex));
  }, throwsFormatException);
}

void main() {
  test('values', testValues);
  test('exceptions', testExceptions);
}

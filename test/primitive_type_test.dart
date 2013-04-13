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

library primitive_type_test;

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre.dart';
import 'dart:html';
import 'dart:web_gl' as WebGL;

void main() {
  test('values', () {
    expect(PrimitiveType.PointList    , WebGL.POINTS);
    expect(PrimitiveType.LineList     , WebGL.LINES);
    expect(PrimitiveType.LineStrip    , WebGL.LINE_STRIP);
    expect(PrimitiveType.TriangleList , WebGL.TRIANGLES);
    expect(PrimitiveType.TriangleStrip, WebGL.TRIANGLE_STRIP);
    expect(PrimitiveType.TriangleFan  , WebGL.TRIANGLE_FAN);
  });

  test('stringify', () {
    expect(PrimitiveType.stringify(PrimitiveType.PointList)    , 'PrimitiveType.PointList');
    expect(PrimitiveType.stringify(PrimitiveType.LineList)     , 'PrimitiveType.LineList');
    expect(PrimitiveType.stringify(PrimitiveType.LineStrip)    , 'PrimitiveType.LineStrip');
    expect(PrimitiveType.stringify(PrimitiveType.TriangleList) , 'PrimitiveType.TriangleList');
    expect(PrimitiveType.stringify(PrimitiveType.TriangleStrip), 'PrimitiveType.TriangleStrip');
    expect(PrimitiveType.stringify(PrimitiveType.TriangleFan)  , 'PrimitiveType.TriangleFan');

    expect(() { PrimitiveType.stringify(-1); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('parse', () {
    expect(PrimitiveType.parse('PrimitiveType.PointList')    , PrimitiveType.PointList);
    expect(PrimitiveType.parse('PrimitiveType.LineList')     , PrimitiveType.LineList);
    expect(PrimitiveType.parse('PrimitiveType.LineStrip')    , PrimitiveType.LineStrip);
    expect(PrimitiveType.parse('PrimitiveType.TriangleList') , PrimitiveType.TriangleList);
    expect(PrimitiveType.parse('PrimitiveType.TriangleStrip'), PrimitiveType.TriangleStrip);
    expect(PrimitiveType.parse('PrimitiveType.TriangleFan')  , PrimitiveType.TriangleFan);

    expect(() { PrimitiveType.parse('NotValid'); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('isValid', () {
    expect(PrimitiveType.isValid(PrimitiveType.PointList)    , true);
    expect(PrimitiveType.isValid(PrimitiveType.LineList)     , true);
    expect(PrimitiveType.isValid(PrimitiveType.LineStrip)    , true);
    expect(PrimitiveType.isValid(PrimitiveType.TriangleList) , true);
    expect(PrimitiveType.isValid(PrimitiveType.TriangleStrip), true);
    expect(PrimitiveType.isValid(PrimitiveType.TriangleFan)  , true);

    expect(PrimitiveType.isValid(-1), false);
  });
}

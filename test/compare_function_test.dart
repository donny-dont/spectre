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

library compare_function_test;

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre.dart';
import 'dart:html';
import 'dart:web_gl' as WebGL;

void main() {
  test('values', () {
    expect(CompareFunction.Always      , WebGL.ALWAYS);
    expect(CompareFunction.Equal       , WebGL.EQUAL);
    expect(CompareFunction.Greater     , WebGL.GREATER);
    expect(CompareFunction.GreaterEqual, WebGL.GEQUAL);
    expect(CompareFunction.Less        , WebGL.LESS);
    expect(CompareFunction.LessEqual   , WebGL.LEQUAL);
    expect(CompareFunction.Fail        , WebGL.NEVER);
    expect(CompareFunction.NotEqual    , WebGL.NOTEQUAL);
  });

  test('stringify', () {
    expect(CompareFunction.stringify(CompareFunction.Always)      , 'CompareFunction.Always');
    expect(CompareFunction.stringify(CompareFunction.Equal)       , 'CompareFunction.Equal');
    expect(CompareFunction.stringify(CompareFunction.Greater)     , 'CompareFunction.Greater');
    expect(CompareFunction.stringify(CompareFunction.GreaterEqual), 'CompareFunction.GreaterEqual');
    expect(CompareFunction.stringify(CompareFunction.Less)        , 'CompareFunction.Less');
    expect(CompareFunction.stringify(CompareFunction.LessEqual)   , 'CompareFunction.LessEqual');
    expect(CompareFunction.stringify(CompareFunction.Fail)        , 'CompareFunction.Fail');
    expect(CompareFunction.stringify(CompareFunction.NotEqual)    , 'CompareFunction.NotEqual');

    expect(() { CullMode.stringify(-1); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('parse', () {
    expect(CompareFunction.parse('CompareFunction.Always')      , CompareFunction.Always);
    expect(CompareFunction.parse('CompareFunction.Equal')       , CompareFunction.Equal);
    expect(CompareFunction.parse('CompareFunction.Greater')     , CompareFunction.Greater);
    expect(CompareFunction.parse('CompareFunction.GreaterEqual'), CompareFunction.GreaterEqual);
    expect(CompareFunction.parse('CompareFunction.Less')        , CompareFunction.Less);
    expect(CompareFunction.parse('CompareFunction.LessEqual')   , CompareFunction.LessEqual);
    expect(CompareFunction.parse('CompareFunction.Fail')        , CompareFunction.Fail);
    expect(CompareFunction.parse('CompareFunction.NotEqual')    , CompareFunction.NotEqual);

    expect(() { CullMode.parse('NotValid'); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('isValid', () {
    expect(CompareFunction.isValid(CompareFunction.Always)      , true);
    expect(CompareFunction.isValid(CompareFunction.Equal)       , true);
    expect(CompareFunction.isValid(CompareFunction.Greater)     , true);
    expect(CompareFunction.isValid(CompareFunction.GreaterEqual), true);
    expect(CompareFunction.isValid(CompareFunction.Less)        , true);
    expect(CompareFunction.isValid(CompareFunction.LessEqual)   , true);
    expect(CompareFunction.isValid(CompareFunction.Fail)        , true);
    expect(CompareFunction.isValid(CompareFunction.NotEqual)    , true);

    expect(CullMode.isValid(-1), false);
  });
}

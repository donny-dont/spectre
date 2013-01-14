library cull_mode_test;

/*

  Copyright (C) 2012 John McCutchan <john@johnmccutchan.com>

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

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre.dart';
import 'dart:html';

void main() {
  test('values', () {
    expect(CullMode.None , 0);
    expect(CullMode.Front, WebGLRenderingContext.FRONT);
    expect(CullMode.Back , WebGLRenderingContext.BACK);
  });

  test('stringify', () {
    expect(CullMode.stringify(CullMode.None) , CullMode.NoneName);
    expect(CullMode.stringify(CullMode.Front), CullMode.FrontName);
    expect(CullMode.stringify(CullMode.Back) , CullMode.BackName);

    expect(() { CullMode.stringify(-1); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('parse', () {
    expect(CullMode.parse(CullMode.NoneName) , CullMode.None);
    expect(CullMode.parse(CullMode.FrontName), CullMode.Front);
    expect(CullMode.parse(CullMode.BackName) , CullMode.Back);

    expect(() { CullMode.parse('NotValid'); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('isValid', () {
    expect(CullMode.isValid(CullMode.None) , true);
    expect(CullMode.isValid(CullMode.Front), true);
    expect(CullMode.isValid(CullMode.Back) , true);

    expect(CullMode.isValid(-1), false);
  });
}

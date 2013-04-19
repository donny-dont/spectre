/*
  Copyright (C) 2013 John McCutchan

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

library texture_min_filter_test;

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre.dart';
import 'dart:html';
import 'dart:web_gl' as WebGL;

void main() {
  test('values', () {
    expect(TextureMinFilter.Linear, WebGL.LINEAR);
    expect(TextureMinFilter.Point , WebGL.NEAREST);
  });

  test('stringify', () {
    expect(TextureMinFilter.stringify(TextureMinFilter.Linear), 'TextureMinFilter.Linear');
    expect(TextureMinFilter.stringify(TextureMinFilter.Point) , 'TextureMinFilter.Point');

    expect(() { TextureMinFilter.stringify(-1); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('parse', () {
    expect(TextureMinFilter.parse('TextureMinFilter.Linear'), TextureMinFilter.Linear);
    expect(TextureMinFilter.parse('TextureMinFilter.Point') , TextureMinFilter.Point);

    expect(() { TextureMinFilter.parse('NotValid'); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('isValid', () {
    expect(TextureMinFilter.isValid(TextureMinFilter.Linear), true);
    expect(TextureMinFilter.isValid(TextureMinFilter.Point) , true);

    expect(TextureMinFilter.isValid(-1), false);
  });
}

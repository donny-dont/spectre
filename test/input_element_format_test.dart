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

library input_element_format_test;

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre.dart';
import 'dart:html';
import 'dart:web_gl' as WebGL;

void main() {
  test('values', () {
    expect(InputElementFormat.Scalar , 1);
    expect(InputElementFormat.Vector2, 2);
    expect(InputElementFormat.Vector3, 3);
    expect(InputElementFormat.Vector4, 4);
  });

  test('stringify', () {
    expect(InputElementFormat.stringify(InputElementFormat.Scalar) , 'InputElementFormat.Scalar');
    expect(InputElementFormat.stringify(InputElementFormat.Vector2), 'InputElementFormat.Vector2');
    expect(InputElementFormat.stringify(InputElementFormat.Vector3), 'InputElementFormat.Vector3');
    expect(InputElementFormat.stringify(InputElementFormat.Vector4), 'InputElementFormat.Vector4');

    expect(() { InputElementFormat.stringify(-1); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('parse', () {
    expect(InputElementFormat.parse('InputElementFormat.Scalar') , InputElementFormat.Scalar);
    expect(InputElementFormat.parse('InputElementFormat.Vector2'), InputElementFormat.Vector2);
    expect(InputElementFormat.parse('InputElementFormat.Vector3'), InputElementFormat.Vector3);
    expect(InputElementFormat.parse('InputElementFormat.Vector4'), InputElementFormat.Vector4);

    expect(() { InputElementFormat.parse('NotValid'); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('isValid', () {
    expect(InputElementFormat.isValid(InputElementFormat.Scalar) , true);
    expect(InputElementFormat.isValid(InputElementFormat.Vector2), true);
    expect(InputElementFormat.isValid(InputElementFormat.Vector3), true);
    expect(InputElementFormat.isValid(InputElementFormat.Vector4), true);

    expect(InputElementFormat.isValid(-1), false);
  });
}

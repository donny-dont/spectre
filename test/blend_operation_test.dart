library blend_operation_test;

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
    expect(BlendOperation.Add            , WebGLRenderingContext.FUNC_ADD);
    expect(BlendOperation.ReverseSubtract, WebGLRenderingContext.FUNC_REVERSE_SUBTRACT);
    expect(BlendOperation.Subtract       , WebGLRenderingContext.FUNC_SUBTRACT);
  });

  test('stringify', () {
    expect(BlendOperation.stringify(BlendOperation.Add)            , 'BlendOperation.Add');
    expect(BlendOperation.stringify(BlendOperation.ReverseSubtract), 'BlendOperation.ReverseSubtract');
    expect(BlendOperation.stringify(BlendOperation.Subtract)       , 'BlendOperation.Subtract');

    expect(() { BlendOperation.stringify(-1); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('parse', () {
    expect(BlendOperation.parse('BlendOperation.Add')            , BlendOperation.Add);
    expect(BlendOperation.parse('BlendOperation.ReverseSubtract'), BlendOperation.ReverseSubtract);
    expect(BlendOperation.parse('BlendOperation.Subtract')       , BlendOperation.Subtract);

    expect(() { BlendOperation.parse('NotValid'); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('isValid', () {
    expect(BlendOperation.isValid(BlendOperation.Add)            , true);
    expect(BlendOperation.isValid(BlendOperation.ReverseSubtract), true);
    expect(BlendOperation.isValid(BlendOperation.Subtract)       , true);

    expect(BlendOperation.isValid(-1), false);
  });
}

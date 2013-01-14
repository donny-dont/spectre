library front_face_test;

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
    expect(FrontFace.Clockwise       , WebGLRenderingContext.CW);
    expect(FrontFace.CounterClockwise, WebGLRenderingContext.CCW);
  });

  test('stringify', () {
    expect(FrontFace.stringify(FrontFace.Clockwise)       , FrontFace.ClockwiseName);
    expect(FrontFace.stringify(FrontFace.CounterClockwise), FrontFace.CounterClockwiseName);

    expect(() { FrontFace.stringify(-1); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('parse', () {
    expect(FrontFace.parse(FrontFace.ClockwiseName)       , FrontFace.Clockwise);
    expect(FrontFace.parse(FrontFace.CounterClockwiseName), FrontFace.CounterClockwise);

    expect(() { FrontFace.parse('NotValid'); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('isValid', () {
    expect(FrontFace.isValid(FrontFace.Clockwise)       , true);
    expect(FrontFace.isValid(FrontFace.CounterClockwise), true);

    expect(FrontFace.isValid(-1), false);
  });
}

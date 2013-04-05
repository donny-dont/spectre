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

library surface_format_test;

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre.dart';
import 'dart:html';
import 'dart:web_gl' as WebGL;

void main() {
  test('values', () {
    expect(SurfaceFormat.Rgba, WebGL.RGBA);
    expect(SurfaceFormat.Rgb , WebGL.RGB);

    // Values are taken directly from the extension specification
    expect(SurfaceFormat.Dxt1, 0x83F0);
    expect(SurfaceFormat.Dxt3, 0x83F2);
    expect(SurfaceFormat.Dxt5, 0x83F3);
  });

  test('stringify', () {
    expect(SurfaceFormat.stringify(SurfaceFormat.Rgba), 'SurfaceFormat.Rgba');
    expect(SurfaceFormat.stringify(SurfaceFormat.Rgb) , 'SurfaceFormat.Rgb');
    expect(SurfaceFormat.stringify(SurfaceFormat.Dxt1), 'SurfaceFormat.Dxt1');
    expect(SurfaceFormat.stringify(SurfaceFormat.Dxt3), 'SurfaceFormat.Dxt3');
    expect(SurfaceFormat.stringify(SurfaceFormat.Dxt5), 'SurfaceFormat.Dxt5');

    expect(() { SurfaceFormat.stringify(-1); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('parse', () {
    expect(SurfaceFormat.parse('SurfaceFormat.Rgba'), SurfaceFormat.Rgba);
    expect(SurfaceFormat.parse('SurfaceFormat.Rgb') , SurfaceFormat.Rgb);
    expect(SurfaceFormat.parse('SurfaceFormat.Dxt1'), SurfaceFormat.Dxt1);
    expect(SurfaceFormat.parse('SurfaceFormat.Dxt3'), SurfaceFormat.Dxt3);
    expect(SurfaceFormat.parse('SurfaceFormat.Dxt5'), SurfaceFormat.Dxt5);

    expect(() { SurfaceFormat.parse('NotValid'); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('isValid', () {
    expect(SurfaceFormat.isValid(SurfaceFormat.Rgba), true);
    expect(SurfaceFormat.isValid(SurfaceFormat.Rgb) , true);
    expect(SurfaceFormat.isValid(SurfaceFormat.Dxt1), true);
    expect(SurfaceFormat.isValid(SurfaceFormat.Dxt3), true);
    expect(SurfaceFormat.isValid(SurfaceFormat.Dxt5), true);

    expect(SurfaceFormat.isValid(-1), false);
  });
}

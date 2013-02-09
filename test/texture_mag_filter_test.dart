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

library texture_mag_filter_test;

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre.dart';
import 'dart:html';

void main() {
  test('values', () {
    expect(TextureMagFilter.Linear         , WebGLRenderingContext.LINEAR);
    expect(TextureMagFilter.Point          , WebGLRenderingContext.NEAREST);
    expect(TextureMagFilter.PointMipPoint  , WebGLRenderingContext.NEAREST_MIPMAP_NEAREST);
    expect(TextureMagFilter.PointMipLinear , WebGLRenderingContext.NEAREST_MIPMAP_LINEAR);
    expect(TextureMagFilter.LinearMipPoint , WebGLRenderingContext.LINEAR_MIPMAP_NEAREST);
    expect(TextureMagFilter.LinearMipLinear, WebGLRenderingContext.LINEAR_MIPMAP_LINEAR);
  });

  test('stringify', () {
    expect(TextureMagFilter.stringify(TextureMagFilter.Linear)         , 'TextureMagFilter.Linear');
    expect(TextureMagFilter.stringify(TextureMagFilter.Point)          , 'TextureMagFilter.Point');
    expect(TextureMagFilter.stringify(TextureMagFilter.PointMipPoint)  , 'TextureMagFilter.PointMipPoint');
    expect(TextureMagFilter.stringify(TextureMagFilter.PointMipLinear) , 'TextureMagFilter.PointMipLinear');
    expect(TextureMagFilter.stringify(TextureMagFilter.LinearMipPoint) , 'TextureMagFilter.LinearMipPoint');
    expect(TextureMagFilter.stringify(TextureMagFilter.LinearMipLinear), 'TextureMagFilter.LinearMipLinear');

    expect(() { TextureMagFilter.stringify(-1); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('parse', () {
    expect(TextureMagFilter.parse('TextureMagFilter.Linear')         , TextureMagFilter.Linear);
    expect(TextureMagFilter.parse('TextureMagFilter.Point')          , TextureMagFilter.Point);
    expect(TextureMagFilter.parse('TextureMagFilter.PointMipPoint')  , TextureMagFilter.PointMipPoint);
    expect(TextureMagFilter.parse('TextureMagFilter.PointMipLinear') , TextureMagFilter.PointMipLinear);
    expect(TextureMagFilter.parse('TextureMagFilter.LinearMipPoint') , TextureMagFilter.LinearMipPoint);
    expect(TextureMagFilter.parse('TextureMagFilter.LinearMipLinear'), TextureMagFilter.LinearMipLinear);

    expect(() { TextureMagFilter.parse('NotValid'); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('isValid', () {
    expect(TextureMagFilter.isValid(TextureMagFilter.Linear)         , true);
    expect(TextureMagFilter.isValid(TextureMagFilter.Point)          , true);
    expect(TextureMagFilter.isValid(TextureMagFilter.PointMipPoint)  , true);
    expect(TextureMagFilter.isValid(TextureMagFilter.PointMipLinear) , true);
    expect(TextureMagFilter.isValid(TextureMagFilter.LinearMipPoint) , true);
    expect(TextureMagFilter.isValid(TextureMagFilter.LinearMipLinear), true);

    expect(TextureMagFilter.isValid(-1), false);
  });
}

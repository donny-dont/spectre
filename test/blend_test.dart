library blend_test;

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
    expect(Blend.Zero                   , WebGLRenderingContext.ZERO);
    expect(Blend.One                    , WebGLRenderingContext.ONE);
    expect(Blend.SourceColor            , WebGLRenderingContext.SRC_COLOR);
    expect(Blend.InverseSourceColor     , WebGLRenderingContext.ONE_MINUS_SRC_COLOR);
    expect(Blend.SourceAlpha            , WebGLRenderingContext.SRC_ALPHA);
    expect(Blend.InverseSourceAlpha     , WebGLRenderingContext.ONE_MINUS_SRC_ALPHA);
    expect(Blend.DestinationAlpha       , WebGLRenderingContext.DST_ALPHA);
    expect(Blend.InverseDestinationAlpha, WebGLRenderingContext.ONE_MINUS_DST_ALPHA);
    expect(Blend.DestinationColor       , WebGLRenderingContext.DST_COLOR);
    expect(Blend.InverseDestinationColor, WebGLRenderingContext.ONE_MINUS_DST_COLOR);
    expect(Blend.SourceAlphaSaturation  , WebGLRenderingContext.SRC_ALPHA_SATURATE);
    expect(Blend.BlendFactor            , WebGLRenderingContext.CONSTANT_COLOR);
    expect(Blend.InverseBlendFactor     , WebGLRenderingContext.ONE_MINUS_CONSTANT_COLOR);
  });

  test('stringify', () {
    expect(Blend.stringify(Blend.Zero)                   , 'Blend.Zero');
    expect(Blend.stringify(Blend.One)                    , 'Blend.One');
    expect(Blend.stringify(Blend.SourceColor)            , 'Blend.SourceColor');
    expect(Blend.stringify(Blend.InverseSourceColor)     , 'Blend.InverseSourceColor');
    expect(Blend.stringify(Blend.SourceAlpha)            , 'Blend.SourceAlpha');
    expect(Blend.stringify(Blend.InverseSourceAlpha)     , 'Blend.InverseSourceAlpha');
    expect(Blend.stringify(Blend.DestinationAlpha)       , 'Blend.DestinationAlpha');
    expect(Blend.stringify(Blend.InverseDestinationAlpha), 'Blend.InverseDestinationAlpha');
    expect(Blend.stringify(Blend.DestinationColor)       , 'Blend.DestinationColor');
    expect(Blend.stringify(Blend.InverseDestinationColor), 'Blend.InverseDestinationColor');
    expect(Blend.stringify(Blend.SourceAlphaSaturation)  , 'Blend.SourceAlphaSaturation');
    expect(Blend.stringify(Blend.BlendFactor)            , 'Blend.BlendFactor');
    expect(Blend.stringify(Blend.InverseBlendFactor)     , 'Blend.InverseBlendFactor');

    expect(() { Blend.stringify(-1); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('parse', () {
    expect(Blend.parse('Blend.Zero')                   , Blend.Zero);
    expect(Blend.parse('Blend.One')                    , Blend.One);
    expect(Blend.parse('Blend.SourceColor')            , Blend.SourceColor);
    expect(Blend.parse('Blend.InverseSourceColor')     , Blend.InverseSourceColor);
    expect(Blend.parse('Blend.SourceAlpha')            , Blend.SourceAlpha);
    expect(Blend.parse('Blend.InverseSourceAlpha')     , Blend.InverseSourceAlpha);
    expect(Blend.parse('Blend.DestinationAlpha')       , Blend.DestinationAlpha);
    expect(Blend.parse('Blend.InverseDestinationAlpha'), Blend.InverseDestinationAlpha);
    expect(Blend.parse('Blend.DestinationColor')       , Blend.DestinationColor);
    expect(Blend.parse('Blend.InverseDestinationColor'), Blend.InverseDestinationColor);
    expect(Blend.parse('Blend.SourceAlphaSaturation')  , Blend.SourceAlphaSaturation);
    expect(Blend.parse('Blend.BlendFactor')            , Blend.BlendFactor);
    expect(Blend.parse('Blend.InverseBlendFactor')     , Blend.InverseBlendFactor);

    expect(() { Blend.parse('NotValid'); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('isValid', () {
    expect(Blend.isValid(Blend.Zero)                   , true);
    expect(Blend.isValid(Blend.One)                    , true);
    expect(Blend.isValid(Blend.SourceColor)            , true);
    expect(Blend.isValid(Blend.InverseSourceColor)     , true);
    expect(Blend.isValid(Blend.SourceAlpha)            , true);
    expect(Blend.isValid(Blend.InverseSourceAlpha)     , true);
    expect(Blend.isValid(Blend.DestinationAlpha)       , true);
    expect(Blend.isValid(Blend.InverseDestinationAlpha), true);
    expect(Blend.isValid(Blend.DestinationColor)       , true);
    expect(Blend.isValid(Blend.InverseDestinationColor), true);
    expect(Blend.isValid(Blend.SourceAlphaSaturation)  , true);
    expect(Blend.isValid(Blend.BlendFactor)            , true);
    expect(Blend.isValid(Blend.InverseBlendFactor)     , true);

    expect(Blend.isValid(-1), false);
  });
}

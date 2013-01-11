library blend_tests;

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

import "package:unittest/unittest.dart";
import 'package:unittest/html_config.dart';
import "package:spectre/spectre.dart";

void main() {
  test('stringify', () {
    expect(Blend.stringify(Blend.Zero)                   , Blend.ZeroName);
    expect(Blend.stringify(Blend.One)                    , Blend.OneName);
    expect(Blend.stringify(Blend.SourceColor)            , Blend.SourceColorName);
    expect(Blend.stringify(Blend.InverseSourceColor)     , Blend.InverseSourceColorName);
    expect(Blend.stringify(Blend.SourceAlpha)            , Blend.SourceAlphaName);
    expect(Blend.stringify(Blend.InverseSourceAlpha)     , Blend.InverseSourceAlphaName);
    expect(Blend.stringify(Blend.DestinationAlpha)       , Blend.DestinationAlphaName);
    expect(Blend.stringify(Blend.InverseDestinationAlpha), Blend.InverseDestinationAlphaName);
    expect(Blend.stringify(Blend.DestinationColor)       , Blend.DestinationColorName);
    expect(Blend.stringify(Blend.InverseDestinationColor), Blend.InverseDestinationColorName);
    expect(Blend.stringify(Blend.SourceAlphaSaturation)  , Blend.SourceAlphaSaturationName);
    expect(Blend.stringify(Blend.BlendFactor)            , Blend.BlendFactorName);
    expect(Blend.stringify(Blend.InverseBlendFactor)     , Blend.InverseBlendFactorName);
  });

  test('parse', () {
    expect(Blend.parse(Blend.ZeroName)                   , Blend.Zero);
    expect(Blend.parse(Blend.OneName)                    , Blend.One);
    expect(Blend.parse(Blend.SourceColorName)            , Blend.SourceColor);
    expect(Blend.parse(Blend.InverseSourceColorName)     , Blend.InverseSourceColor);
    expect(Blend.parse(Blend.SourceAlphaName)            , Blend.SourceAlpha);
    expect(Blend.parse(Blend.InverseSourceAlphaName)     , Blend.InverseSourceAlpha);
    expect(Blend.parse(Blend.DestinationAlphaName)       , Blend.DestinationAlpha);
    expect(Blend.parse(Blend.InverseDestinationAlphaName), Blend.InverseDestinationAlpha);
    expect(Blend.parse(Blend.DestinationColorName)       , Blend.DestinationColor);
    expect(Blend.parse(Blend.InverseDestinationColorName), Blend.InverseDestinationColor);
    expect(Blend.parse(Blend.SourceAlphaSaturationName)  , Blend.SourceAlphaSaturation);
    expect(Blend.parse(Blend.BlendFactorName)            , Blend.BlendFactor);
    expect(Blend.parse(Blend.InverseBlendFactorName)     , Blend.InverseBlendFactor);
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

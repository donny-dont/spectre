library blend_state_test;

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

void testBlendSetter(String testName, dynamic function) {
  BlendState blendState = new BlendState('BlendStateTest', null);

  test(testName, () {
    // Shouldn't throw
    expect(function(blendState, Blend.Zero)                   , Blend.Zero);
    expect(function(blendState, Blend.One)                    , Blend.One);
    expect(function(blendState, Blend.SourceColor)            , Blend.SourceColor);
    expect(function(blendState, Blend.InverseSourceColor)     , Blend.InverseSourceColor);
    expect(function(blendState, Blend.SourceAlpha)            , Blend.SourceAlpha);
    expect(function(blendState, Blend.InverseSourceAlpha)     , Blend.InverseSourceAlpha);
    expect(function(blendState, Blend.DestinationAlpha)       , Blend.DestinationAlpha);
    expect(function(blendState, Blend.InverseDestinationAlpha), Blend.InverseDestinationAlpha);
    expect(function(blendState, Blend.DestinationColor)       , Blend.DestinationColor);
    expect(function(blendState, Blend.InverseDestinationColor), Blend.InverseDestinationColor);
    expect(function(blendState, Blend.SourceAlphaSaturation)  , Blend.SourceAlphaSaturation);
    expect(function(blendState, Blend.BlendFactor)            , Blend.BlendFactor);
    expect(function(blendState, Blend.InverseBlendFactor)     , Blend.InverseBlendFactor);

    // Should throw
    expect(() { function(blendState, -1); }, throwsArgumentError);
  });
}

void testBlendOperationSetter(String testName, dynamic function) {
  BlendState blendState = new BlendState('BlendStateTest', null);

  test(testName, () {
    // Shouldn't throw
    expect(function(blendState, BlendOperation.Add)            , BlendOperation.Add);
    expect(function(blendState, BlendOperation.ReverseSubtract), BlendOperation.ReverseSubtract);
    expect(function(blendState, BlendOperation.Subtract)       , BlendOperation.Subtract);

    // Should throw
    expect(() { function(blendState, -1); }, throwsArgumentError);
  });
}

void testColorSetter(String testName, dynamic function) {
  BlendState blendState = new BlendState('BlendStateTest', null);

  test(testName, () {
    expect(function(blendState, 0.0), 0.0);
    expect(function(blendState, 0.5), 0.5);
    expect(function(blendState, 1.0), 1.0);

    expect(() { function(blendState, -0.00001); }, throwsArgumentError);
    expect(() { function(blendState,  1.00001); }, throwsArgumentError);
    expect(() { function(blendState, -1.00000); }, throwsArgumentError);
    expect(() { function(blendState,  2.00000); }, throwsArgumentError);

    expect(() { function(blendState, double.INFINITY); }         , throwsArgumentError);
    expect(() { function(blendState, double.NEGATIVE_INFINITY); }, throwsArgumentError);
    expect(() { function(blendState, double.NAN); }              , throwsArgumentError);
  });
}

void main() {
  // Test enumeration setters
  testBlendOperationSetter('alphaBlendOperation', (blendState, value) {
    blendState.alphaBlendOperation = value;
    return blendState.alphaBlendOperation;
  });

  testBlendSetter('alphaDestinationBlend', (blendState, value) {
    blendState.alphaDestinationBlend = value;
    return blendState.alphaDestinationBlend;
  });

  testBlendSetter('alphaSourceBlend', (blendState, value) {
    blendState.alphaSourceBlend = value;
    return blendState.alphaSourceBlend;
  });

  testBlendOperationSetter('colorBlendOperation', (blendState, value) {
    blendState.colorBlendOperation = value;
    return blendState.colorBlendOperation;
  });

  testBlendSetter('colorDestinationBlend', (blendState, value) {
    blendState.colorDestinationBlend = value;
    return blendState.colorDestinationBlend;
  });

  testBlendSetter('colorSourceBlend', (blendState, value) {
    blendState.colorSourceBlend = value;
    return blendState.colorSourceBlend;
  });

  // Test color setters
  testColorSetter('blendFactorRed', (blendState, value) {
    blendState.blendFactorRed = value;
    return blendState.blendFactorRed;
  });

  testColorSetter('blendFactorGreen', (blendState, value) {
    blendState.blendFactorGreen = value;
    return blendState.blendFactorGreen;
  });

  testColorSetter('blendFactorBlue', (blendState, value) {
    blendState.blendFactorBlue = value;
    return blendState.blendFactorBlue;
  });

  testColorSetter('blendFactorRed', (blendState, value) {
    blendState.blendFactorAlpha = value;
    return blendState.blendFactorAlpha;
  });

  // Equality
  test('equality', () {
    BlendState blendState0 = new BlendState('BlendState0', null);
    BlendState blendState1 = new BlendState('BlendState1', null);

    expect(blendState0, blendState1);
  });

  // Serialization
  test('serialization', () {
    BlendState original = new BlendState('BlendStateOriginal', null);

    BlendState copy = new BlendState('BlendStateCopy', null);
    copy.alphaBlendOperation = BlendOperation.ReverseSubtract;
    copy.alphaDestinationBlend = Blend.BlendFactor;
    copy.alphaSourceBlend = Blend.BlendFactor;
    copy.colorBlendOperation = BlendOperation.ReverseSubtract;
    copy.colorDestinationBlend = Blend.InverseBlendFactor;
    copy.colorSourceBlend = Blend.InverseBlendFactor;
    copy.blendFactorRed   = 0.0;
    copy.blendFactorGreen = 0.0;
    copy.blendFactorBlue  = 0.0;
    copy.blendFactorAlpha = 0.0;
    copy.writeRenderTargetRed   = false;
    copy.writeRenderTargetGreen = false;
    copy.writeRenderTargetBlue  = false;
    copy.writeRenderTargetAlpha = false;

    Map json = original.toJson();
    copy.fromJson(json);

    expect(original, copy);
  });
}

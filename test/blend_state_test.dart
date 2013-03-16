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

library blend_state_test;

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre.dart';
import 'device_child_equality.dart';
import 'mock_graphics_device.dart';

GraphicsDevice _graphicsDevice;

void testBlendSetter(String testName, dynamic function) {
  BlendState blendState = new BlendState('BlendState_$testName', _graphicsDevice);

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
  BlendState blendState = new BlendState('BlendState_$testName', _graphicsDevice);

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
  BlendState blendState = new BlendState('BlendState_$testName', _graphicsDevice);

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

void testConstructor(BlendState blendState, bool enabled, int alphaDestinationBlend, int alphaSourceBlend, int colorDestinationBlend, int colorSourceBlend) {
  expect(blendState.enabled, enabled);

  expect(blendState.blendFactorRed  , 1.0);
  expect(blendState.blendFactorGreen, 1.0);
  expect(blendState.blendFactorBlue , 1.0);
  expect(blendState.blendFactorAlpha, 1.0);

  expect(blendState.alphaBlendOperation  , BlendOperation.Add);
  expect(blendState.alphaDestinationBlend, alphaDestinationBlend);
  expect(blendState.alphaSourceBlend     , alphaSourceBlend);
  expect(blendState.colorBlendOperation  , BlendOperation.Add);
  expect(blendState.colorDestinationBlend, colorDestinationBlend);
  expect(blendState.colorSourceBlend     , colorSourceBlend);

  expect(blendState.writeRenderTargetRed  , true);
  expect(blendState.writeRenderTargetGreen, true);
  expect(blendState.writeRenderTargetBlue , true);
  expect(blendState.writeRenderTargetAlpha, true);
}

void main() {
  _graphicsDevice = new MockGraphicsDevice.useMock();

  // Construction
  test('construction', () {
    // Default constructor
    BlendState defaultState = new BlendState('BlendStateDefault', _graphicsDevice);
    testConstructor(defaultState, true, Blend.One, Blend.One, Blend.One, Blend.One);
    expect(() { BlendState constructWithNull = new BlendState('BlendStateNull', null); }, throwsArgumentError);

    // BlendState.additive
    BlendState additive = new BlendState.additive('BlendStateAdditive', _graphicsDevice);
    testConstructor(additive, true, Blend.One, Blend.SourceAlpha, Blend.One, Blend.SourceAlpha);
    expect(() { BlendState constructWithNull = new BlendState.additive('BlendStateNull', null); }, throwsArgumentError);

    // BlendState.alphaBlend
    BlendState alphaBlend = new BlendState.alphaBlend('BlendStateAlphaBlend', _graphicsDevice);
    testConstructor(alphaBlend, true, Blend.InverseSourceAlpha, Blend.One, Blend.InverseSourceAlpha, Blend.One);
    expect(() { BlendState constructWithNull = new BlendState.alphaBlend('BlendStateNull', null); }, throwsArgumentError);

    // BlendState.nonPremultiplied
    BlendState nonPremultiplied = new BlendState.nonPremultiplied('BlendStateNonPremultiplied', _graphicsDevice);
    testConstructor(nonPremultiplied, true, Blend.InverseSourceAlpha, Blend.SourceAlpha, Blend.InverseSourceAlpha, Blend.SourceAlpha);
    expect(() { BlendState constructWithNull = new BlendState.nonPremultiplied('BlendStateNull', null); }, throwsArgumentError);

    // Blend.opaque
    BlendState opaque = new BlendState.opaque('BlendStateOpaque', _graphicsDevice);
    testConstructor(opaque, false, Blend.Zero, Blend.One, Blend.Zero, Blend.One);
    expect(() { BlendState constructWithNull = new BlendState.opaque('BlendStateNull', null); }, throwsArgumentError);
  });

  // Enumeration setters
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

  // Color setters
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
    BlendState blendState0 = new BlendState('BlendState0', _graphicsDevice);
    BlendState blendState1 = new BlendState('BlendState1', _graphicsDevice);

    // Check equality
    expect(blendStateEqual(blendState0, blendState0), true);
    expect(blendStateEqual(blendState0, blendState1), true);

    // Check inequality
    blendState0.alphaBlendOperation = BlendOperation.ReverseSubtract;
    expect(blendStateEqual(blendState0, blendState1), false);
    blendState1.alphaBlendOperation = blendState0.alphaBlendOperation;
    expect(blendStateEqual(blendState0, blendState1), true);

    blendState0.alphaDestinationBlend = Blend.BlendFactor;
    expect(blendStateEqual(blendState0, blendState1), false);
    blendState1.alphaDestinationBlend = blendState0.alphaDestinationBlend;
    expect(blendStateEqual(blendState0, blendState1), true);

    blendState0.alphaSourceBlend = Blend.BlendFactor;
    expect(blendStateEqual(blendState0, blendState1), false);
    blendState1.alphaSourceBlend = blendState0.alphaSourceBlend;
    expect(blendStateEqual(blendState0, blendState1), true);

    blendState0.colorBlendOperation = BlendOperation.ReverseSubtract;
    expect(blendStateEqual(blendState0, blendState1), false);
    blendState1.colorBlendOperation = blendState0.colorBlendOperation;
    expect(blendStateEqual(blendState0, blendState1), true);

    blendState0.colorDestinationBlend = Blend.BlendFactor;
    expect(blendStateEqual(blendState0, blendState1), false);
    blendState1.colorDestinationBlend = blendState0.colorDestinationBlend;
    expect(blendStateEqual(blendState0, blendState1), true);

    blendState0.colorSourceBlend = Blend.BlendFactor;
    expect(blendStateEqual(blendState0, blendState1), false);
    blendState1.colorSourceBlend = blendState0.colorSourceBlend;
    expect(blendStateEqual(blendState0, blendState1), true);

    blendState0.blendFactorRed = 0.0;
    expect(blendStateEqual(blendState0, blendState1), false);
    blendState1.blendFactorRed = blendState0.blendFactorRed;
    expect(blendStateEqual(blendState0, blendState1), true);

    blendState0.blendFactorGreen = 0.0;
    expect(blendStateEqual(blendState0, blendState1), false);
    blendState1.blendFactorGreen = blendState0.blendFactorGreen;
    expect(blendStateEqual(blendState0, blendState1), true);

    blendState0.blendFactorBlue = 0.0;
    expect(blendStateEqual(blendState0, blendState1), false);
    blendState1.blendFactorBlue = blendState0.blendFactorBlue;
    expect(blendStateEqual(blendState0, blendState1), true);

    blendState0.blendFactorAlpha = 0.0;
    expect(blendStateEqual(blendState0, blendState1), false);
    blendState1.blendFactorAlpha = blendState0.blendFactorAlpha;
    expect(blendStateEqual(blendState0, blendState1), true);

    blendState0.writeRenderTargetRed = false;
    expect(blendStateEqual(blendState0, blendState1), false);
    blendState1.writeRenderTargetRed = blendState0.writeRenderTargetRed;
    expect(blendStateEqual(blendState0, blendState1), true);

    blendState0.writeRenderTargetGreen = false;
    expect(blendStateEqual(blendState0, blendState1), false);
    blendState1.writeRenderTargetGreen = blendState0.writeRenderTargetGreen;
    expect(blendStateEqual(blendState0, blendState1), true);

    blendState0.writeRenderTargetBlue = false;
    expect(blendStateEqual(blendState0, blendState1), false);
    blendState1.writeRenderTargetBlue = blendState0.writeRenderTargetBlue;
    expect(blendStateEqual(blendState0, blendState1), true);

    blendState0.writeRenderTargetAlpha = false;
    expect(blendStateEqual(blendState0, blendState1), false);
    blendState1.writeRenderTargetAlpha = blendState0.writeRenderTargetAlpha;
    expect(blendStateEqual(blendState0, blendState1), true);
  });

  // Serialization
  test('serialization', () {
    BlendState original = new BlendState('BlendStateOriginal', _graphicsDevice);

    BlendState copy = new BlendState('BlendStateCopy', _graphicsDevice);
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

    expect(blendStateEqual(original, copy), true);
  });
}

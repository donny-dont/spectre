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

library sampler_state_test;

import "package:unittest/unittest.dart";
import "package:spectre/spectre.dart";

void testConstructor(SamplerState samplerState, int addressU, int addressV, int minFilter, int magFilter, int maxAnisotropy) {
  expect(samplerState.addressU, addressU);
  expect(samplerState.addressV, addressV);

  expect(samplerState.minFilter, minFilter);
  expect(samplerState.magFilter, magFilter);

  expect(samplerState.maxAnisotropy, maxAnisotropy);
}

void testTextureAddressModeSetter(String testName, dynamic function) {
  SamplerState samplerState = new SamplerState('SamplerStateTest', null);

  test(testName, () {
    // Shouldn't throw
    expect(function(samplerState, TextureAddressMode.Clamp) , TextureAddressMode.Clamp);
    expect(function(samplerState, TextureAddressMode.Mirror), TextureAddressMode.Mirror);
    expect(function(samplerState, TextureAddressMode.Wrap)  , TextureAddressMode.Wrap);

    // Should throw
    expect(() { function(samplerState, -1); }, throwsArgumentError);
  });
}

void main() {
  // Construction
  test('construction', () {
    // Default constructor
    SamplerState defaultState = new SamplerState('SamplerStateDefault', null);
    testConstructor(defaultState, TextureAddressMode.Wrap, TextureAddressMode.Wrap, TextureMinFilter.Linear, TextureMagFilter.Linear, 1);

    // SamplerState.anisotropicClamp
    SamplerState anisotropicClamp = new SamplerState.anisotropicClamp('SamplerStateAnisotropicClamp', null);
    testConstructor(anisotropicClamp, TextureAddressMode.Clamp, TextureAddressMode.Clamp, TextureMinFilter.Linear, TextureMagFilter.Linear, 4);

    // SamplerState.anisotropicClamp
    SamplerState anisotropicWrap = new SamplerState.anisotropicWrap('SamplerStateAnisotropicWrap', null);
    testConstructor(anisotropicWrap, TextureAddressMode.Wrap, TextureAddressMode.Wrap, TextureMinFilter.Linear, TextureMagFilter.Linear, 4);

    // SamplerState.linearClamp
    SamplerState linearClamp = new SamplerState.linearClamp('SamplerStateLinearClamp', null);
    testConstructor(linearClamp, TextureAddressMode.Clamp, TextureAddressMode.Clamp, TextureMinFilter.Linear, TextureMagFilter.Linear, 1);

    // SamplerState.linearWrap
    SamplerState linearWrap = new SamplerState.linearWrap('SamplerStateLinearWrap', null);
    testConstructor(linearWrap, TextureAddressMode.Wrap, TextureAddressMode.Wrap, TextureMinFilter.Linear, TextureMagFilter.Linear, 1);

    // SamplerState.pointClamp
    SamplerState pointClamp = new SamplerState.pointClamp('SamplerStatePointClamp', null);
    testConstructor(pointClamp, TextureAddressMode.Clamp, TextureAddressMode.Clamp, TextureMinFilter.Point, TextureMagFilter.Point, 1);

    // SamplerState.pointWrap
    SamplerState pointWrap = new SamplerState.pointWrap('SamplerStatePointWrap', null);
    testConstructor(pointWrap, TextureAddressMode.Wrap, TextureAddressMode.Wrap, TextureMinFilter.Point, TextureMagFilter.Point, 1);
  });

  // Enumeration setters
  testTextureAddressModeSetter('addressU', (samplerState, value) {
    samplerState.addressU = value;
    return samplerState.addressU;
  });

  testTextureAddressModeSetter('addressV', (samplerState, value) {
    samplerState.addressV = value;
    return samplerState.addressV;
  });

  test('minFilter', () {
    SamplerState samplerState = new SamplerState('SamplerStateTest', null);

    dynamic function = (samplerState, value) {
      samplerState.minFilter = value;
      return samplerState.minFilter;
    };

    // Shouldn't throw
    expect(function(samplerState, TextureMinFilter.Linear), TextureMinFilter.Linear);
    expect(function(samplerState, TextureMinFilter.Point) , TextureMinFilter.Point);

    // Should throw
    expect(() { function(samplerState, -1); }, throwsArgumentError);
  });

  test('magFilter', () {
    SamplerState samplerState = new SamplerState('SamplerStateTest', null);

    dynamic function = (samplerState, value) {
      samplerState.magFilter = value;
      return samplerState.magFilter;
    };

    // Shouldn't throw
    expect(function(samplerState, TextureMagFilter.Linear)         , TextureMagFilter.Linear);
    expect(function(samplerState, TextureMagFilter.Point)          , TextureMagFilter.Point);
    expect(function(samplerState, TextureMagFilter.PointMipPoint)  , TextureMagFilter.PointMipPoint);
    expect(function(samplerState, TextureMagFilter.PointMipLinear) , TextureMagFilter.PointMipLinear);
    expect(function(samplerState, TextureMagFilter.LinearMipPoint) , TextureMagFilter.LinearMipPoint);
    expect(function(samplerState, TextureMagFilter.LinearMipLinear), TextureMagFilter.LinearMipLinear);

    // Should throw
    expect(() { function(samplerState, -1); }, throwsArgumentError);
  });

  test('maxAnisotropy', () {
    SamplerState samplerState = new SamplerState('SamplerStateTest', null);

    dynamic function = (samplerState, value) {
      samplerState.maxAnisotropy = value;
      return samplerState.maxAnisotropy;
    };

    // Shouldn't throw
    expect(function(samplerState, 1), 1);
    expect(function(samplerState, 4), 4);

    // Should clamp
    // \todo ADD

    // Should throw
    expect(() { function(samplerState,  0); }, throwsArgumentError);
    expect(() { function(samplerState, -1); }, throwsArgumentError);
  });

  // Equality
  test('equality', () {
    // TODO: Fix equality testing.
    SamplerState samplerState0 = new SamplerState('SamplerState0', null);
    SamplerState samplerState1 = new SamplerState('SamplerState1', null);

    // Check identical
    expect(samplerState0, samplerState0);
    expect(samplerState0, samplerState1);

    // Check inequality
    samplerState0.addressU = TextureAddressMode.Clamp;
    expect(samplerState0 == samplerState1, false);
    samplerState1.addressU = samplerState0.addressU;

    samplerState0.addressV = TextureAddressMode.Clamp;
    expect(samplerState0 == samplerState1, false);
    samplerState1.addressV = samplerState0.addressV;

    samplerState0.minFilter = TextureMinFilter.Point;
    expect(samplerState0 == samplerState1, false);
    samplerState1.minFilter = samplerState0.minFilter;

    samplerState0.magFilter = TextureMagFilter.LinearMipLinear;
    expect(samplerState0 == samplerState1, false);
    samplerState1.magFilter = samplerState0.magFilter;

    samplerState0.maxAnisotropy = 4;
    expect(samplerState0 == samplerState1, false);
    samplerState1.maxAnisotropy = samplerState0.maxAnisotropy;
  });

  // Serialization
  test('serialization', () {
    SamplerState original = new SamplerState('SamplerStateOriginal', null);

    SamplerState copy = new SamplerState('SamplerStateCopy', null);
    copy.addressU = TextureAddressMode.Clamp;
    copy.addressV = TextureAddressMode.Clamp;
    copy.minFilter = TextureMinFilter.Point;
    copy.magFilter = TextureMagFilter.LinearMipLinear;
    copy.maxAnisotropy = 4;

    Map json = original.toJson();
    copy.fromJson(json);

    // TODO: Fix equality testing.
    expect(original, copy);
  });
}

/*
  Copyright (C) 2013 John McCutchan

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

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre.dart';
import 'device_child_equality.dart';
import 'mock_graphics_device.dart';

GraphicsDevice _graphicsDevice;

void testConstructor(SamplerState samplerState, int addressU, int addressV, int minFilter, int magFilter, int maxAnisotropy) {
  expect(samplerState.addressU, addressU);
  expect(samplerState.addressV, addressV);

  expect(samplerState.minFilter, minFilter);
  expect(samplerState.magFilter, magFilter);

  expect(samplerState.maxAnisotropy, maxAnisotropy);
}

void testTextureAddressModeSetter(String testName, dynamic function) {
  SamplerState samplerState = new SamplerState('SamplerState_$testName', _graphicsDevice);

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
  _graphicsDevice = new MockGraphicsDevice.useMock();

  // Construction
  test('construction', () {
    // Default constructor
    SamplerState defaultState = new SamplerState('SamplerStateDefault', _graphicsDevice);
    testConstructor(defaultState, TextureAddressMode.Wrap, TextureAddressMode.Wrap, TextureMinFilter.Linear, TextureMagFilter.Linear, 1);
    expect(() { SamplerState constructWithNull = new SamplerState('SamplerStateNull', null); }, throwsArgumentError);

    // SamplerState.anisotropicClamp
    SamplerState anisotropicClamp = new SamplerState.anisotropicClamp('SamplerStateAnisotropicClamp', _graphicsDevice);
    testConstructor(anisotropicClamp, TextureAddressMode.Clamp, TextureAddressMode.Clamp, TextureMinFilter.Linear, TextureMagFilter.Linear, 4);
    expect(() { SamplerState constructWithNull = new SamplerState.anisotropicClamp('SamplerStateNull', null); }, throwsArgumentError);

    // SamplerState.anisotropicClamp
    SamplerState anisotropicWrap = new SamplerState.anisotropicWrap('SamplerStateAnisotropicWrap', _graphicsDevice);
    testConstructor(anisotropicWrap, TextureAddressMode.Wrap, TextureAddressMode.Wrap, TextureMinFilter.Linear, TextureMagFilter.Linear, 4);
    expect(() { SamplerState constructWithNull = new SamplerState.anisotropicWrap('SamplerStateNull', null); }, throwsArgumentError);

    // SamplerState.linearClamp
    SamplerState linearClamp = new SamplerState.linearClamp('SamplerStateLinearClamp', _graphicsDevice);
    testConstructor(linearClamp, TextureAddressMode.Clamp, TextureAddressMode.Clamp, TextureMinFilter.Linear, TextureMagFilter.Linear, 1);
    expect(() { SamplerState constructWithNull = new SamplerState.linearClamp('SamplerStateNull', null); }, throwsArgumentError);

    // SamplerState.linearWrap
    SamplerState linearWrap = new SamplerState.linearWrap('SamplerStateLinearWrap', _graphicsDevice);
    testConstructor(linearWrap, TextureAddressMode.Wrap, TextureAddressMode.Wrap, TextureMinFilter.Linear, TextureMagFilter.Linear, 1);
    expect(() { SamplerState constructWithNull = new SamplerState.linearWrap('SamplerStateNull', null); }, throwsArgumentError);

    // SamplerState.pointClamp
    SamplerState pointClamp = new SamplerState.pointClamp('SamplerStatePointClamp', _graphicsDevice);
    testConstructor(pointClamp, TextureAddressMode.Clamp, TextureAddressMode.Clamp, TextureMinFilter.Point, TextureMagFilter.Point, 1);
    expect(() { SamplerState constructWithNull = new SamplerState('SamplerStateNull', null); }, throwsArgumentError);

    // SamplerState.pointWrap
    SamplerState pointWrap = new SamplerState.pointWrap('SamplerStatePointWrap', _graphicsDevice);
    testConstructor(pointWrap, TextureAddressMode.Wrap, TextureAddressMode.Wrap, TextureMinFilter.Point, TextureMagFilter.Point, 1);
    expect(() { SamplerState constructWithNull = new SamplerState.pointWrap('SamplerStateNull', null); }, throwsArgumentError);
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
    SamplerState samplerState = new SamplerState('SamplerStateTest', _graphicsDevice);

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
    SamplerState samplerState = new SamplerState('SamplerStateTest', _graphicsDevice);

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
    SamplerState samplerState = new SamplerState('SamplerStateTest', _graphicsDevice);

    dynamic function = (samplerState, value) {
      samplerState.maxAnisotropy = value;
      return samplerState.maxAnisotropy;
    };

    // Shouldn't throw
    expect(function(samplerState, 1.0), 1.0);
    expect(function(samplerState, 4.0), 4.0);

    // Should clamp
    expect(function(samplerState, 1024.0), _graphicsDevice.capabilities.maxAnisotropyLevel);

    // Should throw
    expect(() { function(samplerState,  0.0); }, throwsArgumentError);
    expect(() { function(samplerState, -1.0); }, throwsArgumentError);
  });

  // Equality
  test('equality', () {
    SamplerState samplerState0 = new SamplerState('SamplerState0', _graphicsDevice);
    SamplerState samplerState1 = new SamplerState('SamplerState1', _graphicsDevice);

    // Check identical
    expect(samplerStateEqual(samplerState0, samplerState0), true);
    expect(samplerStateEqual(samplerState0, samplerState1), true);

    // Check inequality
    samplerState0.addressU = TextureAddressMode.Clamp;
    expect(samplerStateEqual(samplerState0, samplerState1), false);
    samplerState1.addressU = samplerState0.addressU;
    expect(samplerStateEqual(samplerState0, samplerState1), true);

    samplerState0.addressV = TextureAddressMode.Clamp;
    expect(samplerStateEqual(samplerState0, samplerState1), false);
    samplerState1.addressV = samplerState0.addressV;
    expect(samplerStateEqual(samplerState0, samplerState1), true);

    samplerState0.minFilter = TextureMinFilter.Point;
    expect(samplerStateEqual(samplerState0, samplerState1), false);
    samplerState1.minFilter = samplerState0.minFilter;
    expect(samplerStateEqual(samplerState0, samplerState1), true);

    samplerState0.magFilter = TextureMagFilter.LinearMipLinear;
    expect(samplerStateEqual(samplerState0, samplerState1), false);
    samplerState1.magFilter = samplerState0.magFilter;
    expect(samplerStateEqual(samplerState0, samplerState1), true);

    samplerState0.maxAnisotropy = 4.0;
    expect(samplerStateEqual(samplerState0, samplerState1), false);
    samplerState1.maxAnisotropy = samplerState0.maxAnisotropy;
    expect(samplerStateEqual(samplerState0, samplerState1), true);
  });

  // Serialization
  test('serialization', () {
    SamplerState original = new SamplerState('SamplerStateOriginal', _graphicsDevice);

    SamplerState copy = new SamplerState('SamplerStateCopy', _graphicsDevice);
    copy.addressU = TextureAddressMode.Clamp;
    copy.addressV = TextureAddressMode.Clamp;
    copy.minFilter = TextureMinFilter.Point;
    copy.magFilter = TextureMagFilter.LinearMipLinear;
    copy.maxAnisotropy = 4.0;

    Map json = original.toJson();
    copy.fromJson(json);

    expect(samplerStateEqual(original, copy), true);
  });
}

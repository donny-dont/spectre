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

library depth_state_test;

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre.dart';
import 'device_child_equality.dart';
import 'mock_graphics_device.dart';

GraphicsDevice _graphicsDevice;

void testCompareFunctionSetter(String testName, dynamic function) {
  DepthState depthState = new DepthState('DepthStateTest', _graphicsDevice);

  test(testName, () {
    // Shouldn't throw
    expect(function(depthState, CompareFunction.Always)      , CompareFunction.Always);
    expect(function(depthState, CompareFunction.Equal)       , CompareFunction.Equal);
    expect(function(depthState, CompareFunction.Greater)     , CompareFunction.Greater);
    expect(function(depthState, CompareFunction.GreaterEqual), CompareFunction.GreaterEqual);
    expect(function(depthState, CompareFunction.Less)        , CompareFunction.Less);
    expect(function(depthState, CompareFunction.LessEqual)   , CompareFunction.LessEqual);
    expect(function(depthState, CompareFunction.Fail)        , CompareFunction.Fail);
    expect(function(depthState, CompareFunction.NotEqual)    , CompareFunction.NotEqual);
    // Should throw
    expect(() { function(depthState, -1); }, throwsArgumentError);
  });
}

void testConstructor(DepthState depthState, bool depthBufferEnabled, bool depthBufferWriteEnabled) {
  expect(depthState.depthBufferEnabled     , depthBufferEnabled);
  expect(depthState.depthBufferWriteEnabled, depthBufferWriteEnabled);
  expect(depthState.depthBufferFunction    , CompareFunction.LessEqual);
}

void main() {
  _graphicsDevice = new MockGraphicsDevice.useMock();

  // Construction
  test('construction', () {
    // Default constructor
    DepthState defaultState = new DepthState('DepthStateDefault', _graphicsDevice);
    testConstructor(defaultState, true, false);

    // DepthState.depthWrite
    DepthState depthWrite = new DepthState.depthWrite('DepthStateDepthWrite', _graphicsDevice);
    testConstructor(depthWrite, true, true);

    // DepthState.depthRead
    DepthState depthRead = new DepthState.depthRead('DepthStateDepthRead', _graphicsDevice);
    testConstructor(depthRead, true, false);

    // DepthState.depthRead
    DepthState none = new DepthState.none('DepthStateNone', _graphicsDevice);
    testConstructor(none, false, false);
  });

  // Enumeration setters
  testCompareFunctionSetter('depthBufferFunction', (depthState, value) {
    depthState.depthBufferFunction = value;
    return depthState.depthBufferFunction;
  });

  // Equality
  test('equality', () {
    DepthState depthState0 = new DepthState('DepthState0', _graphicsDevice);
    DepthState depthState1 = new DepthState('DepthState1', _graphicsDevice);

    // Check equality
    expect(depthStateEqual(depthState0, depthState0), true);
    expect(depthStateEqual(depthState0, depthState1), true);

    // Check inequality
    depthState0.depthBufferEnabled = false;
    expect(depthStateEqual(depthState0, depthState1), false);
    depthState1.depthBufferEnabled = depthState0.depthBufferEnabled;
    expect(depthStateEqual(depthState0, depthState1), true);

    depthState0.depthBufferWriteEnabled = true;
    expect(depthStateEqual(depthState0, depthState1), false);
    depthState1.depthBufferWriteEnabled = depthState0.depthBufferWriteEnabled;
    expect(depthStateEqual(depthState0, depthState1), true);

    depthState0.depthBufferFunction = CompareFunction.Always;
    expect(depthStateEqual(depthState0, depthState1), false);
    depthState1.depthBufferFunction = depthState0.depthBufferFunction;
    expect(depthStateEqual(depthState0, depthState1), true);
  });

  // Serialization
  test('serialization', () {
    DepthState original = new DepthState('DepthStateOriginal', _graphicsDevice);

    DepthState copy = new DepthState('DepthStateCopy', _graphicsDevice);
    copy.depthBufferEnabled = false;
    copy.depthBufferWriteEnabled = true;
    copy.depthBufferFunction = CompareFunction.Always;

    Map json = original.toJson();
    copy.fromJson(json);

    expect(depthStateEqual(original, copy), true);
  });
}

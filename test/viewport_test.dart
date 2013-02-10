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

library viewport_test;

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre.dart';
import 'device_child_equality.dart';
import 'mock_graphics_device.dart';

GraphicsDevice _graphicsDevice;

void testDimensionSetter(String testName, dynamic function) {
  Viewport viewport = new Viewport('Viewport_$testName', _graphicsDevice);

  test(testName, () {
    expect(function(viewport,    0), 0);
    expect(function(viewport, 1024), 1024);

    expect(() { function(viewport, -1); }, throwsArgumentError);
  });
}

void testDepthRangeSetter(String testName, dynamic function) {
  Viewport viewport = new Viewport('Viewport_$testName', _graphicsDevice);

  test(testName, () {
    expect(function(viewport, 0.0), 0.0);
    expect(function(viewport, 0.5), 0.5);
    expect(function(viewport, 1.0), 1.0);

    expect(() { function(viewport, -0.00001); }, throwsArgumentError);
    expect(() { function(viewport,  1.00001); }, throwsArgumentError);
    expect(() { function(viewport, -1.00000); }, throwsArgumentError);
    expect(() { function(viewport,  2.00000); }, throwsArgumentError);

    expect(() { function(viewport, double.INFINITY); }         , throwsArgumentError);
    expect(() { function(viewport, double.NEGATIVE_INFINITY); }, throwsArgumentError);
    expect(() { function(viewport, double.NAN); }              , throwsArgumentError);
  });
}

void testConstructor(Viewport viewport, int x, int y, int width, int height) {
  expect(viewport.x, x);
  expect(viewport.y, y);

  expect(viewport.width , width);
  expect(viewport.height, height);

  expect(viewport.minDepth, 0.0);
  expect(viewport.maxDepth, 1.0);
}

void main() {
  _graphicsDevice = new MockGraphicsDevice.useMock();

  // Construction
  test('construction', () {
    // Default constructor
    Viewport defaultViewport = new Viewport('ViewportDefault', _graphicsDevice);
    testConstructor(defaultViewport, 0, 0, 640, 480);

    // Viewport.bounds
    Viewport bounds = new Viewport.bounds('ViewportBounds', _graphicsDevice, 160, 120, 320, 240);
    testConstructor(bounds, 160, 120, 320, 240);
  });

  // Dimension setters
  testDimensionSetter('width', (viewport, value) {
    viewport.width = value;
    return viewport.width;
  });

  testDimensionSetter('height', (viewport, value) {
    viewport.height = value;
    return viewport.height;
  });

  // Range setters
  testDepthRangeSetter('minDepth', (viewport, value) {
    viewport.minDepth = value;
    return viewport.minDepth;
  });

  testDepthRangeSetter('maxDepth', (viewport, value) {
    viewport.maxDepth = value;
    return viewport.maxDepth;
  });

  // Equality
  test('equality', () {
    Viewport viewport0 = new Viewport('Viewport0', _graphicsDevice);
    Viewport viewport1 = new Viewport('Viewport1', _graphicsDevice);

    // Check identical
    expect(viewportEqual(viewport0, viewport0), true);
    expect(viewportEqual(viewport0, viewport1), true);

    // Check inequality
    viewport0.x = 160;
    expect(viewportEqual(viewport0, viewport1), false);
    viewport1.x = viewport0.x;
    expect(viewportEqual(viewport0, viewport1), true);

    viewport0.y = 120;
    expect(viewportEqual(viewport0, viewport1), false);
    viewport1.y = viewport0.y;
    expect(viewportEqual(viewport0, viewport1), true);

    viewport0.width = 320;
    expect(viewportEqual(viewport0, viewport1), false);
    viewport1.width = viewport0.width;
    expect(viewportEqual(viewport0, viewport1), true);

    viewport0.height = 240;
    expect(viewportEqual(viewport0, viewport1), false);
    viewport1.height = viewport0.height;
    expect(viewportEqual(viewport0, viewport1), true);

    viewport0.minDepth = 0.1;
    expect(viewportEqual(viewport0, viewport1), false);
    viewport1.minDepth = viewport0.minDepth;
    expect(viewportEqual(viewport0, viewport1), true);

    viewport0.maxDepth = 0.9;
    expect(viewportEqual(viewport0, viewport1), false);
    viewport1.maxDepth = viewport0.maxDepth;
    expect(viewportEqual(viewport0, viewport1), true);
  });

  // Serialization
  test('serialization', () {
    Viewport original = new Viewport('ViewportOriginal', _graphicsDevice);

    Viewport copy = new Viewport('ViewportCopy', _graphicsDevice);
    copy.x = 160;
    copy.y = 120;
    copy.width = 320;
    copy.height = 240;
    copy.minDepth = 0.1;
    copy.maxDepth = 0.9;

    Map json = original.toJson();
    copy.fromJson(json);

    expect(viewportEqual(original, copy), true);
  });
}

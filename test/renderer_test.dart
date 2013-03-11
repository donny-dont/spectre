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

library renderer_test;

import 'dart:html';
import 'package:unittest/unittest.dart';
import 'package:asset_pack/asset_pack.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_renderer.dart';
import 'device_child_equality.dart';
import 'mock_graphics_device.dart';

GraphicsDevice _graphicsDevice;
Renderer _renderer;
AssetManager _assetManager;
CanvasElement _frontBuffer;

void testFromJson() {
  Map renderer_config = {
    'buffers': [
      {
        'name': 'depthBuffer',
        'type': 'depth',
        'width': 512,
        'height': 512
      },
      {
        'name': 'colorBuffer',
        'type': 'color',
        'width': 512,
        'height': 512
      },
      {
        'name': 'depthBuffer2',
        'type': 'depth',
        'width': 1024,
        'height': 768
      }
    ],
    'targets': [
      {
        'name': 'frontBuffer',
        'width': 123,
        'height': 456,
      },
      {
        'name': 'backBuffer',
        'depthBuffer': 'depthBuffer2',
        'colorBuffer': 'colorBuffer',
      },
      {
        'name': 'backBufferRenderable',
        'depthbuffer': 'depthBuffer',
        'colorBuffer': 'colorBuffer'
      }
    ]
  };
  _renderer.fromJson(renderer_config);
  // Test counts.
  expect(_renderer.colorBuffers.length, 1);
  expect(_renderer.depthBuffers.length, 2);
  expect(_renderer.renderTargets.length, 2);
  // Test update of front buffer dimensions.
  expect(_frontBuffer.clientWidth, 123);
  expect(_frontBuffer.clientHeight, 456);
  // Render target is _NOT_ renderable.
  // This is because the attachments are not of the same dimensions.
  expect(_renderer.renderTargets['backBuffer'].isRenderable, false);
  // Render target is renderable.
  expect(_renderer.renderTargets['backBufferRenderable'].isRenderable, true);
  // Verify device children have been created.
  expect(_graphicsDevice.children.where((child) {
    return child is Texture2D && child.name == 'colorBuffer';
  }).length, 1);
  expect(_graphicsDevice.children.where((child) {
    return child is RenderBuffer &&
           (child.name == 'depthBuffer' || child.name == 'depthBuffer2');
  }).length, 2);
  expect(_graphicsDevice.children.where((child) {
    return child is RenderTarget &&
           (child.name == 'backBuffer' || child.name == 'backBufferRenderable');
  }).length, 2);
  // Test assetManager access
  expect(_assetManager.root.renderer.depthBuffer.width, 512);
  expect(_assetManager.root.renderer.depthBuffer.height, 512);
}

void testClear() {
  _renderer.clear();
  expect(_renderer.colorBuffers.length, 0);
  expect(_renderer.depthBuffers.length, 0);
  expect(_renderer.renderTargets.length, 0);
  // Verify device children are cleaned up.
  expect(_graphicsDevice.children.where((child) {
    return child is Texture2D && child.name == 'colorBuffer';
  }).length, 0);
  expect(_graphicsDevice.children.where((child) {
    return child is RenderBuffer &&
           (child.name == 'depthBuffer' || child.name == 'depthBuffer2');
  }).length, 0);
  expect(_graphicsDevice.children.where((child) {
    return child is RenderTarget &&
           (child.name == 'backBuffer' || child.name == 'backBufferRenderable');
  }).length, 0);
  expect(() => _assetManager.root.getAssetAtPath('renderer.depthBuffer'),
         throws);
  expect(() => _assetManager.root.testpack, throws);
}

void main() {
  _frontBuffer = query('#frontBuffer');
  _graphicsDevice = new GraphicsDevice(_frontBuffer);
  _assetManager = new AssetManager();
  _renderer = new Renderer(_frontBuffer, _graphicsDevice, _assetManager);
  // Construction.
  test('construction', () {
    testFromJson();
  });
  // Destruction, must be run immediately after testFromJson.
  test('clear', () {
    testClear();
  });
}

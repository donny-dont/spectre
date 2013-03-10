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
  _renderer.fromJson();
}

void main() {
  _frontBuffer = query('#frontBuffer');
  _graphicsDevice = new GraphicsDevice(_frontBuffer);
  _assetManager = new AssetManager();
  _renderer = new Renderer(_frontBuffer, _graphicsDevice, _assetManager);
  // Construction
  test('construction', () {

  });
}

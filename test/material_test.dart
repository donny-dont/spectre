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

library material_test;

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

bool materialTextureEquals(MaterialTexture a, MaterialTexture b) {
  if (a.texturePath != b.texturePath) {
    return false;
  }
  if (a.name != b.name) {
    return false;
  }
  return samplerStateEqual(a.sampler, b.sampler);
}

bool materialConstantEquals(MaterialConstant a, MaterialConstant b) {
  if (a.type != b.type) {
    return false;
  }
  if (a.name != b.name) {
    return false;
  }
  if (a.value.length != b.value.length) {
    return false;
  }
  for (int i = 0; i < a.value.length; i++) {
    if (a.value[i] != b.value[i]) {
      return false;
    }
  }
  return true;
}

bool materialEquals(Material a, Material b) {
  if (blendStateEqual(a.blendState, b.blendState) == false) {
    return false;
  }
  if (depthStateEqual(a.depthState, b.depthState) == false) {
    return false;
  }
  if (rasterizerStateEqual(a.rasterizerState, b.rasterizerState) == false) {
    return false;
  }
  if (a.constants.length != b.constants.length) {
    return false;
  }
  if (a.textures.length != b.textures.length) {
    return false;
  }
  bool equalityCheckFlag = true;
  a.textures.forEach((name, texture) {
    var textureB = b.textures[name];
    if (textureB == null ||
        materialTextureEquals(texture, textureB) == false) {
      equalityCheckFlag = false;
    }
  });
  if (equalityCheckFlag == false) {
    return false;
  }
  equalityCheckFlag = true;
  a.constants.forEach((name, constant) {
    var constantB = b.constants[name];
    if (constantB == null ||
        materialConstantEquals(constant, constantB) == false) {
      equalityCheckFlag = false;
    }
  });
  return equalityCheckFlag;
}

void testMaterialConstruct() {
  expect(() {
    Material mateiral = new Material('null shader', null, _renderer);
  }, throws);
  ShaderProgram sp = new ShaderProgram('unlinked program', _graphicsDevice);
  Material material = new Material('unlinked shader', sp, _renderer);
  expect(0, material.constants.length);
  expect(0, material.textures.length);
  sp.vertexShader = new VertexShader('vs', _graphicsDevice);
  sp.fragmentShader = new FragmentShader('fs', _graphicsDevice);
  sp.link();
  expect(false, sp.linked);
  sp.vertexShader.source = '''
precision highp float;

// Input attributes
attribute vec3 vPosition;
attribute vec4 vColor;
// Input uniforms
uniform mat4 cameraTransform;
// Varying outputs
varying vec4 fColor;

void main() {
    fColor = vColor;
    vec4 vPosition4 = vec4(vPosition.x, vPosition.y, vPosition.z, 1.0);
    gl_Position = cameraTransform*vPosition4;
}
''';
  sp.fragmentShader.source = '''
precision mediump float;
uniform sampler2D texture;
varying vec4 fColor;

void main() {
    gl_FragColor = fColor + texture2D(texture, fColor.xy);
}''';
  sp.link();
  expect(true, sp.linked);
  material.link();
  expect(material.constants.length, 1);
  expect(material.textures.length, 1);
}

void testMaterialClone() {
}

void testMaterialJsonRoundTrip() {
}

void testMaterialJsonRoundTripWrongShader() {
}

void main() {
  _frontBuffer = query('#frontBuffer');
  _graphicsDevice = new GraphicsDevice(_frontBuffer);
  _assetManager = new AssetManager();
  _renderer = new Renderer(_frontBuffer, _graphicsDevice, _assetManager);
  test('construction', () {
    testMaterialConstruct();
  });
  test('clone', () {
    testMaterialClone();
  });
  test('JsonRoundTrip', () {
    testMaterialJsonRoundTrip();
  });
  test('JsonRoundTripWrongShader', () {
    testMaterialJsonRoundTripWrongShader();
  });
}



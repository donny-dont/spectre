/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

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

part of spectre_retained;

/**
 * The renderable class contains everything needed to render a mesh instance.
 */
class Renderable {
  final Renderer renderer;
  final String name;
  mat4 T = new mat4.identity();

  /// Path to mesh asset.
  String get meshPath => _meshPath;
  void set meshPath(String o) {
    _meshPath = o;
    mesh = renderer.assetManager.getAssetAtPath(_meshPath);
  }
  String _meshPath;

  /// Path to material asset.
  String get materialPath => _materialPath;
  set materialPath(String o) {
    _materialPath = o;
    material = renderer.assetManager.getAssetAtPath(_materialPath);
  }
  String _materialPath;

  InputLayout _inputLayout;
  // Bounding Box.

  Renderable(this.renderer, this.name, this.meshPath, this.materialPath) {
    _inputLayout = renderer.device.createInputLayout('$name[IL]');
    _link();
  }

  void cleanup() {
    renderer.device.deleteDeviceChild(_inputLayout);
  }

  SpectreMesh get mesh => _mesh;
  set mesh(SpectreMesh m) {
    _mesh = m;
    _link();
  }
  SpectreMesh _mesh;

  Material get material => _material;
  set material(Material m) {
    _material = m;
    _link();
  }
  Material _material;

  void _link() {
    _inputLayout.mesh = _mesh;
    if (_material != null) {
      _inputLayout.shaderProgram = _material.shader;
    }
  }

  void _render() {
    if (_material == null) {
      spectreLog.Error('Cannot render $name it has no material.');
      return;
    }
    if (_mesh == null) {
      spectreLog.Error('Cannot render $name it has no mesh.');
      return;
    }
    if (_inputLayout.ready == false) {
      spectreLog.Error('Cannot render $name inputs are invalid.');
      return;
    }

    renderer.device.context.setIndexedMesh(_mesh);
    _material.apply(renderer.device);
    renderer.device.context.setInputLayout(_inputLayout);
    renderer.device.context.drawIndexedMesh(_mesh);
  }
}

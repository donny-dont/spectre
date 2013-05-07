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

part of spectre_renderer;

class MaterialShader extends Disposable {
  String name;
  final Renderer renderer;
  ShaderProgram _shader;
  ShaderProgram get shader => _shader;

  final List<SpectreTexture> textures = new List<SpectreTexture>();
  final List<SamplerState> samplers = new List<SamplerState>();

  set vertexShader(String source) {
    _shader.vertexShader.source = source;
    _shader.vertexShader.compile();
    _shader.link();
  }
  set fragmentShader(String source) {
    _shader.fragmentShader.source = source;
    _shader.fragmentShader.compile();
    _shader.link();
  }

  MaterialShader(this.name, this.renderer) {
    _shader = new ShaderProgram(name, renderer.device);
    _shader.vertexShader = new VertexShader(name, renderer.device);
    _shader.fragmentShader = new FragmentShader(name, renderer.device);
  }

  void finalize() {
    if (_shader != null) {
      _shader.vertexShader.dispose();
      _shader.fragmentShader.dispose();
      _shader.dispose();
    }
  }

  void _applyConstant(String name, MaterialConstant constant) {
  }

  void _applyTexture(String name, MaterialTexture texture) {
  }
}
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
  /// Constants
  final Map<String, MaterialConstant> constants =
      new Map<String, MaterialConstant>();
  /// Textures
  final Map<String, MaterialTexture> textures =
      new Map<String, MaterialTexture>();

  MaterialShader(this.name, this.renderer);

  void finalize() {
    if (shader != null) {
      shader.dispose();
    }
  }

  void _applyConstant(String name, MaterialConstant constant) {
  }

  final List<SpectreTexture> _textureTable = new List<SpectreTexture>();
  final List<SamplerState> _samplerTable = new List<SamplerState>();

  void _applyTexture(String name, MaterialTexture texture) {
  }
}
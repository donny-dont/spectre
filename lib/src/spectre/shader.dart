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

part of spectre;

class SpectreShader extends DeviceChild {
  final int _type;
  String _source = '';
  WebGL.Shader _shader;

  SpectreShader(String name, GraphicsDevice device, this._type) :
      super._internal(name, device) {
    _shader = device.gl.createShader(_type);
  }

  void finalize() {
    super.finalize();
    device.gl.deleteShader(_shader);
    _shader = null;
  }

  /** Set shader source code. */
  void set source(String s) {
    _source = s;
    device.gl.shaderSource(_shader, _source);
    if (autoCompile) {
      compile();
    }
  }

  /** Get shader source code. */
  String get source {
    return _source;
  }

  /** Shader successfully compiled? */
  bool get compiled {
    if (_shader != null) {
      return device.gl.getShaderParameter(_shader, WebGL.COMPILE_STATUS);
    }
    return false;
  }

  /** Enable or disable automatic shader recompilation when source changes.  */
  bool autoCompile = true;

  /** Compile the shader. */
  void compile() {
    device.gl.compileShader(_shader);
  }

  /** Compile log. */
  String get compileLog {
    return device.gl.getShaderInfoLog(_shader);
  }
}

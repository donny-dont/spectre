part of spectre;

/*

  Copyright (C) 2012 John McCutchan <john@johnmccutchan.com>

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

class SpectreShader extends DeviceChild {
  String _source;
  WebGLShader _shader;
  int _type;

  SpectreShader(String name, GraphicsDevice device) :
      super._internal(name, device) {
    _source = '';
    _shader = null;
  }

  String get log {
    return device.gl.getShaderInfoLog(_shader);
  }

  WebGLShader get shader => this._shader;

  void set source(String s) {
    _source = s;
    device.gl.shaderSource(_shader, _source);
  }

  String get source {
    return _source;
  }

  bool get compiled {
    if (_shader != null) {
      return device.gl.getShaderParameter(_shader, WebGLRenderingContext.COMPILE_STATUS);
    }
    return false;
  }

  void compile() {
    device.gl.compileShader(_shader);
  }

  void _createDeviceState() {
    _shader = device.gl.createShader(_type);
  }

  void _destroyDeviceState() {
    device.gl.deleteShader(_shader);
  }
}

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

class SpectreBuffer extends DeviceChild {
  WebGLBuffer _buffer;
  int _target;
  int _param_target;
  int _usage;

  SpectreBuffer(String name, GraphicsDevice device) : super._internal(name, device) {
    _buffer = null;
  }

  void _createDeviceState() {
    super._createDeviceState();
    _buffer = device.gl.createBuffer();
    _usage = WebGLRenderingContext.DYNAMIC_DRAW;
  }

  void _configDeviceState(Map props) {
    super._configDeviceState(props);

    if (props != null) {
      dynamic o;
      o = props['usage'];
      if (o != null && o is String) {
        switch (o) {
          case 'stream':
            _usage = WebGLRenderingContext.STREAM_DRAW;
          break;
          case 'dynamic':
            _usage = WebGLRenderingContext.DYNAMIC_DRAW;
          break;
          case 'static':
            _usage = WebGLRenderingContext.STATIC_DRAW;
          break;
          default:
            spectreLog.Error('$o is not a valid buffer usage type');
          break;
        }
      }
    }

    /*
    WebGLBuffer oldBind = device.gl.getParameter(_param_target);
    device.gl.bindBuffer(_target, _buffer);
    device.gl.bufferData(_target, _size, _usage);
    device.gl.bindBuffer(_target, oldBind);
    */
  }

  void _destroyDeviceState() {
    device.gl.deleteBuffer(_buffer);
    super._destroyDeviceState();
  }
}

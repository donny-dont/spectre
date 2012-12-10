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

/** A [SpectreBuffer] represents a buffer of memory on the GPU.
 * A [SpectreBuffer] can only be constructed by constructing an [IndexBuffer]
 * or a [VertexBuffer].
 */
class SpectreBuffer extends DeviceChild {
  /** Hint that buffer data is used once and then discarded. */
  static const UsageStream = WebGLRenderingContext.STREAM_DRAW;
  /** Hint that buffer data is used few times and then discarded. */
  static const UsageDynamic = WebGLRenderingContext.DYNAMIC_DRAW;
  /** Hint that buffer data is used many times and never discarded. */
  static const UsageStatic = WebGLRenderingContext.STATIC_DRAW;
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
  }

  void _destroyDeviceState() {
    device.gl.deleteBuffer(_buffer);
    super._destroyDeviceState();
  }

  void _uploadData(dynamic data, int usage) {
    device.gl.bufferData(_target, data, usage);
  }

  /** Resize buffer to fit [data]. Upload [data] with [usage] hint. */
  void uploadData(dynamic data, int usage) {
    var oldBind = device.gl.getParameter(_param_target);
    device.gl.bindBuffer(_target, _buffer);
    _uploadData(data, usage);
    device.gl.bindBuffer(_target, oldBind);
  }

  void _uploadSubData(int offset, dynamic data) {
    device.gl.bufferSubData(_target, offset, data);
  }

  /** Starting at [offset], upload [data] into buffer.
   * The length of [data] + offset must not exceed the size of the buffer
   */
  void uploadSubData(int offset, dynamic data) {
    var oldBind = device.gl.getParameter(_param_target);
    device.gl.bindBuffer(_target, _buffer);
    _uploadSubData(offset, data);
    device.gl.bindBuffer(_target, oldBind);
  }

  void _allocate(int size, int usage) {
    device.gl.bufferData(_target, size, usage);
  }

  /** Resize buffer to be [size] bytes with [usage] hint. */
  void allocate(int size, int usgae) {
    var oldBind = device.gl.getParameter(_param_target);
    device.gl.bindBuffer(_target, _buffer);
    _allocate(size, usage);
    device.gl.bindBuffer(_target, oldBind);
  }

  /** Query the GPU for the size of the buffer. Can be expensive */
  int get size {
    var r;
    var oldBind = device.gl.getParameter(_param_target);
    device.gl.bindBuffer(_target, _buffer);
    r = device.gl.getBufferParameter(_target,
                                     WebGLRenderingContext.BUFFER_SIZE);
    device.gl.bindBuffer(_target, oldBind);
    return r;
  }

  /** Query the GPU for the usage hint of the buffer. Can be expensive */
  int get usage {
    var r;
    var oldBind = device.gl.getParameter(_param_target);
    device.gl.bindBuffer(_target, _buffer);
    r = device.gl.getBufferParameter(_target,
                                     WebGLRenderingContext.BUFFER_USAGE);
    device.gl.bindBuffer(_target, oldBind);
    return r;
  }
}

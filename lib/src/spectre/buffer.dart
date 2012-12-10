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
  int _usage = UsageDynamic;
  int _size = 0;

  SpectreBuffer(String name, GraphicsDevice device) : super._internal(name, device) {
  }

  void _createDeviceState() {
    super._createDeviceState();
    _buffer = device.gl.createBuffer();
  }

  void _destroyDeviceState() {
    device.gl.deleteBuffer(_buffer);
    super._destroyDeviceState();
  }

  void _uploadData(dynamic data, int usage) {
    _size = data.byteLength;
    _usage = usage;
    device.gl.bufferData(_target, data, usage);
  }

  /** Resize buffer to fit [data]. Upload [data] with [usage] hint. */
  void uploadData(dynamic data, int usage) {
    if (data == null) {
      throw new ArgumentError('data cannot be null.');
    }
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
    if (data == null) {
      throw new ArgumentError('data cannot be null.');
    }
    if (offset + data.byteLength >= _size) {
      throw new RangeError('data will not fit.');
    }
    var oldBind = device.gl.getParameter(_param_target);
    device.gl.bindBuffer(_target, _buffer);
    _uploadSubData(offset, data);
    device.gl.bindBuffer(_target, oldBind);
  }

  void _allocate(int size, int usage) {
    _size = size;
    _usage = usage;
    device.gl.bufferData(_target, size, usage);
  }

  /** Resize buffer to be [size] bytes with [usage] hint. */
  void allocate(int size, int usage) {
    if (size <= 0) {
      throw new ArgumentError('size must be > 0');
    }
    var oldBind = device.gl.getParameter(_param_target);
    device.gl.bindBuffer(_target, _buffer);
    _allocate(size, usage);
    device.gl.bindBuffer(_target, oldBind);
  }

  /** Query the size of the buffer */
  int get size => _size;

  /** Query the usage hint of the buffer */
  int get usage => _usage;
}

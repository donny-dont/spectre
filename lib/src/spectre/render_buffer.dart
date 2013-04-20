/*
  Copyright (C) 2013 John McCutchan

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

/** A [RenderBuffer] represents the storage for either a color, depth,
 * or stencil buffer render target attachment.
 */
class RenderBuffer extends DeviceChild {
  static const int FormatRGB = WebGL.RGB565;
  static const int FormatRGBA = WebGL.RGBA4;
  static const int FormatDepth = WebGL.DEPTH_COMPONENT16;

  static String formatToString(int format) {
    if (format == FormatRGB) {
      return 'RGB';
    }
    if (format == FormatRGBA) {
      return 'RGBA';
    }
    if (format == FormatDepth) {
      return 'Depth';
    }
    assert(false);
  }

  static int stringToFormat(String format) {
    if (format == 'RGB') {
      return FormatRGB;
    }
    if (format == 'RGBA') {
      return FormatRGBA;
    }
    if (format == 'Depth') {
      return FormatDepth;
    }
    assert(false);
  }

  final int _target = WebGL.RENDERBUFFER;
  final int _target_param = WebGL.RENDERBUFFER_BINDING;

  int _width = 0;
  int get width => _width;
  int _height = 0;
  int get height => _height;
  int _format = FormatRGB;
  WebGL.Renderbuffer _buffer;

  RenderBuffer(String name, GraphicsDevice device) :
      super._internal(name, device) {
    _buffer = device.gl.createRenderbuffer();
  }

  void finalize() {
    super.finalize();
    device.gl.deleteRenderbuffer(_buffer);
    _buffer = null;
  }

  void _allocateStorage(int width, int height, int format) {
    device.gl.renderbufferStorage(_target, _format, _width, _height);
  }

  /** Allocate storage for render buffer with [format] and
   * [width]x[height] pixels.
   */
  void allocateStorage(int width, int height, int format) {
    _width = width;
    _height = height;
    _format = format;
    WebGL.Renderbuffer oldBind = device.gl.getParameter(_target_param);
    device.gl.bindRenderbuffer(_target, _buffer);
    _allocateStorage(width, height, format);
    device.gl.bindRenderbuffer(_target, oldBind);
  }
}

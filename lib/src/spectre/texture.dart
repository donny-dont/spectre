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

class Texture extends DeviceChild {
  static final int FormatR = WebGLRenderingContext.RED;
  static final int FormatRG = WebGLRenderingContext.RG;
  static final int FormatRGB = WebGLRenderingContext.RGB;
  static final int FormatRGBA = WebGLRenderingContext.RGBA;
  static final int FormatDepth = WebGLRenderingContext.DEPTH_COMPONENT;

  static final int PixelTypeU8 = WebGLRenderingContext.UNSIGNED_BYTE;
  static final int PixelTypeU16 = WebGLRenderingContext.UNSIGNED_SHORT;
  static final int PixelTypeU32 = WebGLRenderingContext.UNSIGNED_INT;
  static final int PixelTypeS8 = WebGLRenderingContext.BYTE;
  static final int PixelTypeS16 = WebGLRenderingContext.SHORT;
  static final int PixelTypeS32 = WebGLRenderingContext.INT;
  static final int PixelTypeFloat = WebGLRenderingContext.FLOAT;

  int _width;
  int _height;
  int _textureFormat;
  int _pixelFormat;
  int _pixelType;

  int _target;
  int _target_param;
  WebGLTexture _buffer;

  Texture(String name, GraphicsDevice device) : super._internal(name, device);

  void _createDeviceState() {
    _buffer = device.gl.createTexture();
  }

  void _configDeviceState(Map props) {

  }

  void _destroyDeviceState() {
    device.gl.deleteTexture(_buffer);
  }
}

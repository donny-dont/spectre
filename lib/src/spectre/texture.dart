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
  static const int FormatR = WebGLRenderingContext.RED;
  static const int FormatRG = WebGLRenderingContext.RG;
  static const int FormatRGB = WebGLRenderingContext.RGB;
  static const int FormatRGBA = WebGLRenderingContext.RGBA;
  static const int FormatDepth = WebGLRenderingContext.DEPTH_COMPONENT;

  static const int PixelTypeU8 = WebGLRenderingContext.UNSIGNED_BYTE;
  static const int PixelTypeU16 = WebGLRenderingContext.UNSIGNED_SHORT;
  static const int PixelTypeU32 = WebGLRenderingContext.UNSIGNED_INT;
  static const int PixelTypeS8 = WebGLRenderingContext.BYTE;
  static const int PixelTypeS16 = WebGLRenderingContext.SHORT;
  static const int PixelTypeS32 = WebGLRenderingContext.INT;
  static const int PixelTypeFloat = WebGLRenderingContext.FLOAT;

  int _width = 0;
  int get width => _width;
  int _height = 0;
  int get height => _height;
  int _textureFormat = FormatRGBA;
  /** Retrieve the internal format used for this texture */
  int get textureFormat => _textureFormat;
  /** Set the internal format used for this texture.
   *
   * NOTE: Will not take affect until next upload.
   */
  set textureFormat(int internalFormat) {
    _textureFormat = internalFormat;
  }

  int _target;
  int _target_param;
  WebGLTexture _buffer;

  Texture(String name, GraphicsDevice device) : super._internal(name, device);

  /** Binds the texture to [unit]. */
  void bind(int unit) {
    device.gl.activeTexture(unit);
    device.gl.bindTexture(_target, _buffer);
  }

  void _createDeviceState() {
    _buffer = device.gl.createTexture();
  }

  void _configDeviceState(Map props) {
  }

  void _destroyDeviceState() {
    device.gl.deleteTexture(_buffer);
  }
}

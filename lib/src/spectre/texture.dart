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

class SpectreTexture extends DeviceChild {
  //static const int FormatR = WebGLRenderingContext.RED;
  //static const int FormatRG = WebGLRenderingContext.RG;
  static const int FormatRGB = WebGLRenderingContext.RGB;
  static const int FormatRGBA = WebGLRenderingContext.RGBA;
  static const int FormatDepth = WebGLRenderingContext.DEPTH_COMPONENT;

  static String formatToString(int format) {
    /*
    if (format == FormatR) {
      return 'R';
    }
    if (format == FormatRG) {
      return 'RG';
    }*/
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
    /*
    if (format == 'R') {
      return FormatR;
    }
    if (format == 'RG') {
      return FormatRG;
    }*/
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

  final int _bindTarget;
  final int _bindingParam;
  final int _textureTarget;
  WebGLTexture _deviceTexture;

  /** Bind this texture and return the previously bound texture. */
  WebGLTexture _pushBind() {
    WebGLTexture oldBind = device.gl.getParameter(_bindingParam);
    device.gl.bindTexture(_bindTarget, _deviceTexture);
    return oldBind;
  }

  /** Rebind [oldBind] */
  void _popBind(WebGLTexture oldBind) {
    device.gl.bindTexture(_bindTarget, oldBind);
  }

  SpectreTexture(String name, GraphicsDevice device, this._bindTarget,
                 this._bindingParam, this._textureTarget)
      : super._internal(name, device);

  void _applySampler(SamplerState sampler) {
    device.gl.texParameteri(_textureTarget,
                            WebGLRenderingContext.TEXTURE_WRAP_S,
                            sampler.addressU);
    device.gl.texParameteri(_textureTarget,
                            WebGLRenderingContext.TEXTURE_WRAP_T,
                            sampler.addressV);
    device.gl.texParameteri(_textureTarget,
                            WebGLRenderingContext.TEXTURE_MIN_FILTER,
                            sampler.minFilter);
    device.gl.texParameteri(_textureTarget,
                            WebGLRenderingContext.TEXTURE_MAG_FILTER,
                            sampler.magFilter);
  }

  /** Binds the texture to [unit]. */
  void _bind(int unit) {
    // TODO(johnmccutchan): Check # texture units and throw exception when
    // unit is out of range.
    device.gl.activeTexture(unit);
    device.gl.bindTexture(_bindTarget, _deviceTexture);
  }

  void _createDeviceState() {
    _deviceTexture = device.gl.createTexture();
  }

  void _destroyDeviceState() {
    if (_deviceTexture != null) {
      device.gl.deleteTexture(_deviceTexture);
    }
    _deviceTexture = null;
  }

  /// Determines whether a [value] is a power of two.
  ///
  /// Assumes that the given value will always be positive.
  static bool _isPowerOfTwo(int value) {
    return (value & (value - 1)) == 0;
  }
}

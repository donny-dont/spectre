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

class SpectreTexture extends DeviceChild {
  //static const int FormatR = WebGLRenderingContext.RED;
  //static const int FormatRG = WebGLRenderingContext.RG;
  static const int FormatRGB = WebGLRenderingContext.RGB;
  static const int FormatRGBA = WebGLRenderingContext.RGBA;
  static const int FormatDepth = WebGLRenderingContext.DEPTH_COMPONENT;

  /// The current [SamplerState] attached to the [Texture].
  /// Constructed with the values in [SamplerState.linearWrap].
  SamplerState _samplerState;

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

  static const int PixelTypeU8 = WebGL.UNSIGNED_BYTE;
  static const int PixelTypeU16 = WebGL.UNSIGNED_SHORT;
  static const int PixelTypeU32 = WebGL.UNSIGNED_INT;
  static const int PixelTypeS8 = WebGL.BYTE;
  static const int PixelTypeS16 = WebGL.SHORT;
  static const int PixelTypeS32 = WebGL.INT;
  static const int PixelTypeFloat = WebGL.FLOAT;

  int _width = 0;
  int _height = 0;
  int _textureFormat = FormatRGBA;
  /** Retrieve the internal format used for this texture */
  int get textureFormat => _textureFormat;
  /// The number of texture levels in a multilevel texture.
  int _levelCount = 0;

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

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------


  SpectreTexture(String name, GraphicsDevice device, this._bindTarget,
                 this._bindingParam, this._textureTarget)
      : super._internal(name, device)
      , _samplerState = new SamplerState.linearWrap('Testing', device)
  {
    _deviceTexture = device.gl.createTexture();
    _initializeState();
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The width of the texture resource, in pixels.
  int get width => _width;
  /// The height of the texture resource, in pixels.
  int get height => _height;

  /// The number of texture levels in a multilevel texture.
  ///
  /// If the mipmaps were explicitly set this will contain the number of levels used.
  /// If the mipmaps were generated by the device then the number of levels will be
  /// estimated as there is no way to query the exact number.
  int get levelCount => _levelCount;

  //---------------------------------------------------------------------
  // GraphicsDevice/Context interactions
  //
  // Should this be here?
  //---------------------------------------------------------------------

  /// Sets the initial state for the [Texture].
  void _initializeState() {
    WebGLTexture oldBind = _pushBind();

    WebGLRenderingContext gl = device.gl;

    // Set the parameters otherwise the texture object cannot be rendered
    gl.texParameteri(
        _textureTarget,
        WebGLRenderingContext.TEXTURE_WRAP_S,
        _samplerState.addressU);

    gl.texParameteri(
        _textureTarget,
        WebGLRenderingContext.TEXTURE_WRAP_T,
        _samplerState.addressV);

    gl.texParameteri(
        _textureTarget,
        WebGLRenderingContext.TEXTURE_MIN_FILTER,
        _samplerState.minFilter);

    gl.texParameteri(
        _textureTarget,
        WebGLRenderingContext.TEXTURE_MAG_FILTER,
        _samplerState.magFilter);

    _popBind(oldBind);
  }

  /// Applies the [SamplerState] to the [Texture].
  ///
  /// WebGL does not have the concept of a [SamplerState] that you can just apply
  /// to the pipeline. Instead the state is attached to the underlying texture object.
  /// So to get ensure redudant state changes are not occurring checks are made within
  /// [Texture] rather than [GraphicsContext].
  void _applySampler(SamplerState samplerState) {
    WebGLRenderingContext gl = device.gl;

    // Modify the texture wrapping if necessary
    if (_samplerState.addressU != samplerState.addressU) {
      gl.texParameteri(
          _textureTarget,
          WebGLRenderingContext.TEXTURE_WRAP_S,
          samplerState.addressU);

      _samplerState.addressU = samplerState.addressU;
    }

    if (_samplerState.addressV != samplerState.addressV) {
      gl.texParameteri(
          _textureTarget,
          WebGLRenderingContext.TEXTURE_WRAP_T,
          samplerState.addressV);

      _samplerState.addressV = samplerState.addressV;
    }

    // See if aniostropy is requested as this overrides the other filters
    if (_samplerState.maxAnisotropy > 1.0) {
      if (_samplerState.maxAnisotropy != samplerState.maxAnisotropy) {
        gl.texParameterf(
            _textureTarget,
            ExtTextureFilterAnisotropic.TEXTURE_MAX_ANISOTROPY_EXT,
            samplerState.maxAnisotropy);

        _samplerState.maxAnisotropy = samplerState.maxAnisotropy;
      }
    } else {
      if (_samplerState.minFilter != samplerState.minFilter) {
        gl.texParameteri(
            _textureTarget,
            WebGLRenderingContext.TEXTURE_MIN_FILTER,
            samplerState.minFilter);

        _samplerState.minFilter = samplerState.minFilter;
      }

      if (_samplerState.magFilter != samplerState.magFilter) {
        gl.texParameteri(
            _textureTarget,
            WebGLRenderingContext.TEXTURE_MAG_FILTER,
            samplerState.magFilter);

        _samplerState.magFilter = samplerState.magFilter;
      }
    }
  }

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

  /** Binds the texture to [unit]. */
  void _bind(int unit) {
    // TODO(johnmccutchan): Check # texture units and throw exception when
    // unit is out of range.
    device.gl.activeTexture(unit);
    device.gl.bindTexture(_bindTarget, _deviceTexture);
  }

  void finalize() {
    super.finalize();
    device.gl.deleteTexture(_deviceTexture);
    _deviceTexture = null;
  }

  //---------------------------------------------------------------------
  // Class methods
  //---------------------------------------------------------------------

  /// Determines whether a [value] is a power of two.
  ///
  /// Assumes that the given value will always be positive.
  static bool _isPowerOfTwo(int value) {
    return (value & (value - 1)) == 0;
  }

  /// Determines the number of mipmap levels that will be created.
  ///
  /// WebGL does not provide a way to get the number of mipmap levels generated
  /// so guess at it.
  ///
  /// Computed using the following formula.
  ///
  ///     levels = log2(max(width, height)) - 1;
  static int _computeMipMapLevels(int width, int height) {
    int maxSize = Math.max(width, height);

    // Bit hack for when we have a known power of two
    // Have to use ternary statements since a boolean can't be treated as an int
    int levels;

    levels  = (maxSize & 0xaaaaaaaa) == 0 ? 0 : 0x1;
    levels |= (maxSize & 0xcccccccc) == 0 ? 0 : 0x2;
    levels |= (maxSize & 0xf0f0f0f0) == 0 ? 0 : 0x4;
    levels |= (maxSize & 0xff00ff00) == 0 ? 0 : 0x8;
    levels |= (maxSize & 0xffff0000) == 0 ? 0 : 0x10;

    return levels - 1;
  }
}

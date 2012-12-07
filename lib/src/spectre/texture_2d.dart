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

/// Texture2D defines the storage for a 2D texture including Mipmaps
/// Create using [Device.createTexture2D]
/// Set using [immediateContext.setTextures]
/// NOTE: Unlike OpenGL, Spectre textures do not describe how they are sampled
class Texture2D extends Texture {
  Texture2D(String name, GraphicsDevice device) : super(name, device) {
    _target = WebGLRenderingContext.TEXTURE_2D;
    _target_param = WebGLRenderingContext.TEXTURE_BINDING_2D;
    _width = 1;
    _height = 1;
    _textureFormat = Texture.FormatRGBA;
    _pixelFormat = Texture.FormatRGBA;
    _pixelType = Texture.PixelTypeU8;
  }

  void _createDeviceState() {
    super._createDeviceState();
  }

  void _configDeviceState(Map props) {
    super._configDeviceState(props);

    if (props != null && props['pixels'] != null) {
      var pixels = props['pixels'];
      uploadPixelData(pixels);
    } else {
      if (props != null) {
        _width = props['width'] != null ? props['width'] : _width;
        _height = props['height'] != null ? props['height'] : _height;
        _textureFormat = props['textureFormat'] != null ?
            props['textureFormat'] : _textureFormat;
        _pixelFormat = props['pixelFormat'] != null ?
            props['pixelFormat'] : _pixelFormat;
        _pixelType = props['pixelType'] != null ?
            props['pixelType'] : _pixelType;
      }
      // TODO(johnmccutchan): Kill this hack.
      // TODO(johnmccutchan): Support texture properties.
      device.gl.pixelStorei(WebGLRenderingContext.UNPACK_FLIP_Y_WEBGL, 1);
      allocatePixelSpace(_width, _height);
    }
  }

  void allocatePixelSpace(int width, int height, [int level=0]) {
    _width = width;
    _height = height;
    WebGLTexture oldBind = device.gl.getParameter(_target_param);
    device.gl.bindTexture(_target, _buffer);
    device.gl.texImage2D(_target, level, _textureFormat, _width, _height,
                         0, _pixelFormat, _pixelType, null);
    device.gl.bindTexture(_target, oldBind);
  }

  void uploadPixelData(dynamic pixels, [int level=0]) {
    WebGLTexture oldBind = device.gl.getParameter(_target_param);
    device.gl.bindTexture(_target, _buffer);
    device.gl.texImage2D(_target, level, _textureFormat, _pixelFormat,
                         _pixelType, pixels);
    // TODO(johmccutchan): Update _width and _height based on pixels.
    device.gl.bindTexture(_target, oldBind);
  }

  void _destroyDeviceState() {
    super._destroyDeviceState();
  }
}

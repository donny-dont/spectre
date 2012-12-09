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

class TextureCube extends Texture {
  static final int PositiveX =
      WebGLRenderingContext.TEXTURE_CUBE_MAP_POSITIVE_X;
  static final int NegativeX =
      WebGLRenderingContext.TEXTURE_CUBE_MAP_NEGATIVE_X;
  static final int PositiveY =
      WebGLRenderingContext.TEXTURE_CUBE_MAP_POSITIVE_Y;
  static final int NegativeY =
      WebGLRenderingContext.TEXTURE_CUBE_MAP_NEGATIVE_Y;
  static final int PositiveZ =
      WebGLRenderingContext.TEXTURE_CUBE_MAP_POSITIVE_Z;
  static final int NegativeZ =
      WebGLRenderingContext.TEXTURE_CUBE_MAP_NEGATIVE_Z;

  TextureCube(String name, GraphicsDevice device) : super(name, device) {
    _target = WebGLRenderingContext.TEXTURE_CUBE_MAP;
    _target_param = WebGLRenderingContext.TEXTURE_BINDING_CUBE_MAP;
  }

  void _createDeviceState() {
    super._createDeviceState();
  }

  void _configDeviceState(Map props) {
    super._configDeviceState(props);
  }

  void _destroyDeviceState() {
    super._destroyDeviceState();
  }

  void _uploadPixelArray(int face, int width, int height, dynamic array,
                         int pixelFormat, int pixelType) {
    device.gl.texImage2D(face, 0, _textureFormat, width, height,
                         0, pixelFormat, pixelType, array);
  }

  /** Replace texture contents with data stored in [array].
   * If [array] is null, space will be allocated on the GPU
   */
  void uploadPixelArray(int face, int width, int height, dynamic array,
                        {pixelFormat: Texture.FormatRGBA,
                         pixelType: Texture.PixelTypeU8}) {
    WebGLTexture oldBind = device.gl.getParameter(_target_param);
    device.gl.bindTexture(_target, _buffer);
    _width = width;
    _height = height;
    _uploadPixelArray(width, height, array, pixelFormat, pixelType);
    device.gl.bindTexture(_target, oldBind);
  }

  void _uploadElement(int face, dynamic element, int pixelFormat,
                      int pixelType) {
    device.gl.texImage2D(face, 0, _textureFormat,
                         pixelFormat, pixelType, element);
  }

  /** Replace texture contents with image data from [element].
   * Supported for [ImageElement], [VideoElement], and [CanvasElement].
   *
   * The image data will be converted to [pixelFormat] and [pixelType] before
   * being uploaded to the GPU.
   */
  void uploadElement(int face, dynamic element,
                     {pixelFormat: Texture.FormatRGBA,
                      pixelType: Texture.PixelTypeU8}) {
    if (element is ImageElement) {
      _width = element.naturalWidth;
      _height = element.naturalHeight;
    } else if (element is CanvasElement) {
      _width = element.width;
      _height = element.height;
    } else if (element is VideoElement) {
      _width = element.width;
      _height = element.height;
    } else {
      throw new ArgumentError('element is not supported.');
    }
    WebGLTexture oldBind = device.gl.getParameter(_target_param);
    device.gl.bindTexture(_target, _buffer);
    _uploadElement(element, pixelFormat, pixelType);
    device.gl.bindTexture(_target, oldBind);
  }

  /** Replace texture contents with data fetched from [url].
   * If an error occurs while fetching the image, loadError will be true.
   */
  Future<Texture2D> uploadFromURL(int face, Sting url,
                                  {pixelFormat: Texture.FormatRGBA,
                                   pixelType: Texture.PixelTypeU8}) {
    ImageElement element = new ImageElement();
    Completer<Texture2D> completer = new Completer<Texture2D>();
    element.on.error.add((event) {
      _loadError = true;
      completer.complete(this);
    });
    element.on.load.add((event) {
      uploadElement(face, element, pixelFormat, pixelType);
      completer.complete(this);
    });
    // Initiate load.
    _loadError = false;
    element.src = url;
    return completer.future;
  }

  void _generateMipmap(int face) {
    device.gl.generateMipmap(face);
  }

  /** Generate Mipmap data for texture. This must be done before the texture
   * can be used for rendering.
   */
  void generateMipmap(int face) {
    WebGLTexture oldBind = device.gl.getParameter(_target_param);
    device.gl.bindTexture(_target, _buffer);
    _generateMipmap(face);
    device.gl.bindTexture(_target, oldBind);
  }
}
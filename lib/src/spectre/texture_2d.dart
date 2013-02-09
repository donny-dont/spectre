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

/// Texture2D defines the storage for a 2D texture including Mipmaps
/// Create using [Device.createTexture2D]
/// Set using [immediateContext.setTextures]
/// NOTE: Unlike OpenGL, Spectre textures do not describe how they are sampled
class Texture2D extends SpectreTexture {
  bool _loadError = false;

  /** Did an error occur when loading from a URL? */
  bool get loadError => _loadError;

  Texture2D(String name, GraphicsDevice device) :
      super(name, device, WebGLRenderingContext.TEXTURE_2D,
          WebGLRenderingContext.TEXTURE_BINDING_2D,
          WebGLRenderingContext.TEXTURE_2D);

  Texture2D._cube(String name, GraphicsDevice device, int bindTarget,
                  int bindParam, int textureTarget) :
      super(name, device, bindTarget, bindParam, textureTarget);

  void _createDeviceState() {
    super._createDeviceState();
  }

  void _destroyDeviceState() {
    super._destroyDeviceState();
  }

  void _uploadPixelArray(int width, int height, dynamic array,
                         int pixelFormat, int pixelType) {
    device.gl.texImage2D(_textureTarget, 0, _textureFormat, width, height,
                         0, pixelFormat, pixelType, array);
  }

  /** Replace texture contents with data stored in [array].
   * If [array] is null, space will be allocated on the GPU
   */
  void uploadPixelArray(int width, int height, dynamic array,
                        {pixelFormat: SpectreTexture.FormatRGBA,
                         pixelType: SpectreTexture.PixelTypeU8}) {
    var oldBind = _pushBind();
    _width = width;
    _height = height;
    _uploadPixelArray(width, height, array, pixelFormat, pixelType);
    _popBind(oldBind);
  }

  void _uploadElement(dynamic element, int pixelFormat, int pixelType) {
    device.gl.texImage2D(_textureTarget, 0, _textureFormat,
                         pixelFormat, pixelType, element);
  }

  /** Replace texture contents with image data from [element].
   * Supported for [ImageElement], [VideoElement], and [CanvasElement].
   *
   * The image data will be converted to [pixelFormat] and [pixelType] before
   * being uploaded to the GPU.
   */
  void uploadElement(dynamic element,
                     {pixelFormat: SpectreTexture.FormatRGBA,
                         pixelType: SpectreTexture.PixelTypeU8}) {
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
    var oldBind = _pushBind();
    _uploadElement(element, pixelFormat, pixelType);
    _popBind(oldBind);
  }

  /** Replace texture contents with data fetched from [url].
   * If an error occurs while fetching the image, loadError will be true.
   */
  Future<Texture2D> uploadFromURL(String url,
                                  {pixelFormat: SpectreTexture.FormatRGBA,
                                   pixelType: SpectreTexture.PixelTypeU8}) {
    ImageElement element = new ImageElement();
    Completer<Texture2D> completer = new Completer<Texture2D>();
    element.onError.listen((event) {
      _loadError = true;
      completer.complete(this);
    });
    element.onLoad.listen((event) {
      uploadElement(element, pixelFormat:pixelFormat, pixelType:pixelType);
      completer.complete(this);
    });
    // Initiate load.
    _loadError = false;
    element.src = url;
    return completer.future;
  }

  void _generateMipmap() {
    device.gl.generateMipmap(_textureTarget);
  }


  /// Generate mipmaps for the [Texture2D].
  ///
  /// This must be done before the texture is used for rendering.
  ///
  /// A call to this method will only generate mipmap data if the
  /// texture is a power of two. If not then this call is ignored.
  void generateMipmap() {
    if (SpectreTexture._isPowerOfTwo(_width) && SpectreTexture._isPowerOfTwo(_height)) {
      var oldBind = _pushBind();
      _generateMipmap();
      _popBind(oldBind);
    }
  }
}

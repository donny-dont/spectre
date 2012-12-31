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
  Texture2D _positiveX;
  Texture2D _positiveY;
  Texture2D _positiveZ;

  Texture2D _negativeX;
  Texture2D _negativeY;
  Texture2D _negativeZ;

  Texture2D get positiveX => _positiveX;
  Texture2D get positiveY => _positiveY;
  Texture2D get positiveZ => _positiveZ;
  Texture2D get negativeX => _negativeX;
  Texture2D get negativeY => _negativeY;
  Texture2D get negativeZ => _negativeZ;

  TextureCube(String name, GraphicsDevice device)
      : super(name, device, WebGLRenderingContext.TEXTURE_CUBE_MAP,
          WebGLRenderingContext.TEXTURE_BINDING_CUBE_MAP,
          WebGLRenderingContext.TEXTURE_CUBE_MAP) {
    _positiveX = new Texture2D._cube(
        '$name[+X]',
        device,
        WebGLRenderingContext.TEXTURE_CUBE_MAP,
        WebGLRenderingContext.TEXTURE_BINDING_CUBE_MAP,
        WebGLRenderingContext.TEXTURE_CUBE_MAP_POSITIVE_X);
    _positiveY = new Texture2D._cube(
        '$name[+Y]',
        device,
        WebGLRenderingContext.TEXTURE_CUBE_MAP,
        WebGLRenderingContext.TEXTURE_BINDING_CUBE_MAP,
        WebGLRenderingContext.TEXTURE_CUBE_MAP_POSITIVE_Y);
    _positiveZ = new Texture2D._cube(
        '$name[+Z]',
        device,
        WebGLRenderingContext.TEXTURE_CUBE_MAP,
        WebGLRenderingContext.TEXTURE_BINDING_CUBE_MAP,
        WebGLRenderingContext.TEXTURE_CUBE_MAP_POSITIVE_Z);
    _negativeX = new Texture2D._cube(
        '$name[-X]',
        device,
        WebGLRenderingContext.TEXTURE_CUBE_MAP,
        WebGLRenderingContext.TEXTURE_BINDING_CUBE_MAP,
        WebGLRenderingContext.TEXTURE_CUBE_MAP_NEGATIVE_X);
    _negativeY = new Texture2D._cube(
        '$name[-Y]',
        device,
        WebGLRenderingContext.TEXTURE_CUBE_MAP,
        WebGLRenderingContext.TEXTURE_BINDING_CUBE_MAP,
        WebGLRenderingContext.TEXTURE_CUBE_MAP_NEGATIVE_Y);
    _negativeZ = new Texture2D._cube(
        '$name[-Z]',
        device,
        WebGLRenderingContext.TEXTURE_CUBE_MAP,
        WebGLRenderingContext.TEXTURE_BINDING_CUBE_MAP,
        WebGLRenderingContext.TEXTURE_CUBE_MAP_NEGATIVE_Z);
  }

  void _createDeviceState() {
    super._createDeviceState();
    _positiveX._deviceTexture = _deviceTexture;
    _positiveY._deviceTexture = _deviceTexture;
    _positiveZ._deviceTexture = _deviceTexture;
    _negativeX._deviceTexture = _deviceTexture;
    _negativeY._deviceTexture = _deviceTexture;
    _negativeZ._deviceTexture = _deviceTexture;
  }

  void _destroyDeviceState() {
    _positiveX._deviceTexture = null;
    _positiveY._deviceTexture = null;
    _positiveZ._deviceTexture = null;
    _negativeX._deviceTexture = null;
    _negativeY._deviceTexture = null;
    _negativeZ._deviceTexture = null;
    super._destroyDeviceState();
  }
}

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

/// SamplerState defines how a texture is sampled
/// Create using [Device.createSamplerState]
/// Set using [immediateContext.setSamplerStates]
class SamplerState extends DeviceChild {
  static const int TextureWrapClampToEdge = WebGLRenderingContext.CLAMP_TO_EDGE;
  static const int TextureWrapMirroredRepeat = WebGLRenderingContext.MIRRORED_REPEAT;
  static const int TextureWrapRepeat = WebGLRenderingContext.REPEAT;

  static const int TextureMagFilterLinear = WebGLRenderingContext.LINEAR;
  static const int TextureMagFilterNearest = WebGLRenderingContext.NEAREST;

  static const int TextureMinFilterLinear = WebGLRenderingContext.LINEAR;
  static const int TextureMinFilterNearest = WebGLRenderingContext.NEAREST;
  static const int TextureMinFilterNearestMipmapNearest = WebGLRenderingContext.NEAREST_MIPMAP_NEAREST;
  static const int TextureMinFilterNearestMipmapLinear = WebGLRenderingContext.NEAREST_MIPMAP_LINEAR;
  static const int TextureMinFilterLinearMipmapNearest = WebGLRenderingContext.LINEAR_MIPMAP_NEAREST;
  static const int TextureMinFilterLinearMipmapLinear = WebGLRenderingContext.LINEAR_MIPMAP_LINEAR;

  int wrapS;
  int wrapT;
  int magFilter;
  int minFilter;

  SamplerState(String name, GraphicsDevice device) : super._internal(name, device) {
    wrapS = TextureWrapRepeat;
    wrapT = TextureWrapRepeat;
    minFilter = TextureMinFilterNearestMipmapLinear;
    magFilter = TextureMagFilterLinear;
  }

  dynamic filter(dynamic o) {
    if (o is String) {
      var table = {
        "TextureWrapClampToEdge": WebGLRenderingContext.CLAMP_TO_EDGE,
        "TextureWrapMirroredRepeat": WebGLRenderingContext.MIRRORED_REPEAT,
        "TextureWrapRepeat": WebGLRenderingContext.REPEAT,
        "TextureMagFilterLinear": WebGLRenderingContext.LINEAR,
        "TextureMagFilterNearest": WebGLRenderingContext.NEAREST,
        "TextureMinFilterLinear": WebGLRenderingContext.LINEAR,
        "TextureMinFilterNearest": WebGLRenderingContext.NEAREST,
        "TextureMinFilterNearestMipmapNearest": WebGLRenderingContext.NEAREST_MIPMAP_NEAREST,
        "TextureMinFilterNearestMipmapLinear": WebGLRenderingContext.NEAREST_MIPMAP_LINEAR,
        "TextureMinFilterLinearMipmapNearest": WebGLRenderingContext.LINEAR_MIPMAP_NEAREST,
        "TextureMinFilterLinearMipmapLinear": WebGLRenderingContext.LINEAR_MIPMAP_LINEAR
      };
      return table[o];
    }
    return o;
  }
}

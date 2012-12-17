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

/// BlendState controls how output from your fragment shader is blended onto the framebuffer
/// Create using [Device.createBlendState]
/// Set using [ImmediateContext.setBlendState]
class BlendState extends DeviceChild {
  static const int BlendSourceZero = WebGLRenderingContext.ZERO;
  static const int BlendSourceOne = WebGLRenderingContext.ONE;
  static const int BlendSourceShaderColor =
      WebGLRenderingContext.SRC_COLOR;
  static const int BlendSourceShaderInverseColor =
      WebGLRenderingContext.ONE_MINUS_SRC_COLOR;
  static const int BlendSourceShaderAlpha =
      WebGLRenderingContext.SRC_ALPHA;
  static const int BlendSourceShaderInverseAlpha =
      WebGLRenderingContext.ONE_MINUS_SRC_ALPHA;
  static const int BlendSourceTargetColor = WebGLRenderingContext.DST_COLOR;
  static const int BlendSourceTargetInverseColor =
      WebGLRenderingContext.ONE_MINUS_DST_COLOR;
  static const int BlendSourceTargetAlpha = WebGLRenderingContext.DST_ALPHA;
  static const int BlendSourceTargetInverseAlpha =
      WebGLRenderingContext.ONE_MINUS_DST_ALPHA;
  static const int BlendSourceBlendColor = WebGLRenderingContext.CONSTANT_COLOR;
  static const int BlendSourceBlendAlpha = WebGLRenderingContext.CONSTANT_ALPHA;
  static const int BlendSourceBlendInverseColor =
      WebGLRenderingContext.ONE_MINUS_CONSTANT_COLOR;
  static const int BlendSourceBlendInverseAlpha =
      WebGLRenderingContext.ONE_MINUS_CONSTANT_ALPHA;

  static const int BlendOpAdd = WebGLRenderingContext.FUNC_ADD;
  static const int BlendOpSubtract = WebGLRenderingContext.FUNC_SUBTRACT;
  static const int BlendOpReverseSubtract =
      WebGLRenderingContext.FUNC_REVERSE_SUBTRACT;

  // Constant blend values
  double blendColorRed;
  double blendColorGreen;
  double blendColorBlue;
  double blendColorAlpha;

  // off by default
  bool blendEnable;
  int blendSourceColorFunc; /* "Source" = "Shader" */
  int blendDestColorFunc; /* "Destination" = "Render Target" */
  int blendSourceAlphaFunc;
  int blendDestAlphaFunc;

  /* Destination = BlendSource<Color|Alpha>Func blend?Op BlendDest<Color|Alpha>Func */
  int blendColorOp;
  int blendAlphaOp;

  // Render Target write flags
  bool writeRenderTargetRed;
  bool writeRenderTargetGreen;
  bool writeRenderTargetBlue;
  bool writeRenderTargetAlpha;

  BlendState(String name, GraphicsDevice device) : super._internal(name, device) {
    // Default state
    blendColorRed = 1.0;
    blendColorGreen = 1.0;
    blendColorBlue = 1.0;
    blendColorAlpha = 1.0;

    blendEnable = false;
    blendSourceColorFunc = BlendSourceOne;
    blendDestColorFunc = BlendSourceZero;
    blendSourceAlphaFunc = BlendSourceOne;
    blendDestAlphaFunc = BlendSourceZero;
    blendColorOp = BlendOpAdd;
    blendAlphaOp = BlendOpAdd;

    writeRenderTargetRed = true;
    writeRenderTargetGreen = true;
    writeRenderTargetBlue = true;
    writeRenderTargetAlpha = true;
  }

  dynamic filter(dynamic o) {
    if (o is String) {
      var table = {
       "BlendSourceZero": WebGLRenderingContext.ZERO,
       "BlendSourceOne": WebGLRenderingContext.ONE,
       "BlendSourceShaderColor": WebGLRenderingContext.SRC_COLOR,
       "BlendSourceShaderInverseColor": WebGLRenderingContext.ONE_MINUS_SRC_COLOR,
       "BlendSourceShaderAlpha": WebGLRenderingContext.SRC_ALPHA,
       "BlendSourceShaderInverseAlpha": WebGLRenderingContext.ONE_MINUS_SRC_ALPHA,
       "BlendSourceTargetColor": WebGLRenderingContext.DST_COLOR,
       "BlendSourceTargetInverseColor": WebGLRenderingContext.ONE_MINUS_DST_COLOR,
       "BlendSourceTargetAlpha": WebGLRenderingContext.DST_ALPHA,
       "BlendSourceTargetInverseAlpha": WebGLRenderingContext.ONE_MINUS_DST_ALPHA,
       "BlendSourceBlendColor": WebGLRenderingContext.CONSTANT_COLOR,
       "BlendSourceBlendAlpha": WebGLRenderingContext.CONSTANT_ALPHA,
       "BlendSourceBlendInverseColor": WebGLRenderingContext.ONE_MINUS_CONSTANT_COLOR,
       "BlendSourceBlendInverseAlpha": WebGLRenderingContext.ONE_MINUS_CONSTANT_ALPHA,
       "BlendOpAdd": WebGLRenderingContext.FUNC_ADD,
       "BlendOpSubtract": WebGLRenderingContext.FUNC_SUBTRACT,
       "BlendOpReverseSubtract": WebGLRenderingContext.FUNC_REVERSE_SUBTRACT
      };
      return table[o];
    }
    return o;
  }

}

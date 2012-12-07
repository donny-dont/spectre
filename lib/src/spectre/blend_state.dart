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
  static final int BlendSourceZero = WebGLRenderingContext.ZERO;
  static final int BlendSourceOne = WebGLRenderingContext.ONE;
  static final int BlendSourceShaderColor = WebGLRenderingContext.SRC_COLOR;
  static final int BlendSourceShaderInverseColor = WebGLRenderingContext.ONE_MINUS_SRC_COLOR;
  static final int BlendSourceShaderAlpha = WebGLRenderingContext.SRC_ALPHA;
  static final int BlendSourceShaderInverseAlpha = WebGLRenderingContext.ONE_MINUS_SRC_ALPHA;
  static final int BlendSourceTargetColor = WebGLRenderingContext.DST_COLOR;
  static final int BlendSourceTargetInverseColor = WebGLRenderingContext.ONE_MINUS_DST_COLOR;
  static final int BlendSourceTargetAlpha = WebGLRenderingContext.DST_ALPHA;
  static final int BlendSourceTargetInverseAlpha = WebGLRenderingContext.ONE_MINUS_DST_ALPHA;
  static final int BlendSourceBlendColor = WebGLRenderingContext.CONSTANT_COLOR;
  static final int BlendSourceBlendAlpha = WebGLRenderingContext.CONSTANT_ALPHA;
  static final int BlendSourceBlendInverseColor = WebGLRenderingContext.ONE_MINUS_CONSTANT_COLOR;
  static final int BlendSourceBlendInverseAlpha = WebGLRenderingContext.ONE_MINUS_CONSTANT_ALPHA;

  static final int BlendOpAdd = WebGLRenderingContext.FUNC_ADD;
  static final int BlendOpSubtract = WebGLRenderingContext.FUNC_SUBTRACT;
  static final int BlendOpReverseSubtract = WebGLRenderingContext.FUNC_REVERSE_SUBTRACT;

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
  void _createDeviceState() {
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
  void _configDeviceState(Map props) {
    if (props != null) {
      dynamic o;
      o = props['blendColorRed'];
      blendColorRed = o != null ? filter(o) : blendColorRed;
      o = props['blendColorGreen'];
      blendColorGreen = o != null ? filter(o) : blendColorGreen;
      o = props['blendColorBlue'];
      blendColorBlue = o != null ? filter(o) : blendColorBlue;
      o = props['blendColorAlpha'];
      blendColorAlpha = o != null ? filter(o) : blendColorAlpha;

      o = props['blendEnable'];
      blendEnable = o != null ? filter(o) : blendEnable;
      o = props['blendSourceColorFunc'];
      blendSourceColorFunc = o != null ? filter(o) : blendSourceColorFunc;
      o = props['blendDestColorFunc'];
      blendDestColorFunc = o != null ? filter(o) : blendDestColorFunc;
      o = props['blendSourceAlphaFunc'];
      blendSourceAlphaFunc = o != null ? filter(o) : blendSourceAlphaFunc;
      o = props['blendDestAlphaFunc'];
      blendDestAlphaFunc = o != null ? filter(o) : blendDestAlphaFunc;

      o = props['blendColorOp'];
      blendColorOp = o != null ? filter(o) : blendColorOp;
      o = props['blendAlphaOp'];
      blendAlphaOp = o != null ? filter(o) : blendAlphaOp;

      o = props['writeRenderTargetRed'];
      writeRenderTargetRed = o != null ? filter(o) : writeRenderTargetRed;
      o = props['writeRenderTargetGreen'];
      writeRenderTargetGreen = o != null ? filter(o) : writeRenderTargetGreen;
      o = props['writeRenderTargetBlue'];
      writeRenderTargetBlue = o != null ? filter(o) : writeRenderTargetBlue;
      o = props['writeRenderTargetAlpha'];
      writeRenderTargetAlpha = o != null ? filter(o) : writeRenderTargetAlpha;
    }
  }

  void _destroyDeviceState() {

  }
}

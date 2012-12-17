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

  //---------------------------------------------------------------------
  // Class variables
  //
  // These should go away once mirrors work for dart2js.
  //---------------------------------------------------------------------

  /// Serialization name for [blendColor].
  static const String blendColorName = 'blendColor';
  /// Serialization name for [blendEnabled].
  static const String blendEnabledName = 'blendEnabled';
  /// Serialization name for [alphaBlendFunction].
  static const String alphaBlendFunctionName = 'alphaBlendFunction';
  /// Serialization name for [alphaDestinationBlend].
  static const String alphaDestinationBlendName = 'alphaDestination';
  /// Serialization name for [alphaSourceBlend].
  static const String alphaSourceBlendName = 'alphaSourceBlend';
  /// Serialization name for [colorBlendFunction].
  static const String colorBlendFunctionName = 'colorBlendFunction';
  /// Serialization name for [colorDestinationBlend].
  static const String colorDestinationBlendName = 'colorDestinationBlend';
  /// Serialization name for [colorSourceBlend].
  static const String colorSourceBlendName = 'colorSourceBlend';
  /// Serialization name for [colorWriteChannels].
  static const String colorWriteChannels = 'colorWriteChannels';

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  // Constant blend values
  double blendColorRed;
  double blendColorGreen;
  double blendColorBlue;
  double blendColorAlpha;

  /// Whether blending operations are enabled. Disabled by default.
  bool _blendEnabled;

  /// The arithmetic operation when blending alpha values.
  /// The default is [BlendFunction.Add].
  int _alphaBlendFunction;
  /// The blend factor for the destination alpha; the percentage of the destination alpha included in the result.
  /// The default is [Blend.One].
  int _alphaDestinationBlend;
  /// The alpha blend factor.
  /// The default is [Blend.One].
  int _alphaSourceBlend;
  /// The arithmetic operation when blending color values.
  /// The default is [BlendFunction.Add].
  int _colorBlendFunction;
  /// The blend factor for the destination color.
  /// The default is [Blend.One].
  int _colorDestinationBlend;
  /// The blend factor for the source color.
  /// The default is Blend.One.
  int _colorSourceBlend;

  /// Whether the red channel is enabled for writing during color blending.
  bool _writeRenderTargetRed;
  /// Whether the green channel is enabled for writing during color blending.
  bool _writeRenderTargetGreen;
  /// Whether the blue channel is enabled for writing during color blending.
  bool _writeRenderTargetBlue;
  /// Whether the alpha channel is enabled for writing during color blending.
  bool _writeRenderTargetAlpha;

  BlendState(String name, GraphicsDevice device) : super._internal(name, device) {
    // Default state
    blendColorRed = 1.0;
    blendColorGreen = 1.0;
    blendColorBlue = 1.0;
    blendColorAlpha = 1.0;

    _blendEnabled = false;

    _alphaBlendFunction = BlendOpAdd;
    _alphaDestinationBlend = BlendSourceOne;
    _alphaSourceBlend = BlendSourceOne;

    _colorBlendFunction = BlendOpAdd;
    _colorDestinationBlend = BlendSourceOne;
    _colorSourceBlend = BlendSourceOne;

    _writeRenderTargetRed = true;
    _writeRenderTargetGreen = true;
    _writeRenderTargetBlue = true;
    _writeRenderTargetAlpha = true;
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
      _blendEnable = o != null ? filter(o) : blendEnable;
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

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// Whether blending operations are enabled.
  bool get blendEnabled => _blendEnabled;
  set blendEnabled(bool value) { _blendEnabled = value; }

  /// The arithmetic operation when blending alpha values.
  /// The default is [BlendFunction.Add].
  int get alphaBlendFunction => _alphaBlendFunction;
  set alphaBlendFunction(int value) {
    _alphaBlendFunction = value;
  }

  /// The blend factor for the destination alpha; the percentage of the destination alpha included in the result.
  /// The default is [Blend.One].
  int get alphaDestinationBlend => _alphaDestinationBlend;
  set alphaDestinationBlend(int value) {
    _alphaDestinationBlend = value;
  }

  /// The alpha blend factor.
  /// The default is [Blend.One].
  int get alphaSourceBlend => _alphaSourceBlend;
  set alphaSourceBlend(int value) {
    _alphaSourceBlend = value;
  }

  /// The arithmetic operation when blending color values.
  /// The default is [BlendFunction.Add].
  int get colorBlendFunction => _colorBlendFunction;
  set colorBlendFunction(int value) {
    _colorBlendFunction = value;
  }

  /// The blend factor for the destination color.
  /// The default is [Blend.One].
  int get colorDestinationBlend => _colorDestinationBlend;
  set colorDestinationBlend(int value) {
    _colorDestinationBlend = value;
  }

  /// The blend factor for the source color.
  /// The default is Blend.One.
  int get colorSourceBlend => _colorSourceBlend;
  set colorSourceBlend(int value) {
    _colorSourceBlend = value;
  }

  /// Whether the red channel is enabled for writing during color blending.
  bool get writeRenderTargetRed => _writeRenderTargetRed;
  set writeRenderTargetRed(bool value) { _writeRenderTargetRed = value; }

  /// Whether the green channel is enabled for writing during color blending.
  bool get writeRenderTargetGreen => _writeRenderTargetGreen;
  set writeRenderTargetGreen(bool value) { _writeRenderTargetGreen = value; }

  /// Whether the blue channel is enabled for writing during color blending.
  bool get writeRenderTargetBlue => _writeRenderTargetBlue;
  set writeRenderTargetBlue(bool value) { _writeRenderTargetBlue = value; }

  /// Whether the alpha channel is enabled for writing during color blending.
  bool get writeRenderTargetAlpha => _writeRenderTargetAlpha;
  set writeRenderTargetAlpha(bool value) { _writeRenderTargetAlpha = value; }

  //---------------------------------------------------------------------
  // Serialization
  //---------------------------------------------------------------------

  /// Serializes the [BlendState] to a JSON.
  Map toJson() {

  }

  /// Deserializes the [BlendState] from a JSON.
  void fromJson(Map values) {

  }
}

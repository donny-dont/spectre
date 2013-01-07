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

  //---------------------------------------------------------------------
  // Class variables
  //
  // These should go away once mirrors work for dart2js.
  //---------------------------------------------------------------------

  /// Serialization name for [blendEnabled].
  static const String blendEnabledName = 'enabled';
  /// Serialization name for [blendFactor].
  static const String blendFactorName = 'blendFactor';
  /// Serialization name for [alphaBlendOperation].
  static const String alphaBlendOperationName = 'alphaBlendOperation';
  /// Serialization name for [alphaDestinationBlend].
  static const String alphaDestinationBlendName = 'alphaDestination';
  /// Serialization name for [alphaSourceBlend].
  static const String alphaSourceBlendName = 'alphaSourceBlend';
  /// Serialization name for [colorBlendOperation].
  static const String colorBlendOperationName = 'colorBlendOperation';
  /// Serialization name for [colorDestinationBlend].
  static const String colorDestinationBlendName = 'colorDestinationBlend';
  /// Serialization name for [colorSourceBlend].
  static const String colorSourceBlendName = 'colorSourceBlend';
  /// Serialization name for [colorWriteChannels].
  static const String colorWriteChannelsName = 'colorWriteChannels';

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// Whether blending operations are enabled. Disabled by default.
  bool _enabled;

  /// The four-component (RGBA) blend factor for alpha blending.
  vec4 _blendFactor;

  /// The arithmetic operation when blending alpha values.
  /// The default is [BlendFunction.Add].
  int _alphaBlendOperation;
  /// The blend factor for the destination alpha; the percentage of the destination alpha included in the result.
  /// The default is [Blend.One].
  int _alphaDestinationBlend;
  /// The alpha blend factor.
  /// The default is [Blend.One].
  int _alphaSourceBlend;
  /// The arithmetic operation when blending color values.
  /// The default is [BlendFunction.Add].
  int _colorBlendOperation;
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
    _enabled = false;

    _blendFactor = new vec4.raw(1.0, 1.0, 1.0, 1.0);

    _alphaBlendOperation = BlendOperation.Add;
    _alphaDestinationBlend = Blend.One;
    _alphaSourceBlend = Blend.One;

    _colorBlendOperation = BlendOperation.Add;
    _colorDestinationBlend = Blend.One;
    _colorSourceBlend = Blend.One;

    _writeRenderTargetRed = true;
    _writeRenderTargetGreen = true;
    _writeRenderTargetBlue = true;
    _writeRenderTargetAlpha = true;
  }

  void _createDeviceState() { }
  // \todo Remove?
  void _configDeviceState(Map props) { fromJson(props); }
  void _destroyDeviceState() {}

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// Whether blending operations are enabled.
  bool get enabled => _enabled;
  set enabled(bool value) { _enabled = value; }

  /// The four-component (RGBA) blend factor for alpha blending
  vec4 get blendFactor => _blendFactor;
  set blendFactor(vec4 value) { _blendFactor = value; }

  /// The arithmetic operation when blending alpha values.
  /// The default is [BlendFunction.Add].
  int get alphaBlendOperation => _alphaBlendOperation;
  set alphaBlendOperation(int value) {
    if (!BlendOperation.isValid(value)) {
      throw new ArgumentError('alphaBlendOperation must be an enumeration within BlendOperation.');
    }

    _alphaBlendOperation = value;
  }

  /// The blend factor for the destination alpha; the percentage of the destination alpha included in the result.
  /// The default is [Blend.One].
  int get alphaDestinationBlend => _alphaDestinationBlend;
  set alphaDestinationBlend(int value) {
    if (!Blend.isValid(value)) {
      throw new ArgumentError('alphaDestinationBlend must be an enumeration within Blend.');
    }

    _alphaDestinationBlend = value;
  }

  /// The alpha blend factor.
  /// The default is [Blend.One].
  int get alphaSourceBlend => _alphaSourceBlend;
  set alphaSourceBlend(int value) {
    if (!Blend.isValid(value)) {
      throw new ArgumentError('alphaSourceBlend must be an enumeration within Blend.');
    }

    _alphaSourceBlend = value;
  }

  /// The arithmetic operation when blending color values.
  /// The default is [BlendFunction.Add].
  int get colorBlendOperation => _colorBlendOperation;
  set colorBlendOperation(int value) {
    if (!BlendOperation.isValid(value)) {
      throw new ArgumentError('colorBlendOperation must be an enumeration within BlendOperation.');
    }

    _colorBlendOperation = value;
  }

  /// The blend factor for the destination color.
  /// The default is [Blend.One].
  int get colorDestinationBlend => _colorDestinationBlend;
  set colorDestinationBlend(int value) {
    if (!Blend.isValid(value)) {
      throw new ArgumentError('colorDestinationBlend must be an enumeration within Blend.');
    }

    _colorDestinationBlend = value;
  }

  /// The blend factor for the source color.
  /// The default is Blend.One.
  int get colorSourceBlend => _colorSourceBlend;
  set colorSourceBlend(int value) {
    if (!Blend.isValid(value)) {
      throw new ArgumentError('colorSourceBlend must be an enumeration within Blend.');
    }

    _colorSourceBlend = value;
  }

  /// The color channels (RGBA) that are enabled for writing during color blending.
  int get colorWriteChannels {
    int value;

    // \todo Is there a better way? Shift doesn't work on a bool
    value  = (_writeRenderTargetRed)   ? ColorWriteChannels.Red   : 0;
    value |= (_writeRenderTargetGreen) ? ColorWriteChannels.Green : 0;
    value |= (_writeRenderTargetBlue)  ? ColorWriteChannels.Blue  : 0;
    value |= (_writeRenderTargetAlpha) ? ColorWriteChannels.All   : 0;

    return value;
  }
  set colorWriteChannels(int value) {
    if ((value < 0) || (value > ColorWriteChannels.All)) {
      throw new ArgumentError('colorWriteChannel must be a flag within ColorWriteChannels.');
    }

    _writeRenderTargetRed   = (value & ColorWriteChannels.Red)   == ColorWriteChannels.Red;
    _writeRenderTargetGreen = (value & ColorWriteChannels.Green) == ColorWriteChannels.Green;
    _writeRenderTargetBlue  = (value & ColorWriteChannels.Blue)  == ColorWriteChannels.Blue;
    _writeRenderTargetAlpha = (value & ColorWriteChannels.Alpha) == ColorWriteChannels.Alpha;
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
    Map json = new Map();

    json[blendEnabledName] = _enabled;

    json[alphaBlendOperationName]   = BlendOperation.stringify(_alphaBlendOperation);
    json[alphaDestinationBlendName] = Blend.stringify(_alphaDestinationBlend);
    json[alphaSourceBlendName]      = Blend.stringify(_alphaSourceBlend);

    json[colorBlendOperationName]   = BlendOperation.stringify(_colorBlendOperation);
    json[colorDestinationBlendName] = Blend.stringify(_colorDestinationBlend);
    json[colorSourceBlendName]      = Blend.stringify(_colorSourceBlend);

    Map blendFactorJson = new Map();
    blendFactorJson['r'] = _blendFactor.r;
    blendFactorJson['g'] = _blendFactor.g;
    blendFactorJson['b'] = _blendFactor.b;
    blendFactorJson['a'] = _blendFactor.a;

    json[blendFactorName] = blendFactorJson;
  }

  /// Deserializes the [BlendState] from a JSON.
  void fromJson(Map values) {
    assert(values != null);

    dynamic value;

    value = values[blendEnabledName];
    _enabled = (value != null) ? value : _enabled;

    value = values[alphaBlendOperation];
    _alphaBlendOperation = (value != null) ? BlendOperation.parse(value) : _alphaBlendOperation;
    value = values[alphaDestinationBlendName];
    _alphaDestinationBlend = (value != null) ? Blend.parse(value) : _alphaDestinationBlend;
    value = values[alphaSourceBlendName];
    _alphaSourceBlend = (value != null) ? Blend.parse(value) : _alphaSourceBlend;

    value = values[colorBlendOperation];
    _colorBlendOperation = (value != null) ? BlendOperation.parse(value) : _colorBlendOperation;
    value = values[colorDestinationBlendName];
    _colorDestinationBlend = (value != null) ? Blend.parse(value) : _colorDestinationBlend;
    value = values[colorSourceBlendName];
    _colorSourceBlend = (value != null) ? Blend.parse(value) : _colorSourceBlend;

    dynamic blendFactorJson = values[blendFactorName];

    if (blendFactorJson != null) {
      value = blendFactorJson['r'];
      _blendFactor.r = (value != null) ? value : 0.0;

      value = blendFactorJson['g'];
      _blendFactor.g = (value != null) ? value : 0.0;

      value = blendFactorJson['b'];
      _blendFactor.b = (value != null) ? value : 0.0;

      value = blendFactorJson['a'];
      _blendFactor.a = (value != null) ? value : 0.0;
    }
  }
}

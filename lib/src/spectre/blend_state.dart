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
  /// Serialization name for [blendFactorRed].
  static const String blendFactorRedName = 'blendFactorRed';
  /// Serialization name for [blendFactorGreen].
  static const String blendFactorGreenName = 'blendFactorGreen';
  /// Serialization name for [blendFactorBlue].
  static const String blendFactorBlueName = 'blendFactorBlue';
  /// Serialization name for [blendFactorAlpha].
  static const String blendFactorAlphaName = 'blendFactorAlpha';
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
  /// Serialization name for [writeRenderTargetRed].
  static const String writeRenderTargetRedName = 'writeRenderTargetRed';
  /// Serialization name for [writeRenderTargetGreen].
  static const String writeRenderTargetGreenName = 'writeRenderTargetGreen';
  /// Serialization name for [writeRenderTargetBlue].
  static const String writeRenderTargetBlueName = 'writeRenderTargetBlue';
  /// Serialization name for [writeRenderTargetAlpha].
  static const String writeRenderTargetAlphaName = 'writeRenderTargetAlpha';

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// Whether blending operations are enabled. Enabled by default.
  bool _enabled = true;

  /// The red component of the blend factor for alpha blending.
  double _blendFactorRed = 1.0;
  /// The green component of the blend factor for alpha blending.
  double _blendFactorGreen = 1.0;
  /// The blue component of the blend factor for alpha blending.
  double _blendFactorBlue = 1.0;
  /// The alpha component of the blend factor for alpha blending.
  double _blendFactorAlpha = 1.0;

  /// The arithmetic operation when blending alpha values.
  /// The default is [BlendFunction.Add].
  int _alphaBlendOperation = BlendOperation.Add;
  /// The blend factor for the destination alpha; the percentage of the destination alpha included in the result.
  /// The default is [Blend.One].
  int _alphaDestinationBlend = Blend.One;
  /// The alpha blend factor.
  /// The default is [Blend.One].
  int _alphaSourceBlend = Blend.One;
  /// The arithmetic operation when blending color values.
  /// The default is [BlendFunction.Add].
  int _colorBlendOperation = BlendOperation.Add;
  /// The blend factor for the destination color.
  /// The default is [Blend.One].
  int _colorDestinationBlend = Blend.One;
  /// The blend factor for the source color.
  /// The default is Blend.One.
  int _colorSourceBlend = Blend.One;

  /// Whether the red channel is enabled for writing during color blending.
  bool _writeRenderTargetRed = true;
  /// Whether the green channel is enabled for writing during color blending.
  bool _writeRenderTargetGreen = true;
  /// Whether the blue channel is enabled for writing during color blending.
  bool _writeRenderTargetBlue = true;
  /// Whether the alpha channel is enabled for writing during color blending.
  bool _writeRenderTargetAlpha = true;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the BlendState class with default values.
  BlendState(String name, GraphicsDevice device)
    : super._internal(name, device);

  /// Initializes an instance of the BlendState class with settings for additive blend.
  /// This adds the destination data to the source data without using alpha.
  BlendState.additive(String name, GraphicsDevice device)
    : super._internal(name, device)
    , _alphaDestinationBlend = Blend.One
    , _alphaSourceBlend = Blend.SourceAlpha
    , _colorDestinationBlend = Blend.One
    , _colorSourceBlend = Blend.SourceAlpha;

  /// Initializes an intance of the BlendState class with settings for alpha blend.
  /// This blends the source and destination data using alpha.
  BlendState.alphaBlend(String name, GraphicsDevice device)
    : super._internal(name, device)
    , _alphaDestinationBlend = Blend.InverseSourceAlpha
    , _alphaSourceBlend = Blend.One
    , _colorDestinationBlend = Blend.InverseSourceAlpha
    , _colorSourceBlend = Blend.One;

  /// Initializes an instance of the BlendState class with settings for blending with non-premultipled alpha.
  /// This blends source and destination data by using alpha while assuming the
  /// color data contains no alpha information.
  BlendState.nonPremultiplied(String name, GraphicsDevice device)
    : super._internal(name, device)
    , _alphaDestinationBlend = Blend.InverseSourceAlpha
    , _alphaSourceBlend = Blend.SourceAlpha
    , _colorDestinationBlend = Blend.InverseSourceAlpha
    , _colorSourceBlend = Blend.SourceAlpha;

  /// Initializes an instance of the BlendState class with settings for opaque blend.
  /// This overwrites the source with the destination data.
  BlendState.opaque(String name, GraphicsDevice device)
    : super._internal(name, device)
    , _enabled = false
    , _alphaDestinationBlend = Blend.Zero
    , _alphaSourceBlend = Blend.One
    , _colorDestinationBlend = Blend.Zero
    , _colorSourceBlend = Blend.One;

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// Whether blending operations are enabled.
  bool get enabled => _enabled;
  set enabled(bool value) { _enabled = value; }

  /// The red component of the blend factor for alpha blending.
  /// Throws [ArgumentError] if [value] is not in the range [0, 1].
  double get blendFactorRed => _blendFactorRed;
  set blendFactorRed(double value) {
    if ((value >= 0.0) && (value <= 1.0)) {
      _blendFactorRed = value;

      return;
    }

    throw new ArgumentError('blendFactorRed must be in the range [0, 1]');
  }

  /// The green component of the blend factor for alpha blending.
  /// Throws [ArgumentError] if [value] is not in the range [0, 1].
  double get blendFactorGreen => _blendFactorGreen;
  set blendFactorGreen(double value) {
    if ((value >= 0.0) && (value <= 1.0)) {
      _blendFactorGreen = value;
      return;
    }

    throw new ArgumentError('blendFactorGreen must be in the range [0, 1]');
  }

  /// The blue component of the blend factor for alpha blending.
  /// Throws [ArgumentError] if [value] is not in the range [0, 1].
  double get blendFactorBlue => _blendFactorBlue;
  set blendFactorBlue(double value) {
    if ((value >= 0.0) && (value <= 1.0)) {
      _blendFactorBlue = value;
      return;
    }

    throw new ArgumentError('blendFactorGreen must be in the range [0, 1]');
  }

  /// The alpha component of the blend factor for alpha blending.
  /// Throws [ArgumentError] if [value] is not in the range [0, 1].
  double get blendFactorAlpha => _blendFactorAlpha;
  set blendFactorAlpha(double value) {
    if ((value >= 0.0) && (value <= 1.0)) {
      _blendFactorAlpha = value;
      return;
    }

    throw new ArgumentError('blendFactorGreen must be in the range [0, 1]');
  }

  /// The arithmetic operation when blending alpha values.
  /// The default is [BlendFunction.Add].
  /// Throws [ArgumentError] if the [value] is not an enumeration within [BlendOperation].
  int get alphaBlendOperation => _alphaBlendOperation;
  set alphaBlendOperation(int value) {
    if (!BlendOperation.isValid(value)) {
      throw new ArgumentError('alphaBlendOperation must be an enumeration within BlendOperation.');
    }

    _alphaBlendOperation = value;
  }

  /// The blend factor for the destination alpha; the percentage of the destination alpha included in the result.
  /// The default is [Blend.One].
  /// Throws [ArgumentError] if the [value] is not an enumeration within [Blend].
  int get alphaDestinationBlend => _alphaDestinationBlend;
  set alphaDestinationBlend(int value) {
    if (!Blend.isValid(value)) {
      throw new ArgumentError('alphaDestinationBlend must be an enumeration within Blend.');
    }

    _alphaDestinationBlend = value;
  }

  /// The alpha blend factor.
  /// The default is [Blend.One].
  /// Throws [ArgumentError] if the [value] is not an enumeration within [Blend].
  int get alphaSourceBlend => _alphaSourceBlend;
  set alphaSourceBlend(int value) {
    if (!Blend.isValid(value)) {
      throw new ArgumentError('alphaSourceBlend must be an enumeration within Blend.');
    }

    _alphaSourceBlend = value;
  }

  /// The arithmetic operation when blending color values.
  /// The default is [BlendFunction.Add].
  /// Throws [ArgumentError] if the [value] is not an enumeration within [Blend].
  int get colorBlendOperation => _colorBlendOperation;
  set colorBlendOperation(int value) {
    if (!BlendOperation.isValid(value)) {
      throw new ArgumentError('colorBlendOperation must be an enumeration within BlendOperation.');
    }

    _colorBlendOperation = value;
  }

  /// The blend factor for the destination color.
  /// The default is [Blend.One].
  /// Throws [ArgumentError] if the [value] is not an enumeration within [Blend].
  int get colorDestinationBlend => _colorDestinationBlend;
  set colorDestinationBlend(int value) {
    if (!Blend.isValid(value)) {
      throw new ArgumentError('colorDestinationBlend must be an enumeration within Blend.');
    }

    _colorDestinationBlend = value;
  }

  /// The blend factor for the source color.
  /// The default is Blend.One.
  /// Throws [ArgumentError] if the [value] is not an enumeration within [Blend].
  int get colorSourceBlend => _colorSourceBlend;
  set colorSourceBlend(int value) {
    if (!Blend.isValid(value)) {
      throw new ArgumentError('colorSourceBlend must be an enumeration within Blend.');
    }

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
  // Equality
  //---------------------------------------------------------------------

  /// Compares two [BlendState]s for equality.
  bool operator== (BlendState other) {
    if (identical(this, other)) {
      return true;
    }

    if (_enabled != other._enabled) {
      return false;
    }

    if ((_blendFactorRed   != other._blendFactorRed)   ||
        (_blendFactorGreen != other._blendFactorGreen) ||
        (_blendFactorBlue  != other._blendFactorBlue)  ||
        (_blendFactorAlpha != other._blendFactorAlpha))
    {
      return false;
    }

    if (_alphaBlendOperation != other._alphaBlendOperation) {
      return false;
    }
    if (_alphaDestinationBlend != other._alphaDestinationBlend) {
      return false;
    }
    if (_alphaSourceBlend != other._alphaSourceBlend) {
      return false;
    }

    if (_colorBlendOperation != other._colorBlendOperation) {
      return false;
    }
    if (_colorDestinationBlend != other._colorDestinationBlend) {
      return false;
    }
    if (_colorSourceBlend != other._colorSourceBlend) {
      return false;
    }

    return ((_writeRenderTargetRed   == other._writeRenderTargetRed)   &&
            (_writeRenderTargetGreen == other._writeRenderTargetGreen) &&
            (_writeRenderTargetBlue  == other._writeRenderTargetBlue)  &&
            (_writeRenderTargetAlpha == other._writeRenderTargetAlpha));
  }

  //---------------------------------------------------------------------
  // Serialization
  //---------------------------------------------------------------------

  /// Serializes the [BlendState] to a JSON.
  dynamic toJson() {
    Map json = new Map();

    json[blendEnabledName] = _enabled;

    json[blendFactorRedName]   = _blendFactorRed;
    json[blendFactorGreenName] = _blendFactorGreen;
    json[blendFactorBlueName]  = _blendFactorBlue;
    json[blendFactorAlphaName] = _blendFactorAlpha;

    json[alphaBlendOperationName]   = BlendOperation.stringify(_alphaBlendOperation);
    json[alphaDestinationBlendName] = Blend.stringify(_alphaDestinationBlend);
    json[alphaSourceBlendName]      = Blend.stringify(_alphaSourceBlend);

    json[colorBlendOperationName]   = BlendOperation.stringify(_colorBlendOperation);
    json[colorDestinationBlendName] = Blend.stringify(_colorDestinationBlend);
    json[colorSourceBlendName]      = Blend.stringify(_colorSourceBlend);

    json[writeRenderTargetRedName]   = _writeRenderTargetRed;
    json[writeRenderTargetGreenName] = _writeRenderTargetGreen;
    json[writeRenderTargetBlueName]  = _writeRenderTargetBlue;
    json[writeRenderTargetAlphaName] = _writeRenderTargetAlpha;

    return json;
  }

  /// Deserializes the [BlendState] from a JSON.
  void fromJson(Map values) {
    assert(values != null);

    dynamic value;

    value = values[blendEnabledName];
    _enabled = (value != null) ? value : _enabled;

    value = values[blendFactorRedName];
    _blendFactorRed = (value != null) ? value : _blendFactorRed;
    value = values[blendFactorGreenName];
    _blendFactorGreen = (value != null) ? value : _blendFactorGreen;
    value = values[blendFactorBlueName];
    _blendFactorBlue = (value != null) ? value : _blendFactorBlue;
    value = values[blendFactorAlphaName];
    _blendFactorAlpha = (value != null) ? value : _blendFactorAlpha;

    value = values[alphaBlendOperationName];
    _alphaBlendOperation = (value != null) ? BlendOperation.parse(value) : _alphaBlendOperation;
    value = values[alphaDestinationBlendName];
    _alphaDestinationBlend = (value != null) ? Blend.parse(value) : _alphaDestinationBlend;
    value = values[alphaSourceBlendName];
    _alphaSourceBlend = (value != null) ? Blend.parse(value) : _alphaSourceBlend;

    value = values[colorBlendOperationName];
    _colorBlendOperation = (value != null) ? BlendOperation.parse(value) : _colorBlendOperation;
    value = values[colorDestinationBlendName];
    _colorDestinationBlend = (value != null) ? Blend.parse(value) : _colorDestinationBlend;
    value = values[colorSourceBlendName];
    _colorSourceBlend = (value != null) ? Blend.parse(value) : _colorSourceBlend;

    value = values[writeRenderTargetRedName];
    _writeRenderTargetRed = (value != null) ? value : _writeRenderTargetRed;
    value = values[writeRenderTargetGreenName];
    _writeRenderTargetGreen = (value != null) ? value : _writeRenderTargetGreen;
    value = values[writeRenderTargetBlueName];
    _writeRenderTargetBlue = (value != null) ? value : _writeRenderTargetBlue;
    value = values[writeRenderTargetAlphaName];
    _writeRenderTargetAlpha = (value != null) ? value : _writeRenderTargetAlpha;
  }

  //---------------------------------------------------------------------
  // Private methods
  //---------------------------------------------------------------------

  void _createDeviceState() {
    // BlendState doesn't actually create resources on the graphics card
    // Empty because there's nothing to create.
  }

  void _destroyDeviceState() {
    // BlendState doesn't actually create resources on the graphics card
    // Empty because there's nothing to destroy.
  }
}

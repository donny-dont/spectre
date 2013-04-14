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

/// RasterizerState controls how the GPU rasterizer functions including primitive culling and width of rasterized lines
/// Create using [Device.createRasterizerState]
/// Set using [ImmediateContext.setRasterizerState]
class RasterizerState extends GraphicsResource {
  //---------------------------------------------------------------------
  // Serialization names
  //---------------------------------------------------------------------

  /// Serialization name for [cullMode].
  static const String _cullModeName = 'cullMode';
  /// Serialization name for [frontFace].
  static const String _frontFaceName = 'frontFace';
  /// Serialization name for [depthBias].
  static const String _depthBiasName = 'depthBias';
  /// Serialization name for [slopeScaleDepthBias].
  static const String _slopeScaleDepthBiasName = 'slopeScaleDepthBias';
  /// Serialization name for [scissorTestEnabled].
  static const String _scissorTestEnabledName = 'scissorTestEnabled';

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// Spcifies what triangles are culled based on its direction.
  /// The default value is [CullMode.Back].
  int _cullMode = CullMode.Back;
  /// Specifies the winding of a front facing polygon.
  /// The default value is [FrontFace.CounterClockwise].
  int _frontFace = FrontFace.CounterClockwise;
  /// The depth bias for polygons.
  /// This is the amount of bias to apply to the depth of a primitive to alleviate depth testing
  /// problems for primitives of similar depth.
  /// The default value is 0.
  double _depthBias = 0.0;
  /// A bias value that takes into account the slope of a polygon.
  /// This bias value is applied to coplanar primitives to reduce aliasing and other rendering
  /// artifacts caused by z-fighting.
  /// The default is 0.
  double _slopeScaleDepthBias = 0.0;
  /// Whether scissor testing is enabled.
  /// ScissorTestEnable  Enables or disables scissor testing.
  /// The default is false.
  bool _scissorTestEnabled = false;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates a new instance of the [RasterizerState] class.
  RasterizerState(String name, GraphicsDevice device)
    : super._internal(name, device);

  /// Initializes an instance of the [RasterizerState] class with settings for culling primitives with clockwise winding order.
  /// The state object has the following settings.
  ///     cullMode = CullMode.Back;
  ///     frontFace = FrontFace.CounterClockwise;
  RasterizerState.cullClockwise(String name, GraphicsDevice device)
    : super._internal(name, device)
    , _cullMode = CullMode.Back
    , _frontFace = FrontFace.CounterClockwise;

  /// Initializes an instance of the [RasterizerState] class with settings for culling primitives with counter-clockwise winding order.
  /// The state object has the following settings.
  ///     cullMode = CullMode.Back;
  ///     frontFace = Clockwise;
  RasterizerState.cullCounterClockwise(String name, GraphicsDevice device)
    : super._internal(name, device)
    , _cullMode = CullMode.Back
    , _frontFace = FrontFace.Clockwise;

  /// Initializes an instance of the [RasterizerState] class with settings for not culling any primitives.
  /// The state object has the following settings.
  ///     cullMode = CullMode.None;
  ///     frontFace = FrontFace.CounterClockwise;
  RasterizerState.cullNone(String name, GraphicsDevice device)
    : super._internal(name, device)
    , _cullMode = CullMode.None
    , _frontFace = FrontFace.CounterClockwise;

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// Spcifies what triangles are culled based on its direction.
  /// The default value is [CullMode.Back].
  /// Throws [ArgumentError] if the [value] is not an enumeration within [CullMode].
  int get cullMode => _cullMode;
  set cullMode(int value) {
    if (!CullMode.isValid(value)) {
      throw new ArgumentError('cullMode must be an enumeration within CullMode.');
    }

    _cullMode = value;
  }

  /// Specifies the winding of a front facing polygon.
  /// The default value is [FrontFace.CounterClockwise].
  /// Throws [ArgumentError] if the [value] is not an enumeration within [FrontFace].
  int get frontFace => _frontFace;
  set frontFace(int value) {
    if (!FrontFace.isValid(value)) {
      throw new ArgumentError('frontFace must be an enumeration within FrontFace.');
    }

    _frontFace = value;
  }

  /// The depth bias for polygons.
  /// This is the amount of bias to apply to the depth of a primitive to alleviate depth testing
  /// problems for primitives of similar depth.
  /// The default value is 0.
  double get depthBias => _depthBias;
  set depthBias(double value) { _depthBias = value; }

  /// A bias value that takes into account the slope of a polygon.
  /// This bias value is applied to coplanar primitives to reduce aliasing and other rendering
  /// artifacts caused by z-fighting.
  /// The default is 0.
  double get slopeScaleDepthBias => _slopeScaleDepthBias;
  set slopeScaleDepthBias(double value) { _slopeScaleDepthBias = value; }

  /// Whether scissor testing is enabled.
  /// ScissorTestEnable  Enables or disables scissor testing.
  /// The default is false.
  bool get scissorTestEnabled => _scissorTestEnabled;
  set scissorTestEnabled(bool value) { _scissorTestEnabled = value; }

  //---------------------------------------------------------------------
  // Serialization
  //---------------------------------------------------------------------

  /// Serializes the [RasterizerState] to a JSON.
  dynamic toJson() {
    Map json = new Map();

    json[_cullModeName]  = CullMode.stringify(_cullMode);
    json[_frontFaceName] = FrontFace.stringify(_frontFace);

    json[_depthBiasName]           = _depthBias;
    json[_slopeScaleDepthBiasName] = _slopeScaleDepthBias;

    json[_scissorTestEnabledName] = _scissorTestEnabled;

    return json;
  }

  /// Deserializes the [RasterizerState] from a JSON.
  void fromJson(dynamic values) {
    assert(values != null);

    dynamic value;

    value = values[_cullModeName];
    _cullMode = (value != null) ? CullMode.parse(value) : _cullMode;
    value = values[_frontFaceName];
    _frontFace = (value != null) ? FrontFace.parse(value): _frontFace;

    value = values[_depthBiasName];
    _depthBias = (value != null) ? value : _depthBias;
    value = values[_slopeScaleDepthBiasName];
    _slopeScaleDepthBias = (value != null) ? value : _slopeScaleDepthBias;

    value = values[_scissorTestEnabledName];
    _scissorTestEnabled = (value != null) ? value : _scissorTestEnabled;
  }
}

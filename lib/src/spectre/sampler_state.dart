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

/// Contains sampler state, which determines how to sample texture data.
class SamplerState extends DeviceChild {
  //---------------------------------------------------------------------
  // Serialization names
  //---------------------------------------------------------------------

  /// Serialization name for [addressU].
  static const String _addressUName = 'addressU';
  /// Serialization name for [wrapV].
  static const String _addressVName = 'addressV';
  /// Serialization name for [minFilter].
  static const String _minFilterName = 'minFilter';
  /// Serialization name for [magFilter].
  static const String _magFilterName = 'magFilter';
  /// Serialization name for [maxAnisotropy].
  static const String _maxAnisotropyName = 'maxAnisotropy';

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The texture-address mode for the u-coordinate.
  int _addressU = TextureAddressMode.Wrap;
  /// The texture-address mode for the v-coordinate.
  int _addressV = TextureAddressMode.Wrap;
  /// The minification filter to use.
  int _minFilter = TextureMinFilter.Linear;
  /// The magnification filter to use.
  int _magFilter = TextureMagFilter.Linear;
  /// The maximum anisotropy.
  ///
  /// The default value is 1.0.
  double _maxAnisotropy = 1.0;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of [SamplerState] with default values.
  SamplerState(String name, GraphicsDevice device)
    : super._internal(name, device);

  /// Initializes an instance of [SamplerState] with anisotropic filtering and texture coordinate clamping.
  ///
  /// The state object has the following settings.
  ///     addressU = TextureAddressMode.Clamp;
  ///     addressV = TextureAddressMode.Clamp;
  ///     maxAnisotropy = 4;
  SamplerState.anisotropicClamp(String name, GraphicsDevice device)
    : super._internal(name, device)
    , _addressU = TextureAddressMode.Clamp
    , _addressV = TextureAddressMode.Clamp
    , _maxAnisotropy = 4.0;

  /// Initializes an instance of [SamplerState] with anisotropic filtering and texture coordinate wrapping.
  ///
  /// The state object has the following settings.
  ///     addressU = TextureAddressMode.Wrap;
  ///     addressV = TextureAddressMode.Wrap;
  ///     maxAnisotropy = 4;
  SamplerState.anisotropicWrap(String name, GraphicsDevice device)
    : super._internal(name, device)
    , _addressU = TextureAddressMode.Wrap
    , _addressV = TextureAddressMode.Wrap
    , _maxAnisotropy = 4.0;

  /// Initializes an instance of [SamplerState] with linear filtering and texture coordinate clamping.
  ///
  /// The state object has the following settings.
  ///     addressU = TextureAddressMode.Clamp;
  ///     addressV = TextureAddressMode.Clamp;
  ///     minFilter = TextureMinFilter.Linear;
  ///     magFilter = TextureMagFilter.Linear;
  SamplerState.linearClamp(String name, GraphicsDevice device)
    : super._internal(name, device)
    , _addressU = TextureAddressMode.Clamp
    , _addressV = TextureAddressMode.Clamp
    , _minFilter = TextureMinFilter.Linear
    , _magFilter = TextureMagFilter.Linear;

  /// Initializes an instance of [SamplerState] with linear filtering and texture coordinate wrapping.
  ///
  /// The state object has the following settings.
  ///     addressU = TextureAddressMode.Wrap;
  ///     addressV = TextureAddressMode.Wrap;
  ///     minFilter = TextureMinFilter.Linear;
  ///     magFilter = TextureMagFilter.Linear;
  SamplerState.linearWrap(String name, GraphicsDevice device)
    : super._internal(name, device)
    , _addressU = TextureAddressMode.Wrap
    , _addressV = TextureAddressMode.Wrap
    , _minFilter = TextureMinFilter.Linear
    , _magFilter = TextureMagFilter.Linear;

  /// Initializes an instance of [SamplerState] with point filtering and texture coordinate clamping.
  ///
  /// The state object has the following settings.
  ///     addressU = TextureAddressMode.Clamp;
  ///     addressV = TextureAddressMode.Clamp;
  ///     minFilter = TextureMinFilter.Point;
  ///     magFilter = TextureMagFilter.Point;
  SamplerState.pointClamp(String name, GraphicsDevice device)
    : super._internal(name, device)
    , _addressU = TextureAddressMode.Clamp
    , _addressV = TextureAddressMode.Clamp
    , _minFilter = TextureMinFilter.Point
    , _magFilter = TextureMagFilter.Point;

  /// Initializes an instance of [SamplerState] with point filtering and texture coordinate wrapping.
  ///
  /// The state object has the following settings.
  ///     addressU = TextureAddressMode.Wrap;
  ///     addressV = TextureAddressMode.Wrap;
  ///     minFilter = TextureMinFilter.Point;
  ///     magFilter = TextureMagFilter.Point;
  SamplerState.pointWrap(String name, GraphicsDevice device)
    : super._internal(name, device)
    , _addressU = TextureAddressMode.Wrap
    , _addressV = TextureAddressMode.Wrap
    , _minFilter = TextureMinFilter.Point
    , _magFilter = TextureMagFilter.Point;

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The texture-address mode for the u-coordinate.
  int get addressU => _addressU;
  set addressU(int value) {
    if (!TextureAddressMode.isValid(value)) {
      throw new ArgumentError('addressU must be an enumeration within TextureAddressMode.');
    }

    _addressU = value;
  }

  /// The texture-address mode for the v-coordinate.
  int get addressV => _addressV;
  set addressV(int value) {
    if (!TextureAddressMode.isValid(value)) {
      throw new ArgumentError('addressU must be an enumeration within TextureAddressMode.');
    }

    _addressV = value;
  }

  /// The minification filter to use.
  ///
  /// Throws [ArgumentError] if the [value] is not an enumeration within [TextureMinFilter].
  int get minFilter => _minFilter;
  set minFilter(int value) {
    if (!TextureMinFilter.isValid(value)) {
      throw new ArgumentError('minFilter must be an enumeration within TextureMinFilter.');
    }

    _minFilter = value;
  }

  /// The magnification filter to use.
  ///
  /// If the [Texture] does not contain mipmaps, such as non-power of two textures,
  /// then the only valid values are [Texture.Linear] and [Texture.Point].
  ///
  /// Throws [ArgumentError] if the [value] is not an enumeration within [TextureMinFilter].
  int get magFilter => _magFilter;
  set magFilter(int value) {
    if (!TextureMagFilter.isValid(value)) {
      throw new ArgumentError('magFilter must be an enumeration within TextureMagFilter.');
    }

    _magFilter = value;
  }

  /// The maximum anisotropy.
  ///
  /// Anisotropic filtering is only available through an extension to WebGL.
  /// The maximum acceptable value is dependent on the graphics hardware, and
  /// can be queried within [GraphicsDeviceCapabilites]. When setting the value
  /// the anisotropy level will be capped to the range 1 < [GraphicsDeviceCapabilities.maxAnisotropyLevel]
  ///
  /// Throws [ArgumentError] if [value] is not a positive number.
  double get maxAnisotropy => _maxAnisotropy;
  set maxAnisotropy(double value) {
    if (value < 1.0) {
      throw new ArgumentError('maxAnisotropy must be >= 1.0');
    }

    _maxAnisotropy = Math.min(value, device.capabilities.maxAnisotropyLevel);
  }

  //---------------------------------------------------------------------
  // Serialization
  //---------------------------------------------------------------------

  /// Serializes the [SamplerState] to a JSON.
  dynamic toJson() {
    Map json = new Map();

    json[_addressUName] = TextureAddressMode.stringify(_addressU);
    json[_addressVName] = TextureAddressMode.stringify(_addressV);

    json[_minFilterName] = TextureMinFilter.stringify(_minFilter);
    json[_magFilterName] = TextureMagFilter.stringify(_magFilter);

    json[_maxAnisotropyName] = _maxAnisotropy;

    return json;
  }

  /// Deserializes the [SamplerState] from a JSON.
  void fromJson(Map values) {
    assert(values != null);

    dynamic value;

    value = values[_addressUName];
    _addressU = (value != null) ? TextureAddressMode.parse(value) : _addressU;

    value = values[_addressVName];
    _addressV = (value != null) ? TextureAddressMode.parse(value) : _addressV;

    value = values[_minFilterName];
    _minFilter = (value != null) ? TextureMinFilter.parse(value) : _minFilter;

    value = values[_magFilterName];
    _magFilter = (value != null) ? TextureMagFilter.parse(value) : _magFilter;

    // Use the property so the anisotropy is clamped properly
    value = values[_maxAnisotropyName];
    maxAnisotropy = (value != null) ? value : _maxAnisotropy;
  }
}

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
  int _addressU = TextureAddressMode.Clamp;
  /// The texture-address mode for the v-coordinate.
  int _addressV = TextureAddressMode.Clamp;
  /// The minification filter to use.
  int _minFilter;
  /// The magnification filter to use.
  int _magFilter;
  /// The maximum anisotropy.
  ///
  /// The default value is 1.
  int _maxAnisotropy = 1;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of [SamplerState] with default values.
  SamplerState(String name, GraphicsDevice device)
    : super._internal(name, device);

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

    _addressU = value;
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
  int get maxAnisotropy => _maxAnisotropy;
  set maxAnisotropy(int value) {
    if (value < 0) {
      throw new ArgumentError('maxAnisotropy must be a positive number');
    }

    _maxAnisotropy = Math.max(value, device.capabilities.maxAnisotropyLevel);
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

    value = values[_maxAnisotropyName];
    _maxAnisotropy = (value != null) ? value : _maxAnisotropy;
  }
}

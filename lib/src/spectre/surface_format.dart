/*
  Copyright (C) 2013 John McCutchan

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

/// Defines various types of surface formats.
class SurfaceFormat {
  //---------------------------------------------------------------------
  // Serialization names
  //---------------------------------------------------------------------

  /// String representation of [Rgba].
  static const String _rgbaName = 'SurfaceFormat.Rgba';
  /// String representation of [Rgb].
  static const String _rgbName = 'SurfaceFormat.Rgb';
  /// String representation of [Dxt1].
  static const String _dxt1Name = 'SurfaceFormat.Dxt1';
  /// String representation of [Dxt3].
  static const String _dxt3Name = 'SurfaceFormat.Dxt3';
  /// String representation of [Dxt5].
  static const String _dxt5Name = 'SurfaceFormat.Dxt5';

  //---------------------------------------------------------------------
  // Enumerations
  //---------------------------------------------------------------------

  /// 32-bit RGBA pixel format with alpha, using 8 bits per channel.
  ///
  /// Underlying format is an unsigned byte.
  static const int Rgba = WebGL.RGBA;
  /// 24-bit RGB pixel format, using 8 bits per channel.
  ///
  /// Underlying format is an unsigned byte.
  static const int Rgb = WebGL.RGB;
  /// DXT1 compression format.
  ///
  /// Only available if the compressed texture s3tc extension is supported. Assumes
  /// the texture has no alpha component. DXT1 can support alpha but only 1-bit.
  static const int Dxt1 = WebGLCompressedTextureS3TC.COMPRESSED_RGB_S3TC_DXT1_EXT;
  /// DXT3 compression format.
  ///
  /// Only available if the compressed texture s3tc extension is supported.
  static const int Dxt3 = WebGLCompressedTextureS3TC.COMPRESSED_RGBA_S3TC_DXT3_EXT;
  /// DXT5 compression format.
  ///
  /// Only available if the compressed texture s3tc extension is supported.
  static const int Dxt5 = WebGLCompressedTextureS3TC.COMPRESSED_RGBA_S3TC_DXT5_EXT;

  //---------------------------------------------------------------------
  // Class methods
  //---------------------------------------------------------------------

  /// Convert from a [String] name to the corresponding [SurfaceFormat] enumeration.
  static int parse(String name) {
    switch (name) {
      case _rgbaName : return Rgba;
      case _rgbName  : return Rgb;
      case _dxt1Name : return Dxt1;
      case _dxt3Name : return Dxt3;
      case _dxt5Name : return Dxt5;
    }

    assert(false);
    return Rgba;
  }

  /// Converts the [SurfaceFormat] enumeration to a [String].
  static String stringify(int value) {
    switch (value) {
      case Rgba : return _rgbaName;
      case Rgb  : return _rgbName;
      case Dxt1 : return _dxt1Name;
      case Dxt3 : return _dxt3Name;
      case Dxt5 : return _dxt5Name;
    }

    assert(false);
    return _rgbaName;
  }

  /// Checks whether the value is a valid enumeration.
  ///
  /// Should be gotten rid of when enums are supported properly.
  static bool isValid(int value) {
    switch (value) {
      case Rgba :
      case Rgb  :
      case Dxt1 :
      case Dxt3 :
      case Dxt5 : return true;
    }

    return false;
  }

  /// Checks whether the value is a compressed format.
  static bool _isCompressedFormat(int value) {
    return ((value == Dxt1) || (value == Dxt3) || (value == Dxt5));
  }

  /// Retrieves the internal format used by the surface.
  ///
  /// WebGL does not determine the internal format based on the surface type
  /// so this must be queried directly.
  static int _getInternalFormat(int value) {
    // This method will not be called for compressed textures as there's no internal format parameter
    // within compressedTexImage) so just return unsigned byte as the other formats are all unsigned byte
    return WebGL.UNSIGNED_BYTE;
  }
}

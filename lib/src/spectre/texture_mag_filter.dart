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

/// Defines filtering types for magnification during texture sampling.
class TextureMagFilter {
  //---------------------------------------------------------------------
  // Serialization names
  //---------------------------------------------------------------------

  /// String representation of [Linear].
  static const String _linearName = 'TextureMagFilter.Linear';
  /// String representation of [Point].
  static const String _pointName = 'TextureMagFilter.Point';
  /// String representation of [PointMipPoint].
  static const String _pointMipPointName = 'TextureMagFilter.PointMipPoint';
  /// String representation of [PointMipLinear].
  static const String _pointMipLinearName = 'TextureMagFilter.PointMipLinear';
  /// String representation of [LinearMipPoint].
  static const String _linearMipPointName = 'TextureMagFilter.LinearMipPoint';
  /// String representation of [LinearMipLinear].
  static const String _linearMipLinearName = 'TextureMagFilter.LinearMipLinear';

  //---------------------------------------------------------------------
  // Enumerations
  //---------------------------------------------------------------------

  /// Use linear filtering for magnification.
  static const int Linear = WebGL.LINEAR;
  /// Use point filtering for magnification.
  static const int Point = WebGL.NEAREST;
  /// Use point filtering to expand, and point filtering between mipmap levels.
  static const int PointMipPoint = WebGL.NEAREST_MIPMAP_NEAREST;
  /// Use point filtering to expand, and linear filtering between mipmap levels.
  static const int PointMipLinear = WebGL.NEAREST_MIPMAP_LINEAR;
  /// Use linear filtering to expand, and point filtering between mipmap levels.
  static const int LinearMipPoint = WebGL.LINEAR_MIPMAP_NEAREST;
  /// Use linear filtering to expand, and linear filtering between mipmap levels.
  static const int LinearMipLinear = WebGL.LINEAR_MIPMAP_LINEAR;

  //---------------------------------------------------------------------
  // Class methods
  //---------------------------------------------------------------------

  /// Convert from a [String] name to the corresponding [TextureMinFilter] enumeration.
  static int parse(String name) {
    switch (name) {

      case _linearName         : return Linear;
      case _pointName          : return Point;
      case _pointMipPointName  : return PointMipPoint;
      case _pointMipLinearName : return PointMipLinear;
      case _linearMipPointName : return LinearMipPoint;
      case _linearMipLinearName: return LinearMipLinear;
    }

    assert(false);
    return Linear;
  }

  /// Converts the [TextureMinFilter] enumeration to a [String].
  static String stringify(int value) {
    switch (value) {
      case Linear         : return _linearName;
      case Point          : return _pointName;
      case PointMipPoint  : return _pointMipPointName;
      case PointMipLinear : return _pointMipLinearName;
      case LinearMipPoint : return _linearMipPointName;
      case LinearMipLinear: return _linearMipLinearName;
    }

    assert(false);
    return _linearName;
  }

  /// Checks whether the value is a valid enumeration.
  ///
  /// Should be gotten rid of when enums are supported properly.
  static bool isValid(int value) {
    switch (value) {
      case Linear         :
      case Point          :
      case PointMipPoint  :
      case PointMipLinear :
      case LinearMipPoint :
      case LinearMipLinear: return true;
    }

    return false;
  }
}

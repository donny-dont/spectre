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

/// Defines filtering types for minification during texture sampling.
class TextureMinFilter {
  //---------------------------------------------------------------------
  // Serialization names
  //---------------------------------------------------------------------

  /// String representation of [Linear].
  static const String _linearName = 'TextureMinFilter.Linear';
  /// String representation of [Point].
  static const String _pointName = 'TextureMinFilter.Point';

  //---------------------------------------------------------------------
  // Enumerations
  //---------------------------------------------------------------------

  /// Use linear filtering for minification.
  static const int Linear = WebGL.LINEAR;
  /// Use point filtering for minification.
  static const int Point = WebGL.NEAREST;

  //---------------------------------------------------------------------
  // Class methods
  //---------------------------------------------------------------------

  /// Convert from a [String] name to the corresponding [TextureMinFilter] enumeration.
  static int parse(String name) {
    if (name == _linearName) {
      return Linear;
    } else if (name == _pointName) {
      return Point;
    }

    assert(false);
    return Linear;
  }

  /// Converts the [TextureMinFilter] enumeration to a [String].
  static String stringify(int value) {
    if (value == Linear) {
      return _linearName;
    } else if (value == Point) {
      return _pointName;
    }

    assert(false);
    return _linearName;
  }

  /// Checks whether the value is a valid enumeration.
  ///
  /// Should be gotten rid of when enums are supported properly.
  static bool isValid(int value) {
    return ((value == Linear) || (value == Point));
  }
}

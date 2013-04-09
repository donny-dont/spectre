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

/// Defines the winding used to determine whether a triangle is front or back facing.
class FrontFace {
  //---------------------------------------------------------------------
  // Serialization names
  //---------------------------------------------------------------------

  /// String representation of [Clockwise].
  static const String _clockwiseName = 'FrontFace.Clockwise';
  /// String representation of [CounterClockwise].
  static const String _counterClockwiseName = 'FrontFace.CounterClockwise';

  //---------------------------------------------------------------------
  // Enumerations
  //---------------------------------------------------------------------

  /// Triangles are considered front-facing if its vertices are clockwise.
  static const int Clockwise = WebGL.CW;
  /// Triangles are considered front-facing if its vertices are counter-clockwise.
  static const int CounterClockwise = WebGL.CCW;

  //---------------------------------------------------------------------
  // Class methods
  //---------------------------------------------------------------------

  /// Convert from a [String] name to the corresponding [FrontFace] enumeration.
  static int parse(String name) {
    if (name == _clockwiseName) {
      return Clockwise;
    } else if (name == _counterClockwiseName) {
      return CounterClockwise;
    }

    assert(false);
    return Clockwise;
  }

  /// Converts the [Blend] enumeration to a [String].
  static String stringify(int value) {
    if (value == Clockwise) {
      return _clockwiseName;
    } else if (value == CounterClockwise) {
      return _counterClockwiseName;
    }

    assert(false);
    return _clockwiseName;
  }

  /// Checks whether the value is a valid enumeration.
  ///
  /// Should be gotten rid of when enums are supported properly.
  static bool isValid(int value) {
    return ((value == Clockwise) || (value == CounterClockwise));
  }
}

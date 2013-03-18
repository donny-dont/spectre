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

class VertexElementFormat {
  //---------------------------------------------------------------------
  // Serialization names
  //---------------------------------------------------------------------

  /// String representation of [Scalar].
  static const String _scalarName = 'VertexElementFormat.Scalar';
  /// String representation of [Vector2].
  static const String _vector2Name = 'VertexElementFormat.Vector2';
  /// String representation of [Vector3].
  static const String _vector3Name = 'VertexElementFormat.Vector3';
  /// String representation of [Vector4].
  static const String _vector4Name = 'VertexElementFormat.Vector4';

  //---------------------------------------------------------------------
  // Enumerations
  //---------------------------------------------------------------------

  /// Single-component, 32-bit floating-point element.
  static const int Scalar = 0;
  /// Two-component, 32-bit floating-point element.
  static const int Vector2 = 1;
  /// Three-component, 32-bit floating-point element.
  static const int Vector3 = 2;
  /// Three-component, 32-bit floating-point element.
  static const int Vector4 = 3;

  //---------------------------------------------------------------------
  // Class methods
  //---------------------------------------------------------------------

  /// Convert from a [String] name to the corresponding [VertexElementFormat] enumeration.
  static int parse(String name) {
    switch (name) {
      case _scalarName : return Scalar;
      case _vector2Name: return Vector2;
      case _vector3Name: return Vector3;
      case _vector4Name: return Vector4;
    }

    assert(false);
    return Scalar;
  }

  /// Converts the [VertexElementFormat] enumeration to a [String].
  static String stringify(int value) {
    switch (value) {
      case Scalar : return _scalarName;
      case Vector2: return _vector2Name;
      case Vector3: return _vector3Name;
      case Vector4: return _vector4Name;
    }

    assert(false);
    return _scalarName;
  }

  /// Checks whether the value is a valid enumeration.
  ///
  /// Should be gotten rid of when enums are supported properly.
  static bool isValid(int value) {
    switch (value) {
      case Scalar :
      case Vector2:
      case Vector3:
      case Vector4: return true;
    }

    return false;
  }
}

/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>
  Copyright (C) 2013 Don Olmstead <don.j.olmstead@gmail.com>

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

/// Defines usage for the input elements.
class InputElementUsage {
  //---------------------------------------------------------------------
  // Serialization names
  //---------------------------------------------------------------------

  /// String representation of [Position].
  static const String _positionName = 'InputElementUsage.Position';
  /// String representation of [Normal].
  static const String _normalName = 'InputElementUsage.Normal';
  /// String representation of [Tangent].
  static const String _tangentName = 'InputElementUsage.Tangent';
  /// String representation of [Binormal].
  static const String _binormalName = 'InputElementUsage.Binormal';
  /// String representation of [TextureCoordinate].
  static const String _textureCoordinateName =
      'InputElementUsage.TextureCoordinate';
  /// String representation of [Color].
  static const String _colorName = 'InputElementUsage.Color';
  /// String representation of [PointSize].
  static const String _pointSizeName = 'InputElementUsage.PointSize';

  //---------------------------------------------------------------------
  // Enumerations
  //---------------------------------------------------------------------

  /// Vertex position data.
  static const int Position = 0;
  /// Vertex normal data.
  static const int Normal = 1;
  /// Vertex tangent data.
  static const int Tangent = 2;
  /// Vertex binormal (bitangent) data.
  static const int Binormal = 3;
  /// Vertex texture coordinate data.
  static const int TextureCoordinate = 4;
  /// Vertex color data.
  static const int Color = 5;
  /// Point size data.
  static const int PointSize = 6;

  //---------------------------------------------------------------------
  // Class methods
  //---------------------------------------------------------------------

  /// Convert from a [String] name to the corresponding [InputElementUsage]
  /// enumeration.
  static int parse(String name) {
    switch (name) {
      case _positionName         : return Position;
      case _normalName           : return Normal;
      case _tangentName          : return Tangent;
      case _binormalName         : return Binormal;
      case _textureCoordinateName: return TextureCoordinate;
      case _colorName            : return Color;
      case _pointSizeName        : return PointSize;
    }

    assert(false);
    return Position;
  }

  /// Converts the [InputElementUsage] enumeration to a [String].
  static String stringify(int value) {
    switch (value) {
      case Position         : return _positionName;
      case Normal           : return _normalName;
      case Tangent          : return _tangentName;
      case Binormal         : return _binormalName;
      case TextureCoordinate: return _textureCoordinateName;
      case Color            : return _colorName;
      case PointSize        : return _pointSizeName;
    }

    assert(false);
    return _positionName;
  }

  /// Checks whether the value is a valid enumeration.
  ///
  /// Should be gotten rid of when enums are supported properly.
  static bool isValid(int value) {
    switch (value) {
      case Position         :
      case Normal           :
      case Tangent          :
      case Binormal         :
      case TextureCoordinate:
      case Color            :
      case PointSize        : return true;
    }

    return false;
  }
}

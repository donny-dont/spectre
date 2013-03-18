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

class PrimitiveType {
  //---------------------------------------------------------------------
  // Serialization names
  //---------------------------------------------------------------------

  /// String representation of [PointList].
  static const String _pointListName = 'PrimitiveType.PointList';
  /// String representation of [LineList].
  static const String _lineListName = 'PrimitiveType.LineList';
  /// String representation of [LineStrip].
  static const String _lineStripName = 'PrimitiveType.LineStrip';
  /// String representation of [TriangleList].
  static const String _triangleListName = 'PrimitiveType.TriangleList';
  /// String representation of [TriangleStrip].
  static const String _triangleStripName = 'PrimitiveType.TriangleStrip';
  /// String representation of [TriangleFan].
  static const String _triangleFanName = 'PrimitiveType.TriangleFan';

  //---------------------------------------------------------------------
  // Enumerations
  //---------------------------------------------------------------------

  /// String representation of [PointList].
  static const int PointList = WebGLRenderingContext.POINTS;
  /// String representation of [LineList].
  static const int LineList = WebGLRenderingContext.LINES;
  /// String representation of [LineStrip].
  static const int LineStrip = WebGLRenderingContext.LINE_STRIP;
  /// String representation of [TriangleList].
  static const int TriangleList = WebGLRenderingContext.TRIANGLES;
  /// String representation of [TriangleStrip].
  static const int TriangleStrip = WebGLRenderingContext.TRIANGLE_STRIP;
  ///
  static const int TriangleFan = WebGLRenderingContext.TRIANGLE_FAN;

  //---------------------------------------------------------------------
  // Class methods
  //---------------------------------------------------------------------

  /// Convert from a [String] name to the corresponding [PrimitiveType] enumeration.
  static int parse(String name) {
    switch (name) {
      case _pointListName    : return PointList;
      case _lineListName     : return LineList;
      case _lineStripName    : return LineStrip;
      case _triangleListName : return TriangleList;
      case _triangleStripName: return TriangleStrip;
      case _triangleFanName  : return TriangleFan;
    }

    assert(false);
    return TriangleList;
  }

  /// Converts the [PrimitiveType] enumeration to a [String].
  static String stringify(int value) {
    switch (value) {
      case PointList    : return _pointListName;
      case LineList     : return _lineListName;
      case LineStrip    : return _lineStripName;
      case TriangleList : return _triangleListName;
      case TriangleStrip: return _triangleStripName;
      case TriangleFan  : return _triangleFanName;
    }

    assert(false);
    return _triangleListName;
  }

  /// Checks whether the value is a valid enumeration.
  ///
  /// Should be gotten rid of when enums are supported properly.
  static bool isValid(int value) {
    switch (value) {
      case PointList    :
      case LineList     :
      case LineStrip    :
      case TriangleList :
      case TriangleStrip:
      case TriangleFan  : return true;
    }

    return false;
  }
}

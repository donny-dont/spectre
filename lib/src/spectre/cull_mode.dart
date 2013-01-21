part of spectre;

/*

  Copyright (C) 2012 John McCutchan <john@johnmccutchan.com>

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

/// Indicates whether triangles facing a particular direction are drawn.
class CullMode {
  //---------------------------------------------------------------------
  // Serialization names
  //---------------------------------------------------------------------

  /// String representation of [None].
  static const String _noneName = 'CullMode.None';
  /// String representation of [Front].
  static const String _frontName = 'CullMode.Front';
  /// String representation of [Back].
  static const String _backName = 'CullMode.Back';

  //---------------------------------------------------------------------
  // Enumerations
  //---------------------------------------------------------------------

  /// Always draw all triangles.
  static const int None = 0;
  /// Do not draw triangles that are front-facing.
  static const int Front = WebGLRenderingContext.FRONT;
  /// Do not draw triangles that are back-facing.
  static const int Back = WebGLRenderingContext.BACK;

  /// Convert from a [String] name to the corresponding [CullMode] enumeration.
  static int parse(String name) {
    if (name == _noneName) {
      return None;
    } else if (name == _frontName) {
      return Front;
    } else if (name == _backName) {
      return Back;
    }

    assert(false);
    return None;
  }

  /// Converts the [CullMode] enumeration to a [String].
  static String stringify(int value) {
    if (value == None) {
      return _noneName;
    } else if (value == Front) {
      return _frontName;
    } else if (value == Back) {
      return _backName;
    }

    assert(false);
    return _noneName;
  }

  /// Checks whether the value is a valid enumeration.
  ///
  /// Should be gotten rid of when enums are supported properly.
  static bool isValid(int value) {
    if (value == None) {
      return true;
    } else if (value == Front) {
      return true;
    } else if (value == Back) {
      return true;
    }

    return false;
  }
}

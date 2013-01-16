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
  /// Always draw all triangles.
  static const int None = 0;
  /// String representation of [None].
  static const String NoneName = 'CullMode.None';
  /// Do not draw triangles that are front-facing.
  static int Front = WebGLRenderingContext.FRONT;
  /// String representation of [Front].
  static const String FrontName = 'CullMode.Front';
  /// Do not draw triangles that are back-facing.
  static int Back = WebGLRenderingContext.BACK;
  /// String representation of [Back].
  static const String BackName = 'CullMode.Back';

  /// Convert from a [String] name to the corresponding [CullMode] enumeration.
  static int parse(String name) {
    if (name == NoneName) {
      return None;
    } else if (name == FrontName) {
      return Front;
    } else if (name == BackName) {
      return Back;
    }

    assert(false);
    return None;
  }

  /// Converts the [CullMode] enumeration to a [String].
  static String stringify(int value) {
    if (value == None) {
      return NoneName;
    } else if (value == Front) {
      return FrontName;
    } else if (value == Back) {
      return BackName;
    }

    assert(false);
    return NoneName;
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

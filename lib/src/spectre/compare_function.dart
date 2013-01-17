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

/// Defines comparison functions that can be chosen for stencil, or depth-buffer tests.
class CompareFunction {
  //---------------------------------------------------------------------
  // Serialization names
  //---------------------------------------------------------------------

  /// Serialization name for [Always].
  static const String _alwaysName = 'CompareFunction.Always';
  /// Serialization name for [Equal].
  static const String _equalName = 'CompareFunction.Equal';
  /// Serialization name for [Greater].
  static const String _greaterName = 'CompareFunction.Greater';
  /// Serialization name for [GreaterEqual].
  static const String _greaterEqualName = 'CompareFunction.GreaterEqual';
  /// Serialization name for [Less].
  static const String _lessName = 'CompareFunction.Less';
  /// Serialization name for [LessEqual].
  static const String _lessEqualName = 'CompareFunction.LessEqual';
  /// Serialization name for [Fail].
  static const String _failName = 'CompareFunction.Fail';
  /// Serialization name for [NotEqual].
  static const String _notEqualName = 'CompareFunction.NotEqual';

  //---------------------------------------------------------------------
  // Enumerations
  //---------------------------------------------------------------------

  /// Always pass the test.
  static const int Always = WebGLRenderingContext.ALWAYS;
  /// Accept the new pixel if its value is equal to the value of the current pixel.
  static const int Equal = WebGLRenderingContext.EQUAL;
  /// Accept the new pixel if its value is greater than the value of the current pixel.
  static const int Greater = WebGLRenderingContext.GREATER;
  /// Accept the new pixel if its value is greater than or equal to the value of the current pixel.
  static const int GreaterEqual = WebGLRenderingContext.GEQUAL;
  /// Accept the new pixel if its value is less than the value of the current pixel.
  static const int Less = WebGLRenderingContext.LESS;
  /// Accept the new pixel if its value is less than or equal to the value of the current pixel.
  static const int LessEqual = WebGLRenderingContext.LEQUAL;
  /// Always fail the test.
  static const int Fail = WebGLRenderingContext.NEVER;
  ///  Accept the new pixel if its value does not equal the value of the current pixel.
  static const int NotEqual = WebGLRenderingContext.NOTEQUAL;

  //---------------------------------------------------------------------
  // Class methods
  //---------------------------------------------------------------------

  /// Convert from a [String] name to the corresponding [CompareFunction] enumeration.
  static int parse(String name) {
    switch (name) {
      case _alwaysName      : return Always;
      case _equalName       : return Equal;
      case _greaterName     : return Greater;
      case _greaterEqualName: return GreaterEqual;
      case _lessName        : return Less;
      case _lessEqualName   : return LessEqual;
      case _failName        : return Fail;
      case _notEqualName    : return NotEqual;
    }

    assert(false);
    return Always;
  }

  /// Converts the [CompareFunction] enumeration to a [String].
  static String stringify(int value) {
    switch (value) {
      case Always      : return _alwaysName;
      case Equal       : return _equalName;
      case Greater     : return _greaterName;
      case GreaterEqual: return _greaterEqualName;
      case Less        : return _lessName;
      case LessEqual   : return _lessEqualName;
      case Fail        : return _failName;
      case NotEqual    : return _notEqualName;
    }

    assert(false);
    return _alwaysName;
  }

  /// Checks whether the value is a valid enumeration.
  ///
  /// Should be gotten rid of when enums are supported properly.
  static bool isValid(int value) {
    switch (value) {
      case Always      :
      case Equal       :
      case Greater     :
      case GreaterEqual:
      case Less        :
      case LessEqual   :
      case Fail        :
      case NotEqual    : return true;
    }

    return false;
  }
}

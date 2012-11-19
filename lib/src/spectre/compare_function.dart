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

/// Defines comparison functions that can be chosen for alpha, stencil, or depth-buffer tests.
class CompareFunction
{
  /// Always pass the test.
  static const int Always = WebGLRenderingContext.ALWAYS;
  /// String representation of [Always].
  static const String AlwaysName = 'CompareFunction.Always';
  /// Accept the new pixel if its value is equal to the value of the current pixel.
  static const int Equal = WebGLRenderingContext.EQUAL;
  /// String representation of [Equal].
  static const String EqualName = 'CompareFunction.Equal';
  /// Accept the new pixel if its value is greater than the value of the current pixel.
  static const int Greater = WebGLRenderingContext.GREATER;
  /// String representation of [Greater].
  static const String GreaterName = 'CompareFunction.Greater';
  /// Accept the new pixel if its value is greater than or equal to the value of the current pixel.
  static const int GreaterEqual = WebGLRenderingContext.GEQUAL;
  /// String representation of [GreaterEqual].
  static const String GreaterEqualName = 'CompareFunction.GreaterEqual';
  /// Accept the new pixel if its value is less than the value of the current pixel.
  static const int Less = WebGLRenderingContext.LESS;
  /// String representation of [Less].
  static const String LessName = 'CompareFunction.Less';
  /// Accept the new pixel if its value is less than or equal to the value of the current pixel.
  static const int LessEqual = WebGLRenderingContext.LEQUAL;
  /// String representation of [LessEqual].
  static const String LessEqualName = 'CompareFunction.LessEqual';
  /// Always fail the test.
  static const int Fail = WebGLRenderingContext.NEVER;
  /// String representation of [Fail].
  static const String FailName = 'CompareFunction.Fail';
  /// Accept the new pixel if its value does not equal the value of the current pixel.
  static const int NotEqual = WebGLRenderingContext.NOTEQUAL;
  /// String representation of [NotEqual].
  static const String NotEqualName = 'CompareFunction.NotEqual';

  /// Deserialize the [CompareFunction].
  static int deserialize(String name) {
    switch (name) {
      case AlwaysName:       return Always;
      case EqualName:        return Equal;
      case GreaterName:      return Greater;
      case GreaterEqualName: return GreaterEqual;
      case LessName:         return Less;
      case LessEqualName:    return LessEqual;
      case FailName:         return Fail;
      case NotEqualName:     return NotEqual;
    }

    assert(false);
    return Always;
  }

  /// Serialize the [CompareFunction].
  static String serialize(int value) {
    switch (value) {
      case Always:       return AlwaysName;
      case Equal:        return EqualName;
      case Greater:      return GreaterName;
      case GreaterEqual: return GreaterEqualName;
      case Less:         return LessName;
      case LessEqual:    return LessEqualName;
      case Fail:         return FailName;
      case NotEqual:     return NotEqualName;
    }

    assert(false);
    return AlwaysName;
  }

  /// Gets a map containing a name value mapping of the [CompareFunction] enumerations.
  static Map<String, int> get mappings {
    Map<String, int> map = new Map<String, int>();

    map[AlwaysName] = Always;
    map[EqualName] = Equal;
    map[GreaterName] = Greater;
    map[GreaterEqualName] = GreaterEqual;
    map[LessName] = Less;
    map[LessEqualName] = LessEqual;
    map[FailName] = Fail;
    map[NotEqualName] = NotEqual;

    return map;
  }
}

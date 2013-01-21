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

/// Defines color blending factors.
class Blend {
  //---------------------------------------------------------------------
  // Serialization names
  //---------------------------------------------------------------------

  /// String representation of [Zero].
  static const String _zeroName = 'Blend.Zero';
  /// String representation of [One].
  static const String _oneName = 'Blend.One';
  /// String representation of [SourceColor].
  static const String _sourceColorName = 'Blend.SourceColor';
  /// String representation of [InverseSourceColor].
  static const String _inverseSourceColorName = 'Blend.InverseSourceColor';
  /// String representation of [SourceAlpha].
  static const String _sourceAlphaName = 'Blend.SourceAlpha';
  /// String representation of [InverseSourceAlpha].
  static const String _inverseSourceAlphaName = 'Blend.InverseSourceAlpha';
  /// String representation of [DestinationAlpha].
  static const String _destinationAlphaName = 'Blend.DestinationAlpha';
  /// String representation of [InverseDestinationAlpha].
  static const String _inverseDestinationAlphaName = 'Blend.InverseDestinationAlpha';
  /// String representation of [DestinationColor].
  static const String _destinationColorName = 'Blend.DestinationColor';
  /// String representation of [InverseDestinationColor].
  static const String _inverseDestinationColorName = 'Blend.InverseDestinationColor';
  /// String representation of [SourceAlphaSaturation].
  static const String _sourceAlphaSaturationName = 'Blend.SourceAlphaSaturation';
  /// String representation of [BlendFactor].
  static const String _blendFactorName = 'Blend.BlendFactor';
  /// String representation of [InverseBlendFactor].
  static const String _inverseBlendFactorName = 'Blend.InverseBlendFactor';

  //---------------------------------------------------------------------
  // Enumerations
  //---------------------------------------------------------------------

  /// Each component of the color is multiplied by (0, 0, 0, 0).
  static const int Zero = WebGLRenderingContext.ZERO;
  /// Each component of the color is multiplied by (1, 1, 1, 1).
  static const int One = WebGLRenderingContext.ONE;
  /// Each component of the color is multiplied by the source color.
  ///
  /// This can be represented as (Rs, Gs, Bs, As), where R, G, B, and A
  /// respectively stand for the red, green, blue, and alpha source values.
  static const int SourceColor = WebGLRenderingContext.SRC_COLOR;
  /// Each component of the color is multiplied by the inverse of the source color.
  ///
  /// This can be represented as (1 − Rs, 1 − Gs, 1 − Bs, 1 − As) where R, G, B, and A
  /// respectively stand for the red, green, blue, and alpha destination values.
  static const int InverseSourceColor = WebGLRenderingContext.ONE_MINUS_SRC_COLOR;
  /// Each component of the color is multiplied by the alpha value of the source.
  ///
  /// This can be represented as (As, As, As, As), where As is the alpha source value.
  static const int SourceAlpha = WebGLRenderingContext.SRC_ALPHA;
  /// Each component of the color is multiplied by the inverse of the alpha value of the source.
  ///
  /// This can be represented as (1 − As, 1 − As, 1 − As, 1 − As), where As is the alpha destination value.
  static const int InverseSourceAlpha = WebGLRenderingContext.ONE_MINUS_SRC_ALPHA;
  /// Each component of the color is multiplied by the alpha value of the destination.
  ///
  /// This can be represented as (Ad, Ad, Ad, Ad), where Ad is the destination alpha value.
  static const int DestinationAlpha = WebGLRenderingContext.DST_ALPHA;
  /// Each component of the color is multiplied by the inverse of the alpha value of the destination.
  ///
  /// This can be represented as (1 − Ad, 1 − Ad, 1 − Ad, 1 − Ad), where Ad is the alpha destination value.
  static const int InverseDestinationAlpha = WebGLRenderingContext.ONE_MINUS_DST_ALPHA;
  /// Each component color is multiplied by the destination color.
  ///
  /// This can be represented as (Rd, Gd, Bd, Ad), where R, G, B, and A respectively stand for
  /// red, green, blue, and alpha destination values.
  static const int DestinationColor = WebGLRenderingContext.DST_COLOR;
  /// Each component of the color is multiplied by the inverse of the destination color.
  ///
  /// This can be represented as (1 − Rd, 1 − Gd, 1 − Bd, 1 − Ad), where Rd, Gd, Bd, and Ad respectively
  /// stand for the red, green, blue, and alpha destination values.
  static const int InverseDestinationColor = WebGLRenderingContext.ONE_MINUS_DST_COLOR;
  /// Each component of the color is multiplied by either the alpha of the source color, or the inverse of the alpha of the source color, whichever is greater.
  ///
  /// This can be represented as (f, f, f, 1), where f = min(A, 1 − Ad).
  static const int SourceAlphaSaturation = WebGLRenderingContext.SRC_ALPHA_SATURATE;
  /// Each component of the color is multiplied by a constant set in BlendFactor.
  static const int BlendFactor = WebGLRenderingContext.CONSTANT_COLOR;
  /// Each component of the color is multiplied by the inverse of a constant set in BlendFactor.
  static const int InverseBlendFactor = WebGLRenderingContext.ONE_MINUS_CONSTANT_COLOR;

  //---------------------------------------------------------------------
  // Class methods
  //---------------------------------------------------------------------

  /// Convert from a [String] name to the corresponding [Blend] enumeration.
  static int parse(String name) {
    switch (name) {
      case _zeroName                   : return Zero;
      case _oneName                    : return One;
      case _sourceColorName            : return SourceColor;
      case _inverseSourceColorName     : return InverseSourceColor;
      case _sourceAlphaName            : return SourceAlpha;
      case _inverseSourceAlphaName     : return InverseSourceAlpha;
      case _destinationAlphaName       : return DestinationAlpha;
      case _inverseDestinationAlphaName: return InverseDestinationAlpha;
      case _destinationColorName       : return DestinationColor;
      case _inverseDestinationColorName: return InverseDestinationColor;
      case _sourceAlphaSaturationName  : return SourceAlphaSaturation;
      case _blendFactorName            : return BlendFactor;
      case _inverseBlendFactorName     : return InverseBlendFactor;
    }

    assert(false);
    return Zero;
  }

  /// Converts the [Blend] enumeration to a [String].
  static String stringify(int value) {
    switch (value) {
      case Zero                   : return _zeroName;
      case One                    : return _oneName;
      case SourceColor            : return _sourceColorName;
      case InverseSourceColor     : return _inverseSourceColorName;
      case SourceAlpha            : return _sourceAlphaName;
      case InverseSourceAlpha     : return _inverseSourceAlphaName;
      case DestinationAlpha       : return _destinationAlphaName;
      case InverseDestinationAlpha: return _inverseDestinationAlphaName;
      case DestinationColor       : return _destinationColorName;
      case InverseDestinationColor: return _inverseDestinationColorName;
      case SourceAlphaSaturation  : return _sourceAlphaSaturationName;
      case BlendFactor            : return _blendFactorName;
      case InverseBlendFactor     : return _inverseBlendFactorName;
    }

    assert(false);
    return _zeroName;
  }

  /// Checks whether the value is a valid enumeration.
  ///
  /// Should be gotten rid of when enums are supported properly.
  static bool isValid(int value) {
    switch (value) {
      case Zero                   :
      case One                    :
      case SourceColor            :
      case InverseSourceColor     :
      case SourceAlpha            :
      case InverseSourceAlpha     :
      case DestinationAlpha       :
      case InverseDestinationAlpha:
      case DestinationColor       :
      case InverseDestinationColor:
      case SourceAlphaSaturation  :
      case BlendFactor            :
      case InverseBlendFactor     : return true;
    }

    return false;
  }
}

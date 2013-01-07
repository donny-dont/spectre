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
  /// Each component of the color is multiplied by (0, 0, 0, 0).
  static const int Zero = WebGLRenderingContext.ZERO;
  /// String representation of [Zero].
  static const String ZeroName = 'Blend.Zero';
  /// Each component of the color is multiplied by (1, 1, 1, 1).
  static const int One = WebGLRenderingContext.ONE;
  /// String representation of [One].
  static const String OneName = 'Blend.One';
  /// Each component of the color is multiplied by the source color.
  ///
  /// This can be represented as (Rs, Gs, Bs, As), where R, G, B, and A
  /// respectively stand for the red, green, blue, and alpha source values.
  static const int SourceColor = WebGLRenderingContext.SRC_COLOR;
  /// String representation of [SourceColor].
  static const String SourceColorName = 'Blend.SourceColor';
  /// Each component of the color is multiplied by the inverse of the source color.
  ///
  /// This can be represented as (1 − Rs, 1 − Gs, 1 − Bs, 1 − As) where R, G, B, and A
  /// respectively stand for the red, green, blue, and alpha destination values.
  static const int InverseSourceColor = WebGLRenderingContext.ONE_MINUS_SRC_COLOR;
  /// String representation of [InverseSourceColor].
  static const String InverseSourceColorName = 'Blend.InverseSourceColor';
  /// Each component of the color is multiplied by the alpha value of the source.
  ///
  /// This can be represented as (As, As, As, As), where As is the alpha source value.
  static const int SourceAlpha = WebGLRenderingContext.SRC_ALPHA;
  /// String representation of [SourceAlpha].
  static const String SourceAlphaName = 'Blend.SourceAlpha';
  /// Each component of the color is multiplied by the inverse of the alpha value of the source.
  ///
  /// This can be represented as (1 − As, 1 − As, 1 − As, 1 − As), where As is the alpha destination value.
  static const int InverseSourceAlpha = WebGLRenderingContext.ONE_MINUS_SRC_ALPHA;
  /// String representation of [InverseSourceAlpha].
  static const String InverseSourceAlphaName = 'Blend.InverseSourceAlpha';
  /// Each component of the color is multiplied by the alpha value of the destination.
  ///
  /// This can be represented as (Ad, Ad, Ad, Ad), where Ad is the destination alpha value.
  static const int DestinationAlpha = WebGLRenderingContext.DST_ALPHA;
  /// String representation of [DestinationAlpha].
  static const String DestinationAlphaName = 'Blend.DestinationAlpha';
  /// Each component of the color is multiplied by the inverse of the alpha value of the destination.
  ///
  /// This can be represented as (1 − Ad, 1 − Ad, 1 − Ad, 1 − Ad), where Ad is the alpha destination value.
  static const int InverseDestinationAlpha = WebGLRenderingContext.ONE_MINUS_DST_ALPHA;
  /// String representation of [InverseDestinationAlpha].
  static const String InverseDestinationAlphaName = 'Blend.InverseDestinationAlpha';
  /// Each component color is multiplied by the destination color.
  ///
  /// This can be represented as (Rd, Gd, Bd, Ad), where R, G, B, and A respectively stand for
  /// red, green, blue, and alpha destination values.
  static const int DestinationColor = WebGLRenderingContext.DST_COLOR;
  /// String representation of [DestinationColor].
  static const String DestinationColorName = 'Blend.DestinationColor';
  /// Each component of the color is multiplied by the inverse of the destination color.
  ///
  /// This can be represented as (1 − Rd, 1 − Gd, 1 − Bd, 1 − Ad), where Rd, Gd, Bd, and Ad respectively
  /// stand for the red, green, blue, and alpha destination values.
  static const int InverseDestinationColor = WebGLRenderingContext.ONE_MINUS_DST_COLOR;
  /// String representation of [InverseDestinationColor].
  static const String InverseDestinationColorName = 'Blend.InverseDestinationColor';
  /// Each component of the color is multiplied by either the alpha of the source color, or the inverse of the alpha of the source color, whichever is greater.
  ///
  /// This can be represented as (f, f, f, 1), where f = min(A, 1 − Ad).
  static const int SourceAlphaSaturation = WebGLRenderingContext.SRC_ALPHA_SATURATE;
  /// String representation of [SourceAlphaSaturation].
  static const String SourceAlphaSaturationName = 'Blend.SourceAlphaSaturation';
  /// Each component of the color is multiplied by a constant set in BlendFactor.
  static const int BlendFactor = WebGLRenderingContext.CONSTANT_COLOR;
  /// String representation of [BlendFactor].
  static const String BlendFactorName = 'Blend.BlendFactor';
  /// Each component of the color is multiplied by the inverse of a constant set in BlendFactor.
  static const int InverseBlendFactor = WebGLRenderingContext.ONE_MINUS_CONSTANT_COLOR;
  /// String representation of [InverseBlendFactor].
  static const String InverseBlendFactorName = 'Blend.InverseBlendFactor';

  /// Convert from a [String] name to the corresponding [Blend] enumeration.
  static int parse(String name) {
    switch (name) {
      case ZeroName                   : return Zero;
      case OneName                    : return One;
      case SourceColorName            : return SourceColor;
      case InverseSourceColorName     : return InverseSourceColor;
      case SourceAlphaName            : return SourceAlpha;
      case InverseSourceAlphaName     : return InverseSourceAlpha;
      case DestinationAlphaName       : return DestinationAlpha;
      case InverseDestinationAlphaName: return InverseDestinationAlpha;
      case DestinationColorName       : return DestinationColor;
      case InverseDestinationColorName: return InverseDestinationColor;
      case SourceAlphaSaturationName  : return SourceAlphaSaturation;
      case BlendFactorName            : return BlendFactor;
      case InverseBlendFactorName     : return InverseBlendFactor;
    }

    assert(false);
    return Zero;
  }

  /// Converts the [Blend] enumeration to a [String].
  static String stringify(int value) {
    switch (value) {
      case Zero                   : return ZeroName;
      case One                    : return OneName;
      case SourceColor            : return SourceColorName;
      case InverseSourceColor     : return InverseSourceColorName;
      case SourceAlpha            : return SourceAlphaName;
      case InverseSourceAlpha     : return InverseSourceAlphaName;
      case DestinationAlpha       : return DestinationAlphaName;
      case InverseDestinationAlpha: return InverseDestinationAlphaName;
      case DestinationColor       : return DestinationColorName;
      case InverseDestinationColor: return InverseDestinationColorName;
      case SourceAlphaSaturation  : return SourceAlphaSaturationName;
      case BlendFactor            : return BlendFactorName;
      case InverseBlendFactor     : return InverseBlendFactorName;
    }

    assert(false);
    return ZeroName;
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

  /// Gets a map containing a name value mapping of the [Blend] enumerations.
  static Map<String, int> get mappings {
    Map<String, int> map = new Map<String, int>();

    map[ZeroName]                    = Zero;
    map[OneName]                     = One;
    map[SourceColorName]             = SourceColor;
    map[InverseSourceColorName]      = InverseSourceColor;
    map[SourceAlphaName]             = SourceAlpha;
    map[InverseSourceAlphaName]      = InverseSourceAlpha;
    map[DestinationAlphaName]        = DestinationAlpha;
    map[InverseDestinationAlphaName] = InverseDestinationAlpha;
    map[DestinationColorName]        = DestinationColor;
    map[InverseDestinationColorName] = InverseDestinationColor;
    map[SourceAlphaSaturationName]   = SourceAlphaSaturation;
    map[BlendFactorName]             = BlendFactor;
    map[InverseBlendFactorName]      = InverseBlendFactor;

    return map;
  }
}

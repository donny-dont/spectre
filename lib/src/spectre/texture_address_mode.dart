part of spectre;

/**
 * Defines modes for addressing texels using texture coordinates that are outside of the typical range of 0.0 to 1.0.
 */
class TextureAddressMode
{
  /// Clamp Texture coordinates outside the range [0.0, 1.0] are set to the texture color at 0.0 or 1.0, respectively.
  static const int clamp = WebGLRenderingContext.CLAMP_TO_EDGE;
  /// String representation of [clamp].
  static const String clampName = 'TextureAddressMode.clamp';
  /// Similar to [wrap], except that the texture is flipped at every integer junction.
  ///
  /// For u values between 0 and 1, for example, the texture is addressed normally;
  /// between 1 and 2, the texture is flipped (mirrored); between 2 and 3, the
  /// texture is normal again, and so on.
  static const int mirror = WebGLRenderingContext.MIRRORED_REPEAT;
  /// String representation of [mirror].
  static const String mirrorName = 'TextureAddressMode.mirror';
  /// Tile the texture at every integer junction.
  ///
  /// For example, for u values between 0 and 3, the texture is repeated three times;
  /// no mirroring is performed.
  static const int wrap = WebGLRenderingContext.WRAP;
  /// String representation of [wrap'.
  static const String wrapName = 'TextureAddressMode.wrap';

  /// Deserializes the [TextureAddressMode].
  static int deserialize(String name) {
    if (name == clampName) {
      return clamp;
    } else if (name == mirrorName) {
      return mirror;
    } else if (name == wrapName) {
      return wrap;
    }

    assert(false);
    return wrap;
  }

  /// Serialize the [TextureAddressMode].
  static String serialize(int value) {
    if (value == clamp) {
      return clampName;
    } else if (value == mirror) {
      return mirrorName;
    } else if (value == wrap) {
      return wrapName;
    }

    assert(false);
    return wrapName;
  }

  /// Gets a map containing a name value mapping of the [TextureAddressMode] enumerations.
  static Map<String, int> get mappings {
    Map<String, int> map = new Map<String, int>();

    map[clampName] = clamp;
    map[mirrorName] = mirror;
    map[wrapName] = wrap;

    return map;
  }
}

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

/// The declared type of a uniform value.
///
/// Maps to the types exposed in GLSL.
class UniformType
{
  //---------------------------------------------------------------------
  // Sampler types
  //---------------------------------------------------------------------

  /// A 2D sampler value.
  static const int Sampler2d = WebGLRenderingContext.SAMPLER_2D;
  /// String representation of [Sampler2D].
  static const String Sampler2dName = 'sampler2D';
  /// A cube map sampler value.
  static const int SamplerCube = WebGLRenderingContext.SAMPLER_CUBE;
  /// String representation of [SamplerCube].
  static const String SamplerCubeName = 'samplerCube';

  //---------------------------------------------------------------------
  // Floating point vector types
  //---------------------------------------------------------------------

  /// A single floating point value.
  static const int Float = WebGLRenderingContext.FLOAT;
  /// String representation of [Float].
  static const String FloatName = 'float';
  /// A two dimensional vector containing floating point values.
  static const int Vector2f = WebGLRenderingContext.FLOAT_VEC2;
  /// String representation of [Vector2f].
  static const String Vector2fName = 'vec2';
  /// A three dimensional vector containg floating point values.
  static const int Vector3f = WebGLRenderingContext.FLOAT_VEC3;
  /// String representation of [Vector3f].
  static const String Vector3fName = 'vec3';
  /// A four dimensional vector containing floating point values.
  static const int Vector4f = WebGLRenderingContext.FLOAT_VEC4;
  /// String representation of [Vector4f].
  static const String Vector4fName = 'vec4';

  //---------------------------------------------------------------------
  // Floating point matrix types
  //---------------------------------------------------------------------

  /// A 2x2 matrix of floating point values.
  static const int Matrix2x2f = WebGLRenderingContext.FLOAT_MAT2;
  /// String representation of [Matrix2x2f].
  static const String Matrix2x2fName = 'mat2';
  /// A 3x3 matrix of floating point values.
  static const int Matrix3x3f = WebGLRenderingContext.FLOAT_MAT3;
  /// String representation of [Matrix3x3f].
  static const String Matrix3x3fName = 'mat3';
  /// A 4x4 matrix of floating point values.
  static const int Matrix4x4f = WebGLRenderingContext.FLOAT_MAT4;
  /// String representation of [Matrix4x4f].
  static const String Matrix4x4fName = 'mat4';

  //---------------------------------------------------------------------
  // Integer vector types
  //---------------------------------------------------------------------

  /// A single integer value.
  static const int Integer = WebGLRenderingContext.INT;
  /// String representation of [Int].
  static const String IntegerName = 'int';
  /// A two dimensional vector containing integer values.
  static const int Vector2i = WebGLRenderingContext.INT_VEC2;
  /// String representation of [Vector2i].
  static const String Vector2iName = 'ivec2';
  /// A three dimensional vector containg integer values.
  static const int Vector3i = WebGLRenderingContext.INT_VEC3;
  /// String representation of [Vector3i].
  static const String Vector3iName = 'ivec3';
  /// A four dimensional vector containing integer values.
  static const int Vector4i = WebGLRenderingContext.INT_VEC4;
  /// String representation of [Vector4i].
  static const String Vector4iName = 'vec4';

  //---------------------------------------------------------------------
  // Boolean vector types
  //---------------------------------------------------------------------

  /// A single boolean value.
  static const int Boolean = WebGLRenderingContext.BOOL;
  /// String representation of [Boolean].
  static const String BooleanName = 'bool';
  /// A two dimensional vector containing boolean values.
  static const int Vector2b = WebGLRenderingContext.BOOL_VEC2;
  /// String representation of [Vector2b].
  static const String Vector2bName = 'bvec2';
  /// A three dimensional vector containg boolean values.
  static const int Vector3b = WebGLRenderingContext.BOOL_VEC3;
  /// String representation of [Vector3b].
  static const String Vector3bName = 'bvec3';
  /// A four dimensional vector containing boolean values.
  static const int Vector4b = WebGLRenderingContext.BOOL_VEC4;
  /// String representation of [Vector4b].
  static const String Vector4bName = 'bvec4';

  /// Deserializes the [UniformType].
  static int deserialize(String name) {
    switch (name)
    {
      case Sampler2dName  : return Sampler2d;
      case SamplerCubeName: return SamplerCube;
      case FloatName      : return Float;
      case Vector2fName   : return Vector2f;
      case Vector3fName   : return Vector3f;
      case Vector4fName   : return Vector4f;
      case Matrix2x2fName : return Matrix2x2f;
      case Matrix3x3fName : return Matrix3x3f;
      case Matrix4x4fName : return Matrix4x4f;
      case Vector2iName   : return Vector2i;
      case Vector3iName   : return Vector3i;
      case Vector4iName   : return Vector4i;
      case BooleanName    : return Boolean;
      case Vector2bName   : return Vector2b;
      case Vector3bName   : return Vector3b;
      case Vector4bName   : return Vector4b;
    }

    assert(false);
    return Sampler2d;
  }

  /// Serialize the [UniformType].
  static String serialize(int value) {
    switch (value)
    {
      case Sampler2d  : return Sampler2dName;
      case SamplerCube: return SamplerCubeName;
      case Float      : return FloatName;
      case Vector2f   : return Vector2fName;
      case Vector3f   : return Vector3fName;
      case Vector4f   : return Vector4fName;
      case Matrix2x2f : return Matrix2x2fName;
      case Matrix3x3f : return Matrix3x3fName;
      case Matrix4x4f : return Matrix4x4fName;
      case Vector2i   : return Vector2iName;
      case Vector3i   : return Vector3iName;
      case Vector4i   : return Vector4iName;
      case Boolean    : return BooleanName;
      case Vector2b   : return Vector2bName;
      case Vector3b   : return Vector3bName;
      case Vector4b   : return Vector4bName;
    }

    assert(false);
    return Sampler2dName;
  }

  /// Gets a map containing a name value mapping of the [UniformType] enumerations.
  static Map<String, int> get mappings {
    Map<String, int> map = new Map<String, int>();

    map[Sampler2dName]   = Sampler2d;
    map[SamplerCubeName] = SamplerCube;
    map[FloatName]       = Float;
    map[Vector2fName]    = Vector2f;
    map[Vector3fName]    = Vector3f;
    map[Vector4fName]    = Vector4f;
    map[Matrix2x2fName]  = Matrix2x2f;
    map[Matrix3x3fName]  = Matrix3x3f;
    map[Matrix4x4fName]  = Matrix4x4f;
    map[Vector2iName]    = Vector2i;
    map[Vector3iName]    = Vector3i;
    map[Vector4iName]    = Vector4i;
    map[BooleanName]     = Boolean;
    map[Vector2bName]    = Vector2b;
    map[Vector3bName]    = Vector3b;
    map[Vector4bName]    = Vector4b;

    return map;
  }
}

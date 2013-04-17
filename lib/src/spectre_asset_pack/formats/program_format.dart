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

part of spectre_asset_pack;

/// Defines a [ShaderProgram] asset to load.
///
/// This corresponds roughly to the shader specification within the OpenGL
/// Transmission Format (glTF) [https://github.com/KhronosGroup/glTF/blob/master/specification/README.md#program]
/// which ignores the uniform variables field.
class ProgramFormat extends OpenGLTransmissionFormat {
  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The [VertexShader] to attach to the [ShaderProgram].
  ShaderFormat _vertexShader;
  /// The [FragmentShader] to attach to the [ShaderProgram].
  ShaderFormat _fragmentShader;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [ProgramFormat] where the data is in another instance.
  ProgramFormat.reference(String name)
      : super._reference(name);

  /// Creates an instance of the [ProgramFormat] class from JSON data.
  ProgramFormat.fromJson(Map json)
      : super._fromJson(json)
  {

    // Parse the shader data
    _vertexShader   = _parseShader(json['vertexShader']);
    _fragmentShader = _parseShader(json['fragmentShader']);
  }

  /// Parses the [ShaderFormat].
  ShaderFormat _parseShader(dynamic shader) {
    if (shader == null) {
      throw new ArgumentError('Shader not present');
    }

    if (shader is Map) {
      return new ShaderFormat.fromJson(shader);
    } else if (shader is String) {
      return new ShaderFormat.reference(shader);
    } else {
      throw new ArgumentError('Shader data is invalid');
    }
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The [VertexShader] to attach to the [ShaderProgram].
  ShaderFormat get vertexShader => _vertexShader;

  /// The [FragmentShader] to attach to the [ShaderProgram].
  ShaderFormat get fragmentShader => _fragmentShader;

  //---------------------------------------------------------------------
  // Class methods
  //---------------------------------------------------------------------

  /// Parses a list containing [ProgramFormat]s.
  ///
  /// Returns a [Map] containing the [ProgramFormat]s where the [name] is the
  /// key value.
  static Map<String, ProgramFormat> parseList(List formats) {
    var create = (value) => new ProgramFormat.fromJson(value);

    return OpenGLTransmissionFormat._parseList(formats, create);
  }
}

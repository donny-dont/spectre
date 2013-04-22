/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>
  Copyright (C) 2013 Don Olmstead <don.j.olmstead@gmail.com>

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
/// This corresponds roughly to the shader specification within the [OpenGL
/// Transmission Format (glTF)]
/// (https://github.com/KhronosGroup/glTF/blob/master/specification/README.md#program)
/// which ignores the uniform variables field.
class ProgramAttribute {
  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The [_SemanticFormat] that the attribute is referring to.
  _SemanticFormat _semantic;
  /// The name of the symbol within the [ShaderProgram].
  ///
  /// Used to map the name of the attribute within the [ShaderProgram] to
  /// the associated [InputLayoutElement].
  String _symbol;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [ProgramAttribute] class from JSON data.
  ProgramAttribute.fromJson(Map json) {
    _semantic = new _SemanticFormat.parse(json['semantic']);

    _symbol = json['symbol'];

    if (_symbol == null) {
      throw new ArgumentError('Symbol not present');
    }
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The [InputElementUsage] of the semantic.
  int get usage => _semantic.usage;

  /// The index of the semantic.
  int get usageIndex => _semantic.usageIndex;

  /// The name of the symbol within the [ShaderProgram].
  ///
  /// Used to map the name of the attribute within the [ShaderProgram] to
  /// the associated [InputLayoutElement].
  String get symbol => _symbol;
}

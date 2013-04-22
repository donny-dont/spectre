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

/// Defines a semantic.
///
/// Semantics are used to resolve an [InputLayout] and a [ShaderProgram]'s
/// attribute indices. This corresponds to the semantics specification within
/// the [OpenGL Transmission Format (glTF)]
/// (https://github.com/KhronosGroup/glTF/tree/master/specification#semantics)
class _SemanticFormat {
  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The [InputElementUsage] of the semantic.
  int _usage;
  /// The index of the semantic.
  int _usageIndex = 0;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [_SemanticFormat] from a string.
  _SemanticFormat.parse(String value) {
    if (value == null) {
      throw new ArgumentError('No semantic provided');
    }

    // The '_' character is used to separate the semantic name from
    // an optional index
    List<String> values = value.split('_');
    int valueCount = values.length;

    if ((valueCount <= 0) || (valueCount > 2)) {
      throw new ArgumentError('Invalid semantic format');
    }

    _usage = _getInputElementUsage(values[0]);

    if (valueCount == 2) {
      _usageIndex = int.parse(values[1]);
    }
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The [InputElementUsage] of the semantic.
  int get usage => _usage;

  /// The index of the semantic.
  int get usageIndex => _usageIndex;

  //---------------------------------------------------------------------
  // Class methods
  //---------------------------------------------------------------------

  /// Determines the corresponding [InputElementUsage].
  static int _getInputElementUsage(String value) {
    switch (value) {
      case 'POSITION': return InputElementUsage.Position;
      case 'NORMAL'  : return InputElementUsage.Normal;
      case 'TANGENT' : return InputElementUsage.Tangent;
      case 'BINORMAL': return InputElementUsage.Binormal;
      case 'TEXCOORD': return InputElementUsage.TextureCoordinate;
      case 'COLOR'   : return InputElementUsage.Color;
    }

    throw new ArgumentError('Unsupported semantic name');
  }
}

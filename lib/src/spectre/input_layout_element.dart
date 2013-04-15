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

part of spectre;

/// Defines input vertex data to the pipeline.
class InputLayoutElement {
  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  ///
  int _offset;
  int _usageIndex;
  int _format;
  int _usage;
  /// The actual attribute index within WebGL.
  int _vertexAttribIndex;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  InputLayoutElement(int offset, int format, int usage, [int usageIndex = 0])
      : _offset = offset
      , _format = format
      , _usage = usage
      , _usageIndex = usageIndex;

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  int get offset => _offset;
  int get format => _format;
  int get usage => _usage;
  int get usageIndex => _usageIndex;

  //---------------------------------------------------------------------
  // Private methods
  //---------------------------------------------------------------------

  /// Converts the [InputLayoutElement] to a semantic name.
  ///
  /// A semantic name is used to map between the [InputLayout] and the vertex
  /// attributes used in a [ShaderProgram]. This aligns to DirectX conventions.
  String _toSemanticName() {
    String semantic;

    switch (usage) {
      case InputElementUsage.Position         : semantic = 'POSITION'; break;
      case InputElementUsage.Normal           : semantic = 'NORMAL'  ; break;
      case InputElementUsage.Tangent          : semantic = 'TANGENT' ; break;
      case InputElementUsage.Binormal         : semantic = 'BINORMAL'; break;
      case InputElementUsage.TextureCoordinate: semantic = 'TEXCOORD'; break;
      case InputElementUsage.Color            : semantic = 'COLOR'   ; break;
      case InputElementUsage.PointSize        : semantic = 'PSIZE'   ; break;
    }

    return '${semantic}${usageIndex}';
  }
}

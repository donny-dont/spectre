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

class InputLayoutElement {
  final int vboSlot;
   int attributeIndex;
  final int attributeOffset;
  final int attributeStride;
  final DeviceFormat attributeFormat;
  InputLayoutElement(this.vboSlot, this.attributeIndex, this.attributeOffset,
                     this.attributeStride, this.attributeFormat);
}

class InputLayout extends DeviceChild {
  final List<InputLayoutElement> elements = new List<InputLayoutElement>();
  /** A list of shader program attributes the mesh does not have. If this
   * list has any elements the input layout will not be [ready].
   */
  final List<ShaderProgramAttribute> missingAttributes =
      new List<ShaderProgramAttribute>();

  ShaderProgram _shaderProgram;
  ShaderProgram get shaderProgram => _shaderProgram;
  /** Set the shader program. Input layout will be verified to be [ready]. */
  set shaderProgram(ShaderProgram shaderProgram) {
    _shaderProgram = shaderProgram;
    _refresh();
  }

  SpectreMesh _mesh;
  SpectreMesh get mesh => _mesh;
  /** Set the mesh. Input layout will be verified to be [ready]. */
  set mesh(SpectreMesh mesh) {
    _mesh = mesh;
    _refresh();
  }

  /** In order for a InputLayout to be ready the mesh must have
   * all the attributes the shader program requires.
   */
  bool get ready => _shaderProgram != null && _mesh != null &&
                    missingAttributes.length == 0;

  void _refresh() {
    elements.clear();
    missingAttributes.clear();

    if (_shaderProgram == null || _mesh == null) {
      return;
    }

    if (_shaderProgram.attributes.length == 0) {
      print('InputLayout $name shaderProgram has 0 attributes.');
      return;
    }

    if (_mesh.attributes.length == 0) {
      print('InputLayout $name mesh has 0 attributes.');
      return;
    }

    _shaderProgram.attributes.forEach((name, shaderProgramAttribute) {
      SpectreMeshAttribute meshAttribute = _mesh.attributes[name];
      if (meshAttribute == null) {
        missingAttributes.add(shaderProgramAttribute);
      } else {
        InputLayoutElement element = new InputLayoutElement(
            0,
            shaderProgramAttribute.location,
            meshAttribute.offset,
            meshAttribute.stride,
            meshAttribute.deviceFormat);
        elements.add(element);
      }
    });
    print('InputLayout $name refreshed: $ready');
  }

  InputLayout(String name, GraphicsDevice device)
      : super._internal(name, device) {
  }
}
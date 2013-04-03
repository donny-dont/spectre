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

part of spectre_mesh;

class VertexData {
  Map<String, VertexArray> _elements;
  int _vertexCount;

  VertexData(Float32Array array, List<InputLayoutElement> elements) {
    _elements = new Map<String, VertexArray>();

    for (InputLayoutElement element in elements) {
      int count  = element.attributeFormat.count;
      int offset = element.attributeOffset;
      int stride = element.attributeStride;

      _vertexCount = array.length ~/ (stride >> 2);

      VertexArray vertexArray;

      switch (count) {
        case 1:  vertexArray = new Vector2Array.fromArray(array, offset, stride); break;
        case 2:  vertexArray = new Vector2Array.fromArray(array, offset, stride); break;
        case 3:  vertexArray = new Vector3Array.fromArray(array, offset, stride); break;
        default: vertexArray = new Vector4Array.fromArray(array, offset, stride); break;
      }

      String elementName;

      // \TODO remove!
      switch (element.attributeIndex) {
        case 2: elementName = 'vPosition'; break;
        case 1: elementName = 'vNormal'; break;
        case 3: elementName = 'vTangent'; break;
        case 0: elementName = 'vBitangent'; break;
        case 4: elementName = 'vTexCoord0'; break;
      }

      //print('$elementName $count');
      _elements[elementName] = vertexArray;
    }
  }

  Map<String, VertexArray> get elements => _elements;

  int get vertexCount => _vertexCount;
}

/*

  Copyright (C) 2012 The Spectre Project authors.

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


class VertexData {
  Map<String, VertexArray> _elements;

  VertexData(Float32Array array, List<InputElementDescription> elements) {
    _elements = new Map<String, VertexArray>();

    for (InputElementDescription element in elements) {
      int count  = element.format.count;
      int offset = element.vertexBufferOffset;
      int stride = element.elementStride;

      VertexArray vertexArray;

      switch (count) {
        case 1:  vertexArray = new Vector2Array.fromArray(array, offset, stride); break;
        case 2:  vertexArray = new Vector2Array.fromArray(array, offset, stride); break;
        case 3:  vertexArray = new Vector3Array.fromArray(array, offset, stride); break;
        default: vertexArray = new Vector2Array.fromArray(array, offset, stride); break;
      }

      String elementName = element.name;
      _elements[element.name] = vertexArray;
    }
  }

  Map<String, VertexArray> get elements => _elements;
}

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

class NormalDataBuilder {

  /**
   * Calculates the normal data based on the triangle data.
   *
   *
   */
  static void build(Float32Array vertexBuffer,
                    Uint16Array indexBuffer,
                    List<InputElementDescription> bufferLayout)
  {
    VertexData vertexData = new VertexData(vertexBuffer, bufferLayout);
    Vector3Array normals = vertexData.elements['vNormal'];
    assert(normals != null);

    // Compute normals for each triangle
    {
      Vector3Array positions = vertexData.elements['vPosition'];

      // Temporary variables
      vec3 v0;
      vec3 v1;
      vec3 v2;

      int indexCount = indexBuffer.length;

      for (int i = 0; i < indexCount; i += 3) {
        int i0 = indexBuffer[i];
        int i1 = indexBuffer[i + 1];
        int i2 = indexBuffer[i + 2];

        positions.getAt(i0, v0);
        positions.getAt(i1, v1);
        positions.getAt(i2, v2);

        // Compute the normal
        v1.sub(v0); // p0 = v1 - v0
        v2.sub(v0); // p0 = v2 - v0

        v1.cross(v2, v0); // cross(v1, v2)
        v0.normalize();

        // Add the normal to the vertices
        _addToVec3(i0, normals, v0, v1);
        _addToVec3(i1, normals, v0, v1);
        _addToVec3(i2, normals, v0, v1);
      }
    }

    // Normalize the values
    {
      int vertexCount = normals.length;
      vec3 normal;

      for (int i = 0; i < vertexCount; ++i) {
        normals.getAt(i, normal);
        normal.normalize();
        normals.setAt(i, normal);
      }
    }
  }

  static void _addToVec3(int index, Vector3Array array, vec3 value, vec3 temp) {
    array.getAt(index, temp);
    temp.add(value);
    array.setAt(index, temp);
  }
}

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

class TangentSpaceBuilder {

  static void build(Float32Array vertexBuffer,
                    Uint16Array indexBuffer,
                    List<InputElementDescription> bufferLayout)
  {
    VertexData vertexData = new VertexData(vertexBuffer, bufferLayout);
    assert(vertexData.elements['vPosition']  != null);
    assert(vertexData.elements['vTexCoord']  != null);
    assert(vertexData.elements['vNormal']    != null);
    assert(vertexData.elements['vTangent']   != null);
    assert(vertexData.elements['vBitangent'] != null);

    int vertexCount = vertexData.vertexCount;

    Vector3Array tan1 = new Vector3Array(vertexCount);
    Vector3Array tan2 = new Vector3Array(vertexCount);

    {
      Vector3Array positions = vertexData.elements['vPosition'];
      Vector2Array texCoords = vertexData.elements['vTexCoords'];

      vec3 v0;
      vec3 v1;
      vec3 v2;

      vec2 w0;
      vec2 w1;
      vec2 w2;

      vec3 tdir;
      vec3 sdir;

      int indexCount = indexBuffer.length;

      for (int i = 0; i < indexCount; i += 3) {
        int i0 = indexBuffer[i];
        int i1 = indexBuffer[i + 1];
        int i2 = indexBuffer[i + 2];

        positions.getAt(i0, v0);
        positions.getAt(i1, v1);
        positions.getAt(i2, v2);

        texCoords.getAt(i0, w0);
        texCoords.getAt(i1, w1);
        texCoords.getAt(i2, w2);

        double x0 = v1.x - v0.x;
        double x1 = v2.x - v0.x;
        double y0 = v1.y - v0.y;
        double y1 = v2.y - v0.y;
        double z0 = v1.z - v0.z;
        double z1 = v2.z - v0.z;

        double s0 = w1.x - w0.x;
        double s1 = w2.x - w0.x;
        double t0 = w1.y - w0.y;
        double t1 = w2.y - w0.y;

        double r = 1.0 / ((s0 * t1) - (s1 * t0));

        sdir.setComponents(
          ((t1 * x0) - (t0 * x1)) * r,
          ((t1 * y0) - (t0 * y1)) * r,
          ((t1 * z0) - (t0 * z1)) * r
        );

        tdir.setComponents(
          ((s0 * x1) - (s1 * x0)) * r,
          ((s0 * y1) - (s1 * y0)) * r,
          ((s0 * z1) - (s1 * z0)) * r
        );

        _addToVec3(i0, tan1, sdir, v0);
        _addToVec3(i1, tan1, sdir, v0);
        _addToVec3(i2, tan1, sdir, v0);

        _addToVec3(i0, tan2, tdir, v0);
        _addToVec3(i1, tan2, tdir, v0);
        _addToVec3(i2, tan2, tdir, v0);
      }
    }

    {
      Vector3Array normals = vertexData.elements['vNormal'];
      Vector3Array tangents = vertexData.elements['vTangent'];
      Vector3Array bitangents = vertexData.elements['vBitangent'];

      vec3 n;
      vec3 t;
      vec3 temp;
      vec3 nCrossT;

      for (int i = 0; i < vertexCount; ++i) {
        normals.getAt(i, n);
        tan1.getAt(i, t);

        double nDotT = n.dot(t);
        n.cross(t, nCrossT);

        t.sub(n);
        t.x *= nDotT;
        t.y *= nDotT;
        t.z *= nDotT;
        t.normalize();

        tangents.setAt(i, t);

        tan2.getAt(i, t);
        double h = nCrossT.dot(t) < 0.0 ? -1.0 : 0.0;
        nCrossT.x *= h;
        nCrossT.y *= h;
        nCrossT.z *= h;
        bitangents.setAt(i, nCrossT);
      }
    }
  }

  static void _addToVec3(int index, Vector3Array array, vec3 value, vec3 temp) {
    array.getAt(index, temp);
    temp.add(value);
    array.setAt(index, temp);
  }
}

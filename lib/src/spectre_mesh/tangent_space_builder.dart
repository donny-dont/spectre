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

/// Contains functions for generating tangents for arbitrary mesh data.
class TangentSpaceBuilder {

  static void build(Vector3Array positions,
                    Vector2Array texCoords,
                    Vector3Array normals,
                    Vector3Array tangents,
                    Vector3Array bitangents,
                    Uint16Array indices,
                   [int vertexOffset = 0,
                    int vertexCount,
                    int indexOffset = 0,
                    int indexCount])
  {
    // Get the maximum vertex index
    int maxVertex = _VertexDataBuilder._getMaxIndex(vertexOffset, vertexCount, tangents.length);

    // Create temporary arrays to hold the tangent data
    vertexCount = maxVertex - vertexOffset;

    Vector3Array tan1 = new Vector3Array(vertexCount);
    Vector3Array tan2 = new Vector3Array(vertexCount);

    {
      vec3 v0 = new vec3();
      vec3 v1 = new vec3();
      vec3 v2 = new vec3();

      vec2 w0 = new vec2();
      vec2 w1 = new vec2();
      vec2 w2 = new vec2();

      vec3 tdir = new vec3();
      vec3 sdir = new vec3();

      // Get the maximum index within indices to use
      int maxIndex = _VertexDataBuilder._getMaxIndex(indexOffset, indexCount, indices.length);

      for (int i = indexOffset; i < maxIndex; i += 3) {
        int i0 = indices[i];
        int i1 = indices[i + 1];
        int i2 = indices[i + 2];

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

        // Take into account the offset
        i0 -= vertexOffset;
        i1 -= vertexOffset;
        i2 -= vertexOffset;

        _VertexDataBuilder._addToVec3(i0, tan1, sdir, v0);
        _VertexDataBuilder._addToVec3(i1, tan1, sdir, v0);
        _VertexDataBuilder._addToVec3(i2, tan1, sdir, v0);

        _VertexDataBuilder._addToVec3(i0, tan2, tdir, v0);
        _VertexDataBuilder._addToVec3(i1, tan2, tdir, v0);
        _VertexDataBuilder._addToVec3(i2, tan2, tdir, v0);
      }
    }

    {
      vec3 n = new vec3();
      vec3 t = new vec3();
      vec3 nCrossT = new vec3();

      for (int i = vertexOffset, j = 0; i < maxVertex; ++i, ++j) {
        normals.getAt(i, n);
        tan1.getAt(j, t);

        double nDotT = n.dot(t);
        n.cross(t, nCrossT);

        n.x *= nDotT;
        n.y *= nDotT;
        n.z *= nDotT;
        t.sub(n);
        t.normalize();

        tangents.setAt(i, t);

        tan2.getAt(j, t);
        double h = nCrossT.dot(t) < 0.0 ? -1.0 : 1.0;
        nCrossT.x *= h;
        nCrossT.y *= h;
        nCrossT.z *= h;
        nCrossT.normalize();
        bitangents.setAt(i, nCrossT);
      }
    }
  }
}

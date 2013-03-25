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

/// Contains functions for generating normals for arbitrary mesh data.
class NormalDataBuilder {
  /// Uses the index data and positions to compute the vertex [normals].
  ///
  /// To compute the normal for a vertex the [indices] are used to access the [positions]
  /// that make up a triangle face. The face normal is then computed and added to the value
  /// contained in [normals]. As a final step the values within [normals] are themselves
  /// normalized.
  ///
  /// It is assumed that the indices in the range \[indexOffset .. indexOffset + indexLength] refer
  /// only to vertices within the range \[[vertexOffset], .. [vertexOffset] + [vertexLength]\].
  /// No checks are done to ensure this. This is to remove the cost of determining the vertex
  /// range.
  ///
  /// It is also assumed that the values within [normals] are all set to (0, 0, 0). If this
  /// is not the case the values within [normals] will be incorrect.
  static void build(Vector3Array positions, Vector3Array normals, Uint16Array indices, [int vertexOffset = 0, int vertexLength, int indexOffset = 0, int indexLength]) {
    // Temporary variables
    vec3 v0 = new vec3();
    vec3 v1 = new vec3();
    vec3 v2 = new vec3();

    // Get the maximum index within indices to use
    int maxIndex = _getMaxIndex(indexOffset, indexLength, indices.length);

    // Run through the indices computing the normals for each triangle
    // and adding them to the normal data
    for (int i = indexOffset; i < maxIndex; i += 3) {
      int i0 = indices[i];
      int i1 = indices[i + 1];
      int i2 = indices[i + 2];

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

    // Get the maximum vertex index
    int maxVertex = _getMaxIndex(vertexOffset, vertexLength, normals.length);

    // Normalize the values
    vec3 normal = new vec3();

    for (int i = vertexOffset; i < maxVertex; ++i) {
      normals.getAt(i, normal);
      normal.normalize();
      normals.setAt(i, normal);
    }
  }

  static int _getMaxIndex(int offset, int length, int lastIndex) {
    if (length == null) {
      return lastIndex;
    } else {
      int maxIndex = offset + length;
      return Math.min(maxIndex, lastIndex);
    }
  }

  static void _addToVec3(int index, Vector3Array array, vec3 value, vec3 temp) {
    array.getAt(index, temp);
    temp.add(value);
    array.setAt(index, temp);
  }
}

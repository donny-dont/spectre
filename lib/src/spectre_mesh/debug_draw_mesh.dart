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

/// Draws vertex vector data.
void _debugDrawVertexVectorData(DebugDrawManager debugDrawManager,
                                Vector3Array positions,
                                Vector3Array vectors,
                                mat4 modelMatrix,
                                vec4 color,
                                double duration,
                                int vertexOffset,
                                int vertexLength)
{
  // Compute the maximum value
  int maxValue;

  maxValue = vertexOffset + vertexLength;
  maxValue = Math.min(maxValue, positions.length);

  // Temp values
  vec3 position3 = new vec3();
  vec4 position4 = new vec4();
  vec3 vector = new vec3();
  vec3 endPoint = new vec3();

  double factor = 0.05;
  vec3 multiplyBy = new vec3.raw(factor, factor, factor);

  // Add the lines
  for (int i = vertexOffset; i < maxValue; ++i) {
    // Get the position in homogenous coordinates
    positions.getAt(i, position3);

    position4.x = position3.x;
    position4.y = position3.y;
    position4.z = position3.z;
    position4.w = 1.0;

    // Convert to the model's space
    //
    // \TODO If Dart Vector Math gets a way to multiply a vector by
    // a matrix without a temporary switch to that
    vec4 actualPosition = modelMatrix * position4;

    position3.x = actualPosition.x;
    position3.y = actualPosition.y;
    position3.z = actualPosition.z;

    // Compute the endpoint
    vectors.getAt(i, vector);
    vector.multiply(multiplyBy);

    endPoint.copyFrom(position3);
    endPoint.add(vector);

    print('Position: $position3 EndPoint: $endPoint');

    // Add the line
    debugDrawManager.addLine(
        position3,
        endPoint,
        color,
        duration:duration
    );
  }
}

void debugDrawMeshNormals(DebugDrawManager debugDrawManager,
                          Vector3Array positions,
                          Vector3Array normals,
                          mat4 modelMatrix,
                         [double duration = 120.0,
                          int vertexOffset = 0,
                          int vertexLength])
{
  if (vertexLength == null) {
    vertexLength = positions.length - vertexOffset;
  }

  vec4 color = new vec4(1.0, 0.0, 0.0, 1.0);

  _debugDrawVertexVectorData(
      debugDrawManager,
      positions,
      normals,
      modelMatrix,
      color,
      duration,
      vertexOffset,
      vertexLength
  );
}

void debugDrawMeshTangents(DebugDrawManager debugDrawManager,
                           Vector3Array positions,
                           Vector3Array tangents,
                           Vector3Array bitangents,
                           mat4 modelMatrix,
                          [double duration = 120.0,
                           int vertexOffset = 0,
                           int vertexLength])
{
  if (vertexLength == null) {
    vertexLength = positions.length - vertexOffset;
  }

  // Draw the tangents
  vec4 color = new vec4(0.0, 1.0, 0.0, 1.0);

  _debugDrawVertexVectorData(
      debugDrawManager,
      positions,
      tangents,
      modelMatrix,
      color,
      duration,
      vertexOffset,
      vertexLength
  );

  // Draw the bitangents
  color.setComponents(0.0, 0.0, 1.0, 1.0);

  _debugDrawVertexVectorData(
      debugDrawManager,
      positions,
      bitangents,
      modelMatrix,
      color,
      duration,
      vertexOffset,
      vertexLength
  );
}

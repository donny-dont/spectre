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

class BoxGenerator extends MeshGenerator {
  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The extents of the [Mesh] to generate.
  vec3 _extents = new vec3.raw(0.5, 0.5, 0.5);

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [BoxGenerator] class.
  BoxGenerator();

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// Gets the number of vertices that will be generated.
  ///
  /// For the amount of storage space required see [vertexBufferSize].
  int get vertexCount => 24;

  /// Retrieves the size of the index buffer necessary to hold the generated [Mesh].
  int get indexCount => 36;

  /// The extents of the box.
  vec3 get extents => _extents;
  set extents(vec3 value) { _extents = value; }

  //---------------------------------------------------------------------
  // Private mesh generation methods
  //---------------------------------------------------------------------

  /// Populates the indices for the mesh.
  ///
  /// Index data will be placed within the [indices] array starting at the specified
  /// [indexOffset].
  void _generateIndices(Int16Array indices, int vertexOffset, int indexOffset) {
    // Negative X
    indices[indexOffset++] =  0;  indices[indexOffset++] =  1;  indices[indexOffset++] =  2;
    indices[indexOffset++] =  0;  indices[indexOffset++] =  2;  indices[indexOffset++] =  3;

    // Negative Y
    indices[indexOffset++] =  4;  indices[indexOffset++] =  6;  indices[indexOffset++] =  7;
    indices[indexOffset++] =  4;  indices[indexOffset++] =  7;  indices[indexOffset++] =  5;

    // Negative Z
    indices[indexOffset++] =  8;  indices[indexOffset++] = 11;  indices[indexOffset++] = 10;
    indices[indexOffset++] =  8;  indices[indexOffset++] = 10;  indices[indexOffset++] =  9;

    // Positive Y
    indices[indexOffset++] = 15;  indices[indexOffset++] = 14;  indices[indexOffset++] = 13;
    indices[indexOffset++] = 15;  indices[indexOffset++] = 13;  indices[indexOffset++] = 12;

    // Positive Z
    indices[indexOffset++] = 18;  indices[indexOffset++] = 19;  indices[indexOffset++] = 16;
    indices[indexOffset++] = 18;  indices[indexOffset++] = 16;  indices[indexOffset++] = 17;

    // Positive X
    indices[indexOffset++] = 20;  indices[indexOffset++] = 22;  indices[indexOffset++] = 23;
    indices[indexOffset++] = 20;  indices[indexOffset++] = 23;  indices[indexOffset++] = 21;
  }

  /// Generates the positions for the mesh.
  ///
  /// Positions will be placed within the [positions] array starting at the specified
  /// [vertexOffset]. When complete \[[vertexOffset], [vertexOffset] + [vertexCount]\]
  /// within the [array] will contain position data.
  ///
  /// The mesh will be centered at the given [center] position.
  void _generatePositions(Vector3Array positions, vec3 center, int vertexOffset) {
    // Create the position values
    double xExtent = _extents.x;
    double yExtent = _extents.y;
    double zExtent = _extents.z;

    double xCenter = center.x;
    double yCenter = center.y;
    double zCenter = center.z;

    List<vec3> positionValues = [
      new vec3.raw(-xExtent + xCenter,  yExtent + yCenter,  zExtent + zCenter),
      new vec3.raw(-xExtent + xCenter,  yExtent + yCenter, -zExtent + zCenter),
      new vec3.raw(-xExtent + xCenter, -yExtent + yCenter, -zExtent + zCenter),
      new vec3.raw(-xExtent + xCenter, -yExtent + yCenter,  zExtent + zCenter),
      new vec3.raw( xExtent + xCenter, -yExtent + yCenter, -zExtent + zCenter),
      new vec3.raw( xExtent + xCenter, -yExtent + yCenter,  zExtent + zCenter),
      new vec3.raw( xExtent + xCenter,  yExtent + yCenter, -zExtent + zCenter),
      new vec3.raw( xExtent + xCenter,  yExtent + yCenter,  zExtent + zCenter)
    ];

    // Negative X
    positions[vertexOffset++] = positionValues[0];
    positions[vertexOffset++] = positionValues[1];
    positions[vertexOffset++] = positionValues[2];
    positions[vertexOffset++] = positionValues[3];

    // Negative Y
    positions[vertexOffset++] = positionValues[2];
    positions[vertexOffset++] = positionValues[3];
    positions[vertexOffset++] = positionValues[4];
    positions[vertexOffset++] = positionValues[5];

    // Negative Z
    positions[vertexOffset++] = positionValues[1];
    positions[vertexOffset++] = positionValues[2];
    positions[vertexOffset++] = positionValues[4];
    positions[vertexOffset++] = positionValues[6];

    // Positive Y
    positions[vertexOffset++] = positionValues[0];
    positions[vertexOffset++] = positionValues[1];
    positions[vertexOffset++] = positionValues[6];
    positions[vertexOffset++] = positionValues[7];

    // Positive Z
    positions[vertexOffset++] = positionValues[0];
    positions[vertexOffset++] = positionValues[3];
    positions[vertexOffset++] = positionValues[5];
    positions[vertexOffset++] = positionValues[7];

    // Positive X
    positions[vertexOffset++] = positionValues[4];
    positions[vertexOffset++] = positionValues[5];
    positions[vertexOffset++] = positionValues[6];
    positions[vertexOffset++] = positionValues[7];
  }

  /// Generates the texture coordinates for the mesh.
  ///
  /// Texture coordinates will be placed within the [array] starting at the
  /// specified [vertexData]. When complete the \[[vertexOffset], [vertexOffset] + [vertexCount]\]
  /// within the [array] will contain texture coordinate data.
  void _generateTextureCoordinates(Vector2Array texCoords, int vertexOffset) {
    List<vec2> textureCoordValues = [
      new vec2(0.0, 1.0),
      new vec2(0.0, 0.0),
      new vec2(1.0, 1.0),
      new vec2(1.0, 0.0)
    ];

    textureCoords[vertexOffset++] = textureCoordValues[0];
    textureCoords[vertexOffset++] = textureCoordValues[1];
    textureCoords[vertexOffset++] = textureCoordValues[2];
    textureCoords[vertexOffset++] = textureCoordValues[3];
    textureCoords[vertexOffset++] = textureCoordValues[2];
    textureCoords[vertexOffset++] = textureCoordValues[3];
    textureCoords[vertexOffset++] = textureCoordValues[2];
    textureCoords[vertexOffset++] = textureCoordValues[3];

    textureCoords[vertexOffset++] = textureCoordValues[2];
    textureCoords[vertexOffset++] = textureCoordValues[3];
    textureCoords[vertexOffset++] = textureCoordValues[0];
    textureCoords[vertexOffset++] = textureCoordValues[1];
    textureCoords[vertexOffset++] = textureCoordValues[0];
    textureCoords[vertexOffset++] = textureCoordValues[1];
    textureCoords[vertexOffset++] = textureCoordValues[0];
    textureCoords[vertexOffset++] = textureCoordValues[1];

    textureCoords[vertexOffset++] = textureCoordValues[1];
    textureCoords[vertexOffset++] = textureCoordValues[0];
    textureCoords[vertexOffset++] = textureCoordValues[3];
    textureCoords[vertexOffset++] = textureCoordValues[2];
    textureCoords[vertexOffset++] = textureCoordValues[2];
    textureCoords[vertexOffset++] = textureCoordValues[3];
    textureCoords[vertexOffset++] = textureCoordValues[0];
    textureCoords[vertexOffset++] = textureCoordValues[1];
  }

  /// Generates the normals for the mesh.
  ///
  /// Normals will be placed within the [vertexArray] starting at the specified
  /// [vertexOffset]. When complete the \[[vertexOffset], [vertexOffset] + [vertexCount]\]
  /// within the [vertexArray] will contain normal data.
  void _generateNormals(Vector3Array positions, Vector3Array normals, Int16Array indices, int vertexOffset, int indexOffset) {
    List<vec3> normalValues = [
        new vec3(-1.0,  0.0,  0.0),
        new vec3( 0.0, -1.0,  0.0),
        new vec3( 0.0,  0.0, -1.0),
        new vec3( 0.0,  1.0,  0.0),
        new vec3( 0.0,  0.0,  1.0),
        new vec3( 1.0,  0.0,  0.0)
    ];

    // Negative X
    normals[vertexOffset++] = normalValues[0];
    normals[vertexOffset++] = normalValues[0];
    normals[vertexOffset++] = normalValues[0];
    normals[vertexOffset++] = normalValues[0];

    // Negative Y
    normals[vertexOffset++] = normalValues[1];
    normals[vertexOffset++] = normalValues[1];
    normals[vertexOffset++] = normalValues[1];
    normals[vertexOffset++] = normalValues[1];

    // Negative Z
    normals[vertexOffset++] = normalValues[2];
    normals[vertexOffset++] = normalValues[2];
    normals[vertexOffset++] = normalValues[2];
    normals[vertexOffset++] = normalValues[2];

    // Positive Y
    normals[vertexOffset++] = normalValues[3];
    normals[vertexOffset++] = normalValues[3];
    normals[vertexOffset++] = normalValues[3];
    normals[vertexOffset++] = normalValues[3];

    // Positive Z
    normals[vertexOffset++] = normalValues[4];
    normals[vertexOffset++] = normalValues[4];
    normals[vertexOffset++] = normalValues[4];
    normals[vertexOffset++] = normalValues[4];

    // Positive X
    normals[vertexOffset++] = normalValues[5];
    normals[vertexOffset++] = normalValues[5];
    normals[vertexOffset++] = normalValues[5];
    normals[vertexOffset++] = normalValues[5];
  }

  //---------------------------------------------------------------------
  // Single mesh generation
  //---------------------------------------------------------------------

  /// Creates a single box with the given [extents] at the specified [center].
  ///
  /// This is a helper method for creating a single box. If you are creating
  /// many box meshes prefer creating a [BoxGenerator] and using that to generate
  /// multiple meshes.
  static Mesh createBox(String name, GraphicsDevice graphicsDevice, List<InputLayoutElement> elements, vec3 extents, vec3 center) {
    // Setup the generator
    BoxGenerator generator = new BoxGenerator();

    // Create the mesh
    return MeshGenerator._createMesh(name, graphicsDevice, elements, generator, center);
  }
}

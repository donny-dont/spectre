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

class BoxGenerator extends MeshGenerator {

  vec3 _extents;
  VertexData _vertexData;

  BoxGenerator(vec3 extents, [bool generateTextureCoords = false, bool generateNormals = false, bool generateTangents = false])
      : super(generateTextureCoords, generateNormals, generateTangents)
      , _extents = new vec3.raw(1.0, 1.0, 1.0);

  /**
   * Gets the number of vertices that will be created.
   *
   * For the amount of storage space see [vertexBufferSize].
   */
  int get vertexCount => 24;

  /**
   * Retrieves the index buffer size necessary to hold the generated mesh.
   */
  int get indexCount => 36;

  /**
   * The extents of the box.
   */
  vec3 get extents => _extents;
  set extents(vec3 value) { _extents = value; }


  void generate(Float32Array vertexBuffer, Int16Array indexBuffer, List<InputElementDescription> elements, [int vertexOffset = 0, int indexOffset = 0]) {
    _vertexData = new VertexData(vertexBuffer, elements);

    _generatePositionData(vertexOffset);

    if (generateTextureCoords) {
      _generateTextureCoordData(vertexOffset);
    }

    if (generateNormals) {
      _generateNormalData(vertexOffset);
    }

    if (generateTangents) {

    }

    // Generate index data
    indexBuffer[indexOffset++] =  0;  indexBuffer[indexOffset++] =  1;  indexBuffer[indexOffset++] =  2;
    indexBuffer[indexOffset++] =  1;  indexBuffer[indexOffset++] =  3;  indexBuffer[indexOffset++] =  2;
    indexBuffer[indexOffset++] = 10;  indexBuffer[indexOffset++] = 11;  indexBuffer[indexOffset++] =  4;
    indexBuffer[indexOffset++] = 11;  indexBuffer[indexOffset++] =  5;  indexBuffer[indexOffset++] =  4;
    indexBuffer[indexOffset++] = 12;  indexBuffer[indexOffset++] = 13;  indexBuffer[indexOffset++] =  6;
    indexBuffer[indexOffset++] = 13;  indexBuffer[indexOffset++] =  7;  indexBuffer[indexOffset++] =  6;
    indexBuffer[indexOffset++] = 14;  indexBuffer[indexOffset++] = 15;  indexBuffer[indexOffset++] =  8;
    indexBuffer[indexOffset++] = 15;  indexBuffer[indexOffset++] =  9;  indexBuffer[indexOffset++] =  8;
    indexBuffer[indexOffset++] = 22;  indexBuffer[indexOffset++] = 16;  indexBuffer[indexOffset++] = 20;
    indexBuffer[indexOffset++] = 16;  indexBuffer[indexOffset++] = 18;  indexBuffer[indexOffset++] = 20;
    indexBuffer[indexOffset++] = 17;  indexBuffer[indexOffset++] = 23;  indexBuffer[indexOffset++] = 19;
    indexBuffer[indexOffset++] = 23;  indexBuffer[indexOffset++] = 21;  indexBuffer[indexOffset++] = 19;
  }

  /**
   * Generates positional data.
   */
  void _generatePositionData(int vertexOffset) {
    double xExtent = 0.5;
    double yExtent = 0.5;
    double zExtent = 0.5;

    List<vec3> positionValues = [
      new vec3(-xExtent,  yExtent,  zExtent),
      new vec3(-xExtent, -yExtent,  zExtent),
      new vec3( xExtent,  yExtent,  zExtent),
      new vec3( xExtent, -yExtent,  zExtent),
      new vec3( xExtent,  yExtent, -zExtent),
      new vec3( xExtent, -yExtent, -zExtent),
      new vec3(-xExtent,  yExtent, -zExtent),
      new vec3(-xExtent, -yExtent, -zExtent)
    ];

    Vector3Array positions = _vertexData.elements['vPosition'];

    positions[vertexOffset++] = positionValues[0];
    positions[vertexOffset++] = positionValues[1];
    positions[vertexOffset++] = positionValues[2];
    positions[vertexOffset++] = positionValues[3];
    positions[vertexOffset++] = positionValues[4];
    positions[vertexOffset++] = positionValues[5];
    positions[vertexOffset++] = positionValues[6];
    positions[vertexOffset++] = positionValues[7];

    positions[vertexOffset++] = positionValues[0];
    positions[vertexOffset++] = positionValues[1];
    positions[vertexOffset++] = positionValues[2];
    positions[vertexOffset++] = positionValues[3];
    positions[vertexOffset++] = positionValues[4];
    positions[vertexOffset++] = positionValues[5];
    positions[vertexOffset++] = positionValues[6];
    positions[vertexOffset++] = positionValues[7];

    positions[vertexOffset++] = positionValues[0];
    positions[vertexOffset++] = positionValues[1];
    positions[vertexOffset++] = positionValues[2];
    positions[vertexOffset++] = positionValues[3];
    positions[vertexOffset++] = positionValues[4];
    positions[vertexOffset++] = positionValues[5];
    positions[vertexOffset++] = positionValues[6];
    positions[vertexOffset++] = positionValues[7];
  }

  /**
   * Generates texture coordinate data.
   */
  void _generateTextureCoordData(int vertexOffset) {
    List<vec2> textureCoordValues = [
      new vec2(0.0, 1.0),
      new vec2(0.0, 0.0),
      new vec2(1.0, 1.0),
      new vec2(1.0, 0.0)
    ];

    Vector2Array textureCoords = _vertexData.elements['vTexCoord'];

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

  /**
   * Generates normal data.
   *
   * With a box the normal data is well known,
   * so rather than computing it just assign it over.
   */
  void _generateNormalData(int vertexOffset) {
    List<vec3> normalValues = [
      new vec3( 0.0,  0.0,  1.0),
      new vec3( 1.0,  0.0,  0.0),
      new vec3( 0.0,  0.0, -1.0),
      new vec3(-1.0,  0.0,  0.0),
      new vec3( 0.0,  1.0,  0.0),
      new vec3( 0.0, -1.0,  0.0)
    ];

    Vector3Array normals = _vertexData.elements['vNormal'];

    normals[vertexOffset++] = normalValues[0];
    normals[vertexOffset++] = normalValues[0];
    normals[vertexOffset++] = normalValues[0];
    normals[vertexOffset++] = normalValues[0];
    normals[vertexOffset++] = normalValues[1];
    normals[vertexOffset++] = normalValues[1];
    normals[vertexOffset++] = normalValues[2];
    normals[vertexOffset++] = normalValues[2];

    normals[vertexOffset++] = normalValues[3];
    normals[vertexOffset++] = normalValues[3];
    normals[vertexOffset++] = normalValues[1];
    normals[vertexOffset++] = normalValues[1];
    normals[vertexOffset++] = normalValues[2];
    normals[vertexOffset++] = normalValues[2];
    normals[vertexOffset++] = normalValues[3];
    normals[vertexOffset++] = normalValues[3];

    normals[vertexOffset++] = normalValues[4];
    normals[vertexOffset++] = normalValues[5];
    normals[vertexOffset++] = normalValues[4];
    normals[vertexOffset++] = normalValues[5];
    normals[vertexOffset++] = normalValues[4];
    normals[vertexOffset++] = normalValues[5];
    normals[vertexOffset++] = normalValues[4];
    normals[vertexOffset++] = normalValues[5];
  }
}

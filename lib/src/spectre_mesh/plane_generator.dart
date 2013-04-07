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

class PlaneGenerator extends MeshGenerator {
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// The default value for the number of segments.
  static const int _defaultSegments = 10;
  /// The default value for whether a plane should be double sided.
  static const bool _defaultDoubleSided = false;

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The extents of the [Mesh] to generate.
  vec2 _extents = new vec2.raw(0.5, 0.5);
  /// The number of segments in the x direction.
  int _xSegments = _defaultSegments;
  /// The number of segments in the y direction.
  int _ySegments = _defaultSegments;
  /// Whether the plane should be double sided.
  bool _doubleSided = _defaultDoubleSided;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [PlaneGenerator] class.
  PlaneGenerator();

  /// Initializes an instance of the [PlaneGenerator] class that outputs quads.
  PlaneGenerator.quads()
      : _xSegments = 1
      , _ySegments = 1
      , _doubleSided = false;

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// Gets the number of vertices that will be generated.
  ///
  /// For the amount of storage space required see [vertexBufferSize].
  int get vertexCount => _sides * _singleSideVertexCount;

  /// Retrieves the size of the index buffer necessary to hold the generated [Mesh].
  int get indexCount => _sides * _singleSideIndexCount;

  /// The extents of the box.
  vec2 get extents => _extents;
  set extents(vec2 value) {
    _extents.copyInto(value);

    // Get absolute value
    _extents.absolute();
  }

  /// The number of segments in the x direction.
  int get xSegments => _xSegments;
  set xSegments(int value) {
    if (value <= 0) {
      throw new ArgumentError('The number of segments must be greater than 0');
    }

    _xSegments = value;
  }

  /// The number of segments in the y direction.
  int get ySegments => _ySegments;
  set ySegments(int value) {
    if (value <= 0) {
      throw new ArgumentError('The number of segments must be greater than 0');
    }

    _ySegments = value;
  }

  /// Whether the plane should be double sided.
  bool get doubleSided => _doubleSided;
  set doubleSided(bool value) { _doubleSided = value; }

  /// The number of vertices for a single side of the plane.
  int get _singleSideVertexCount => (_xSegments + 1) * (_ySegments + 1);

  /// The number of indices for a single side of the plane.
  int get _singleSideIndexCount =>  xSegments * ySegments * 6;

  /// The number of sides on the plane.
  int get _sides => (_doubleSided) ? 2 : 1;

  //---------------------------------------------------------------------
  // Private mesh generation methods
  //---------------------------------------------------------------------

  /// Populates the indices for the mesh.
  ///
  /// Index data will be placed within the [indices] array starting at the specified
  /// [indexOffset].
  void _generateIndices(Uint16Array indices, int vertexOffset, int indexOffset) {
    _generateIndicesSingleSide(indices, vertexOffset, indexOffset);

    if (_doubleSided) {
      _generateIndicesSingleSide(indices, vertexOffset + _singleSideVertexCount, indexOffset + _singleSideIndexCount);
    }
  }

  /// Populates the indices for a single side of the plane.
  void _generateIndicesSingleSide(Uint16Array indices, int vertexOffset, int indexOffset) {
    int topLeft = vertexOffset;
    int topRight = topLeft + 1;
    int bottomLeft = topLeft + xSegments + 1;
    int bottomRight = bottomLeft + 1;

    for (int y = 0; y < ySegments; ++y) {
      for (int x = 0; x < xSegments; ++x) {
        indices[indexOffset++] = topLeft;
        indices[indexOffset++] = topRight;
        indices[indexOffset++] = bottomRight;

        indices[indexOffset++] = topLeft;
        indices[indexOffset++] = bottomRight;
        indices[indexOffset++] = bottomLeft;

        // Iterate to the next set
        topLeft++;
        topRight++;
        bottomLeft++;
        bottomRight++;
      }

      topLeft++;
      topRight++;
      bottomLeft++;
      bottomRight++;
    }
  }

  /// Generates the positions for the mesh.
  ///
  /// Positions will be placed within the [positions] array starting at the specified
  /// [vertexOffset]. When complete \[[vertexOffset], [vertexOffset] + [vertexCount]\]
  /// within the [array] will contain position data.
  ///
  /// The mesh will be centered at the given [center] position.
  void _generatePositions(Vector3Array positions, vec3 center, int vertexOffset) {
    double xExtent = _extents.x;
    double yExtent = _extents.y;

    double minX = center.x - xExtent;
    double maxX = center.x + xExtent;
    double minY = center.y - yExtent;
    double maxY = center.y + yExtent;

    List<double> xSegmentList = _createSegmentList(minX, maxX, _xSegments);
    List<double> ySegmentList = _createSegmentList(minY, maxY, _ySegments);

    _generatePositionsSingleSide(positions, vertexOffset, xSegmentList, ySegmentList);

    if (_doubleSided) {
      _reverseList(ySegmentList);

      _generatePositionsSingleSide(positions, vertexOffset + _singleSideVertexCount, xSegmentList, ySegmentList);
    }
  }

  /// Populates the positions for a single side of the plane.
  void _generatePositionsSingleSide(Vector3Array positions, int vertexOffset, List<double> xSegmentList, List<double> ySegmentList) {
    vec3 position = new vec3.zero();

    for (int y = 0; y <= ySegments; ++y) {
      position.y = ySegmentList[y];

      for (int x = 0; x <= xSegments; ++x) {
        position.x = xSegmentList[x];

        positions.setAt(vertexOffset, position);

        vertexOffset++;
      }
    }
  }

  /// Generates the texture coordinates for the mesh.
  ///
  /// Texture coordinates will be placed within the [array] starting at the
  /// specified [vertexData]. When complete the \[[vertexOffset], [vertexOffset] + [vertexCount]\]
  /// within the [array] will contain texture coordinate data.
  void _generateTextureCoordinates(Vector2Array texCoords, int vertexOffset) {
    List<double> uSegmentList = _createSegmentList(0.0, 1.0, xSegments);
    List<double> vSegmentList = _createSegmentList(1.0, 0.0, ySegments);

    _generateTextureCoordinatesSingleSide(texCoords, vertexOffset, uSegmentList, vSegmentList);

    if (_doubleSided) {
      _reverseList(vSegmentList);

      _generateTextureCoordinatesSingleSide(texCoords, vertexOffset + _singleSideVertexCount, uSegmentList, vSegmentList);
    }
  }

  /// Populates the texture coordinates for a single side of the plane.
  void _generateTextureCoordinatesSingleSide(Vector2Array texCoords, int vertexOffset, List<double> uSegmentList, List<double> vSegmentList) {
    vec2 texCoord = new vec2();

    for (int y = 0; y <= ySegments; ++y) {
      texCoord.y = vSegmentList[y];

      for (int x = 0; x <= xSegments; ++x) {
        texCoord.x = uSegmentList[x];

        texCoords.setAt(vertexOffset, texCoord);

        vertexOffset++;
      }
    }
  }

  /// Generates the normals for the mesh.
  ///
  /// Normals will be placed within the [vertexArray] starting at the specified
  /// [vertexOffset]. When complete the \[[vertexOffset], [vertexOffset] + [vertexCount]\]
  /// within the [vertexArray] will contain normal data.
  void _generateNormals(Vector3Array positions, Vector3Array normals, Uint16Array indices, int vertexOffset, int indexOffset) {
    int singleSideVertexCount = _singleSideVertexCount;
    vec3 normal = new vec3.raw(0.0, 0.0, 1.0);

    int maxIndex = vertexOffset + singleSideVertexCount;
    for (int i = vertexOffset; i < maxIndex; ++i) {
      normals.setAt(i, normal);
    }

    if (_doubleSided) {
      vertexOffset += singleSideVertexCount;
      maxIndex += singleSideVertexCount;
      normal.z = -1.0;

      for (int i = vertexOffset; i < maxIndex; ++i) {
        normals.setAt(i, normal);
      }
    }
  }

  //---------------------------------------------------------------------
  // Private class methods
  //---------------------------------------------------------------------

  /// Creates a [List] containing the segments.
  static List<double> _createSegmentList(double minValue, double maxValue, int segments) {
    List<double> list = new List<double>(segments + 1);

    double value = minValue;
    double increment = (maxValue - minValue) / segments;

    for (int i = 0; i < segments; ++i) {
      list[i] = value;

      value += increment;
    }

    // Set the last value to be the maximum
    list[segments] = maxValue;

    return list;
  }

  /// Reverses a [List].
  ///
  /// This isn't present in the [List] implementation. Remove if it is added.
  static void _reverseList(List<double> list) {
    int length = list.length;
    int halfLength = length ~/ 2;

    for (int i = 0, j = length - 1; i < halfLength; ++i, --j) {
      double temp = list[i];

      list[i] = list[j];
      list[j] = temp;
    }
  }

  //---------------------------------------------------------------------
  // Single mesh generation
  //---------------------------------------------------------------------

  /// Creates a single plane with the given [extents] at the specified [center].
  ///
  /// This is a helper method for creating a single plane. If you are creating
  /// many plane meshes prefer creating a [PlaneGenerator] and using that to generate
  /// multiple meshes.
  static Mesh createPlane(String name,
                          GraphicsDevice graphicsDevice,
                          List<InputLayoutElement> elements,
                         {vec2 extents,
                          int xSegments : _defaultSegments,
                          int ySegments : _defaultSegments,
                          bool doubleSided : _defaultDoubleSided,
                          vec3 center})
  {
    // Setup the generator
    PlaneGenerator generator = new PlaneGenerator();

    generator.xSegments = xSegments;
    generator.ySegments = ySegments;
    generator.doubleSided = doubleSided;

    if (extents != null) {
      generator.extents = extents;
    }

    // Create the mesh
    return MeshGenerator._createMesh(name, graphicsDevice, elements, generator, center);
  }

  /// Creates a single quad with the given [extents] at the specified [center].
  ///
  /// This is a helper method for creating a single quad. If you are creating
  /// many quads prefer creating a [PlaneGenerator] are using that to generate
  /// multiple quads.
  static Mesh createQuad(String name,
                         GraphicsDevice graphicsDevice,
                         List<InputLayoutElement> elements,
                        {vec2 extents,
                         vec3 center})
  {
    // Setup the generator
    PlaneGenerator generator = new PlaneGenerator.quads();

    if (extents != null) {
      generator.extents = extents;
    }

    // Create the mesh
    return MeshGenerator._createMesh(name, graphicsDevice, elements, generator, center);
  }
}

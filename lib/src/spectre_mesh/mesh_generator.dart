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


/// Base class for mesh generation.
///
/// Contains the base information for what vertex attributes should be
/// generated. This includes texture coordinates, normal data, and
/// tangent data. Additionally the generator provides methods to
/// calculate the normal, and tangent data.
///
/// Mesh generators do not allocate any memory, instead the client is
/// expected to query the number of vertices and indices required and
/// pass in an array with enough space to hold the mesh data.
abstract class MeshGenerator {
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// The default name of the vertex position attribute.
  static const String _defaultPositionAttributeName = 'vPosition';
  /// The default name of the vertex texture coordinate attribute.
  static const String _defaultTextureCoordinateAttributeName = 'vTexCoord0';
  /// The default name of the vertex normal attribute.
  static const String _defaultNormalAttributeName = 'vNormal';
  /// The default name of the vertex tangent attribute.
  static const String _defaultTangentAttributeName = 'vTangent';
  /// The default name of the vertex bitangent attribute.
  static const String _defaultBitangentAttributeName = 'vBitangent';

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The name of the vertex position attribute.
  ///
  /// This value is mandatory for generating a mesh, and needs to be present within
  /// the vertex declaration sent to the generator.
  String _positionAttributeName = _defaultPositionAttributeName;
  /// The name of the vertex texture coordinate attribute.
  ///
  /// If this value is found in the vertex declaration then texture coordinates
  /// will be generated.
  String _textureCoordinateAttributeName = _defaultTextureCoordinateAttributeName;
  /// The name of the vertex normal attribute.
  ///
  /// If this value is found in the vertex declaration then normals will be
  /// generated.
  String _normalAttributeName = _defaultNormalAttributeName;
  /// The name of the vertex tangent attribute.
  ///
  /// If this value is found, along with the [bitangentAttributeName], in the vertex
  /// declaration then tangent data will be generated.
  String _tangentAttributeName = _defaultTangentAttributeName;
  /// The name of the vertex bitangent attribute.
  ///
  /// If this value is found, along with the [tangentAttributeName], in the vertex
  /// declaration then tangent data will be generated.
  String _bitangentAttributeName = _defaultBitangentAttributeName;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the MeshGenerator class.
  MeshGenerator();

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// Gets the number of vertices that will be generated.
  ///
  /// For the amount of storage space required see [vertexBufferSize].
  int get vertexCount;

  /// Retrieves the size of the index buffer necessary to hold the generated [Mesh].
  int get indexCount;

  //---------------------------------------------------------------------
  // Public methods
  //---------------------------------------------------------------------

  /// Adds the generated mesh's data to the [vertexData] and [indices].
  ///
  /// Specifying the [center] point changes the location the position data is generated at. By default
  /// the mesh will be centered at \[0.0, 0.0, 0.0\]. Additionally an offset into the vertex and index
  /// data can be specified by [vertexOffset] and [indexOffset]. If unspecified the mesh will be generated
  /// at the start of the arrays.
  void generateMesh(VertexData vertexData, Uint16Array indices, [vec3 center, int vertexOffset = 0, int indexOffset = 0]) {
    // Ensure that there is enough room in the vertex and index data to hold the mesh
    if (vertexData.vertexCount < vertexOffset + vertexCount) {
      throw new ArgumentError('The vertex data does not have enough space to hold the mesh');
    }

    if (indices.length < indexOffset + indexCount) {
      throw new ArgumentError('The index data does not have enough space to hold the mesh');
    }

    // Default to a center at (0, 0, 0)
    if (center == null) {
      center = new vec3.zero();
    }

    // Generate position data
    Vector3List positions = vertexData.elements[_positionAttributeName];

    if (positions == null) {
      throw new ArgumentError('The vertex data does not contain a position attribute');
    }

    _generatePositions(positions, center, vertexOffset);

    // Generate indices
    _generateIndices(indices, vertexOffset, indexOffset);

    // Generate texture coordinates if requested
    Vector2List texCoords = vertexData.elements[_textureCoordinateAttributeName];

    if (texCoords != null) {
      _generateTextureCoordinates(texCoords, vertexOffset);
    }

    // Generate normals if requested
    Vector3List normals = vertexData.elements[_normalAttributeName];

    if (normals != null) {
      _generateNormals(positions, normals, indices, vertexOffset, indexOffset);
    }

    // Generate texture data if requested
    Vector3List tangents = vertexData.elements[_tangentAttributeName];
    Vector3List bitangents = vertexData.elements[_bitangentAttributeName];

    if ((tangents != null) && (bitangents != null)) {
      _generateTangents(positions, texCoords, normals, tangents, bitangents, indices, vertexOffset, indexOffset);
    }
  }

  //---------------------------------------------------------------------
  // Private methods
  //---------------------------------------------------------------------

  /// Populates the indices for the mesh.
  ///
  /// Index data will be placed within the [indices] array starting at the specified
  /// [indexOffset].
  void _generateIndices(Uint16Array indexBuffer, int vertexOffset, int indexOffset);

  /// Generates the positions for the mesh.
  ///
  /// Positions will be placed within the [positions] array starting at the specified
  /// [vertexOffset]. When complete \[[vertexOffset], [vertexOffset] + [vertexCount]\]
  /// within the [array] will contain position data.
  ///
  /// The mesh will be centered at the given [center] position.
  void _generatePositions(Vector3List positions, vec3 center, int vertexOffset);

  /// Generates the texture coordinates for the mesh.
  ///
  /// Texture coordinates will be placed within the [array] starting at the
  /// specified [vertexData]. When complete the \[[vertexOffset], [vertexOffset] + [vertexCount]\]
  /// within the [array] will contain texture coordinate data.
  void _generateTextureCoordinates(Vector2List texCoords, int vertexOffset);

  /// Generates the normals for the mesh.
  ///
  /// Normals will be placed within the [vertexArray] starting at the specified
  /// [vertexOffset]. When complete the \[[vertexOffset], [vertexOffset] + [vertexCount]\]
  /// within the [vertexArray] will contain normal data.
  ///
  /// Uses the indices present in the [indexArray] and the positions in the [vertexArray]
  /// to calculate the normals of the mesh.
  ///
  /// A subclass should override this if the normals can easily be determined. This
  /// is the case for something like a box or plane.
  void _generateNormals(Vector3List positions, Vector3List normals, Uint16Array indices, int vertexOffset, int indexOffset) {
    NormalDataBuilder.build(
        positions,
        normals,
        indices,
        vertexOffset,
        vertexCount,
        indexOffset,
        indexCount
    );
  }

  /// Generates the tangent data for the mesh.
  void _generateTangents(Vector3List positions, Vector2List texCoords, Vector3List normals, Vector3List tangents, Vector3List bitangents, Uint16Array indices, int vertexOffset, int indexOffset) {
    TangentSpaceBuilder.build(
        positions,
        texCoords,
        normals,
        tangents,
        bitangents,
        indices,
        vertexOffset,
        vertexCount,
        indexOffset,
        indexCount
    );
  }

  /// Creates a single [Mesh] using the supplied [MeshGenerator].
  ///
  /// Provides a shorthand way for [MeshGenerators] to create a single mesh.
  /// The [MeshGenerator] should be supplied with any options regarding its creation
  /// before calling this.
  static Mesh _createMesh(String name, GraphicsDevice graphicsDevice, List<InputLayoutElement> elements, MeshGenerator generator, vec3 center) {
    int elementCount = elements[0].attributeStride ~/ 4;

    // Create storage space for the vertices and indices
    Float32Array vertices = new Float32Array(generator.vertexCount * elementCount);
    Uint16Array indices = new Uint16Array(generator.indexCount);

    // Create the vertex data view
    VertexData vertexData = new VertexData(vertices, elements);

    // Generate the box
    generator.generateMesh(vertexData, indices, center);

    // Upload the graphics data
    VertexBuffer vertexBuffer = new VertexBuffer('${name}_VBO', graphicsDevice);
    vertexBuffer.uploadData(vertices, SpectreBuffer.UsageStatic);

    IndexBuffer indexBuffer = new IndexBuffer('${name}_IBO', graphicsDevice);
    indexBuffer.uploadData(indices, SpectreBuffer.UsageStatic);

    InputLayout inputLayout = new InputLayout('remove', graphicsDevice);
    inputLayout.elements.addAll(elements);

    // Create the mesh
    // \TODO Remove vertexData???
    Mesh mesh = new Mesh(name, graphicsDevice, [ vertexBuffer ], inputLayout, indexBuffer);
    mesh.vertexData = vertexData;

    return mesh;
  }
}

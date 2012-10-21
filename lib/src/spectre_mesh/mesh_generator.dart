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

/**
 * Base class for mesh generation.
 *
 * Contains the base information for what vertex attributes should be
 * generated. This includes texture coordinates, normal data, and
 * tangent data. Additionally the generator provides methods to
 * calculate the normal, and tangent data.
 *
 * Mesh generators do not allocate any memory, instead the client is
 * expected to query the number of vertices and indices required and
 * pass in an array with enough space to hold the mesh data.
 */
abstract class MeshGenerator {

  /// Whether texture coordinates should be generated.
  bool _generateTextureCoords;
  /// Whether normal data should be generated.
  bool _generateNormals;
  /// Whether tangent data should be generated.
  bool _generateTangents;
  /**
   * The center point of the mesh.
   *
   * Position data is generated based on what the center point
   * of the mesh is.
   */
  vec3 _center;

  /**
   * Creates an instance of the MeshGenerator class.
   */
  MeshGenerator(bool this._generateTextureCoords, bool this._generateNormals, bool this._generateTangents)
    : _center = new vec3.zero();

  /**
   * Gets the number of vertices that will be created.
   *
   * For the amount of storage space see [vertexBufferSize].
   */
  abstract int get vertexCount;

  /**
   * Retrieves the index buffer size necessary to hold the generated mesh.
   */
  abstract int get indexCount;

  /**
   * Retrieves the vertex buffer size necessary to hold the generated mesh.
   *
   * This value is dependent on what vertex attributes have been
   * requested.
   */
  int get vertexBufferSize {
    int perAttribute = vertexCount;
    int size = perAttribute;

    if (_generateTextureCoords) {
      size += perAttribute;
    }

    if (_generateNormals) {
      size += perAttribute;
    }

    if (_generateTangents) {
      size += 2 * perAttribute;
    }

    return size;
  }

  /**
   * Whether texture data should be generated.
   */
  bool get generateTextureCoords => _generateTextureCoords;
  set generateTextureCoords(bool value) { _generateTextureCoords = value; }

  /**
   * Whether normal data should be generated.
   */
  bool get generateNormals => _generateNormals;
  set generateNormals(bool value) { _generateNormals = value; }

  /**
   * Whether tangent data should be generated.
   */
  bool get generateTangents => _generateTangents;
  set generateTangents(bool value) { _generateTangents = value; }

  /**
   * The center point of the mesh.
   *
   * Position data is generated based on what the center point
   * of the mesh is.
   */
  vec3 get center => _center;
  set center(vec3 value) { _center = value; }

  abstract generate(Float32Array buffer, [int offset = 0]);
}

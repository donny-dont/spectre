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


  void generate(Float32Array buffer, [int offset = 0]) {
    _generatePositionData();

    if (generateTextureCoords) {
      _generateTextureCoordData();
    }

    if (generateNormals) {
      _generateNormalData();
    }

    if (generateTangents) {

    }
  }

  /**
   * Generates positional data.
   */
  void _generatePositionData() {

  }

  /**
   * Generates texture coordinate data.
   */
  void _generateTextureCoordData() {
    List<vec2> textureCoordValues = [
      new vec2(0.0, 1.0),
      new vec2(0.0, 0.0),
      new vec2(1.0, 1.0),
      new vec2(1.0, 0.0)
    ];


  }

  /**
   * Generates normal data.
   *
   * With a box the normal data is well known,
   * so rather than computing it just assign it over.
   */
  void _generateNormalData() {

  }
}

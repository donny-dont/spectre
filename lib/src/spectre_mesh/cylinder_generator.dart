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

class CylinderGenerator extends MeshGenerator {
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// The default value for the radius of the cylinder.
  static const double _defaultRadius = 0.5;
  /// The default value for the height of the cylinder.
  static const double _defaultHeight = 1.0;
  /// The default value for the number of segments.
  static const int _defaultSegments = 16;

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The radius of the cylinder top.
  double _topRadius = _defaultRadius;
  /// The radius of the cylinder bottom.
  double _bottomRadius = _defaultRadius;
  /// The height of the cylinder.
  double _height = _defaultHeight;
  /// The number of segments the [Mesh] will be divided into.
  int _segments = _defaultSegments;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [CylinderGenerator] class.
  CylinderGenerator();

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// Gets the number of vertices that will be generated.
  ///
  /// For the amount of storage space required see [vertexBufferSize].
  int get vertexCount => ((_segments + 1) * 2) + (_segments * 2);

  /// Retrieves the size of the index buffer necessary to hold the generated [Mesh].
  int get indexCount => (_segments * 6) + ((_segments - 2) * 6);

  /// The radius of the cylinder top.
  double get topRadius => _topRadius;
  set topRadius(num value) {
    if (value < 0.0) {
      throw new ArgumentError('The radius must be a positive number');
    }

    _topRadius = value.toDouble();
  }

  /// The radius of the cylinder bottom.
  double get bottomRadius => _bottomRadius;
  set bottomRadius(num value) {
    if (value < 0.0) {
      throw new ArgumentError('The radius must be a positive number');
    }

    _bottomRadius = value.toDouble();
  }

  /// The height of the cylinder.
  double get height => _height;
  set height(num value) {
    if (value < 0.0) {
      throw new ArgumentError('The height must be a positive number');
    }

    _height = value.toDouble();
  }

  /// The number of segments the [Mesh] will be divided into.
  int get segments => _segments;
  set segments(int value) {
    if (value < 0.0) {
      throw new ArgumentError('The number of segments must be greater than 0');
    }

    _segments = value;
  }

  //---------------------------------------------------------------------
  // Private mesh generation methods
  //---------------------------------------------------------------------

  /// Populates the indices for the mesh.
  ///
  /// Index data will be placed within the [indices] array starting at the specified
  /// [indexOffset].
  void _generateIndices(Uint16Array indices, int vertexOffset, int indexOffset) {
    int x;

    // Sides
    int base1 = 0;
    int base2 = _segments + 1;
    for(x = 0; x < _segments; ++x) {
      indices[indexOffset++] = base1 + x;
      indices[indexOffset++] = base1 + x + 1;
      indices[indexOffset++] = base2 + x;

      indices[indexOffset++] = base1 + x + 1;
      indices[indexOffset++] = base2 + x + 1;
      indices[indexOffset++] = base2 + x;
    }

    // Top cap
    base1 = (_segments + 1) * 2;
    for(x = 1; x < _segments - 1; ++x) {
      indices[indexOffset++] = base1;
      indices[indexOffset++] = base1 + x + 1;
      indices[indexOffset++] = base1 + x;
    }

    // Bottom cap
    base1 = (_segments + 1) * 2 + _segments;
    for(x = 1; x < _segments - 1; ++x) {
      indices[indexOffset++] = base1;
      indices[indexOffset++] = base1 + x;
      indices[indexOffset++] = base1 + x + 1;
    }
  }

  /// Generates the positions for the mesh.
  ///
  /// Positions will be placed within the [positions] array starting at the specified
  /// [vertexOffset]. When complete \[[vertexOffset], [vertexOffset] + [vertexCount]\]
  /// within the [array] will contain position data.
  ///
  /// The mesh will be centered at the given [center] position.
  void _generatePositions(Vector3List positions, vec3 center, int vertexOffset) {
    // Vertices are doubled up so that normals will be sharp

    // Top
    for (int x = 0; x <= _segments; ++x) {
      double u = x / _segments;

      positions[vertexOffset++] = new vec3.raw(
          _topRadius * cos(u * Math.PI * 2.0) + center.x,
          _height * 0.5 + center.y,
          _topRadius * sin(u * Math.PI * 2.0) + center.z
      );
    }

    // Bottom
    for (int x = 0; x <= _segments; ++x) {
      double u = x / _segments;

      positions[vertexOffset++] = new vec3.raw(
          _bottomRadius * cos(u * Math.PI * 2.0) + center.x,
          _height * -0.5 + center.y,
          _bottomRadius * sin(u * Math.PI * 2.0) + center.z
      );
    }

    // Top cap
    for (int x = 0; x < _segments; ++x) {
      double u = x / _segments;

      positions[vertexOffset++] = new vec3.raw(
          _topRadius * cos(u * Math.PI * 2.0) + center.x,
          _height * 0.5 + center.y,
          _topRadius * sin(u * Math.PI * 2.0) + center.z
      );
    }

    // Bottom cap
    for (int x = 0; x < _segments; ++x) {
      double u = x / _segments;

      positions[vertexOffset++] = new vec3.raw(
          _bottomRadius * cos(u * Math.PI * 2.0) + center.x,
          _height * -0.5 + center.y,
          _bottomRadius * sin(u * Math.PI * 2.0) + center.z
      );
    }
  }

  /// Generates the texture coordinates for the mesh.
  ///
  /// Texture coordinates will be placed within the [array] starting at the
  /// specified [vertexData]. When complete the \[[vertexOffset], [vertexOffset] + [vertexCount]\]
  /// within the [array] will contain texture coordinate data.
  void _generateTextureCoordinates(Vector2List texCoords, int vertexOffset) {
    // Vertices are doubled up so that normals will be sharp

    // Cylinder top
    for (int x = 0; x <= _segments; ++x) {
      double u = 1.0 - (x / _segments);
      texCoords[vertexOffset++] = new vec2.raw(u, 0.0);
    }

    // Cylinder bottom
    for (int x = 0; x <= _segments; ++x) {
      double u = 1.0 - (x / _segments);
      texCoords[vertexOffset++] = new vec2.raw(u, 1.0);
    }

    // Top cap
    for (int x = 0; x < _segments; ++x) {
      double r = (x / _segments) * Math.PI * 2.0;
      texCoords[vertexOffset++] = new vec2.raw(
          (cos(r) * 0.5 + 0.5),
          (sin(r) * 0.5 + 0.5)
      );
    }

    // Bottom cap
    for (int x = 0; x < _segments; ++x) {
      double r = (x / _segments) * Math.PI * 2.0;
      texCoords[vertexOffset++] = new vec2.raw(
          (cos(r) * 0.5 + 0.5),
          (sin(r) * 0.5 + 0.5)
      );
    }
  }

  //---------------------------------------------------------------------
  // Single mesh generation
  //---------------------------------------------------------------------

  /// Creates a single cylinder with the given [radius] and [height] at the specified [center].
  ///
  /// This is a helper method for creating a single cylinder. If you are creating
  /// many cylinder meshes prefer creating a [CylinderGenerator] and using that to generate
  /// multiple meshes.
  static Mesh createCylinder(String name,
                             GraphicsDevice graphicsDevice,
                             List<InputLayoutElement> elements,
                            {num topRadius : _defaultRadius,
                             num bottomRadius : _defaultRadius,
                             num height : _defaultHeight,
                             int segments : _defaultSegments,
                             vec3 center})
  {
    // Setup the generator
    CylinderGenerator generator = new CylinderGenerator();
    generator.topRadius = topRadius;
    generator.bottomRadius = bottomRadius;
    generator.height = height;
    generator.segments = segments;

    // Create the mesh
    return MeshGenerator._createMesh(name, graphicsDevice, elements, generator, center);
  }
}

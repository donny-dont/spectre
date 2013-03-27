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

class SphereGenerator extends MeshGenerator {
  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------
  
  /// The radius of the [Mesh] to create
  num radius = 0.5;
  
  /// The number of segments the [Mesh] will be divided into vertically
  int latSegments = 12;
  
  /// The number of segments the [Mesh] will be divided into horizontally
  int lonSegments = 16;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [SphereGenerator] class.
  SphereGenerator();

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// Gets the number of vertices that will be generated.
  ///
  /// For the amount of storage space required see [vertexBufferSize].
  int get vertexCount => ((lonSegments * (latSegments - 1)) + 2);

  /// Retrieves the size of the index buffer necessary to hold the generated [Mesh].
  int get indexCount => 6 * lonSegments * latSegments;
  
  //---------------------------------------------------------------------
  // Private mesh generation methods
  //---------------------------------------------------------------------

  /// Populates the indices for the mesh.
  ///
  /// Index data will be placed within the [indices] array starting at the specified
  /// [indexOffset].
  void _generateIndices(Uint16Array indices, int vertexOffset, int indexOffset) {
    int x;
    
    // First ring
    for(x = 0; x < lonSegments-1; ++x) {
      indices[indexOffset++] = 0;
      indices[indexOffset++] = x + 2;
      indices[indexOffset++] = x + 1;
    }
    indices[indexOffset++] = 0;
    indices[indexOffset++] = 1;
    indices[indexOffset++] = x + 1;
    
    // Center rings
    int ring1Base, ring2Base;
    for (int y = 0; y < latSegments-2; ++y) {
      ring1Base = (lonSegments * y) + 1;
      ring2Base = (lonSegments * (y + 1)) + 1;
      for (x = 0; x < lonSegments-1; ++x) {
        indices[indexOffset++] = ring1Base + x;
        indices[indexOffset++] = ring1Base + x + 1;
        indices[indexOffset++] = ring2Base + x;
        
        indices[indexOffset++] = ring1Base + x + 1;
        indices[indexOffset++] = ring2Base + x + 1;
        indices[indexOffset++] = ring2Base + x;
      }
      
      indices[indexOffset++] = ring1Base + x;
      indices[indexOffset++] = ring1Base;
      indices[indexOffset++] = ring2Base + x;
      
      indices[indexOffset++] = ring1Base;
      indices[indexOffset++] = ring2Base;
      indices[indexOffset++] = ring2Base + x;
    }
    
    // Last ring
    ring1Base = (lonSegments * (latSegments-2)) + 1;
    ring2Base = (lonSegments * (latSegments-1)) + 1;
    for(x = 0; x < lonSegments-1; ++x) {
      indices[indexOffset++] = ring2Base;
      indices[indexOffset++] = ring1Base + x;
      indices[indexOffset++] = ring1Base + x + 1;
    }
    indices[indexOffset++] = ring2Base;
    indices[indexOffset++] = ring1Base + x;
    indices[indexOffset++] = ring1Base;
  }
  
  /// Generates the positions for the mesh.
  ///
  /// Positions will be placed within the [positions] array starting at the specified
  /// [vertexOffset]. When complete \[[vertexOffset], [vertexOffset] + [vertexCount]\]
  /// within the [array] will contain position data.
  ///
  /// The mesh will be centered at the given [center] position.
  void _generatePositions(Vector3Array positions, vec3 center, int vertexOffset) {
    positions[vertexOffset++] = new vec3.raw(center.x, center.y + radius, center.z);

    for (int y = 1; y < latSegments; ++y) {
      double v = y / latSegments;
      double sv = sin(v * Math.PI);
      double cv = cos(v * Math.PI);
      
      for (int x = 0; x < lonSegments; ++x) {
        double u = x / lonSegments;
        
        positions[vertexOffset++] = new vec3.raw(
            radius * cos(u * Math.PI * 2.0) * sv + center.x,
            radius * cv + center.y,
            radius * sin(u * Math.PI * 2.0) * sv + center.z
        );
      }
    }

    positions[vertexOffset++] = new vec3.raw(center.x, center.y - radius, center.z);
  }
  
  /// Generates the texture coordinates for the mesh.
  ///
  /// Texture coordinates will be placed within the [array] starting at the
  /// specified [vertexData]. When complete the \[[vertexOffset], [vertexOffset] + [vertexCount]\]
  /// within the [array] will contain texture coordinate data.
  void _generateTextureCoordinates(Vector2Array texCoords, int vertexOffset) {
    int offset = vertexOffset++;
    
    texCoords[vertexOffset++] = new vec2.raw(0.5, 0);
    
    for (int y = 1; y < latSegments; ++y) {
      double v = y / latSegments;
      
      for (int x = 0; x < lonSegments; ++x) {
        double u = x / lonSegments;
        texCoords[vertexOffset++] = new vec2.raw(u, v);
      }
    }

    texCoords[vertexOffset++] = new vec2.raw(0.5, 1.0);
  }
  
  //---------------------------------------------------------------------
  // Single mesh generation
  //---------------------------------------------------------------------

  /// Creates a single sphere with the given [radius] at the specified [center].
  ///
  /// This is a helper method for creating a single sphere. If you are creating
  /// many sphere meshes prefer creating a [SphereGenerator] and using that to generate
  /// multiple meshes.
  static Mesh createSphere(String name, GraphicsDevice graphicsDevice, List<InputLayoutElement> elements, num radius, vec3 center) {
    // Setup the generator
    SphereGenerator generator = new SphereGenerator();
    generator.radius = radius;

    // Create the mesh
    return MeshGenerator._createMesh(name, graphicsDevice, elements, generator, center);
  }
}

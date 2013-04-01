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
  // Member variables
  //---------------------------------------------------------------------

  /// The radius of the cylinder top
  num topRadius = 0.5;
  
  /// The radius of the cylinder bottom
  num bottomRadius = 0.5;
  
  /// The height of the cylinder
  num height = 1.0;
  
  /// The number of segments the [Mesh] will be divided into
  int segments = 16;
  
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
  int get vertexCount => ((segments + 1) * 2) + (segments * 2);

  /// Retrieves the size of the index buffer necessary to hold the generated [Mesh].
  int get indexCount => (segments * 6) + ((segments - 2) * 6);

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
    int base2 = segments + 1;
    for(x = 0; x < segments; ++x) {
      indices[indexOffset++] = base1 + x;
      indices[indexOffset++] = base1 + x + 1;
      indices[indexOffset++] = base2 + x;
      
      indices[indexOffset++] = base1 + x + 1;
      indices[indexOffset++] = base2 + x + 1;
      indices[indexOffset++] = base2 + x;
    }
    
    // Top cap
    base1 = (segments + 1) * 2;
    for(x = 1; x < segments-1; ++x) {
      indices[indexOffset++] = base1;
      indices[indexOffset++] = base1 + x + 1;
      indices[indexOffset++] = base1 + x;
    }
    
    // Bottom cap
    base1 = (segments + 1) * 2 + segments;
    for(x = 1; x < segments-1; ++x) {
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
  void _generatePositions(Vector3Array positions, vec3 center, int vertexOffset) {
    // Vertices are doubled up so that normals will be sharp
    
    // Top
    for (int x = 0; x <= segments; ++x) {
      double u = x / segments;
      
      positions[vertexOffset++] = new vec3.raw(
          topRadius * cos(u * Math.PI * 2.0) + center.x,
          height * 0.5 + center.y,
          topRadius * sin(u * Math.PI * 2.0) + center.z
      );
    }
    
    // Bottom
    for (int x = 0; x <= segments; ++x) {
      double u = x / segments;
      
      positions[vertexOffset++] = new vec3.raw(
          bottomRadius * cos(u * Math.PI * 2.0) + center.x,
          height * -0.5 + center.y,
          bottomRadius * sin(u * Math.PI * 2.0) + center.z
      );
    }
    
    // Top cap
    for (int x = 0; x < segments; ++x) {
      double u = x / segments;
      
      positions[vertexOffset++] = new vec3.raw(
          topRadius * cos(u * Math.PI * 2.0) + center.x,
          height * 0.5 + center.y,
          topRadius * sin(u * Math.PI * 2.0) + center.z
      );
    }
    
    // Bottom cap
    for (int x = 0; x < segments; ++x) {
      double u = x / segments;
      
      positions[vertexOffset++] = new vec3.raw(
          bottomRadius * cos(u * Math.PI * 2.0) + center.x,
          height * -0.5 + center.y,
          bottomRadius * sin(u * Math.PI * 2.0) + center.z
      );
    }
  }

  /// Generates the texture coordinates for the mesh.
  ///
  /// Texture coordinates will be placed within the [array] starting at the
  /// specified [vertexData]. When complete the \[[vertexOffset], [vertexOffset] + [vertexCount]\]
  /// within the [array] will contain texture coordinate data.
  void _generateTextureCoordinates(Vector2Array texCoords, int vertexOffset) {
    // Vertices are doubled up so that normals will be sharp
    
    // Cylinder top
    for (int x = 0; x <= segments; ++x) {
      double u = 1.0 - (x / segments);
      texCoords[vertexOffset++] = new vec2.raw(u, 0.0);
    }
    
    // Cylinder bottom
    for (int x = 0; x <= segments; ++x) {
      double u = 1.0 - (x / segments);
      texCoords[vertexOffset++] = new vec2.raw(u, 1.0);
    }
    
    // Top cap
    for (int x = 0; x < segments; ++x) {
      double r = (x / segments) * Math.PI * 2.0;
      texCoords[vertexOffset++] = new vec2.raw(
          (cos(r) * 0.5 + 0.5),
          (sin(r) * 0.5 + 0.5)
      );
    }
    
    // Bottom cap
    for (int x = 0; x < segments; ++x) {
      double r = (x / segments) * Math.PI * 2.0;
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
  static Mesh createCylinder(String name, GraphicsDevice graphicsDevice, List<InputLayoutElement> elements, num topRadius, num bottomRadius, num height, vec3 center) {
    // Setup the generator
    CylinderGenerator generator = new CylinderGenerator();
    generator.topRadius = topRadius;
    generator.bottomRadius = bottomRadius;
    generator.height = height;

    // Create the mesh
    return MeshGenerator._createMesh(name, graphicsDevice, elements, generator, center);
  }
}



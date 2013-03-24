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

  VertexData _vertexData;
  num radius = 0.5;
  vec3 center = new vec3.zero();
  int latSegments = 6;
  int lonSegments = 8;

  SphereGenerator();

  /**
   * Gets the number of vertices that will be created.
   *
   * For the amount of storage space see [vertexBufferSize].
   */
  int get vertexCount => ((lonSegments * (latSegments - 1)) + 2);

  /**
   * Retrieves the index buffer size necessary to hold the generated mesh.
   */
  int get indexCount => 6 * lonSegments * latSegments;
  
  /**
   * Generates positional data.
   */
  void _generatePositions(Vector3Array positions, vec3 center, int vertexOffset) {
    positions[vertexOffset++] = new vec3.raw(center.x, center.y + radius, center.z);

    for (int y = 1; y < latSegments; ++y) {
      for (int x = 0; x < lonSegments; ++x) {
        num u = x / lonSegments;
        num v = y / latSegments;

        positions[vertexOffset++] = new vec3.raw(
            radius * cos(u * Math.PI * 2.0) * sin(v * Math.PI) + center.x,
            radius * cos(v * Math.PI) + center.y,
            radius * sin(u * Math.PI * 2.0) * sin(v * Math.PI) + center.z
        );
      }
    }

    positions[vertexOffset++] = new vec3.raw(center.x, center.y - radius, center.z);
  }
  
  /**
   * Generates texture coordinate data.
   */
  void _generateTextureCoordData(Vector2Array texCoords, int vertexOffset) {
    int offset = vertexOffset++;
    
    texCoords[vertexOffset++] = new vec2.raw(0.5, 0);
    
    for (int y = 1; y < latSegments; ++y) {
      for (int x = 0; x < lonSegments; ++x) {
        num u = x / lonSegments;
        num v = y / latSegments;
        texCoords[vertexOffset++] = new vec2.raw(u, v);
      }
    }

    texCoords[vertexOffset++] = new vec2.raw(0.5, 1.0);
  }
  
  /**
   * Populates the indices for the mesh.
   */
  void _generateIndices(Int16Array indexBuffer, int vertexOffset, int indexOffset) {
    int x;
    
    // First ring
    for(x = 0; x < lonSegments-1; ++x) {
      indexBuffer[indexOffset++] = 0;
      indexBuffer[indexOffset++] = x + 2;
      indexBuffer[indexOffset++] = x + 1;
    }
    indexBuffer[indexOffset++] = 0;
    indexBuffer[indexOffset++] = 1;
    indexBuffer[indexOffset++] = x + 1;
    
    // Center rings
    int ring1Base, ring2Base;
    for (int y = 0; y < latSegments-2; ++y) {
      ring1Base = (lonSegments * y) + 1;
      ring2Base = (lonSegments * (y + 1)) + 1;
      for (x = 0; x < lonSegments-1; ++x) {
        indexBuffer[indexOffset++] = ring1Base + x;
        indexBuffer[indexOffset++] = ring1Base + x + 1;
        indexBuffer[indexOffset++] = ring2Base + x;
        
        indexBuffer[indexOffset++] = ring1Base + x + 1;
        indexBuffer[indexOffset++] = ring2Base + x + 1;
        indexBuffer[indexOffset++] = ring2Base + x;
      }
      
      indexBuffer[indexOffset++] = ring1Base + x;
      indexBuffer[indexOffset++] = ring1Base;
      indexBuffer[indexOffset++] = ring2Base + x;
      
      indexBuffer[indexOffset++] = ring1Base;
      indexBuffer[indexOffset++] = ring2Base;
      indexBuffer[indexOffset++] = ring2Base + x;
    }
    
    // Last ring
    ring1Base = (lonSegments * (latSegments-2)) + 1;
    ring2Base = (lonSegments * (latSegments-1)) + 1;
    for(x = 0; x < lonSegments-1; ++x) {
      indexBuffer[indexOffset++] = ring2Base;
      indexBuffer[indexOffset++] = ring1Base + x;
      indexBuffer[indexOffset++] = ring1Base + x + 1;
    }
    indexBuffer[indexOffset++] = ring2Base;
    indexBuffer[indexOffset++] = ring1Base + x;
    indexBuffer[indexOffset++] = ring1Base;
  }

  /// Creates a single sphere with the given [extents] at the specified [center].
  ///
  /// This is a helper method for creating a single sphere. If you are creating
  /// many sphere meshes prefer creating a [SphereGenerator] and using that to generate
  /// multiple meshes.
  static Mesh createSphere(String name, GraphicsDevice graphicsDevice, List<InputLayoutElement> elements, num radius, vec3 center) {
    // Setup the generator
    SphereGenerator generator = new SphereGenerator();
    generator.radius = radius;

    // Create the mesh
    Mesh mesh = MeshGenerator._createMesh(name, graphicsDevice, elements, generator, center);
    return mesh;
  }
}

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

part of spectre;

/// A container for mesh data.
///
/// Made up of a [VertexBuffer], [InputLayout], [PrimitiveType], and optionally
/// an [IndexBuffer]. Whenever possible prefer creating a [Mesh] and setting this
/// to the [GraphicsContext] rather than setting each of the components individually.
class Mesh extends DeviceChild {
  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The vertices of the mesh.
  VertexBuffer _vertexBuffer;
  /// The layout of the vertices within the mesh.
  InputLayout _inputLayout;
  /// The indices of the mesh.
  IndexBuffer _indexBuffer;
  /// The primitive type
  int _primitiveType;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  Mesh(String name, GraphicsDevice graphicsDevice, VertexBuffer vertexBuffer, InputLayout inputLayout, [IndexBuffer indexBuffer = null, int primitiveType = PrimitiveType.TriangleList])
    : super._internal(name, graphicsDevice)
    , _vertexBuffer = vertexBuffer
    , _inputLayout = inputLayout
    , _indexBuffer = indexBuffer
    , _primitiveType = primitiveType;

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The vertices of the mesh.
  VertexBuffer get vertexBuffer => _vertexBuffer;
  /// The layout of the vertices within the mesh.
  InputLayout get inputLayout => _inputLayout;
  /// The indices of the mesh.
  IndexBuffer get indexBuffer => _indexBuffer;
  /// The primitive type
  int get primitiveType => _primitiveType;
}

class SpectreMeshAttribute {
  final String name;
  final String componentType;
  final int componentCount;
  final int offset;
  final int stride;
  final bool normalized;

  SpectreMeshAttribute(this.name, this.componentType, this.componentCount,
                       this.offset, this.stride, this.normalized);

  DeviceFormat get deviceFormat {
    assert(componentType == 'float');
    switch (componentCount) {
      case 1:
        return GraphicsDevice.DeviceFormatFloat1;
      case 2:
        return GraphicsDevice.DeviceFormatFloat2;
      case 3:
        return GraphicsDevice.DeviceFormatFloat3;
      case 4:
        return GraphicsDevice.DeviceFormatFloat4;
      default:
        throw new FallThroughError();
    }
  }

  String toString() => '$name $componentType$componentCount $offset $stride';
}

abstract class SpectreMesh extends DeviceChild {
  final Map<String, SpectreMeshAttribute> attributes =
      new Map<String, SpectreMeshAttribute>();
  int count = 0;
  int primitiveTopology = GraphicsContext.PrimitiveTopologyTriangles;
  SpectreMesh(String name, GraphicsDevice device)
      : super._internal(name, device);
  void finalize() {
    super.finalize();
  }
}

class SingleArrayMesh extends SpectreMesh {
  VertexBuffer _deviceVertexBuffer;
  VertexBuffer get vertexArray => _deviceVertexBuffer;

  SingleArrayMesh(String name, GraphicsDevice device) : super(name, device) {
    _deviceVertexBuffer = new VertexBuffer(name, device);
  }

  void finalize() {
    super.finalize();
    _deviceVertexBuffer.dispose();
    _deviceVertexBuffer = null;
    count = 0;
  }
}

class SingleArrayIndexedMesh extends SpectreMesh {
  VertexBuffer _deviceVertexBuffer;
  IndexBuffer _deviceIndexBuffer;
  IndexBuffer get indexArray => _deviceIndexBuffer;
  VertexBuffer get vertexArray => _deviceVertexBuffer;

  SingleArrayIndexedMesh(String name, GraphicsDevice device)
      : super(name, device) {
    _deviceVertexBuffer = new VertexBuffer(name, device);
    _deviceIndexBuffer = new IndexBuffer(name, device);
  }

  void finalize() {
    super.finalize();
    _deviceVertexBuffer.dispose();
    _deviceIndexBuffer.dispose();
    count = 0;
  }
}

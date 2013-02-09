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

class SpectreMesh extends DeviceChild {
  final Map<String, SpectreMeshAttribute> attributes =
      new Map<String, SpectreMeshAttribute>();

  int count = 0;
  int primitiveTopology = GraphicsContext.PrimitiveTopologyTriangles;

  SpectreMesh(String name, GraphicsDevice device)
      : super._internal(name, device);


  void _createDeviceState() {
    super._createDeviceState();
  }


  void _destroyDeviceState() {
    super._destroyDeviceState();
  }
}

class SingleArrayMesh extends SpectreMesh {
  VertexBuffer _deviceVertexBuffer;
  VertexBuffer get vertexArray => _deviceVertexBuffer;

  SingleArrayMesh(String name, GraphicsDevice device) : super(name, device) {
  }


  void _createDeviceState() {
    super._createDeviceState();
    _deviceVertexBuffer = device.createVertexBuffer('$name[VB]');
  }


  void _destroyDeviceState() {
    if (_deviceVertexBuffer != null) {
      _deviceVertexBuffer._destroyDeviceState();
    }
    _deviceVertexBuffer = null;
    count = 0;
    super._destroyDeviceState();
  }
}

class SingleArrayIndexedMesh extends SpectreMesh {
  VertexBuffer _deviceVertexBuffer;
  IndexBuffer _deviceIndexBuffer;
  IndexBuffer get indexArray => _deviceIndexBuffer;
  VertexBuffer get vertexArray => _deviceVertexBuffer;

  SingleArrayIndexedMesh(String name, GraphicsDevice device)
      : super(name, device) {
  }


  void _createDeviceState() {
    super._createDeviceState();
    _deviceVertexBuffer = device.createVertexBuffer('$name[VB]');
    _deviceIndexBuffer = device.createIndexBuffer('$name[IB]');
  }


  void _destroyDeviceState() {
    if (_deviceVertexBuffer != null) {
      device.deleteDeviceChild(_deviceVertexBuffer);
      _deviceVertexBuffer = null;
    }
    if (_deviceIndexBuffer != null) {
      device.deleteDeviceChild(_deviceIndexBuffer);
      _deviceIndexBuffer = null;
    }
    count = 0;
    super._destroyDeviceState();
  }
}

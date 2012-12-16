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
      break;
      case 2:
        return GraphicsDevice.DeviceFormatFloat2;
      break;
      case 3:
        return GraphicsDevice.DeviceFormatFloat3;
      break;
      case 4:
        return GraphicsDevice.DeviceFormatFloat4;
      break;
      default:
        throw new FallThroughError();
    }
  }

  String toString() => '$name $componentType$componentCount $offset $stride';
}

class SpectreMesh extends DeviceChild {
  final Map<String, SpectreMeshAttribute> attributes =
      new Map<String, SpectreMeshAttribute>();


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
  int numVertices = 0;

  SingleArrayMesh(String name, GraphicsDevice device) : super(name, device) {
    _deviceVertexBuffer = device.createVertexBuffer('$name[VB]', {});
  }


  void _createDeviceState() {
    super._createDeviceState();
    _deviceVertexBuffer._createDeviceState();
  }


  void _destroyDeviceState() {
    if (_deviceVertexBuffer != null) {
      _deviceVertexBuffer._destroyDeviceState();
    }
    _deviceVertexBuffer = null;
    numVertices = 0;
    super._destroyDeviceState();
  }
}

class SingleArrayIndexedMesh extends SpectreMesh {
  VertexBuffer _deviceVertexBuffer;
  IndexBuffer _deviceIndexBuffer;
  IndexBuffer get indexArray => _deviceIndexBuffer;
  VertexBuffer get vertexArray => _deviceVertexBuffer;
  int numIndices = 0;

  SingleArrayIndexedMesh(String name, GraphicsDevice device)
      : super(name, device) {
    _deviceVertexBuffer = device.createVertexBuffer('$name[VB]', {});
    _deviceIndexBuffer = device.createIndexBuffer('$name[IB]', {});
  }


  void _createDeviceState() {
    super._createDeviceState();
    _deviceVertexBuffer._createDeviceState();
    _deviceIndexBuffer._createDeviceState();
  }


  void _destroyDeviceState() {
    if (_deviceVertexBuffer != null) {
      _deviceVertexBuffer._destroyDeviceState();
    }
    if (_deviceIndexBuffer != null) {
      _deviceIndexBuffer._destroyDeviceState();
    }
    _deviceVertexBuffer = null;
    _deviceIndexBuffer = null;
    numIndices = 0;
    super._destroyDeviceState();
  }
}

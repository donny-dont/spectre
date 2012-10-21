/*

  Copyright (C) 2012 John McCutchan <john@johnmccutchan.com>

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

/// Format describing a vertex buffer element
class DeviceFormat {
  final int type;
  final int count;
  final bool normalized;
  const DeviceFormat(this.type, this.count, this.normalized);
  String toString() {
    return '($type, $count, $normalized)';
  }
}

/// Description used to create an input layout
/// Attribute [name] must match name in shader program
/// Attribute [format] device format for attribute
/// Attribute [elementStride] bytes between successive elements
/// Attribute [vertexBufferSlot] the vertex buffer slot to pull elements from
/// Attribute [vertexBufferOffset] the offset into the vertex buffer to pull the first element
class InputElementDescription {
  String name;
  DeviceFormat format;
  int elementStride;
  int vertexBufferSlot;
  int vertexBufferOffset;

  InputElementDescription(this.name, this.format, this.elementStride, this.vertexBufferSlot, this.vertexBufferOffset);
}

class _InputElementCheckerItem {
  String name;
  int vertexBufferSlot;
  int vertexBufferOffset;
  _InputElementCheckerItem(this.name, this.vertexBufferSlot, this.vertexBufferOffset);
}

class _InputElementChecker {
  List<_InputElementCheckerItem> items;
  _InputElementChecker() {
    items = new List<_InputElementCheckerItem>();
  }

  void add(InputElementDescription d) {
    _InputElementCheckerItem item = new _InputElementCheckerItem(d.name, d.vertexBufferSlot, d.vertexBufferOffset);
    for(_InputElementCheckerItem check in items) {
      if (check.vertexBufferOffset == item.vertexBufferOffset && check.vertexBufferSlot == item.vertexBufferSlot) {
        spectreLog.Warning('Input elements -  ${check.name} and ${item.name} - share same offset. This is likely an error.');
      }
    }
    items.add(item);
  }
}

/// Spectre GPU Device

/// All GPU resources are created and destroyed through a Device.

/// Each resource requires a unique name.

/// An existing resource can be looked up using its name.
class GraphicsDevice {
  static const DeviceFormat DeviceFormatFloat1 = const DeviceFormat(WebGLRenderingContext.FLOAT, 1, false);
  static const DeviceFormat DeviceFormatFloat2 = const DeviceFormat(WebGLRenderingContext.FLOAT, 2, false);
  static const DeviceFormat DeviceFormatFloat3 = const DeviceFormat(WebGLRenderingContext.FLOAT, 3, false);
  static const DeviceFormat DeviceFormatFloat4 = const DeviceFormat(WebGLRenderingContext.FLOAT, 4, false);

  static const int BufferHandleType = 1;
  static const int RenderBufferHandleType = 2;
  static const int RenderTargetHandleType = 3;
  static const int TextureHandleType = 4;
  static const int SamplerStateHandleType = 5;
  static const int ShaderHandleType = 6;
  static const int ShaderProgramHandleType = 7;
  static const int ViewportHandleType = 8;
  static const int DepthStateHandleType = 9;
  static const int BlendStateHandleType = 10;
  static const int RasterizerStateHandleType = 11;
  static const int InputLayoutHandleType = 12;
  static const int MeshHandleType = 13;

  Map _getPropertyMap(Dynamic props) {
    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }
    return props;
  }

  String getHandleType(int handle) {
    int type = Handle.getType(handle);
    switch (type) {
      case BufferHandleType:
        return 'Buffer';
      case RenderBufferHandleType:
        return 'RenderBuffer';
      case RenderTargetHandleType:
        return 'RenderTarget';
      case TextureHandleType:
        return 'Texture';
      case SamplerStateHandleType:
        return 'SamplerState';
      case ShaderHandleType:
        return 'Shader';
      case ShaderProgramHandleType:
        return 'ShaderProgram';
      case ViewportHandleType:
        return 'Viewport';
      case DepthStateHandleType:
        return 'DepthState';
      case BlendStateHandleType:
        return 'BlendState';
      case RasterizerStateHandleType:
        return 'RasterizerState';
      case InputLayoutHandleType:
        return 'Input Layout';
      default:
        return 'Unknown handle type';
    }
  }

  GraphicsContext _context;
  GraphicsContext get context() => _context;

  WebGLRenderingContext _gl;
  WebGLRenderingContext get gl() => _gl;

  // There is a 1:1 mapping between _childrenHandles and _childrenObjects
  HandleSystem _childrenHandles;
  List<DeviceChild> _childrenObjects;

  // Maps from child object name to handle
  Map<String, int> _nameMapping;

  static const int MaxDeviceChildren = 2048;
  static const int MaxStaticDeviceChildren = 512;

  int _fallbackTextureID;

  void _drawSquare(CanvasRenderingContext2D context, int x, int y, int w, int h) {
    context.save();
    context.beginPath();
    context.translate(x, y);
    context.fillStyle = "#656565";
    context.fillRect(0, 0, w, h);
    context.restore();
  }

  void _drawGrid(CanvasRenderingContext2D context, int width, int height, int horizSlices, int vertSlices) {
    int sliceWidth = width ~/ horizSlices;
    int sliceHeight = height ~/ vertSlices;
    int sliceHalfWidth = sliceWidth ~/ 2;
    for (int i = 0; i < horizSlices; i++) {
      for (int j = 0; j < vertSlices; j++) {
        if (j % 2 == 0) {
          _drawSquare(context, i * sliceWidth, j * sliceHeight, sliceHalfWidth, sliceHeight);
        } else {
          _drawSquare(context, i * sliceWidth + sliceHalfWidth, j * sliceHeight, sliceHalfWidth, sliceHeight);
        }
      }
    }
  }

  /// Constructs a GPU device
  GraphicsDevice(WebGLRenderingContext gl) {
    _gl = gl;
    _childrenHandles = new HandleSystem(MaxDeviceChildren, MaxStaticDeviceChildren);
    _childrenObjects = new List(MaxDeviceChildren);
    _nameMapping = new Map<String, int>();
    _context = new GraphicsContext(this);
    _fallbackTextureID = createTexture2D('Device.Fallback', {'width': 512, 'height': 512, 'textureFormat' : Texture.TextureFormatRGBA, 'pixelFormat': Texture.PixelFormatUnsignedByte});
    {
      CanvasElement canvas = new CanvasElement();
      canvas.width = 512;
      canvas.height = 512;
      CanvasRenderingContext2D context = canvas.getContext('2d');
      _drawGrid(context, 512, 512, 8, 8);
      configureDeviceChild(_fallbackTextureID, {'pixels': canvas});
      _context.generateMipmap(_fallbackTextureID);
    }
  }

  /// Returns the handle to the device child named [name]
  int getDeviceChildHandle(String name) {
    int h = _nameMapping[name];
    if (h == null) {
      return Handle.BadHandle;
    }
    return h;
  }

  Map<String, int> get children() => _nameMapping;

  /// Lookup the actual device child object given the [handle]
  Dynamic getDeviceChild(int handle, [bool noFallback=false]) {
    if (handle == 0) {
      return null;
    }
    if (_childrenHandles.validHandle(handle) == false) {
      spectreLog.Warning('$handle is not a valid handle');
      return null;
    }
    int index = Handle.getIndex(handle);
    DeviceChild dc = _childrenObjects[index];
    if (dc == null) {
      spectreLog.Warning('$handle is not a valid handle [2]');
      return null;
    }
    if (noFallback == false && dc.ready == false && dc.fallback != 0) {
      // Recurse
      //print('Fetching fallback: ${_childrenObjects[index].fallback}');
      return getDeviceChild(_childrenObjects[index].fallback);
    }
    return dc;
  }

  String getDeviceChildName(int handle) {
    Dynamic dc = getDeviceChild(handle);
    if (dc != null) {
      return dc.name;
    }
    return 'Unknown handle: $handle';
  }

  void _setChildObject(int handle, DeviceChild o) {
    int index = Handle.getIndex(handle);
    _childrenObjects[index] = o;
  }

  /// Registers a handle with the given [type] and [name]
  /// [handle] is an optional argument that, if provided, must be a statically reserved handle
  int _registerHandle(String name, int type, [int handle=Handle.BadHandle]) {
    {
      // Check if name is already registered
      int existingHandle = getDeviceChildHandle(name);
      if (existingHandle != Handle.BadHandle) {
        int handleType = Handle.getType(existingHandle);
        if (handleType != type) {
          spectreLog.Error('Returning existing handle for $name but types do not match. Requested type = $type found type = $handleType');
        }
        return existingHandle;
      }
    }
    if (handle != Handle.BadHandle) {
      // Static handle
      {
        int handleType = Handle.getType(handle);
        assert(handleType == type);
      }
      int r = _childrenHandles.setStaticHandle(handle);
      if (r != handle) {
        spectreLog.Error('Spectre.Device._registerHandle - Registering a static handle $handle failed.');
        return Handle.BadHandle;
      }
    } else {
      // Dynamic handle
      handle = _childrenHandles.allocateHandle(type);
      if (handle == Handle.BadHandle) {
        spectreLog.Error('Spectre.Device._registerHandle - Registering dynamic handle failed.');
        return Handle.BadHandle;
      }
    }
    assert(_childrenHandles.validHandle(handle));
    int index = Handle.getIndex(handle);
    //print('$index - $name');
    // Nothing is at this index
    assert(_childrenObjects[index] == null);

    // Register name
    _nameMapping[name] = handle;

    return handle;
  }

  /// Deletes the device child [handle]
  void deleteDeviceChild(int handle) {
    if (handle == 0) {
      return;
    }
    if (_childrenHandles.validHandle(handle) == false) {
      spectreLog.Warning('Deleting device child handle [$handle] is invalid.');
      return;
    }
    int index = Handle.getIndex(handle);
    DeviceChild dc = _childrenObjects[index];
    if (dc == null) {
      spectreLog.Error('deleteDeviceChild unable to find device child for [$handle]');
      return;
    }
    dc._destroyDeviceState();
    _nameMapping.remove(dc.name);
    _childrenObjects[index] = null;
    print('remove: $index - ${dc.name}');
  }

  void batchDeleteDeviceChildren(List<int> handles) {
    for (int h in handles) {
      deleteDeviceChild(h);
    }
  }

  void configureDeviceChild(int handle, Dynamic props) {
    Dynamic deviceChild = getDeviceChild(handle);
    if (deviceChild == null) {
      return;
    }
    props = _getPropertyMap(props);
    deviceChild._configDeviceState(props);
  }

  /// Create a IndexBuffer named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the IndexBuffer being created. If [handle] is specified it must be a registered handle.
  ///
  /// Returns the handle to the IndexBuffer.
  int createIndexBuffer(String name, Dynamic props) {
    int handle = _registerHandle(name, BufferHandleType);
    if (handle == Handle.BadHandle) {
      return handle;
    }
    props = _getPropertyMap(props);
    IndexBuffer ib = new IndexBuffer(name, this);
    _setChildObject(handle, ib);
    ib._createDeviceState();
    ib._configDeviceState(props);
    return handle;
  }

  /// Create a [VertexBuffer] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [VertexBuffer] being created
  int createVertexBuffer(String name, Dynamic props) {
    int handle = _registerHandle(name, BufferHandleType);
    if (handle == Handle.BadHandle) {
      return handle;
    }
    props = _getPropertyMap(props);
    VertexBuffer vb = new VertexBuffer(name, this);
    _setChildObject(handle, vb);
    vb._createDeviceState();
    vb._configDeviceState(props);
    return handle;
  }

  /// Create a [RenderBuffer] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [RenderBuffer] being created
  int createRenderBuffer(String name, Dynamic props) {
    int handle = _registerHandle(name, RenderBufferHandleType);
    if (handle == Handle.BadHandle) {
      return handle;
    }
    props = _getPropertyMap(props);
    RenderBuffer rb = new RenderBuffer(name, this);
    _setChildObject(handle, rb);
    rb._createDeviceState();
    rb._configDeviceState(props);
    return handle;
  }

  /// Create a [RenderTarget] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [RenderTarget] being created
  int createRenderTarget(String name, Dynamic props) {
    int handle = _registerHandle(name, RenderTargetHandleType);
    if (handle == Handle.BadHandle) {
      return handle;
    }
    props = _getPropertyMap(props);
    RenderTarget rt = new RenderTarget(name, this);
    _setChildObject(handle, rt);
    rt._createDeviceState();
    rt._configDeviceState(props);
    return handle;
  }

  /// Create a [Texture2D] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [Texture2D] being created
  int createTexture2D(String name, Dynamic props) {
    int handle = _registerHandle(name, TextureHandleType);
    if (handle == Handle.BadHandle) {
      return handle;
    }
    props = _getPropertyMap(props);
    Texture2D tex = new Texture2D(name, this);
    _setChildObject(handle, tex);
    tex._createDeviceState();
    tex._configDeviceState(props);
    if (_fallbackTextureID != null) {
      // After the fallback texture is ready we mark all textures unready.
      tex.ready = false;
      tex.fallback = _fallbackTextureID;
    }
    return handle;
  }

  /// Create a [VertexShader] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [VertexShader] being created
  int createVertexShader(String name, Dynamic props) {
    int handle = _registerHandle(name, ShaderHandleType);
    if (handle == Handle.BadHandle) {
      return handle;
    }
    props = _getPropertyMap(props);
    VertexShader vertexShader = new VertexShader(name, this);
    _setChildObject(handle, vertexShader);
    vertexShader._createDeviceState();
    vertexShader._configDeviceState(props);
    return handle;
  }

  /// Create a [FragmentShader] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [FragmentShader] being created
  int createFragmentShader(String name, Dynamic props) {
    int handle = _registerHandle(name, ShaderHandleType);
    if (handle == Handle.BadHandle) {
      return handle;
    }
    props = _getPropertyMap(props);
    FragmentShader fragmentShader = new FragmentShader(name, this);
    _setChildObject(handle, fragmentShader);
    fragmentShader._createDeviceState();
    fragmentShader._configDeviceState(props);
    return handle;
  }

  /// Create a [ShaderProgram] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [ShaderProgram] being created
  int createShaderProgram(String name, Dynamic props) {
    int handle = _registerHandle(name, ShaderProgramHandleType);
    if (handle == Handle.BadHandle) {
      return handle;
    }
    props = _getPropertyMap(props);
    ShaderProgram shaderProgram = new ShaderProgram(name, this);
    _setChildObject(handle, shaderProgram);
    shaderProgram._createDeviceState();
    shaderProgram._configDeviceState(props);

    return handle;
  }

  /// Create a [SamplerState] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [SamplerState] being created
  int createSamplerState(String name, Dynamic props) {
    int handle = _registerHandle(name, SamplerStateHandleType);
    if (handle == Handle.BadHandle) {
      return handle;
    }
    props = _getPropertyMap(props);
    SamplerState sampler = new SamplerState(name, this);
    _setChildObject(handle, sampler);
    sampler._createDeviceState();
    sampler._configDeviceState(props);
    return handle;
  }

  /// Create a [Viewport] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [Viewport] being created
  int createViewport(String name, Dynamic props) {
    int handle = _registerHandle(name, ViewportHandleType);
    if (handle == Handle.BadHandle) {
      return handle;
    }
    props = _getPropertyMap(props);
    Viewport viewport = new Viewport(name, this);
    _setChildObject(handle, viewport);
    viewport._createDeviceState();
    viewport._configDeviceState(props);
    return handle;
  }

  /// Create a [DepthState] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [DepthState] being created
  int createDepthState(String name, Dynamic props) {
    int handle = _registerHandle(name, DepthStateHandleType);
    if (handle == Handle.BadHandle) {
      return handle;
    }
    props = _getPropertyMap(props);
    DepthState depthState = new DepthState(name, this);
    _setChildObject(handle, depthState);
    depthState._createDeviceState();
    depthState._configDeviceState(props);
    return handle;
  }

  /// Create a [BlendState] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [BlendState] being created
  int createBlendState(String name, Object props) {
    int handle = _registerHandle(name, BlendStateHandleType);
    if (handle == Handle.BadHandle) {
      return handle;
    }
    props = _getPropertyMap(props);

    BlendState blendState = new BlendState(name, this);
    _setChildObject(handle, blendState);
    blendState._createDeviceState();
    blendState._configDeviceState(props);
    return handle;
  }

  /// Create a [RasterizerState] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [RasterizerState] being created
  int createRasterizerState(String name, Object props) {
    int handle = _registerHandle(name, RasterizerStateHandleType);
    if (handle == Handle.BadHandle) {
      return handle;
    }
    props = _getPropertyMap(props);

    RasterizerState rasterizerState = new RasterizerState(name, this);
    _setChildObject(handle, rasterizerState);
    rasterizerState._createDeviceState();
    rasterizerState._configDeviceState(props);
    return handle;
  }

  /// Create an [InputLayout] named [name]
  ///
  /// [props] is a JSONS tring or a [Map] containing a set of properties
  /// describing the [InputLayout] being created.
  int createInputLayout(String name, Object props) {
    int handle = _registerHandle(name, InputLayoutHandleType);
    if (handle == Handle.BadHandle) {
      return handle;
    }

    props = _getPropertyMap(props);
    InputLayout il = new InputLayout(name, this);
    _setChildObject(handle, il);
    il._createDeviceState();
    il._configDeviceState(props);
    return handle;
  }

  /// Create an [IndexedMesh] named [name]
  /// [props] is a JSON String or a [Map] containing a set of properties
  int createIndexedMesh(String name, Dynamic props) {
    int handle = _registerHandle(name, MeshHandleType);
    if (handle == Handle.BadHandle) {
      return handle;
    }
    props = _getPropertyMap(props);

    IndexedMesh indexedMesh = new IndexedMesh(name, this);
    _setChildObject(handle, indexedMesh);
    indexedMesh._createDeviceState();
    indexedMesh._configDeviceState(props);
    return handle;
  }

  /// Create an [ArrayMesh] name [name]
  /// [props] is a JSON String or a [Map] containing a set of properties
  int createArrayMesh(String name, Dynamic props) {
    int handle = _registerHandle(name, MeshHandleType);
    if (handle == Handle.BadHandle) {
      return handle;
    }
    props = _getPropertyMap(props);
    ArrayMesh arrayMesh = new ArrayMesh(name, this);
    _setChildObject(handle, arrayMesh);
    arrayMesh._createDeviceState();
    arrayMesh._configDeviceState(props);
    return handle;
  }
}

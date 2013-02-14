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

/// Spectre GPU Device

/// All GPU resources are created and destroyed through a Device.

/// Each resource requires a unique name.

/// An existing resource can be looked up using its name.
class GraphicsDevice {
  static const DeviceFormat DeviceFormatFloat1 =
                    const DeviceFormat(WebGLRenderingContext.FLOAT, 1, false);
  static const DeviceFormat DeviceFormatFloat2 =
                    const DeviceFormat(WebGLRenderingContext.FLOAT, 2, false);
  static const DeviceFormat DeviceFormatFloat3 =
                    const DeviceFormat(WebGLRenderingContext.FLOAT, 3, false);
  static const DeviceFormat DeviceFormatFloat4 =
                    const DeviceFormat(WebGLRenderingContext.FLOAT, 4, false);

  // Dump all children.
  void dumpChildren() {
    _children.forEach((child) {
      print('${child.name} ${child.runtimeType}');
    });
  }

  GraphicsContext _context;
  GraphicsContext get context => _context;

  GraphicsDeviceCapabilities _capabilities;
  GraphicsDeviceCapabilities get capabilities => _capabilities;

  WebGLRenderingContext _gl;
  WebGLRenderingContext get gl => _gl;

  final Set<DeviceChild> _children = new Set<DeviceChild>();

  void _addChild(DeviceChild child) {
    _children.add(child);
  }

  void _removeChild(DeviceChild child) {
    _children.remove(child);
  }

  void _drawSquare(CanvasRenderingContext2D context2d, int x, int y, int w, int h) {
    context2d.save();
    context2d.beginPath();
    context2d.translate(x, y);
    context2d.fillStyle = "#656565";
    context2d.fillRect(0, 0, w, h);
    context2d.restore();
  }

  void _drawGrid(CanvasRenderingContext2D context2d, int width, int height, int horizSlices, int vertSlices) {
    int sliceWidth = width ~/ horizSlices;
    int sliceHeight = height ~/ vertSlices;
    int sliceHalfWidth = sliceWidth ~/ 2;
    for (int i = 0; i < horizSlices; i++) {
      for (int j = 0; j < vertSlices; j++) {
        if (j % 2 == 0) {
          _drawSquare(context2d, i * sliceWidth, j * sliceHeight, sliceHalfWidth, sliceHeight);
        } else {
          _drawSquare(context2d, i * sliceWidth + sliceHalfWidth, j * sliceHeight, sliceHalfWidth, sliceHeight);
        }
      }
    }
  }

  /// Initializes an instance of the [GraphicsDevice] class.
  ///
  /// A [WebGLRenderingContext] is created from the given [surface]. Additionally an
  /// optional instance of [GraphicsDeviceConfig] can be passed in to control the creation
  /// of the underlying frame buffer.
  GraphicsDevice(CanvasElement surface, [GraphicsDeviceConfig config = null]) {
    assert(surface != null);

    // Get the WebGL context
    if (config == null) {
      config = new GraphicsDeviceConfig();
    }

    _gl = surface.getContext3d(stencil: config.stencilBuffer);
    _capabilities = new GraphicsDeviceCapabilities._fromContext(gl);

    print(_capabilities);

    // Create the associated GraphicsContext
    _context = new GraphicsContext(this);

    RenderTarget._systemRenderTarget = createRenderTarget(
        'SystemProvidedRenderTarget');
    RenderTarget._systemRenderTarget._makeSystemTarget();
  }

  /// Deletes the device child [child].
  void deleteDeviceChild(DeviceChild child) {
    child.dispose();
    _children.remove(child);
  }

  /// Delete a list of device children [children].
  void batchDeleteDeviceChildren(List<DeviceChild> children) {
    for (DeviceChild dc in children) {
      deleteDeviceChild(dc);
    }
  }

  /// Create an [IndexBuffer] named [name]
  IndexBuffer createIndexBuffer(String name) {
    IndexBuffer ib = new IndexBuffer(name, this);
    _children.add(ib);
    return ib;
  }

  /// Create a [VertexBuffer] named [name]
  VertexBuffer createVertexBuffer(String name) {
    VertexBuffer vb = new VertexBuffer(name, this);
    _children.add(vb);
    return vb;
  }

  /// Create a [RenderBuffer] named [name]
  RenderBuffer createRenderBuffer(String name) {
    RenderBuffer rb = new RenderBuffer(name, this);
    _children.add(rb);
    return rb;
  }

  /// Create a [RenderTarget] named [name]
  RenderTarget createRenderTarget(String name) {
    RenderTarget rt = new RenderTarget(name, this);
    _children.add(rt);
    return rt;
  }

  /// Create a [Texture2D] named [name]
  Texture2D createTexture2D(String name) {
    Texture2D tex = new Texture2D(name, this);
    _children.add(tex);
    return tex;
  }

  /// Create a [TextureCube] named [name].
  TextureCube createTextureCube(String name) {
    TextureCube tex = new TextureCube(name, this);
    _children.add(tex);
    return tex;
  }

  /// Create a [VertexShader] named [name].
  VertexShader createVertexShader(String name) {
    VertexShader vertexShader = new VertexShader(name, this);
    _children.add(vertexShader);
    return vertexShader;
  }

  /// Create a [FragmentShader] named [name].
  FragmentShader createFragmentShader(String name) {
    FragmentShader fragmentShader = new FragmentShader(name, this);
    _children.add(fragmentShader);
    return fragmentShader;
  }

  /// Create a [ShaderProgram] named [name].
  ShaderProgram createShaderProgram(String name) {
    ShaderProgram shaderProgram = new ShaderProgram(name, this);
    _children.add(shaderProgram);
    return shaderProgram;
  }

  /// Create a [SamplerState] named [name].
  SamplerState createSamplerState(String name) {
    SamplerState sampler = new SamplerState(name, this);
    _children.add(sampler);
    return sampler;
  }

  /// Create a [Viewport] named [name].
  Viewport createViewport(String name) {
    Viewport viewport = new Viewport(name, this);
    _children.add(viewport);
    return viewport;
  }

  /// Create a [DepthState] named [name].
  DepthState createDepthState(String name) {
    DepthState depthState = new DepthState(name, this);
    _children.add(depthState);
    return depthState;
  }

  /// Create a [BlendState] named [name].
  BlendState createBlendState(String name) {
    BlendState blendState = new BlendState(name, this);
    _children.add(blendState);
    return blendState;
  }

  /// Create a [RasterizerState] named [name].
  RasterizerState createRasterizerState(String name) {
    RasterizerState rasterizerState = new RasterizerState(name, this);
    _children.add(rasterizerState);
    return rasterizerState;
  }

  /// Create an [InputLayout] named [name].
  InputLayout createInputLayout(String name) {
    InputLayout il = new InputLayout(name, this);
    _children.add(il);
    return il;
  }

  /// Create a [SingleArrayMesh] named [name].
  SingleArrayMesh createSingleArrayMesh(String name) {
    SingleArrayMesh arrayMesh = new SingleArrayMesh(name, this);
    _children.add(arrayMesh);
    return arrayMesh;
  }

  /// Create a [SingleArrayIndexedMesh] named [name].
  SingleArrayIndexedMesh createSingleArrayIndexedMesh(String name) {
    SingleArrayIndexedMesh indexedMesh = new SingleArrayIndexedMesh(name, this);
    _children.add(indexedMesh);
    return indexedMesh;
  }
}

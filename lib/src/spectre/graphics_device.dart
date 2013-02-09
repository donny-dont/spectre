part of spectre;

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

  /// Constructs a GPU device
  GraphicsDevice(CanvasElement canvas) {
    assert(canvas != null);

    // Get the WebGL context.
    // A stencil buffer is not created by default so request that be
    // created. Other than that the defaults are fine.
    //_gl = canvas.getContext3d(stencil: true);
    _gl = canvas.getContext('experimental-webgl');

    _context = new GraphicsContext(this);
    _capabilities = new GraphicsDeviceCapabilities._fromContext(gl);
    /*
     var _fallbackTexture = createTexture2D('Device.Fallback');
     {
      CanvasElement canvas = new CanvasElement();
      canvas.width = 512;
      canvas.height = 512;
      CanvasRenderingContext2D context2d = canvas.getContext('2d');
      _drawGrid(context2d, 512, 512, 8, 8);
      _fallbackTexture.uploadElement(canvas);
      _fallbackTexture.generateMipmap();
    }
    */
    RenderTarget._systemRenderTarget = createRenderTarget(
        'SystemProvidedRenderTarget');
    RenderTarget._systemRenderTarget._makeSystemTarget();
  }


  /// Deletes the device child [child].
  void deleteDeviceChild(DeviceChild child) {
    child._destroyDeviceState();
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
    ib._createDeviceState();
    return ib;
  }

  /// Create a [VertexBuffer] named [name]
  VertexBuffer createVertexBuffer(String name) {
    VertexBuffer vb = new VertexBuffer(name, this);
    _children.add(vb);
    vb._createDeviceState();
    return vb;
  }

  /// Create a [RenderBuffer] named [name]
  RenderBuffer createRenderBuffer(String name) {
    RenderBuffer rb = new RenderBuffer(name, this);
    _children.add(rb);
    rb._createDeviceState();
    return rb;
  }

  /// Create a [RenderTarget] named [name]
  RenderTarget createRenderTarget(String name) {
    RenderTarget rt = new RenderTarget(name, this);
    _children.add(rt);
    rt._createDeviceState();
    return rt;
  }

  /// Create a [Texture2D] named [name]
  Texture2D createTexture2D(String name) {
    Texture2D tex = new Texture2D(name, this);
    _children.add(tex);
    tex._createDeviceState();
    return tex;
  }

  /// Create a [TextureCube] named [name].
  TextureCube createTextureCube(String name) {
    TextureCube tex = new TextureCube(name, this);
    _children.add(tex);
    tex._createDeviceState();
    return tex;
  }

  /// Create a [VertexShader] named [name].
  VertexShader createVertexShader(String name) {
    VertexShader vertexShader = new VertexShader(name, this);
    _children.add(vertexShader);
    vertexShader._createDeviceState();
    return vertexShader;
  }

  /// Create a [FragmentShader] named [name].
  FragmentShader createFragmentShader(String name) {
    FragmentShader fragmentShader = new FragmentShader(name, this);
    _children.add(fragmentShader);
    fragmentShader._createDeviceState();
    return fragmentShader;
  }

  /// Create a [ShaderProgram] named [name].
  ShaderProgram createShaderProgram(String name) {
    ShaderProgram shaderProgram = new ShaderProgram(name, this);
    _children.add(shaderProgram);
    shaderProgram._createDeviceState();
    return shaderProgram;
  }

  /// Create a [SamplerState] named [name].
  SamplerState createSamplerState(String name) {
    SamplerState sampler = new SamplerState(name, this);
    _children.add(sampler);
    sampler._createDeviceState();
    return sampler;
  }

  /// Create a [Viewport] named [name].
  Viewport createViewport(String name) {
    Viewport viewport = new Viewport(name, this);
    _children.add(viewport);
    viewport._createDeviceState();
    return viewport;
  }

  /// Create a [DepthState] named [name].
  DepthState createDepthState(String name) {
    DepthState depthState = new DepthState(name, this);
    _children.add(depthState);
    depthState._createDeviceState();
    return depthState;
  }

  /// Create a [BlendState] named [name].
  BlendState createBlendState(String name) {
    BlendState blendState = new BlendState(name, this);
    _children.add(blendState);
    blendState._createDeviceState();
    return blendState;
  }

  /// Create a [RasterizerState] named [name].
  RasterizerState createRasterizerState(String name) {
    RasterizerState rasterizerState = new RasterizerState(name, this);
    _children.add(rasterizerState);
    rasterizerState._createDeviceState();
    return rasterizerState;
  }

  /// Create an [InputLayout] named [name].
  InputLayout createInputLayout(String name) {
    InputLayout il = new InputLayout(name, this);
    _children.add(il);
    il._createDeviceState();
    return il;
  }

  /// Create a [SingleArrayMesh] named [name].
  SingleArrayMesh createSingleArrayMesh(String name) {
    SingleArrayMesh arrayMesh = new SingleArrayMesh(name, this);
    _children.add(arrayMesh);
    arrayMesh._createDeviceState();
    return arrayMesh;
  }

  /// Create a [SingleArrayIndexedMesh] named [name].
  SingleArrayIndexedMesh createSingleArrayIndexedMesh(String name) {
    SingleArrayIndexedMesh indexedMesh = new SingleArrayIndexedMesh(name, this);
    _children.add(indexedMesh);
    indexedMesh._createDeviceState();
    return indexedMesh;
  }
}

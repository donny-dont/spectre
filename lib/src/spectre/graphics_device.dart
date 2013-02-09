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

/// Allows the querying of the capabilities of the [GraphicsDevice].
///
/// Can be used to get maximum values for the underlying WebGL implementation as
/// well as access what WebGL extensions are available.
class GraphicsDeviceCapabilities {
  // Device info
  /// The graphics card vendor
  String _vendor;
  /// The renderer
  String _renderer;
  /// The number of texture units available.
  int _textureUnits;
  /// The number of texture units available in the vertex shader
  int _vertexShaderTextureUnits;
  /// The largest texture size available.
  int _maxTextureSize;
  /// The largest cube map texture size available.
  int _maxCubeMapTextureSize;
  /// Maximum number of vertex attributes available.
  int _maxVertexAttribs;
  /// Maximum number of varying vectors available in the shader program.
  int _maxVaryingVectors;
  /// Maximum number of uniforms available in the vertex shader.
  int _maxVertexShaderUniforms;
  /// Maximum number of uniforms available in the fragment shader.
  int _maxFragmentShaderUniforms;

  // Extensions

  /// Whether floating point textures are available.
  bool _floatTextures;
  /// Whether half-floating point textures are available.
  bool _halfFloatTextures;
  /// Whether standard derivatives (dFdx, dFdy, fwidth) are available in the fragment shader.
  bool _standardDerivatives;
  /// Whether vertex array objects are available.
  bool _vertexArrayObjects;
  /// Whether the renderer and vendor can be queried for debug purposes.
  bool _debugRendererInfo;
  /// Whether the translated shader source can be viewed.
  bool _debugShaders;
  /// Whether unsigned int can be used as an index.
  bool _unsignedIntIndices;
  /// Whether anisotropic filtering is available.
  bool _anisotropicFiltering;
  /// Whether context losing/restoring can be simulated.
  bool _loseContext;
  /// Whether S3TC compressed textures can be used.
  bool _compressedTextureS3TC;
  /// Whether depth textures can be used.
  bool _depthTextures;
  /// Whether ATC compressed textures can be used.
  bool _compressedTextureATC;
  /// Whether PVRTC compressed textures can be used.
  bool _compressedTexturePVRTC;

  GraphicsDeviceCapabilities._fromContext(WebGLRenderingContext gl) {
    _queryDeviceInfo(gl);
    _queryExtensionInfo(gl);

    if (_debugRendererInfo) {
      // \todo Add query using UNMASKED_{VENDOR|RENDERER}_WEBGL
      // Enum to query is not exposed currently
      _vendor = gl.getParameter(0x9245);
      _renderer = gl.getParameter(0x9246);
    } else {
      _vendor = '';
      _renderer = '';
    }
  }

  /// The graphics card vendor
  String get vendor => _vendor;
  /// The renderer
  String get renderer => _renderer;
  /// The number of texture units available.
  int get textureUnits => _textureUnits;
  /// The number of texture units available in the vertex shader
  int get vertexShaderTextureUnits => _vertexShaderTextureUnits;
  /// The largest texture size available.
  int get maxTextureSize => _maxTextureSize;
  /// The largest cube map texture size available.
  int get maxCubeMapTextureSize => _maxCubeMapTextureSize;
  /// Maximum number of vertex attributes available.
  int get maxVertexAttribs => _maxVertexAttribs;
  /// Maximum number of varying vectors available in the shader program.
  int get maxVaryingVectors => _maxVaryingVectors;
  /// Maximum number of uniforms available in the vertex shader.
  int get maxVertexShaderUniforms => _maxVertexShaderUniforms;
  /// Maximum number of uniforms available in the fragment shader.
  int get maxFragmentShaderUniforms => _maxFragmentShaderUniforms;

  /// Whether floating point textures are available.
  bool get hasFloatTextures => _floatTextures;
  /// Whether half-floating point textures are available.
  bool get hasHalfFloatTextures => _halfFloatTextures;
  /// Whether standard derivatives (dFdx, dFdy, fwidth) are available in the fragment shader.
  bool get hasStandardDerivatives => _standardDerivatives;
  /// Whether vertex array objects are available.
  bool get hasVertexArrayObjects => _vertexArrayObjects;
  /// Whether the renderer and vendor can be queried for debug purposes.
  bool get hasDebugRendererInfo => _debugRendererInfo;
  /// Whether the translated shader source can be viewed.
  bool get hasDebugShaders => _debugShaders;
  /// Whether unsigned int can be used as an index.
  bool get hasUnsignedIntIndices => _unsignedIntIndices;
  /// Whether anisotropic filtering is available.
  bool get hasAnisotropicFiltering => _anisotropicFiltering;
  /// Whether context losing/restoring can be simulated.
  bool get canLoseContext => _loseContext;
  /// Whether S3TC compressed textures can be used.
  bool get hasCompressedTextureS3TC => _compressedTextureS3TC;
  /// Whether depth textures can be used.
  bool get hasDepthTextures => _depthTextures;
  /// Whether ATC compressed textures can be used.
  bool get hasCompressedTextureATC => _compressedTextureATC;
  /// Whether PVRTC compressed textures can be used.
  bool get hasCompressedTexturePVRTC => _compressedTexturePVRTC;

  String toString() {
    String vendorString = _vendor.isEmpty ? 'Unknown' : _vendor;
    String rendererString = _renderer.isEmpty ? 'Unknown' : _renderer;
    return
        '''
Vendor: $vendorString
Renderer: $rendererString

Device stats
Texture Units: $_textureUnits
Vertex Texture Units: $_vertexShaderTextureUnits
Max Texture Size: ${_maxTextureSize}x${_maxTextureSize}
Max Cube Map Size: ${_maxCubeMapTextureSize}x${_maxCubeMapTextureSize}
Max Vertex Attributes: ${_maxVertexAttribs}
Max Varying Vectors: $_maxVaryingVectors
Max Vertex Shader Uniforms: $_maxVertexShaderUniforms
Max Fragment Shader Uniforms: $_maxFragmentShaderUniforms

Extensions
OES_texture_float: $_floatTextures
OES_texture_half_float: $_halfFloatTextures
OES_standard_derivatives: $_standardDerivatives
OES_vertex_array_object: $_vertexArrayObjects
WEBGL_debug_renderer_info: $_debugRendererInfo
WEBGL_debug_shaders: $_debugShaders
OES_element_index_uint: $_unsignedIntIndices
EXT_texture_filter_anisotropic: $_anisotropicFiltering
WEBGL_lose_context: $_loseContext
WEBGL_compressed_texture_s3tc: $_compressedTextureS3TC
WEBGL_depth_texture: $_depthTextures
WEBGL_compressed_texture_atc: $_compressedTextureATC
WEBGL_compressed_texture_pvrtc: $_compressedTexturePVRTC
        ''';
  }

  void _queryDeviceInfo(WebGLRenderingContext gl) {
    _textureUnits = gl.getParameter(WebGLRenderingContext.MAX_TEXTURE_IMAGE_UNITS);
    _vertexShaderTextureUnits = gl.getParameter(WebGLRenderingContext.MAX_VERTEX_TEXTURE_IMAGE_UNITS);
    _maxTextureSize = gl.getParameter(WebGLRenderingContext.MAX_TEXTURE_SIZE);
    _maxCubeMapTextureSize = gl.getParameter(WebGLRenderingContext.MAX_CUBE_MAP_TEXTURE_SIZE);
    _maxVertexAttribs = gl.getParameter(WebGLRenderingContext.MAX_VERTEX_ATTRIBS);
    _maxVaryingVectors = gl.getParameter(WebGLRenderingContext.MAX_VARYING_VECTORS);
    _maxVertexShaderUniforms = gl.getParameter(WebGLRenderingContext.MAX_VERTEX_UNIFORM_VECTORS);
    _maxFragmentShaderUniforms = gl.getParameter(WebGLRenderingContext.MAX_FRAGMENT_UNIFORM_VECTORS);
  }

  void _queryExtensionInfo(WebGLRenderingContext gl) {
    // Approved
    _floatTextures = _hasExtension(gl, 'OES_texture_float');
    _halfFloatTextures = _hasExtension(gl, 'OES_texture_half_float');
    _standardDerivatives = _hasExtension(gl, 'OES_standard_derivatives');
    _vertexArrayObjects = _hasExtension(gl, 'OES_vertex_array_object');
    _debugRendererInfo = _hasExtension(gl, 'WEBGL_debug_renderer_info');
    _debugShaders = _hasExtension(gl, 'WEBGL_debug_shaders');
    // \todo This call is crashing on me. See if its just my machine.
    _unsignedIntIndices = false; // _hasExtension(gl, 'OES_element_index_uint');
    _anisotropicFiltering = _hasExtension(gl, 'EXT_texture_filter_anisotropic');

    // Draft
    _loseContext = _hasExtension(gl, 'WEBGL_lose_context');
    _compressedTextureS3TC = _hasExtension(gl, 'WEBGL_compressed_texture_s3tc');
    _depthTextures = _hasExtension(gl, 'WEBGL_depth_texture');
    _compressedTextureATC = _hasExtension(gl, 'WEBGL_compressed_texture_atc');
    _compressedTexturePVRTC = _hasExtension(gl, 'WEBGL_compressed_texture_pvrtc');
  }

  static bool _hasExtension(WebGLRenderingContext gl, String name) {
    return gl.getExtension(name) != null;
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
    _gl = canvas.getContext3d(stencil: true);

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

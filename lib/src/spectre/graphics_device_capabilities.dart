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

/// Allows the querying of the capabilities of the [GraphicsDevice].
///
/// Can be used to get maximum values for the underlying WebGL implementation as
/// well as access what WebGL extensions are available.
class GraphicsDeviceCapabilities {
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// Vendor extensions to use when searching for extensions.
  static List<String> _vendorExtensions = [ '', 'WEBKIT_', 'MOZ_' ];

  //---------------------------------------------------------------------
  // Device information
  //---------------------------------------------------------------------

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
  /// The largest anisotropy level available.
  int _maxAnisotropyLevel;
  /// Maximum number of vertex attributes available.
  int _maxVertexAttribs;
  /// Maximum number of varying vectors available in the shader program.
  int _maxVaryingVectors;
  /// Maximum number of uniforms available in the vertex shader.
  int _maxVertexShaderUniforms;
  /// Maximum number of uniforms available in the fragment shader.
  int _maxFragmentShaderUniforms;

  //---------------------------------------------------------------------
  // Extension information
  //---------------------------------------------------------------------

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
  /// Whether multiple render targets can be used.
  bool _multipleRenderTargets;
  /// Whether instanced arrays can be used.
  bool _instancedArrays;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Queries the device capabilities in the [WebGLRenderingContext].
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

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

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
  /// The largest anisotropy level available.
  int get maxAnisotropyLevel => _maxAnisotropyLevel;
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
  /// Whether multiple render targets can be used.
  bool get hasMultipleRenderTargets => _multipleRenderTargets;
  /// Whether instanced arrays can be used.
  bool get hasInstancedArrays => _instancedArrays;

  //---------------------------------------------------------------------
  // Public methods
  //---------------------------------------------------------------------

  /// Returns a string representation of this object.
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
Max Anisotropy Level: $_maxAnisotropyLevel
Max Vertex Attributes: $_maxVertexAttribs
Max Varying Vectors: $_maxVaryingVectors
Max Vertex Shader Uniforms: $_maxVertexShaderUniforms
Max Fragment Shader Uniforms: $_maxFragmentShaderUniforms

Extensions
ANGLE_instanced_arrays: $_instancedArrays
EXT_draw_buffers: $_multipleRenderTargets
EXT_texture_filter_anisotropic: $_anisotropicFiltering
OES_element_index_uint: $_unsignedIntIndices
OES_texture_float: $_floatTextures
OES_texture_half_float: $_halfFloatTextures
OES_standard_derivatives: $_standardDerivatives
OES_vertex_array_object: $_vertexArrayObjects
WEBGL_compressed_texture_s3tc: $_compressedTextureS3TC
WEBGL_compressed_texture_atc: $_compressedTextureATC
WEBGL_compressed_texture_pvrtc: $_compressedTexturePVRTC
WEBGL_debug_renderer_info: $_debugRendererInfo
WEBGL_debug_shaders: $_debugShaders
WEBGL_depth_texture: $_depthTextures
WEBGL_lose_context: $_loseContext
        ''';
  }

  /// Queries device infor using the [WebGLRenderingContext].
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

  /// Queries extensions using the [WebGLRenderingContext].
  void _queryExtensionInfo(WebGLRenderingContext gl) {
    // Approved
    _floatTextures = _hasExtension(gl, 'OES_texture_float');
    _halfFloatTextures = _hasExtension(gl, 'OES_texture_half_float');
    _loseContext = _hasExtension(gl, 'WEBGL_lose_context');
    _standardDerivatives = _hasExtension(gl, 'OES_standard_derivatives');
    _vertexArrayObjects = _hasExtension(gl, 'OES_vertex_array_object');
    _debugRendererInfo = _hasExtension(gl, 'WEBGL_debug_renderer_info');
    _debugShaders = _hasExtension(gl, 'WEBGL_debug_shaders');
    _compressedTextureS3TC = _hasExtension(gl, 'WEBGL_compressed_texture_s3tc');
    _depthTextures = _hasExtension(gl, 'WEBGL_depth_texture');
    // \todo This call is crashing on me. See if its just my machine.
    _unsignedIntIndices = false; //_hasExtension(gl, 'OES_element_index_uint');

    // Query the anisotropic extension and get the maximum anisotropy level
    if (_hasExtension(gl, 'EXT_texture_filter_anisotropic') != null) {
      _anisotropicFiltering = true;
      _maxAnisotropyLevel = gl.getParameter(ExtTextureFilterAnisotropic.MAX_TEXTURE_MAX_ANISOTROPY_EXT);
    } else {
      _anisotropicFiltering = false;
      _maxAnisotropyLevel = 1;
    }

    // Draft
    _compressedTextureATC = _hasExtension(gl, 'WEBGL_compressed_texture_atc');
    _instancedArrays = _hasExtension(gl, 'ANGLE_instanced_arrays');
    _compressedTexturePVRTC = _hasExtension(gl, 'WEBGL_compressed_texture_pvrtc');
    _multipleRenderTargets = _hasExtension(gl, 'EXT_draw_buffers');
  }

  //---------------------------------------------------------------------
  // Class methods
  //---------------------------------------------------------------------

  /// Queries the [WebGLRenderingContext] to see if the given extension is available.
  static bool _hasExtension(WebGLRenderingContext gl, String name) {
    return _getExtension(gl, name) != null;
  }

  /// Queries the [WebGLRenderingContext] to retrieve the given extension.
  ///
  /// Returns [null] if the extension is not supported.
  static Object _getExtension(WebGLRenderingContext gl, String name) {
    Object extension;
    int numVendorExtensions = _vendorExtensions.length;

    for (int i = 0; i < numVendorExtensions; ++i) {
      extension = gl.getExtension('${_vendorExtensions[i]}${name}');

      if (extension != null) {
        return extension;
      }
    }

    // Extension not found
    return null;
  }
}

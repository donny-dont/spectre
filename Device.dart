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

class _InputLayoutElement {
  int _vboSlot;
  int _vboOffset;
  int _attributeIndex;
  int _attributeStride;
  DeviceFormat _attributeFormat;

  String toString() {
    return 'Attribute $_attributeIndex bound to VBO: $_vboSlot VBO_OFFSET: $_vboOffset Attribute Stride: $_attributeStride Format: $_attributeFormat';
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

/// A resource created by a device
/// All resources have a [name]
class DeviceChild implements Hashable {
  String name;
  int hashCode() {
    return name.hashCode();
  }
  abstract void _fillProps(Map props);
  abstract void _cleanup();
}

/// A mapping of vertex buffers to shader program input attributes
/// Create using [Device.createInputLayout]
/// Set using [ImmediateContext.setInputLayout]
class InputLayout extends DeviceChild {
  int _maxAttributeIndex;
  List<_InputLayoutElement> _elements;

  void _fillProps(Map props) {

  }

  void _cleanup() {

  }
}

/// Rendering viewport
/// Create using [Device.createViewport]
/// Set using [ImmediateContext.setViewport]
class Viewport extends DeviceChild {
  int x;
  int y;
  int width;
  int height;

  Viewport() {
    x = 0;
    y = 0;
    width = 640;
    height = 480;
  }

  void _fillProps(Map props) {
    x = props['x'];
    y = props['y'];
    width = props['width'];
    height = props['height'];
  }

  void _cleanup() {

  }
}

/// BlendState controls how output from your fragment shader is blended onto the framebuffer
/// Create using [Device.createBlendState]
/// Set using [ImmediateContext.setBlendState]
class BlendState extends DeviceChild {
  static final int BlendSourceZero = WebGLRenderingContext.ZERO;
  static final int BlendSourceOne = WebGLRenderingContext.ONE;
  static final int BlendSourceShaderColor = WebGLRenderingContext.SRC_COLOR;
  static final int BlendSourceShaderInverseColor = WebGLRenderingContext.ONE_MINUS_SRC_COLOR;
  static final int BlendSourceShaderAlpha = WebGLRenderingContext.SRC_ALPHA;
  static final int BlendSourceShaderInverseAlpha = WebGLRenderingContext.ONE_MINUS_SRC_ALPHA;
  static final int BlendSourceTargetColor = WebGLRenderingContext.DST_COLOR;
  static final int BlendSourceTargetInverseColor = WebGLRenderingContext.ONE_MINUS_DST_COLOR;
  static final int BlendSourceTargetAlpha = WebGLRenderingContext.DST_ALPHA;
  static final int BlendSourceTargetInverseAlpha = WebGLRenderingContext.ONE_MINUS_DST_ALPHA;
  static final int BlendSourceBlendColor = WebGLRenderingContext.CONSTANT_COLOR;
  static final int BlendSourceBlendAlpha = WebGLRenderingContext.CONSTANT_ALPHA;
  static final int BlendSourceBlendInverseColor = WebGLRenderingContext.ONE_MINUS_CONSTANT_COLOR;
  static final int BlendSourceBlendInverseAlpha = WebGLRenderingContext.ONE_MINUS_CONSTANT_ALPHA;

  static final int BlendOpAdd = WebGLRenderingContext.FUNC_ADD;
  static final int BlendOpSubtract = WebGLRenderingContext.FUNC_SUBTRACT;
  static final int BlendOpReverseSubtract = WebGLRenderingContext.FUNC_REVERSE_SUBTRACT;

  // Constant blend values
  double blendColorRed;
  double blendColorGreen;
  double blendColorBlue;
  double blendColorAlpha;

  // off by default
  bool blendEnable;
  int blendSourceColorFunc; /* "Source" = "Shader" */
  int blendDestColorFunc; /* "Destination" = "Render Target" */
  int blendSourceAlphaFunc;
  int blendDestAlphaFunc;

  /* Destination = BlendSource<Color|Alpha>Func blend?Op BlendDest<Color|Alpha>Func */
  int blendColorOp;
  int blendAlphaOp;

  // Render Target write flags
  bool writeRenderTargetRed;
  bool writeRenderTargetGreen;
  bool writeRenderTargetBlue;
  bool writeRenderTargetAlpha;

  BlendState() {
    // Default state
    blendColorRed = 1.0;
    blendColorGreen = 1.0;
    blendColorBlue = 1.0;
    blendColorAlpha = 1.0;

    blendEnable = false;
    blendSourceColorFunc = BlendSourceOne;
    blendDestColorFunc = BlendSourceZero;
    blendSourceAlphaFunc = BlendSourceOne;
    blendDestAlphaFunc = BlendSourceZero;
    blendColorOp = BlendOpAdd;
    blendAlphaOp = BlendOpAdd;

    writeRenderTargetRed = true;
    writeRenderTargetGreen = true;
    writeRenderTargetBlue = true;
    writeRenderTargetAlpha = true;
  }

  void _fillProps(Map props) {
    Dynamic o;
    o = props['blendColorRed'];
    blendColorRed = o != null ? o : 1.0;
    o = props['blendColorGreen'];
    blendColorGreen = o != null ? o : 1.0;
    o = props['blendColorBlue'];
    blendColorBlue = o != null ? o : 1.0;
    o = props['blendColorAlpha'];
    blendColorAlpha = o != null ? o : 1.0;

    o = props['blendEnable'];
    blendEnable = o != null ? o : false;
    o = props['blendSourceColorFunc'];
    blendSourceColorFunc = o != null ? o : BlendSourceOne;
    o = props['blendDestColorFunc'];
    blendDestColorFunc = o != null ? o : BlendSourceZero;
    o = props['blendSourceAlphaFunc'];
    blendSourceAlphaFunc = o != null ? o : BlendSourceOne;
    o = props['blendDestAlphaFunc'];
    blendDestAlphaFunc = o != null ? o : BlendSourceZero;

    o = props['blendColorOp'];
    blendColorOp = o != null ? o : BlendOpAdd;
    o = props['blendAlphaOp'];
    blendAlphaOp = o != null ? o : BlendOpAdd;

    o = props['writeRenderTargetRed'];
    writeRenderTargetRed = o != null ? o : true;
    o = props['writeRenderTargetGreen'];
    writeRenderTargetGreen = o != null ? o : true;
    o = props['writeRenderTargetBlue'];
    writeRenderTargetBlue = o != null ? o : true;
    o = props['writeRenderTargetAlpha'];
    writeRenderTargetAlpha = o != null ? o : true;
  }

  void _cleanup() {

  }
}

/// DepthState controls depth testing and writing to a depth buffer
/// Create using [Device.createDepthState]
/// Set using [ImmediateContext.setDepthState]
class DepthState extends DeviceChild {
  static final int DepthComparisonOpNever = WebGLRenderingContext.NEVER;
  static final int DepthComparisonOpAlways = WebGLRenderingContext.ALWAYS;
  static final int DepthComparisonOpEqual = WebGLRenderingContext.EQUAL;
  static final int DepthComparisonOpNotEqual = WebGLRenderingContext.NOTEQUAL;

  static final int DepthComparisonOpLess = WebGLRenderingContext.LESS;
  static final int DepthComparisonOpLessEqual = WebGLRenderingContext.LEQUAL;
  static final int DepthComparisonOpGreaterEqual = WebGLRenderingContext.GEQUAL;
  static final int DepthComparisonOpGreater = WebGLRenderingContext.GREATER;

  bool depthTestEnabled;
  bool depthWriteEnabled;
  bool polygonOffsetEnabled;

  num depthNearVal;
  num depthFarVal;
  num polygonOffsetFactor;
  num polygonOffsetUnits;

  int depthComparisonOp;

  DepthState() {
    depthTestEnabled = false;
    depthWriteEnabled = false;
    polygonOffsetEnabled = false;

    depthNearVal = 0.0;
    depthFarVal = 1.0;
    polygonOffsetFactor = 0.0;
    polygonOffsetUnits = 0.0;

    depthComparisonOp = DepthComparisonOpAlways;
  }

  void _fillProps(Map props) {
    Dynamic o;

    o = props['depthTestEnabled'];
    depthTestEnabled = o != null ? o : false;
    o = props['depthWriteEnabled'];
    depthWriteEnabled = o != null ? o : false;
    o = props['polygonOffsetEnabled'];
    polygonOffsetEnabled = o != null ? o : false;

    o = props['depthNearVal'];
    depthNearVal = o != null ? o : 0.0;
    o = props['depthFarVal'];
    depthFarVal = o != null ? o : 1.0;
    o = props['polygonOffsetFactor'];
    polygonOffsetFactor = o != null ? o : 0.0;
    o = props['polygonOffsetUnits'];
    polygonOffsetUnits = o != null ? o : 0.0;
    o = props['depthComparisonOp'];
    depthComparisonOp = o != null ? o : DepthComparisonOpAlways;
  }

  void _cleanup() {

  }
}

class StencilState extends DeviceChild {
  void _fillProps(Map props) {

  }

  void _cleanup() {

  }
}

/// RasterizerState controls how the GPU rasterizer functions including primitive culling and width of rasterized lines
/// Create using [Device.createRasterizerState]
/// Set using [ImmediateContext.setRasterizerState]
class RasterizerState extends DeviceChild {
  static final int CullFront = WebGLRenderingContext.FRONT;
  static final int CullBack = WebGLRenderingContext.BACK;
  static final int CullFrontAndBack = WebGLRenderingContext.FRONT_AND_BACK;
  static final int FrontCW = WebGLRenderingContext.CW;
  static final int FrontCCW = WebGLRenderingContext.CCW;

  bool cullEnabled;
  int cullMode;
  int cullFrontFace;

  num lineWidth;

  RasterizerState() {
    cullEnabled = false;
    cullMode = CullBack;
    cullFrontFace = FrontCCW;
    lineWidth = 1.0;
  }

  void _fillProps(Map props) {
    Dynamic o;

    o = props['cullEnabled'];
    cullEnabled = o != null ? o : false;
    o = props['cullMode'];
    cullMode = o != null ? o : CullBack;
    o = props['cullFrontFace'];
    cullFrontFace = o != null ? o : FrontCCW;
    o = props['lineWidth'];
    lineWidth = o != null ? o : lineWidth;
  }

  void _cleanup() {

  }
}

class Shader extends DeviceChild {
  String _source;
  WebGLShader _shader;
  int _type;

  Shader() {
    _source = '';
    _shader = null;
  }

  String get log() {
    return webGL.getShaderInfoLog(_shader);
  }

  WebGLShader get shader() => this._shader;

  void set source(String s) {
    _source = s;
    webGL.shaderSource(_shader, _source);
  }

  String get source() {
    return _source;
  }

  void compile() {
    webGL.compileShader(_shader);
    String log = webGL.getShaderInfoLog(_shader);
    spectreLog.Info('Compiled $name - $log');
  }

  void _fillProps(Map props) {

  }

  void _cleanup() {
    webGL.deleteShader(_shader);
  }
}

/// A vertex shader
/// Create using [Device.createVertexShader]
/// Must be linked into a ShaderProgram before use
class VertexShader extends Shader {
  void _fillProps(Map props) {
    _type = WebGLRenderingContext.VERTEX_SHADER;
  }
}

/// A fragment shader
/// Create using [Device.createFragmentShader]
/// Must be linked into a ShaderProgram before use
class FragmentShader extends Shader {
  void _fillProps(Map props) {
    _type = WebGLRenderingContext.FRAGMENT_SHADER;
  }
}

/// A shader program defines how the programmable units of the GPU pipeline function
/// Create using [Device.createShaderProgram]
/// Set using [ImmediateContext.setShaderProgram]
class ShaderProgram extends DeviceChild {
  int vs;
  int fs;
  WebGLProgram _program;
  int numAttributes;
  int numUniforms;

  ShaderProgram() {
    vs = 0;
    fs = 0;
    numUniforms = 0;
    numAttributes = 0;
    _program = null;
  }

  void _fillProps(Map props) {
    Object o = null;

    o = props['VertexProgram'];
    vs = o != null ? o : 0;
    o = props['FragmentProgram'];
    fs = o != null ? o : 0;
  }

  void _cleanup() {
    vs = null;
    fs = null;
    webGL.deleteProgram(_program);
  }

  void link() {
    webGL.linkProgram(_program);
    String linkLog = webGL.getProgramInfoLog(_program);
    spectreLog.Info('Linked $name - $linkLog');
    refreshUniforms();
    refreshAttributes();
  }

  String _convertType(int type) {
    switch (type) {
      case WebGLRenderingContext.FLOAT:
        return 'float';
      case WebGLRenderingContext.FLOAT_VEC2:
        return 'vec2';
      case WebGLRenderingContext.FLOAT_VEC3:
        return 'vec3';
      case WebGLRenderingContext.FLOAT_VEC4:
        return 'vec4';
      case WebGLRenderingContext.FLOAT_MAT2:
        return 'mat2';
      case WebGLRenderingContext.FLOAT_MAT3:
        return 'mat3';
      case WebGLRenderingContext.FLOAT_MAT4:
        return 'mat4';
      case WebGLRenderingContext.BOOL:
        return 'bool';
      case WebGLRenderingContext.BOOL_VEC2:
        return 'bvec2';
      case WebGLRenderingContext.BOOL_VEC3:
        return 'bvec3';
      case WebGLRenderingContext.BOOL_VEC4:
        return 'bvec4';
      case WebGLRenderingContext.INT:
        return 'int';
      case WebGLRenderingContext.INT_VEC2:
        return 'ivec2';
      case WebGLRenderingContext.INT_VEC3:
        return 'ivec3';
      case WebGLRenderingContext.INT_VEC4:
        return 'ivec4';
      default:
        return 'unknown code: $type';
    }
  }

  void refreshUniforms() {
    numUniforms = webGL.getProgramParameter(_program, WebGLRenderingContext.ACTIVE_UNIFORMS);
    spectreLog.Info('$name has $numUniforms uniform variables');
    for (int i = 0; i < numUniforms; i++) {
      WebGLActiveInfo activeUniform = webGL.getActiveUniform(_program, i);
      spectreLog.Info('$i - ${_convertType(activeUniform.type)} ${activeUniform.name} (${activeUniform.size})');
    }
  }

  void refreshAttributes() {
    numAttributes = webGL.getProgramParameter(_program, WebGLRenderingContext.ACTIVE_ATTRIBUTES);
    spectreLog.Info('$name has $numAttributes attributes');
    for (int i = 0; i < numAttributes; i++) {
      WebGLActiveInfo activeUniform = webGL.getActiveAttrib(_program, i);
      spectreLog.Info('$i - ${_convertType(activeUniform.type)} ${activeUniform.name} (${activeUniform.size})');
    }
  }
}

class RenderBuffer extends DeviceChild {
  int _target;
  int _width;
  int _height;
  int _format;
  WebGLRenderbuffer _buffer;
  void _fillProps(Map props) {
    _target = WebGLRenderingContext.RENDERBUFFER;
    String format = props['format'];
    switch (format) {
      case 'R8G8B8A8':
        _format = WebGLRenderingContext.RGB565;
      break;
      case 'DEPTH32':
        _format = WebGLRenderingContext.DEPTH_COMPONENT16;
      break;
      default:
        spectreLog.Error('format is not a valid render buffer format');
      break;
    }
    _width = props['width'];
    _height = props['height'];
  }

  void _cleanup() {
    webGL.deleteRenderbuffer(_buffer);
  }
}

class Texture extends DeviceChild {
  static final int TextureFormatAlpha = WebGLRenderingContext.ALPHA;
  static final int TextureFormatRGB = WebGLRenderingContext.RGB;
  static final int TextureFormatRGBA = WebGLRenderingContext.RGBA;
  static final int TextureFormatLuminance = WebGLRenderingContext.LUMINANCE;
  static final int TextureFormatLuminanceAlpha = WebGLRenderingContext.LUMINANCE_ALPHA;

  static final int PixelFormatUnsignedByte = WebGLRenderingContext.UNSIGNED_BYTE;
  static final int PixelFormatUnsignedShort_4_4_4_4 = WebGLRenderingContext.UNSIGNED_SHORT_4_4_4_4;
  static final int PixelFormatUnsignedShort_5_5_5_1 = WebGLRenderingContext.UNSIGNED_SHORT_5_5_5_1;
  static final int PixelFormatUnsignedShort_5_6_5 = WebGLRenderingContext.UNSIGNED_SHORT_5_6_5;

  int _target;
  int _target_param;
  int _width;
  int _height;
  int _textureFormat;
  int _pixelFormat;
  WebGLTexture _buffer;

  void _fillProps(Map props) {

  }

  void _cleanup() {
    webGL.deleteTexture(_buffer);
  }
}

/// Texture2D defines the storage for a 2D texture including Mipmaps
/// Create using [Device.createTexture2D]
/// Set using [immediateContext.setTextures]
/// NOTE: Unlike OpenGL, Spectre textures do not describe how they are sampled
class Texture2D extends Texture {
  Texture2D() {
    _target = WebGLRenderingContext.TEXTURE_2D;
    _target_param = WebGLRenderingContext.TEXTURE_BINDING_2D;
    _width = 1;
    _height = 1;
    _textureFormat = Texture.TextureFormatRGBA;
    _pixelFormat = Texture.PixelFormatUnsignedByte;
  }

  void _fillProps(Map props) {
    _width = props['width'] != null ? props['width'] : 1;
    _height = props['height'] != null ? props['height'] : 1;
    _textureFormat = props['textureFormat'] != null ? props['textureFormat'] : Texture.TextureFormatRGBA;
    _pixelFormat = props['pixelFormat'] != null ? props['pixelFormat'] : Texture.PixelFormatUnsignedByte;
  }
}

/// SamplerState defines how a texture is sampled
/// Create using [Device.createSamplerState]
/// Set using [immediateContext.setSamplerStates]
class SamplerState extends DeviceChild {
  static final int TextureWrapClampToEdge = WebGLRenderingContext.CLAMP_TO_EDGE;
  static final int TextureWrapMirroredRepeat = WebGLRenderingContext.MIRRORED_REPEAT;
  static final int TextureWrapRepeat = WebGLRenderingContext.REPEAT;

  static final int TextureMagFilterLinear = WebGLRenderingContext.LINEAR;
  static final int TextureMagFilterNearest = WebGLRenderingContext.NEAREST;

  static final int TextureMinFilterLinear = WebGLRenderingContext.LINEAR;
  static final int TextureMinFilterNearest = WebGLRenderingContext.NEAREST;
  static final int TextureMinFilterNearestMipmapNearest = WebGLRenderingContext.NEAREST_MIPMAP_NEAREST;
  static final int TextureMinFilterNearestMipmapLinear = WebGLRenderingContext.NEAREST_MIPMAP_LINEAR;
  static final int TextureMinFilterLinearMipmapNearest = WebGLRenderingContext.LINEAR_MIPMAP_NEAREST;
  static final int TextureMinFilterLinearMipmapLinear = WebGLRenderingContext.LINEAR_MIPMAP_LINEAR;

  int _wrap_s;
  int _wrap_t;
  int _mag_filter;
  int _min_filter;

  SamplerState() {
    _wrap_s = TextureWrapRepeat;
    _wrap_t = TextureWrapRepeat;
    _min_filter = TextureMinFilterNearestMipmapLinear;
    _mag_filter = TextureMagFilterLinear;
  }

  void _fillProps(Map props) {
    _wrap_s = props['wrapS'] != null ? props['wrapS'] : TextureWrapRepeat;
    _wrap_t = props['wrapT'] != null ? props['wrapT'] : TextureWrapRepeat;
    _min_filter = props['minFilter'] != null ? props['minFilter'] : TextureMinFilterNearestMipmapLinear;
    _mag_filter = props['magFilter'] != null ? props['magFilter'] : TextureMagFilterLinear;
  }

  void _cleanup() {

  }
}

class RenderTarget extends DeviceChild {
  Object _color0;
  Object _depth;
  Object _stencil;
  WebGLFramebuffer _buffer;
  int _target;

  void _fillProps(Map props) {
    _target = WebGLRenderingContext.FRAMEBUFFER;
    _color0 = props['color0'];
    _depth = props['depth'];
    _stencil = props['stencil'];
  }

  void _cleanup() {
    webGL.deleteFramebuffer(_buffer);
  }
}

class SpectreBuffer extends DeviceChild {
  WebGLBuffer _buffer;
  int _target;
  int _param_target;
  int _usage;
  int _size;

  void _fillProps(Map props) {

  }

  void _cleanup() {
    webGL.deleteBuffer(_buffer);
  }
}

/// IndexBuffer defines the storage for indexes used to construct primitives
/// Create using [Device.createIndexBuffer]
/// Set using [Device.setIndexBuffer]
class IndexBuffer extends SpectreBuffer {
  void _fillProps(Map props) {
    _target = WebGLRenderingContext.ELEMENT_ARRAY_BUFFER;
    _param_target = WebGLRenderingContext.ELEMENT_ARRAY_BUFFER_BINDING;
    String usage = props['usage'];
    switch (usage) {
      case 'stream':
        _usage = WebGLRenderingContext.STREAM_DRAW;
      break;
      case 'dynamic':
        _usage = WebGLRenderingContext.DYNAMIC_DRAW;
      break;
      case 'static':
        _usage = WebGLRenderingContext.STATIC_DRAW;
      break;
      default:
        spectreLog.Error('$usage is not a valid buffer usage type');
      break;
    }
    _size = props['size'];
  }
}

/// VertexBuffer defines storage for vertex attribute elements
/// Create using [Device.createVertexBuffer]
/// Set using [Device.setVertexBuffers]
class VertexBuffer extends SpectreBuffer {
  void _fillProps(Map props) {
    _target = WebGLRenderingContext.ARRAY_BUFFER;
    _param_target = WebGLRenderingContext.ARRAY_BUFFER_BINDING;
    String usage = props['usage'];
    switch (usage) {
      case 'stream':
        _usage = WebGLRenderingContext.STREAM_DRAW;
      break;
      case 'dynamic':
        _usage = WebGLRenderingContext.DYNAMIC_DRAW;
      break;
      case 'static':
        _usage = WebGLRenderingContext.STATIC_DRAW;
      break;
      default:
        spectreLog.Error('$usage is not a valid buffer usage type');
      break;
    }
    _size = props['size'];
  }
}

/// Spectre GPU Device

/// All GPU resources are created and destroyed through a Device.

/// Each resource requires a unique name.

/// An existing resource can be looked up using its name.
class Device {
  static final DeviceFormat DeviceFormatFloat1 = const DeviceFormat(WebGLRenderingContext.FLOAT, 1, false);
  static final DeviceFormat DeviceFormatFloat2 = const DeviceFormat(WebGLRenderingContext.FLOAT, 2, false);
  static final DeviceFormat DeviceFormatFloat3 = const DeviceFormat(WebGLRenderingContext.FLOAT, 3, false);
  static final DeviceFormat DeviceFormatFloat4 = const DeviceFormat(WebGLRenderingContext.FLOAT, 4, false);

  static final int BufferHandleType = 1;
  static final int RenderBufferHandleType = 2;
  static final int RenderTargetHandleType = 3;
  static final int TextureHandleType = 4;
  static final int SamplerStateHandleType = 5;
  static final int ShaderHandleType = 6;
  static final int ShaderProgramHandleType = 7;
  static final int ViewportHandleType = 8;
  static final int DepthStateHandleType = 9;
  static final int BlendStateHandleType = 10;
  static final int RasterizerStateHandleType = 11;
  static final int InputLayoutHandleType = 12;

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

  // There is a 1:1 mapping between _childrenHandles and _childrenObjects
  HandleSystem _childrenHandles;
  List<DeviceChild> _childrenObjects;

  // Maps from child object name to handle
  Map<String, int> _nameMapping;

  static final int MaxDeviceChildren = 2048;
  static final int MaxStaticDeviceChildren = 512;

  /// Constructs a GPU device
  Device() {
    _childrenHandles = new HandleSystem(MaxDeviceChildren, MaxStaticDeviceChildren);
    _childrenObjects = new List(MaxDeviceChildren);
    _nameMapping = new Map<String, int>();
  }

  /// Returns the handle to the device child named [name]
  int findHandle(String name) {
    int h = _nameMapping[name];
    if (h == null) {
      spectreLog.Warning('Could not find handle for device child $name');
      return Handle.BadHandle;
    }
    return h;
  }

  Map<String, int> get children() => _nameMapping;

  /// Lookup the actual device child object given the [handle]
  Dynamic getDeviceChild(int handle) {
    if (handle == 0) {
      return null;
    }
    if (_childrenHandles.validHandle(handle) == false) {
      spectreLog.Warning('$handle is not a valid handle');
      return null;
    }
    int index = Handle.getIndex(handle);
    return _childrenObjects[index];
  }

  String getDeviceChildName(int handle) {
    Dynamic dc = getDeviceChild(handle);
    if (dc != null) {
      return dc.name;
    }
    return 'Unknown handle: $handle';
  }

  int _checkName(String name, String type) {
    int handle = _nameMapping[name];
    if (handle != null) {
      spectreLog.Error('Attempting to create a $type with a name that already exists: $name. Returning existing $name');
      return handle;
    }
    return Handle.BadHandle;
  }

  void _setChildObject(int handle, Dynamic o) {
    int index = Handle.getIndex(handle);
    _childrenObjects[index] = o;
  }

  /// Registers a handle with the given [type] and [name]
  /// [handle] is an optional argument that, if provided, must be a statically reserved handle
  int registerHandle(int type, [int handle=Handle.BadHandle]) {
    if (handle != Handle.BadHandle) {
      int handleType = Handle.getType(handle);
      if (type != handleType) {
        spectreLog.Error('$type and static handle type do not match.');
        return Handle.BadHandle;
      }
      int r = _childrenHandles.setStaticHandle(handle);
      if (r != handle) {
        spectreLog.Error('Registering a static handle $handle failed.');
        return Handle.BadHandle;
      }
    } else {
      handle = _childrenHandles.allocateHandle(type);
      if (handle == Handle.BadHandle) {
        spectreLog.Error('Registering dynamic handle failed.');
        return Handle.BadHandle;
      }
    }
    int index = Handle.getIndex(handle);
    if (_childrenObjects[index] != null) {
      spectreLog.Warning('Registering an object at $index but there is already something there.');
      _childrenObjects[index]._cleanup();
      // Nuke it
      _childrenObjects[index] = null;
    }
    assert(_childrenHandles.validHandle(handle));
    return handle;
  }

  /// Deletes the device child [handle]
  void deleteDeviceChild(int handle) {
    if (_childrenHandles.validHandle(handle) == false) {
      spectreLog.Warning('Deleting device child handle [$handle] is invalid.');
      return;
    }
    int index = Handle.getIndex(handle);
    DeviceChild dc = _childrenObjects[index];
    if (dc == null) {
      return;
    }
    dc._cleanup();
    _nameMapping.remove(dc.name);
    _childrenObjects[index] = null;
  }

  void batchDeleteDeviceChildren(List<int> handles) {
    for (int h in handles) {
      deleteDeviceChild(h);
    }
  }

  /// Create a IndexBuffer named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the IndexBuffer being created. If [handle] is specified it must be a registered handle.
  ///
  /// Returns the handle to the IndexBuffer.
  int createIndexBuffer(String name, Object props, [int handle=Handle.BadHandle]) {
    {
      int checkHandle = _checkName(name, 'IndexBuffer');
      if (checkHandle != Handle.BadHandle) {
        return checkHandle;
      }
    }

    if (handle == Handle.BadHandle) {
      handle = registerHandle(BufferHandleType);
      if (handle == Handle.BadHandle) {
        return handle;
      }
    }

    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }

    IndexBuffer ib = new IndexBuffer();
    ib.name = name;
    ib._fillProps(props);
    WebGLBuffer oldBind = webGL.getParameter(ib._param_target);
    ib._buffer = webGL.createBuffer();
    webGL.bindBuffer(ib._target, ib._buffer);
    webGL.bufferData(ib._target, ib._size, ib._usage);
    webGL.bindBuffer(ib._target, oldBind);


    _setChildObject(handle, ib);
    _nameMapping[name] = handle;
    return handle;
  }

  /// Create a [VertexBuffer] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [VertexBuffer] being created
  int createVertexBuffer(String name, Object props, [int handle = Handle.BadHandle]) {
    {
      int checkHandle = _checkName(name, 'VertexBuffer');
      if (checkHandle != Handle.BadHandle) {
        return checkHandle;
      }
    }

    if (handle == Handle.BadHandle) {
      handle = registerHandle(BufferHandleType);
      if (handle == Handle.BadHandle) {
        return handle;
      }
    }

    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }

    VertexBuffer vb = new VertexBuffer();
    vb.name = name;
    vb._fillProps(props);
    WebGLBuffer oldBind = webGL.getParameter(WebGLRenderingContext.ARRAY_BUFFER_BINDING);
    vb._buffer = webGL.createBuffer();
    webGL.bindBuffer(vb._target, vb._buffer);
    webGL.bufferData(vb._target, vb._size, vb._usage);
    webGL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, oldBind);

    _setChildObject(handle, vb);
    _nameMapping[name] = handle;
    return handle;
  }

  /// Create a [RenderBuffer] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [RenderBuffer] being created
  int createRenderBuffer(String name, Object props, [int handle = Handle.BadHandle]) {
    {
      int checkHandle = _checkName(name, 'RenderBuffer');
      if (checkHandle != Handle.BadHandle) {
        return checkHandle;
      }
    }

    if (handle == Handle.BadHandle) {
      handle = registerHandle(RenderBufferHandleType);
      if (handle == Handle.BadHandle) {
        return handle;
      }
    }

    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }
    RenderBuffer rb = new RenderBuffer();
    rb.name = name;
    rb._fillProps(props);

    rb._buffer = webGL.createRenderbuffer();
    WebGLRenderbuffer oldBind = webGL.getParameter(WebGLRenderingContext.RENDERBUFFER_BINDING);
    webGL.bindRenderbuffer(rb._target, rb._buffer);
    webGL.renderbufferStorage(rb._target, rb._format, rb._width, rb._height);
    webGL.bindRenderbuffer(WebGLRenderingContext.RENDERBUFFER, oldBind);

    _setChildObject(handle, rb);
    _nameMapping[name] = handle;
    return handle;
  }

  /// Create a [RenderTarget] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [RenderTarget] being created
  int createRenderTarget(String name, Object props, [int handle = Handle.BadHandle]) {
    {
      int checkHandle = _checkName(name, 'RenderTarget');
      if (checkHandle != Handle.BadHandle) {
        return checkHandle;
      }
    }

    if (handle == Handle.BadHandle) {
      handle = registerHandle(RenderTargetHandleType);
      if (handle == Handle.BadHandle) {
        return handle;
      }
    }

    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }

    RenderTarget rt = new RenderTarget();
    rt.name = name;
    rt._fillProps(props);
    rt._buffer = webGL.createFramebuffer();
    WebGLFramebuffer oldBind = webGL.getParameter(WebGLRenderingContext.FRAMEBUFFER_BINDING);
    webGL.bindFramebuffer(rt._target, rt._buffer);
    if (rt._color0 != null) {
      webGL.framebufferRenderbuffer(rt._target, WebGLRenderingContext.COLOR_ATTACHMENT0, WebGLRenderingContext.RENDERBUFFER, rt._color0._buffer);
    } else {
      webGL.framebufferRenderbuffer(rt._target, WebGLRenderingContext.COLOR_ATTACHMENT0, WebGLRenderingContext.RENDERBUFFER, null);
    }
    if (rt._depth != null) {
      webGL.framebufferRenderbuffer(rt._target, WebGLRenderingContext.DEPTH_ATTACHMENT, WebGLRenderingContext.RENDERBUFFER, rt._depth._buffer);
    } else {
      webGL.framebufferRenderbuffer(rt._target, WebGLRenderingContext.DEPTH_ATTACHMENT, WebGLRenderingContext.RENDERBUFFER, null);
    }
    if (rt._stencil != null) {
      webGL.framebufferRenderbuffer(rt._target, WebGLRenderingContext.STENCIL_ATTACHMENT, WebGLRenderingContext.RENDERBUFFER, rt._stencil._buffer);
    } else {
      webGL.framebufferRenderbuffer(rt._target, WebGLRenderingContext.STENCIL_ATTACHMENT, WebGLRenderingContext.RENDERBUFFER, null);
    }
    int status = webGL.checkFramebufferStatus(rt._target);
    if (status != WebGLRenderingContext.FRAMEBUFFER_COMPLETE) {
      spectreLog.Error('RenderTarget $name incomplete status = $status');
    } else {
      spectreLog.Info('RenderTarget $name complete.');
    }
    webGL.bindFramebuffer(WebGLRenderingContext.FRAMEBUFFER, oldBind);

    _setChildObject(handle, rt);
    _nameMapping[name] = handle;
    return handle;
  }

  /// Create a [Texture2D] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [Texture2D] being created
  int createTexture2D(String name, Object props, [int handle = Handle.BadHandle]) {
    {
      int checkHandle = _checkName(name, 'Texture2D');
      if (checkHandle != Handle.BadHandle) {
        return checkHandle;
      }
    }

    if (handle == Handle.BadHandle) {
      handle = registerHandle(TextureHandleType);
      if (handle == Handle.BadHandle) {
        return handle;
      }
    }

    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }

    Texture2D tex = new Texture2D();
    tex.name = name;
    tex._fillProps(props);
    tex._buffer = webGL.createTexture();

    WebGLTexture oldBind = webGL.getParameter(tex._target_param);
    webGL.bindTexture(tex._target, tex._buffer);
    // Allocate memory for texture
    webGL.texImage2D(tex._target, 0, tex._textureFormat, tex._width, tex._height, 0, tex._textureFormat, tex._pixelFormat, null);
    webGL.bindTexture(tex._target, oldBind);

    _setChildObject(handle, tex);
    _nameMapping[name] = handle;
    return handle;
  }

  /// Create a [VertexShader] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [VertexShader] being created
  int createVertexShader(String name, Object props, [int handle = Handle.BadHandle]) {
    {
      int checkHandle = _checkName(name, 'VertexShader');
      if (checkHandle != Handle.BadHandle) {
        return checkHandle;
      }
    }

    if (handle == Handle.BadHandle) {
      handle = registerHandle(ShaderHandleType);
      if (handle == Handle.BadHandle) {
        return handle;
      }
    }

    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }

    VertexShader vertexshader = new VertexShader();
    vertexshader.name = name;
    vertexshader._fillProps(props);
    vertexshader._shader = webGL.createShader(vertexshader._type);

    _setChildObject(handle, vertexshader);
    _nameMapping[name] = handle;
    return handle;
  }

  /// Create a [FragmentShader] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [FragmentShader] being created
  int createFragmentShader(String name, Object props, [int handle = Handle.BadHandle]) {
    {
      int checkHandle = _checkName(name, 'FragmentShader');
      if (checkHandle != Handle.BadHandle) {
        return checkHandle;
      }
    }

    if (handle == Handle.BadHandle) {
      handle = registerHandle(ShaderHandleType);
      if (handle == Handle.BadHandle) {
        return handle;
      }
    }

    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }

    FragmentShader fragmentshader = new FragmentShader();
    fragmentshader.name = name;
    fragmentshader._fillProps(props);
    fragmentshader._shader = webGL.createShader(fragmentshader._type);

    _setChildObject(handle, fragmentshader);
    _nameMapping[name] = handle;
    return handle;

  }

  /// Create a [ShaderProgram] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [ShaderProgram] being created
  int createShaderProgram(String name, Object props, [int handle = Handle.BadHandle]) {
    {
      int checkHandle = _checkName(name, 'ShaderProgram');
      if (checkHandle != Handle.BadHandle) {
        return checkHandle;
      }
    }

    if (handle == Handle.BadHandle) {
      handle = registerHandle(ShaderProgramHandleType);
      if (handle == Handle.BadHandle) {
        return handle;
      }
    }

    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }

    ShaderProgram shaderprogram = new ShaderProgram();
    shaderprogram.name = name;
    shaderprogram._fillProps(props);
    shaderprogram._program = webGL.createProgram();
    VertexShader vs = getDeviceChild(shaderprogram.vs);
    FragmentShader fs = getDeviceChild(shaderprogram.fs);
    if (vs != null && fs != null) {
      webGL.attachShader(shaderprogram._program, vs._shader);
      webGL.attachShader(shaderprogram._program, fs._shader);
      shaderprogram.link();
    }

    _setChildObject(handle, shaderprogram);
    _nameMapping[name] = handle;
    return handle;
  }

  /// Create a [SamplerState] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [SamplerState] being created
  int createSamplerState(String name, Object props, [int handle = Handle.BadHandle]) {
    {
      int checkHandle = _checkName(name, 'SamplerState');
      if (checkHandle != Handle.BadHandle) {
        return checkHandle;
      }
    }

    if (handle == Handle.BadHandle) {
      handle = registerHandle(SamplerStateHandleType);
      if (handle == Handle.BadHandle) {
        return handle;
      }
    }

    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }

    SamplerState sampler = new SamplerState();
    sampler.name = name;
    sampler._fillProps(props);

    _setChildObject(handle, sampler);
    _nameMapping[name] = handle;
    return handle;
  }

  /// Create a [Viewport] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [Viewport] being created
  int createViewport(String name, Object props, [int handle = Handle.BadHandle]) {
    {
      int checkHandle = _checkName(name, 'Viewport');
      if (checkHandle != Handle.BadHandle) {
        return checkHandle;
      }
    }

    if (handle == Handle.BadHandle) {
      handle = registerHandle(ViewportHandleType);
      if (handle == Handle.BadHandle) {
        return handle;
      }
    }

    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }

    Viewport viewport = new Viewport();
    viewport.name = name;
    viewport._fillProps(props);

    _setChildObject(handle, viewport);
    _nameMapping[name] = handle;
    return handle;
  }

  /// Create a [DepthState] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [DepthState] being created
  int createDepthState(String name, Object props, [int handle = Handle.BadHandle]) {
    {
      int checkHandle = _checkName(name, 'DepthState');
      if (checkHandle != Handle.BadHandle) {
        return checkHandle;
      }
    }

    if (handle == Handle.BadHandle) {
      handle = registerHandle(DepthStateHandleType);
      if (handle == Handle.BadHandle) {
        return handle;
      }
    }

    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }

    DepthState depthstate = new DepthState();
    depthstate.name = name;
    depthstate._fillProps(props);

    _setChildObject(handle, depthstate);
    _nameMapping[name] = handle;
    return handle;
  }

  /// Create a [BlendState] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [BlendState] being created
  int createBlendState(String name, Object props, [int handle = Handle.BadHandle]) {
    {
      int checkHandle = _checkName(name, 'BlendState');
      if (checkHandle != Handle.BadHandle) {
        return checkHandle;
      }
    }

    if (handle == Handle.BadHandle) {
      handle = registerHandle(BlendStateHandleType);
      if (handle == Handle.BadHandle) {
        return handle;
      }
    }

    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }

    BlendState blendstate = new BlendState();
    blendstate.name = name;
    blendstate._fillProps(props);

    _setChildObject(handle, blendstate);
    _nameMapping[name] = handle;
    return handle;
  }

  /// Create a [RasterizerState] named [name]
  ///
  /// [props] is a JSON String or a [Map] containing a set of properties
  /// describing the [RasterizerState] being created
  int createRasterizerState(String name, Object props, [int handle = Handle.BadHandle]) {
    {
      int checkHandle = _checkName(name, 'BlendState');
      if (checkHandle != Handle.BadHandle) {
        return checkHandle;
      }
    }

    if (handle == Handle.BadHandle) {
      handle = registerHandle(BlendStateHandleType);
      if (handle == Handle.BadHandle) {
        return handle;
      }
    }

    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }

    RasterizerState rasterizerstate = new RasterizerState();
    rasterizerstate.name = name;
    rasterizerstate._fillProps(props);

    _setChildObject(handle, rasterizerstate);
    _nameMapping[name] = handle;
    return handle;
  }

  /// Create an [InputLayout] named [name] for [elements] and [shaderProgramHandle]
  int createInputLayout(String name, List<InputElementDescription> elements, int shaderProgramHandle, [int handle = Handle.BadHandle]) {
    {
      int checkHandle = _checkName(name, 'BlendState');
      if (checkHandle != Handle.BadHandle) {
        return checkHandle;
      }
    }

    if (handle == Handle.BadHandle) {
      handle = registerHandle(BlendStateHandleType);
      if (handle == Handle.BadHandle) {
        return handle;
      }
    }

    ShaderProgram sp = getDeviceChild(shaderProgramHandle);

    InputLayout il = new InputLayout();
    il.name = name;
    il._maxAttributeIndex = -1;
    il._elements = new List<_InputLayoutElement>();
    for (var e in elements) {
      var index = webGL.getAttribLocation(sp._program, e.name);
      if (index == -1) {
        spectreLog.Warning('Can\'t find ${e.name} in ${sp.name}');
        continue;
      }
      _InputLayoutElement el = new _InputLayoutElement();
      el._attributeIndex = index;
      if (index > il._maxAttributeIndex) {
        il._maxAttributeIndex = index;
      }
      el._attributeFormat = e.format;
      el._vboOffset = e.vertexBufferOffset;
      el._vboSlot = e.vertexBufferSlot;
      el._attributeStride = e.elementStride;
      il._elements.add(el);
    }

    _setChildObject(handle, il);
    _nameMapping[name] = handle;
    return handle;
  }

}

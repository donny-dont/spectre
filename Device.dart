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

class DeviceChild implements Hashable {
  String name;
  int hashCode() {
    return name.hashCode();
  }
}

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

class InputElementDescription {
  String name;
  DeviceFormat format;
  int elementStride;
  int vertexBufferSlot;
  int vertexBufferOffset;
  
  InputElementDescription(this.name, this.format, this.elementStride, this.vertexBufferSlot, this.vertexBufferOffset);
}

class InputLayout extends DeviceChild {
  int _maxAttributeIndex;
  List<_InputLayoutElement> _elements;
}

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
  
  void fillProps(Map props) {
    x = props['x'];
    y = props['y'];
    width = props['width'];
    height = props['height'];
  }
}

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

  void fillProps(Map props) {
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
}

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
  
  void fillProps(Map props) {
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
}

class StencilState extends DeviceChild {
  void fillProps(Map props) {
    
  }
}

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
  
  void fillProps(Map props) {
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

  void fillProps(Map props) {

  }
}

class VertexShader extends Shader {
  void fillProps(Map props) {
    _type = WebGLRenderingContext.VERTEX_SHADER;
  }
}

class FragmentShader extends Shader {
  void fillProps(Map props) {
    _type = WebGLRenderingContext.FRAGMENT_SHADER;
  }
}

class ShaderProgram extends DeviceChild {
  VertexShader vs;
  FragmentShader fs;
  WebGLProgram _program;
  int numAttributes;
  int numUniforms;
  
  void fillProps(Map props) {
    vs = props['VertexProgram'];
    fs = props['FragmentProgram'];
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
        return 'unknown';
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
  void fillProps(Map props) {
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
}

class Texture2D extends Texture {
  Texture2D() {
    _target = WebGLRenderingContext.TEXTURE_2D;
    _target_param = WebGLRenderingContext.TEXTURE_BINDING_2D;
    _width = 1;
    _height = 1;
    _textureFormat = Texture.TextureFormatRGBA;
    _pixelFormat = Texture.PixelFormatUnsignedByte;
  }
  
  void fillProps(Map props) {
    _width = props['width'] != null ? props['width'] : 1;
    _height = props['height'] != null ? props['height'] : 1;
    _textureFormat = props['textureFormat'] != null ? props['textureFormat'] : Texture.TextureFormatRGBA;
    _pixelFormat = props['pixelFormat'] != null ? props['pixelFormat'] : Texture.PixelFormatUnsignedByte;
  }
}

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
  
  void fillProps(Map props) {
    _wrap_s = props['wrapS'] != null ? props['wrapS'] : TextureWrapRepeat;
    _wrap_t = props['wrapT'] != null ? props['wrapT'] : TextureWrapRepeat;
    _min_filter = props['minFilter'] != null ? props['minFilter'] : TextureMinFilterNearestMipmapLinear;
    _mag_filter = props['magFilter'] != null ? props['magFilter'] : TextureMagFilterLinear;
  }
}

class RenderTarget extends DeviceChild {
  Object _color0;
  Object _depth;
  Object _stencil;
  WebGLFramebuffer _buffer;
  int _target;

  void fillProps(Map props) {
    _target = WebGLRenderingContext.FRAMEBUFFER;
    _color0 = props['color0'];
    _depth = props['depth'];
    _stencil = props['stencil'];
  }
}

class SpectreBuffer extends DeviceChild {
  WebGLBuffer _buffer;
  int _target;
  int _usage;
  int _size;
}

class IndexBuffer extends SpectreBuffer {
  void fillProps(Map props) {
    _target = WebGLRenderingContext.ELEMENT_ARRAY_BUFFER;
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

class VertexBuffer extends SpectreBuffer {
  void fillProps(Map props) {
    _target = WebGLRenderingContext.ARRAY_BUFFER;
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

class Device {
  static final DeviceFormat DeviceFormatFloat1 = const DeviceFormat(WebGLRenderingContext.FLOAT, 1, false);
  static final DeviceFormat DeviceFormatFloat2 = const DeviceFormat(WebGLRenderingContext.FLOAT, 2, false);
  static final DeviceFormat DeviceFormatFloat3 = const DeviceFormat(WebGLRenderingContext.FLOAT, 3, false);
  static final DeviceFormat DeviceFormatFloat4 = const DeviceFormat(WebGLRenderingContext.FLOAT, 4, false);
  
  Map<String, IndexBuffer> _indexBuffers;
  Map<String, VertexBuffer> _vertexBuffers;
  Map<String, RenderBuffer> _renderBuffers;
  Map<String, RenderTarget> _renderTargets;
  Map<String, Texture2D> _texture2Ds;
  Map<String, SamplerState> _samplerStates;
  Map<String, VertexShader> _vertexShaders;
  Map<String, FragmentShader> _fragmentShaders;
  Map<String, ShaderProgram> _shaderPrograms;
  Map<String, Viewport> _viewports;
  Map<String, DepthState> _depthStates;
  Map<String, BlendState> _blendStates;
  Map<String, RasterizerState> _rasterizerStates;
  Map<String, InputLayout> _inputLayouts;
  
  Device() {
    _indexBuffers = new Map<String, IndexBuffer>();
    _vertexBuffers = new Map<String, VertexBuffer>();
    _renderBuffers = new Map<String, RenderBuffer>();
    _renderTargets = new Map<String, RenderTarget>();
    _texture2Ds = new Map<String, Texture2D>();
    _samplerStates = new Map<String, SamplerState>();
    _vertexShaders = new Map<String, VertexShader>();
    _fragmentShaders = new Map<String, FragmentShader>();
    _shaderPrograms = new Map<String, ShaderProgram>();
    _viewports = new Map<String, Viewport>();
    _depthStates = new Map<String, DepthState>();
    _blendStates = new Map<String, BlendState>();
    _rasterizerStates = new Map<String, RasterizerState>();
    _inputLayouts = new Map<String, InputLayout>();
  }

  IndexBuffer findIndexBuffer(String name) {
    IndexBuffer ib = _indexBuffers[name];
    if (ib == null) {
      spectreLog.Warning('IndexBuffer $name not found.');
    }
    return ib;
  }

  IndexBuffer createIndexBuffer(String name, Object props) {
    if (_indexBuffers.containsKey(name)){
      spectreLog.Error('Attempting to create index buffer with same name $name');
      return _indexBuffers[name];
    }
    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }
    IndexBuffer ib = new IndexBuffer();
    ib.name = name;
    ib.fillProps(props);

    WebGLBuffer oldBind = webGL.getParameter(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER_BINDING);
    
    ib._buffer = webGL.createBuffer();
    webGL.bindBuffer(ib._target, ib._buffer);
    webGL.bufferData(ib._target, ib._size, ib._usage);
    _indexBuffers[ib.name] = ib;
    
    webGL.bindBuffer(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, oldBind);
    
    return ib;
  }

  void deleteIndexBuffer(IndexBuffer ib) {
    if (ib == null) {
      spectreLog.Warning('Attempting to delete null index buffer');
      return;
    }
    _indexBuffers.remove(ib.name);
    webGL.deleteBuffer(ib._buffer);
  }

  VertexBuffer findVertexBuffer(String name) {
    VertexBuffer vb = _vertexBuffers[name];
    if (vb == null) {
      spectreLog.Warning('VertexBuffer $name not found.');
    }
    return vb;
  }

  VertexBuffer createVertexBuffer(String name, Object props) {
    if (_vertexBuffers.containsKey(name)){
      spectreLog.Error('Attempting to create vertex buffer with same name $name');
      return _vertexBuffers[name];
    }
    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }
    VertexBuffer vb = new VertexBuffer();
    vb.name = name;
    vb.fillProps(props);
    WebGLBuffer oldBind = webGL.getParameter(WebGLRenderingContext.ARRAY_BUFFER_BINDING);
    vb._buffer = webGL.createBuffer();
    webGL.bindBuffer(vb._target, vb._buffer);
    webGL.bufferData(vb._target, vb._size, vb._usage);
    webGL.bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, oldBind);
    _vertexBuffers[vb.name] = vb;
    return vb;
  }

  void deleteVertexBuffer(VertexBuffer vb) {
    if (vb == null) {
      spectreLog.Warning('Attempting to delete null vertex buffer');
      return;
    }
    _vertexBuffers.remove(vb.name);
    webGL.deleteBuffer(vb._buffer);
  }

  RenderBuffer findRenderBuffer(String name) {
    RenderBuffer b = _renderBuffers[name];
    if (b == null) {
      spectreLog.Warning('RenderBuffer $name not found.');
    }
    return b;
  }

  RenderBuffer createRenderBuffer(String name, Object props) {
    if (_renderBuffers.containsKey(name)){
      spectreLog.Error('Attempting to create render buffer with same name $name');
      return _renderBuffers[name];
    }
    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }
    RenderBuffer rb = new RenderBuffer();
    rb.name = name;
    rb.fillProps(props);

    rb._buffer = webGL.createRenderbuffer();
    WebGLRenderbuffer oldBind = webGL.getParameter(WebGLRenderingContext.RENDERBUFFER_BINDING);
    webGL.bindRenderbuffer(rb._target, rb._buffer);
    webGL.renderbufferStorage(rb._target, rb._format, rb._width, rb._height);
    webGL.bindRenderbuffer(WebGLRenderingContext.RENDERBUFFER, oldBind);
    _renderBuffers[rb.name] = rb;
    return rb;
  }

  void deleteRenderBuffer(RenderBuffer rb) {
    _renderBuffers.remove(rb.name);
    webGL.deleteRenderbuffer(rb._buffer);
  }

  RenderTarget findRenderTarget(String name) {
    RenderTarget t = _renderTargets[name];
    if (t == null) {
      spectreLog.Warning('RenderTarget $name not found');
    }
    return t;
  }

  RenderTarget createRenderTarget(String name, Object props) {
    if (_renderTargets.containsKey(name)){
      spectreLog.Error('Attempting to create render target with same name $name');
      return _renderTargets[name];
    }
    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }
    RenderTarget rt = new RenderTarget();
    rt.name = name;
    rt.fillProps(props);
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
    _renderTargets[rt.name] = rt;
    return rt;
  }

  Texture2D findTexture2D(String name) {
    Texture t = _texture2Ds[name];
    if (t == null) {
      spectreLog.Warning('Texture $name not found');
    }
    return t;
  }

  Texture createTexture2D(String name, Object props) {
    if (_texture2Ds.containsKey(name)){
      spectreLog.Error('Attempting to create Texture2D with same name $name');
      return _texture2Ds[name];
    }
    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }
    Texture2D rt = new Texture2D();
    rt.name = name;
    rt.fillProps(props);
    rt._buffer = webGL.createTexture();
    
    WebGLTexture oldBind = webGL.getParameter(rt._target_param); 
    webGL.bindTexture(rt._target, rt._buffer);
    // Allocate memory for texture
    webGL.texImage2D(rt._target, 0, rt._textureFormat, rt._width, rt._height, 0, rt._textureFormat, rt._pixelFormat, null);
    webGL.bindTexture(rt._target, oldBind);
    _texture2Ds[rt.name] = rt;
    return rt;
  }

  void deleteTexture(Texture t) {
    _texture2Ds.remove(t.name);
    webGL.deleteTexture(t._buffer);
  }

  SamplerState findSamplerState(String name) {
    SamplerState s = _samplerStates[name];
    if (s == null) {
      spectreLog.Warning('Sampler $name not found');
    }
    return s;
  }

  SamplerState createSamplerState(String name, Object props) {
    if (_samplerStates.containsKey(name)){
      spectreLog.Error('Attempting to create sampler with same name $name');
      return _samplerStates[name];
    }
    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }
    SamplerState sampler = new SamplerState();
    sampler.name = name;
    sampler.fillProps(props);
    _samplerStates[sampler.name] = sampler;
    return sampler;
  }

  void deleteSamplerState(SamplerState sampler) {
    _samplerStates.remove(sampler.name);
  }

  void deleteRenderTarget(RenderTarget rt) {
    _renderTargets.remove(rt.name);
    webGL.deleteFramebuffer(rt._buffer);
  }

  VertexShader findVertexShader(String name) {
    VertexShader vs = _vertexShaders[name];
    if (vs == null) {
      spectreLog.Warning('VertexShader $name not found');
    }
    return vs;
  }

  VertexShader createVertexShader(String name, Object props) {
    if (_vertexShaders.containsKey(name)){
      spectreLog.Error('Attempting to create render target with same name $name');
      return _vertexShaders[name];
    }
    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }
    VertexShader rt = new VertexShader();
    rt.name = name;
    rt.fillProps(props);
    rt._shader = webGL.createShader(rt._type);

    _vertexShaders[rt.name] = rt;
    return rt;
  }

  void deleteVertexShader(VertexShader shader) {
    _vertexShaders.remove(shader.name);
    webGL.deleteShader(shader._shader);
  }

  FragmentShader findFragmentShader(String name) {
    FragmentShader vs = _fragmentShaders[name];
    if (vs == null) {
      spectreLog.Warning('FragmentShader $name not found');
    }
    return vs;
  }

  FragmentShader createFragmentShader(String name, Object props) {
    if (_fragmentShaders.containsKey(name)) {
      spectreLog.Error('Attempting to create fragment shader with same name $name');
      return _fragmentShaders[name];
    }
    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }
    FragmentShader rt = new FragmentShader();
    rt.name = name;
    rt.fillProps(props);
    rt._shader = webGL.createShader(rt._type);
    _fragmentShaders[rt.name] = rt;
    return rt;
  }

  void deleteFragmentShader(FragmentShader fs) {
    if (fs == null) {
      spectreLog.Warning('Attempting to delete null fragment shader');
      return;
    }
    _fragmentShaders.remove(fs.name);
    webGL.deleteShader(fs._shader);
  }

  ShaderProgram findShaderProgram(String name) {
    ShaderProgram vs = _shaderPrograms[name];
    if (vs == null) {
      spectreLog.Warning('ShaderProgram $name not found');
    }
    return vs;
  }

  ShaderProgram createShaderProgram(String name, Object props) {
    if (_shaderPrograms.containsKey(name)) {
      spectreLog.Error('Attempting to create shader program with same name $name');
      return _shaderPrograms[name];
    }
    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }
    ShaderProgram rt = new ShaderProgram();
    rt.name = name;
    rt.fillProps(props);
    rt._program = webGL.createProgram();
    webGL.attachShader(rt._program, rt.vs._shader);
    webGL.attachShader(rt._program, rt.fs._shader);
    rt.link();
    _shaderPrograms[rt.name] = rt;
    return rt;
  }

  void deleteShaderProgram(ShaderProgram sp) {
    _shaderPrograms.remove(sp.name);
    webGL.deleteProgram(sp._program);
  }

  Viewport findViewport(String name) {
    Dynamic o = _viewports[name];
    if (o == null) {
      spectreLog.Warning('Viewport $name not found');
    }
    return o;
  }

  Viewport createViewport(String name, Object props) {
    if (_viewports.containsKey(name)) {
      spectreLog.Error('Attempting to create viewport with same name $name');
      return _viewports[name];
    }
    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }
    Viewport rt = new Viewport();
    rt.name = name;
    rt.fillProps(props);
    _viewports[rt.name] = rt;
    return rt;
  }

  void deleteViewport(Viewport vp) {
    _viewports.remove(vp.name);
  }

  DepthState findDepthState(String name) {
    Dynamic o = _depthStates[name];
    if (o == null) {
      spectreLog.Warning('DepthState $name not found');
    }
    return o;
  }

  DepthState createDepthState(String name, Object props) {
    if (_depthStates.containsKey(name)) {
      spectreLog.Error('Attempting to create Depth Stencil State with same name $name');
      return _depthStates[name];
    }
    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }
    DepthState rt = new DepthState();
    rt.name = name;
    rt.fillProps(props);
    _depthStates[rt.name] = rt;
    return rt;
  }

  void deleteDepthState(DepthState ds) {
    _depthStates.remove(ds.name);
  }

  BlendState findBlendState(String name) {
    Dynamic o = _blendStates[name];
    if (o == null) {
      spectreLog.Warning('BlendState $name not found');
    }
    return o;
  }

  BlendState createBlendState(String name, Object props) {
    if (_blendStates.containsKey(name)) {
      spectreLog.Error('Attempting to create Blend State with same name $name');
      return _blendStates[name];
    }
    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }
    BlendState rt = new BlendState();
    rt.name = name;
    rt.fillProps(props);
    _blendStates[rt.name] = rt;
    return rt;
  }

  void deleteBlendState(BlendState bs) {
    _blendStates.remove(bs.name);
  }

  RasterizerState findRasterizerState(String name) {
    Dynamic o = _rasterizerStates[name];
    if (o == null) {
      spectreLog.Warning('RasterizerState $name not found');
    }
    return o;
  }

  RasterizerState createRasterizerState(String name, Object props) {
    if (_rasterizerStates.containsKey(name)) {
      spectreLog.Error('Attempting to create Rasterizer State with same name $name');
      return _rasterizerStates[name];
    }
    if (props is String) {
      props = JSON.parse(props);
    }
    if ((props is Map) == false) {
      return null;
    }
    RasterizerState rt = new RasterizerState();
    rt.name = name;
    rt.fillProps(props);
    _rasterizerStates[rt.name] = rt;
    return rt;
  }

  void deleteRasterizerState(RasterizerState rs) {
    _rasterizerStates.remove(rs.name);
  }

  InputLayout findInputLayout(String name) {
    Dynamic o = _inputLayouts[name];
    if (o == null) {
      spectreLog.Warning('InputLayout $name not found');
    }
    return o;
  }
  
  InputLayout createInputLayout(String name, List<InputElementDescription> elements, ShaderProgram sp) {
    if (_inputLayouts.containsKey(name)) {
      spectreLog.Error('Attempting to create input layout with same name $name');
      return _inputLayouts[name];
    }
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
    _inputLayouts[name] = il;
    spectreLog.Info('Created InputLayout $name with ${il._elements.length} attributes');
    return il;
  }
  
  void deleteInputLayout(InputLayout il) {
    _inputLayouts.remove(il.name);
  }
}

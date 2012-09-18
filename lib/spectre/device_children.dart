/// A resource created by a device
/// All resources have a [name]
class DeviceChild implements Hashable {
  static final int StatusDirty = 0x1;
  static final int StatusReady = 0x2;
  
  String name;
  Device device;
  int _status;
  int fallback;
  
  void set dirty(bool r) {
    if (r) {
      _status |= StatusDirty;
    } else { 
      _status &= ~StatusDirty;
    }
  }
  bool get dirty() => (_status & StatusDirty) != 0;
  void set ready(bool r) {
    if (r) {
      _status |= StatusReady;
    } else { 
      _status &= ~StatusReady;
    }
  }
  bool get ready() => (_status & StatusReady) != 0;
  
  DeviceChild(this.name, this.device) {
    _status = 0;
    fallback = 0;
    ready = true;
    dirty = false;
  }

  int hashCode() {
    return name.hashCode();
  }
  
  bool equals(DeviceChild b) => name == b.name && device == b.device;

  void _createDeviceState() {
  }
  void _configDeviceState(Dynamic props) {
  }
  void _destroyDeviceState() {
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

/// A mapping of vertex buffers to shader program input attributes
/// Create using [Device.createInputLayout]
/// Set using [ImmediateContext.setInputLayout]
class InputLayout extends DeviceChild {
  int _maxAttributeIndex;
  List<_InputLayoutElement> _elements;
  List<InputElementDescription> _elementDescription;
  int _shaderProgramHandle;
  
  InputLayout(String name, Device device) : super(name, device) {
    _maxAttributeIndex = 0;
    _elements = null;
    _shaderProgramHandle = 0;
    _elementDescription = null;
  }

  void _createDeviceState() {
  }
  
  void _bind() {
    ShaderProgram sp = device.getDeviceChild(_shaderProgramHandle);
    if (_elementDescription == null || _elementDescription.length <= 0 || sp == null) {
      return;
    }
    
    _InputElementChecker checker = new _InputElementChecker();
    
    _maxAttributeIndex = -1;
    _elements = new List<_InputLayoutElement>();
    for (InputElementDescription e in _elementDescription) {
      checker.add(e);
      var index = device.gl.getAttribLocation(sp._program, e.name);
      if (index == -1) {
        spectreLog.Warning('Can\'t find ${e.name} in ${sp.name}');
        continue;
      }
      _InputLayoutElement el = new _InputLayoutElement();
      el._attributeIndex = index;
      if (index > _maxAttributeIndex) {
        _maxAttributeIndex = index;
      }
      el._attributeFormat = e.format;
      el._vboOffset = e.vertexBufferOffset;
      el._vboSlot = e.vertexBufferSlot;
      el._attributeStride = e.elementStride;
      _elements.add(el);
    }
  }
  
  void _configDeviceState(Dynamic props) {

    Dynamic o;
    
    o = props['shaderProgram'];
    if (o != null && o is int) {
      _shaderProgramHandle = o;
    }
    o = props['elements'];
    if (o != null && o is List) {
      _elementDescription = o;
    }
    _bind();
  }
  void _destroyDeviceState() {
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

  Viewport(String name, Device device) : super(name, device) {
    x = 0;
    y = 0;
    width = 640;
    height = 480;
  }

  void _createDeviceState() {
  }

  void _configDeviceState(Dynamic props) {
    if (props != null) {
      Dynamic o;
      o = props['x'];
      x = o != null ? o : x;
      o = props['y'];
      y = o != null ? o : y;
      o = props['width'];
      width = o != null ? o : width;
      o = props['height'];
      height = o != null ? o : height;
    }
  }

  void _destroyDeviceState() {
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

  BlendState(String name, Device device) : super(name, device) {
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
  void _createDeviceState() {
  }

  void _configDeviceState(Dynamic props) {
    if (props != null) {
      Dynamic o;
      o = props['blendColorRed'];
      blendColorRed = o != null ? o : blendColorRed;
      o = props['blendColorGreen'];
      blendColorGreen = o != null ? o : blendColorGreen;
      o = props['blendColorBlue'];
      blendColorBlue = o != null ? o : blendColorBlue;
      o = props['blendColorAlpha'];
      blendColorAlpha = o != null ? o : blendColorAlpha;

      o = props['blendEnable'];
      blendEnable = o != null ? o : blendEnable;
      o = props['blendSourceColorFunc'];
      blendSourceColorFunc = o != null ? o : blendSourceColorFunc;
      o = props['blendDestColorFunc'];
      blendDestColorFunc = o != null ? o : blendDestColorFunc;
      o = props['blendSourceAlphaFunc'];
      blendSourceAlphaFunc = o != null ? o : blendSourceAlphaFunc;
      o = props['blendDestAlphaFunc'];
      blendDestAlphaFunc = o != null ? o : blendDestAlphaFunc;

      o = props['blendColorOp'];
      blendColorOp = o != null ? o : blendColorOp;
      o = props['blendAlphaOp'];
      blendAlphaOp = o != null ? o : blendAlphaOp;

      o = props['writeRenderTargetRed'];
      writeRenderTargetRed = o != null ? o : writeRenderTargetRed;
      o = props['writeRenderTargetGreen'];
      writeRenderTargetGreen = o != null ? o : writeRenderTargetGreen;
      o = props['writeRenderTargetBlue'];
      writeRenderTargetBlue = o != null ? o : writeRenderTargetBlue;
      o = props['writeRenderTargetAlpha'];
      writeRenderTargetAlpha = o != null ? o : writeRenderTargetAlpha;
    }
  }

  void _destroyDeviceState() {

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

  DepthState(String name, Device device) : super(name, device) {
    depthTestEnabled = false;
    depthWriteEnabled = false;
    polygonOffsetEnabled = false;

    depthNearVal = 0.0;
    depthFarVal = 1.0;
    polygonOffsetFactor = 0.0;
    polygonOffsetUnits = 0.0;

    depthComparisonOp = DepthComparisonOpAlways;
  }

  void _createDeviceState() {
  }


  void _configDeviceState(Dynamic props) {
    if (props != null) {
      Dynamic o;

      o = props['depthTestEnabled'];
      depthTestEnabled = o != null ? o : depthTestEnabled;
      o = props['depthWriteEnabled'];
      depthWriteEnabled = o != null ? o : depthWriteEnabled;
      o = props['polygonOffsetEnabled'];
      polygonOffsetEnabled = o != null ? o : polygonOffsetEnabled;

      o = props['depthNearVal'];
      depthNearVal = o != null ? o : depthNearVal;
      o = props['depthFarVal'];
      depthFarVal = o != null ? o : depthFarVal;
      o = props['polygonOffsetFactor'];
      polygonOffsetFactor = o != null ? o :polygonOffsetFactor;
      o = props['polygonOffsetUnits'];
      polygonOffsetUnits = o != null ? o : polygonOffsetUnits;
      o = props['depthComparisonOp'];
      depthComparisonOp = o != null ? o : depthComparisonOp;
    }

  }

  void _destroyDeviceState() {

  }
}

class StencilState extends DeviceChild {

  StencilState(String name, Device device) : super(name, device) {

  }

  void _createDeviceState() {

  }

  void _configDeviceState(Map props) {

  }

  void _destroyDeviceState() {

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

  RasterizerState(String name, Device device) : super(name, device) {
    cullEnabled = false;
    cullMode = CullBack;
    cullFrontFace = FrontCCW;
    lineWidth = 1.0;
  }

  void _createDeviceState() {

  }

  void _configDeviceState(Dynamic props) {
    if (props != null) {
      Dynamic o;

      o = props['cullEnabled'];
      cullEnabled = o != null ? o : cullEnabled;
      o = props['cullMode'];
      cullMode = o != null ? o : cullMode;
      o = props['cullFrontFace'];
      cullFrontFace = o != null ? o : cullFrontFace;
      o = props['lineWidth'];
      lineWidth = o != null ? o : lineWidth;
    }
  }

  void _destroyDeviceState() {

  }
}

class Shader extends DeviceChild {
  String _source;
  WebGLShader _shader;
  int _type;
  
  Shader(String name, Device device) : super(name, device) {
    _source = '';
    _shader = null;
  }

  String get log() {
    return device.gl.getShaderInfoLog(_shader);
  }

  WebGLShader get shader() => this._shader;

  void set source(String s) {
    _source = s;
    device.gl.shaderSource(_shader, _source);
  }

  String get source() {
    return _source;
  }

  bool get compiled() {
    if (_shader != null) {
      return device.gl.getShaderParameter(_shader, WebGLRenderingContext.COMPILE_STATUS);
    }
    return false;
  }
  
  void compile() {
    device.gl.compileShader(_shader);
  }

  void _createDeviceState() {
    _shader = device.gl.createShader(_type);
  }


  void _configDeviceState(Dynamic props) {
  }

  void _destroyDeviceState() {
    device.gl.deleteShader(_shader);
  }
}

/// A vertex shader
/// Create using [Device.createVertexShader]
/// Must be linked into a ShaderProgram before use
class VertexShader extends Shader {
  VertexShader(String name, Device device) : super(name, device) {
    _type = WebGLRenderingContext.VERTEX_SHADER;
  }


  void _createDeviceState() {
    super._createDeviceState();
  }


  void _configDeviceState(Dynamic props) {
   super._configDeviceState(props);
  }

  void _destroyDeviceState() {
    super._destroyDeviceState();
  }
}

/// A fragment shader
/// Create using [Device.createFragmentShader]
/// Must be linked into a ShaderProgram before use
class FragmentShader extends Shader {
  FragmentShader(String name, Device device) : super(name, device) {
    _type = WebGLRenderingContext.FRAGMENT_SHADER;
  }

  void _createDeviceState() {
    super._createDeviceState();
  }


  void _configDeviceState(Dynamic props) {
   super._configDeviceState(props);
  }

  void _destroyDeviceState() {
    super._destroyDeviceState();
  }
}

typedef void UniformCallback(String name, int index, String type, int size);

/// A shader program defines how the programmable units of the GPU pipeline function
/// Create using [Device.createShaderProgram]
/// Set using [ImmediateContext.setShaderProgram]
class ShaderProgram extends DeviceChild {
  int vertexShaderHandle;
  int fragmentShaderHandle;
  WebGLProgram _program;
  int numAttributes;
  int numUniforms;

  ShaderProgram(String name, Device device) : super(name, device) {
    vertexShaderHandle = 0;
    fragmentShaderHandle = 0;
    numUniforms = 0;
    numAttributes = 0;
    _program = null;
  }

  void _createDeviceState() {
    _program = device.gl.createProgram();
  }

  void _detach(int shaderHandle) {
    Shader shader = device.getDeviceChild(shaderHandle);
    if (shader != null) {
      device.gl.detachShader(_program, shader._shader);
    }
  }
  
  void _attach(int shaderHandle) {
    Shader shader = device.getDeviceChild(shaderHandle);
    if (shader != null) {
      device.gl.attachShader(_program, shader._shader);
    }
  }
  
  void _configDeviceState(Dynamic props) {
    if (props != null) {
      Dynamic o;
      o = props['VertexProgram'];
      if (o != null && o is int) {
        _detach(vertexShaderHandle);
        vertexShaderHandle = o;
        _attach(vertexShaderHandle);
      }
      
      o = props['FragmentProgram'];
      if (o != null && o is int) {
        _detach(fragmentShaderHandle);
        fragmentShaderHandle = o;
        _attach(fragmentShaderHandle);
      }
      
      VertexShader vertexShader = device.getDeviceChild(vertexShaderHandle);
      FragmentShader fragmentShader = device.getDeviceChild(fragmentShaderHandle);
      if (vertexShader != null && fragmentShader != null) {
        // relink
        link();
      }
    }
  }

  void _destroyDeviceState() {
    vertexShaderHandle = 0;
    fragmentShaderHandle = 0;
    device.gl.deleteProgram(_program);
  }

  void link() {
    device.gl.linkProgram(_program);
    String linkLog = device.gl.getProgramInfoLog(_program);
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
      case WebGLRenderingContext.SAMPLER_2D:
        return 'sampler2D';
      default:
        return 'unknown code: $type';
    }
  }

  bool get linked() {
    if (_program != null) {
      return device.gl.getProgramParameter(_program, WebGLRenderingContext.LINK_STATUS);
    }
    return false;
  }
  
  void refreshUniforms() {
    numUniforms = device.gl.getProgramParameter(_program, WebGLRenderingContext.ACTIVE_UNIFORMS);
    spectreLog.Info('$name has $numUniforms uniform variables');
    for (int i = 0; i < numUniforms; i++) {
      WebGLActiveInfo activeUniform = device.gl.getActiveUniform(_program, i);
      spectreLog.Info('$i - ${_convertType(activeUniform.type)} ${activeUniform.name} (${activeUniform.size})');
    }
  }

  void refreshAttributes() {
    numAttributes = device.gl.getProgramParameter(_program, WebGLRenderingContext.ACTIVE_ATTRIBUTES);
    spectreLog.Info('$name has $numAttributes attributes');
    for (int i = 0; i < numAttributes; i++) {
      WebGLActiveInfo activeUniform = device.gl.getActiveAttrib(_program, i);
      spectreLog.Info('$i - ${_convertType(activeUniform.type)} ${activeUniform.name} (${activeUniform.size})');
    }
  }
  
  void forEachUniforms(UniformCallback callback) {
    numUniforms = device.gl.getProgramParameter(_program, WebGLRenderingContext.ACTIVE_UNIFORMS);
    for (int i = 0; i < numUniforms; i++) {
      WebGLActiveInfo activeUniform = device.gl.getActiveUniform(_program, i);
      callback(activeUniform.name, i, _convertType(activeUniform.type), activeUniform.size);
    }
  }
}

class RenderBuffer extends DeviceChild {
  int _target;
  int _width;
  int _height;
  int _format;
  WebGLRenderbuffer _buffer;

  RenderBuffer(String name, Device device) : super(name, device) {

  }

  void _createDeviceState() {
    _buffer = device.gl.createRenderbuffer();
  }

  void _destroyDeviceState() {
    device.gl.deleteRenderbuffer(_buffer);
  }

  void _configDeviceState(Dynamic props) {
    _target = WebGLRenderingContext.RENDERBUFFER;
    String format = props['format'];
    switch (format) {
      case 'R8G8B8A8':
        _format = WebGLRenderingContext.RGB565;
      break;
      case 'D32':
      case 'DEPTH32':
        _format = WebGLRenderingContext.DEPTH_COMPONENT16;
      break;
      default:
        spectreLog.Error('format is not a valid render buffer format');
      break;
    }
    _width = props['width'];
    _height = props['height'];

    WebGLRenderbuffer oldBind = device.gl.getParameter(WebGLRenderingContext.RENDERBUFFER_BINDING);
    device.gl.bindRenderbuffer(_target, _buffer);
    device.gl.renderbufferStorage(_target, _format, _width, _height);
    device.gl.bindRenderbuffer(WebGLRenderingContext.RENDERBUFFER, oldBind);
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

  Texture(String name, Device device) : super(name, device);

  void _createDeviceState() {
    _buffer = device.gl.createTexture();
  }

  void _configDeviceState(Dynamic props) {

  }

  void _destroyDeviceState() {
    device.gl.deleteTexture(_buffer);
  }
}

/// Texture2D defines the storage for a 2D texture including Mipmaps
/// Create using [Device.createTexture2D]
/// Set using [immediateContext.setTextures]
/// NOTE: Unlike OpenGL, Spectre textures do not describe how they are sampled
class Texture2D extends Texture {
  Texture2D(String name, Device device) : super(name, device) {
    _target = WebGLRenderingContext.TEXTURE_2D;
    _target_param = WebGLRenderingContext.TEXTURE_BINDING_2D;
    _width = 1;
    _height = 1;
    _textureFormat = Texture.TextureFormatRGBA;
    _pixelFormat = Texture.PixelFormatUnsignedByte;
  }

  void _createDeviceState() {
    super._createDeviceState();
  }

  void _configDeviceState(Dynamic props) {
    super._configDeviceState(props);

    if (props != null && props['pixels'] != null) {
      var pixels = props['pixels'];
      if ((pixels is CanvasElement)) {
        WebGLTexture oldBind = device.gl.getParameter(_target_param);
        device.gl.bindTexture(_target, _buffer);
        device.gl.texImage2D(WebGLRenderingContext.TEXTURE_2D, 0, _textureFormat, _textureFormat, _pixelFormat, pixels);
        device.gl.bindTexture(_target, oldBind);
      }
    } else {
      if (props != null) {
        _width = props['width'] != null ? props['width'] : _width;
        _height = props['height'] != null ? props['height'] : _height;
        _textureFormat = props['textureFormat'] != null ? props['textureFormat'] : _textureFormat;
        _pixelFormat = props['pixelFormat'] != null ? props['pixelFormat'] : _pixelFormat;
      }
      WebGLTexture oldBind = device.gl.getParameter(_target_param);
      device.gl.bindTexture(_target, _buffer);
      // Allocate memory for texture
      device.gl.texImage2D(_target, 0, _textureFormat, _width, _height, 0, _textureFormat, _pixelFormat, null);
      device.gl.bindTexture(_target, oldBind);
    }
  }

  void _destroyDeviceState() {
    super._destroyDeviceState();
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

  int _wrapS;
  int _wrapT;
  int _magFilter;
  int _minFilter;

  SamplerState(String name, Device device) : super(name, device) {
    _wrapS = TextureWrapRepeat;
    _wrapT = TextureWrapRepeat;
    _minFilter = TextureMinFilterNearestMipmapLinear;
    _magFilter = TextureMagFilterLinear;
  }

  void _createDeviceState() {
    super._createDeviceState();
  }


  void _configDeviceState(Dynamic props) {
    if (props != null) {
      _wrapS = props['wrapS'] != null ? props['wrapS'] : _wrapS;
      _wrapT = props['wrapT'] != null ? props['wrapT'] : _wrapT;
      _minFilter = props['minFilter'] != null ? props['minFilter'] : _minFilter;
      _magFilter = props['magFilter'] != null ? props['magFilter'] : _magFilter;
    }

  }

  void _destroyDeviceState() {
  }
}

class RenderTarget extends DeviceChild {
  WebGLFramebuffer _buffer;
  int _target;
  int _target_param;

  RenderTarget(String name, Device device) : super(name, device) {
    _target = WebGLRenderingContext.FRAMEBUFFER;
    _target_param = WebGLRenderingContext.FRAMEBUFFER_BINDING;
  }

  void _createDeviceState() {
    super._createDeviceState();
    _buffer = device.gl.createFramebuffer();
  }

  void _configDeviceState(Dynamic props) {
    int colorHandle = props['color0'] != null ? props['color0'] : 0;
    int colorType = Handle.getType(colorHandle);
    int depthHandle = props['depth'] != null ? props['depth'] : 0;
    int depthType = Handle.getType(depthHandle);
    int stencilHandle = props['stencil'] != null ? props['stencil'] : 0;
    if (stencilHandle != 0) {
      spectreLog.Error('No support for stencil buffers yet.');
    }
    
    WebGLFramebuffer oldBind = device.gl.getParameter(_target_param);
    device.gl.bindFramebuffer(_target, _buffer);
    if (colorHandle != 0) {
      if (colorType == Device.RenderBufferHandleType) {
        RenderBuffer rb = device.getDeviceChild(colorHandle, true);
        device.gl.framebufferRenderbuffer(_target, WebGLRenderingContext.COLOR_ATTACHMENT0, WebGLRenderingContext.RENDERBUFFER, rb._buffer);
      } else if (colorType == Device.TextureHandleType) {
        Texture2D t2d = device.getDeviceChild(colorHandle, true);
        device.gl.framebufferTexture2D(_target, WebGLRenderingContext.COLOR_ATTACHMENT0, WebGLRenderingContext.TEXTURE_2D, t2d._buffer, 0);
      }
    } else {
      device.gl.framebufferRenderbuffer(_target, WebGLRenderingContext.COLOR_ATTACHMENT0, WebGLRenderingContext.RENDERBUFFER, null);
    }
    if (depthHandle != 0) {
      if (depthType == Device.RenderBufferHandleType) {
        RenderBuffer rb = device.getDeviceChild(depthHandle, true);
        device.gl.framebufferRenderbuffer(_target, WebGLRenderingContext.DEPTH_ATTACHMENT, WebGLRenderingContext.RENDERBUFFER, rb._buffer);
      } else if (depthType == Device.TextureHandleType) {
        Texture2D t2d = device.getDeviceChild(depthHandle, true);
        device.gl.framebufferTexture2D(_target, WebGLRenderingContext.DEPTH_ATTACHMENT, WebGLRenderingContext.TEXTURE_2D, t2d._buffer, 0);
      }
    } else {
      device.gl.framebufferRenderbuffer(_target, WebGLRenderingContext.DEPTH_ATTACHMENT, WebGLRenderingContext.RENDERBUFFER, null);
    }
    device.gl.framebufferRenderbuffer(_target, WebGLRenderingContext.STENCIL_ATTACHMENT, WebGLRenderingContext.RENDERBUFFER, null);
    
    int fbStatus = device.gl.checkFramebufferStatus(_target);
    if (fbStatus != WebGLRenderingContext.FRAMEBUFFER_COMPLETE) {
      spectreLog.Error('RenderTarget $name incomplete status = $fbStatus');
    } else {
      spectreLog.Info('RenderTarget $name complete.');
    }
    device.gl.bindFramebuffer(WebGLRenderingContext.FRAMEBUFFER, oldBind);
  }

  void _destroyDeviceState() {
    device.gl.deleteFramebuffer(_buffer);
    super._destroyDeviceState();
  }
}

class SpectreBuffer extends DeviceChild {
  WebGLBuffer _buffer;
  int _target;
  int _param_target;
  int _usage;

  SpectreBuffer(String name, Device device) : super(name, device) {
    _buffer = null;
  }

  void _createDeviceState() {
    super._createDeviceState();
    _buffer = device.gl.createBuffer();
    _usage = WebGLRenderingContext.DYNAMIC_DRAW;
  }

  void _configDeviceState(Dynamic props) {
    super._configDeviceState(props);

    if (props != null) {
      Dynamic o;
      o = props['usage'];
      if (o != null && o is String) {
        switch (o) {
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
            spectreLog.Error('$o is not a valid buffer usage type');
          break;
        }
      }
    }

    /*
    WebGLBuffer oldBind = device.gl.getParameter(_param_target);
    device.gl.bindBuffer(_target, _buffer);
    device.gl.bufferData(_target, _size, _usage);
    device.gl.bindBuffer(_target, oldBind);
    */
  }

  void _destroyDeviceState() {
    device.gl.deleteBuffer(_buffer);
    super._destroyDeviceState();
  }
}

/// IndexBuffer defines the storage for indexes used to construct primitives
/// Create using [Device.createIndexBuffer]
/// Set using [Device.setIndexBuffer]
class IndexBuffer extends SpectreBuffer {

  IndexBuffer(String name, Device device) : super(name, device) {
    _target = WebGLRenderingContext.ELEMENT_ARRAY_BUFFER;
    _param_target = WebGLRenderingContext.ELEMENT_ARRAY_BUFFER_BINDING;
  }

  void _createDeviceState() {
    super._createDeviceState();
  }

  void _configDeviceState(Dynamic props) {
    super._configDeviceState(props);
  }

  void _destroyDeviceState() {
    super._destroyDeviceState();
  }
}

/// VertexBuffer defines storage for vertex attribute elements
/// Create using [Device.createVertexBuffer]
/// Set using [Device.setVertexBuffers]
class VertexBuffer extends SpectreBuffer {
  VertexBuffer(String name, Device device) : super(name, device) {
    _target = WebGLRenderingContext.ARRAY_BUFFER;
    _param_target = WebGLRenderingContext.ARRAY_BUFFER_BINDING;
  }

  void _createDeviceState() {
    super._createDeviceState();
  }

  void _configDeviceState(Dynamic props) {
    super._configDeviceState(props);

  }

  void _destroyDeviceState() {
    super._destroyDeviceState();
  }
}

class IndexedMesh extends DeviceChild {
  int vertexArrayHandle;
  int indexArrayHandle;
  int numIndices;
  int indexOffset;

  IndexedMesh(String name, Device device) : super(name, device) {
    vertexArrayHandle = 0;
    indexArrayHandle = 0;
    numIndices = 0;
    indexOffset = 0;
  }

  void _createDeviceState() {
    super._createDeviceState();
    vertexArrayHandle = device.createVertexBuffer('${name}.array', {});
    indexArrayHandle = device.createIndexBuffer('${name}.index', {});
  }

  void _configDeviceState(Dynamic props) {
    super._configDeviceState(props);
    if (props != null) {
      Dynamic o;

      o = props['UpdateFromMeshResource'];
      if (o != null && o is Map) {
        ResourceManager rm = o['resourceManager'];
        int meshResourceHandle = o['meshResourceHandle'];
        /*
         * MeshResource just loads the first index for now
        int meshResourceIndex = o['meshResourceIndex'];
        if (meshResourceIndex == null) {
          meshResourceIndex = 0;
        }*/
        if (rm != null && rm is ResourceManager && meshResourceHandle != null) {
          MeshResource mesh = rm.getResource(meshResourceHandle);
          device.immediateContext.updateBuffer(vertexArrayHandle, mesh.vertexArray, WebGLRenderingContext.STATIC_DRAW);
          device.immediateContext.updateBuffer(indexArrayHandle, mesh.indexArray, WebGLRenderingContext.STATIC_DRAW);
          indexOffset = 0;
          numIndices = mesh.numIndices;
        }
      }

      /* TODO
      o = props['UpdateFromArray'];
      if (o != null && o is int) {

      }
      */

      o = props['indexOffset'];
      if (o != null && o is int) {
        indexOffset = o;
      }

      o = props['numIndices'];
      if (o != null && o is int) {
        numIndices = o;
      }
    }
  }

  void _destroyDeviceState() {
    device.deleteDeviceChild(indexArrayHandle);
    device.deleteDeviceChild(vertexArrayHandle);
    super._destroyDeviceState();
  }
}

class ArrayMesh extends DeviceChild {
  int vertexArrayHandle;
  int numVertices;
  int vertexOffset;

  ArrayMesh(String name, Device device) : super(name, device) {
    vertexArrayHandle = 0;
    numVertices = 0;
    vertexOffset = 0;
  }

  void _createDeviceState() {
    super._createDeviceState();
    vertexArrayHandle = device.createVertexBuffer('${name}.array', {});
  }

  void _configDeviceState(Dynamic props) {
    super._configDeviceState(props);
    if (props != null) {
      Dynamic o;

      /* TODO
      o = props['UpdateFromArray'];
      if (o != null && o is int) {

      }

      o = props['vertexOffset'];
      if (o != null && o is int) {
        vertexOffset = o;
      }

      o = props['numVertices'];
      if (o != null && o is int) {
        numVertices = o;
      }*/
    }
  }

  void _destroyDeviceState() {
    device.deleteDeviceChild(vertexArrayHandle);
    super._destroyDeviceState();
  }
}
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

/// A resource created by a device
/// All resources have a [name]

class DeviceChild implements Hashable {
  static final int StatusDirty = 0x1;
  static final int StatusReady = 0x2;

  String name;
  GraphicsDevice device;
  int _status;
  int fallback;

  void set dirty(bool r) {
    if (r) {
      _status |= StatusDirty;
    } else {
      _status &= ~StatusDirty;
    }
  }
  bool get dirty => (_status & StatusDirty) != 0;
  void set ready(bool r) {
    if (r) {
      _status |= StatusReady;
    } else {
      _status &= ~StatusReady;
    }
  }
  bool get ready => (_status & StatusReady) != 0;

  DeviceChild(this.name, this.device) {
    _status = 0;
    fallback = 0;
    ready = true;
    dirty = false;
  }

  int get hashCode {
    return name.hashCode;
  }

  bool equals(DeviceChild b) => name == b.name && device == b.device;

  void _createDeviceState() {
  }
  void _configDeviceState(dynamic props) {
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

  InputLayout(String name, GraphicsDevice device) : super(name, device) {
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

  void _configDeviceState(dynamic props) {

    dynamic o;

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

  Viewport(String name, GraphicsDevice device) : super(name, device) {
    x = 0;
    y = 0;
    width = 640;
    height = 480;
  }

  void _createDeviceState() {
  }

  void _configDeviceState(dynamic props) {
    if (props != null) {
      dynamic o;
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

  BlendState(String name, GraphicsDevice device) : super(name, device) {
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

  dynamic filter(dynamic o) {
    if (o is String) {
      var table = {
       "BlendSourceZero": WebGLRenderingContext.ZERO,
       "BlendSourceOne": WebGLRenderingContext.ONE,
       "BlendSourceShaderColor": WebGLRenderingContext.SRC_COLOR,
       "BlendSourceShaderInverseColor": WebGLRenderingContext.ONE_MINUS_SRC_COLOR,
       "BlendSourceShaderAlpha": WebGLRenderingContext.SRC_ALPHA,
       "BlendSourceShaderInverseAlpha": WebGLRenderingContext.ONE_MINUS_SRC_ALPHA,
       "BlendSourceTargetColor": WebGLRenderingContext.DST_COLOR,
       "BlendSourceTargetInverseColor": WebGLRenderingContext.ONE_MINUS_DST_COLOR,
       "BlendSourceTargetAlpha": WebGLRenderingContext.DST_ALPHA,
       "BlendSourceTargetInverseAlpha": WebGLRenderingContext.ONE_MINUS_DST_ALPHA,
       "BlendSourceBlendColor": WebGLRenderingContext.CONSTANT_COLOR,
       "BlendSourceBlendAlpha": WebGLRenderingContext.CONSTANT_ALPHA,
       "BlendSourceBlendInverseColor": WebGLRenderingContext.ONE_MINUS_CONSTANT_COLOR,
       "BlendSourceBlendInverseAlpha": WebGLRenderingContext.ONE_MINUS_CONSTANT_ALPHA,
       "BlendOpAdd": WebGLRenderingContext.FUNC_ADD,
       "BlendOpSubtract": WebGLRenderingContext.FUNC_SUBTRACT,
       "BlendOpReverseSubtract": WebGLRenderingContext.FUNC_REVERSE_SUBTRACT
      };
      return table[o];
    }
    return o;
  }
  void _configDeviceState(dynamic props) {
    if (props != null) {
      dynamic o;
      o = props['blendColorRed'];
      blendColorRed = o != null ? filter(o) : blendColorRed;
      o = props['blendColorGreen'];
      blendColorGreen = o != null ? filter(o) : blendColorGreen;
      o = props['blendColorBlue'];
      blendColorBlue = o != null ? filter(o) : blendColorBlue;
      o = props['blendColorAlpha'];
      blendColorAlpha = o != null ? filter(o) : blendColorAlpha;

      o = props['blendEnable'];
      blendEnable = o != null ? filter(o) : blendEnable;
      o = props['blendSourceColorFunc'];
      blendSourceColorFunc = o != null ? filter(o) : blendSourceColorFunc;
      o = props['blendDestColorFunc'];
      blendDestColorFunc = o != null ? filter(o) : blendDestColorFunc;
      o = props['blendSourceAlphaFunc'];
      blendSourceAlphaFunc = o != null ? filter(o) : blendSourceAlphaFunc;
      o = props['blendDestAlphaFunc'];
      blendDestAlphaFunc = o != null ? filter(o) : blendDestAlphaFunc;

      o = props['blendColorOp'];
      blendColorOp = o != null ? filter(o) : blendColorOp;
      o = props['blendAlphaOp'];
      blendAlphaOp = o != null ? filter(o) : blendAlphaOp;

      o = props['writeRenderTargetRed'];
      writeRenderTargetRed = o != null ? filter(o) : writeRenderTargetRed;
      o = props['writeRenderTargetGreen'];
      writeRenderTargetGreen = o != null ? filter(o) : writeRenderTargetGreen;
      o = props['writeRenderTargetBlue'];
      writeRenderTargetBlue = o != null ? filter(o) : writeRenderTargetBlue;
      o = props['writeRenderTargetAlpha'];
      writeRenderTargetAlpha = o != null ? filter(o) : writeRenderTargetAlpha;
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

  DepthState(String name, GraphicsDevice device) : super(name, device) {
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

  dynamic filter(dynamic o) {
    if (o is String) {
      Map table = {
        "DepthComparisonOpNever": WebGLRenderingContext.NEVER,
        "DepthComparisonOpAlways": WebGLRenderingContext.ALWAYS,
        "DepthComparisonOpEqual": WebGLRenderingContext.EQUAL,
        "DepthComparisonOpNotEqual": WebGLRenderingContext.NOTEQUAL,
        "DepthComparisonOpLess": WebGLRenderingContext.LESS,
        "DepthComparisonOpLessEqual": WebGLRenderingContext.LEQUAL,
        "DepthComparisonOpGreaterEqual": WebGLRenderingContext.GEQUAL,
        "DepthComparisonOpGreater": WebGLRenderingContext.GREATER,
      };
      return table[o];
    }
    return o;
  }
  void _configDeviceState(dynamic props) {
    if (props != null) {
      dynamic o;

      o = props['depthTestEnabled'];
      depthTestEnabled = o != null ? filter(o) : depthTestEnabled;
      o = props['depthWriteEnabled'];
      depthWriteEnabled = o != null ? filter(o) : depthWriteEnabled;
      o = props['polygonOffsetEnabled'];
      polygonOffsetEnabled = o != null ? filter(o) : polygonOffsetEnabled;

      o = props['depthNearVal'];
      depthNearVal = o != null ? filter(o) : depthNearVal;
      o = props['depthFarVal'];
      depthFarVal = o != null ? filter(o) : depthFarVal;
      o = props['polygonOffsetFactor'];
      polygonOffsetFactor = o != null ? filter(o) : polygonOffsetFactor;
      o = props['polygonOffsetUnits'];
      polygonOffsetUnits = o != null ? filter(o) : polygonOffsetUnits;
      o = props['depthComparisonOp'];
      depthComparisonOp = o != null ? filter(o) : depthComparisonOp;
    }

  }

  void _destroyDeviceState() {

  }
}

class StencilState extends DeviceChild {

  StencilState(String name, GraphicsDevice device) : super(name, device) {

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

  RasterizerState(String name, GraphicsDevice device) : super(name, device) {
    cullEnabled = false;
    cullMode = CullBack;
    cullFrontFace = FrontCCW;
    lineWidth = 1.0;
  }

  void _createDeviceState() {

  }

  dynamic filter(dynamic o) {
    if (o is String) {
      var table = {
       "CullFront": WebGLRenderingContext.FRONT,
       "CullBack": WebGLRenderingContext.BACK,
       "CullFrontAndBack": WebGLRenderingContext.FRONT_AND_BACK,
       "FrontCW": WebGLRenderingContext.CW,
       "FrontCCW": WebGLRenderingContext.CCW,
      };
      return table[o];
    }
    return o;
  }
  void _configDeviceState(dynamic props) {
    if (props != null) {
      dynamic o;

      o = props['cullEnabled'];
      cullEnabled = o != null ? filter(o) : cullEnabled;
      o = props['cullMode'];
      cullMode = o != null ? filter(o) : cullMode;
      o = props['cullFrontFace'];
      cullFrontFace = o != null ? filter(o) : cullFrontFace;
      o = props['lineWidth'];
      lineWidth = o != null ? filter(o) : lineWidth;
    }
  }

  void _destroyDeviceState() {

  }
}

class Shader extends DeviceChild {
  String _source;
  WebGLShader _shader;
  int _type;

  Shader(String name, GraphicsDevice device) : super(name, device) {
    _source = '';
    _shader = null;
  }

  String get log {
    return device.gl.getShaderInfoLog(_shader);
  }

  WebGLShader get shader => this._shader;

  void set source(String s) {
    _source = s;
    device.gl.shaderSource(_shader, _source);
  }

  String get source {
    return _source;
  }

  bool get compiled {
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


  void _configDeviceState(dynamic props) {
  }

  void _destroyDeviceState() {
    device.gl.deleteShader(_shader);
  }
}

/// A vertex shader
/// Create using [Device.createVertexShader]
/// Must be linked into a ShaderProgram before use
class VertexShader extends Shader {
  VertexShader(String name, GraphicsDevice device) : super(name, device) {
    _type = WebGLRenderingContext.VERTEX_SHADER;
  }


  void _createDeviceState() {
    super._createDeviceState();
  }


  void _configDeviceState(dynamic props) {
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
  FragmentShader(String name, GraphicsDevice device) : super(name, device) {
    _type = WebGLRenderingContext.FRAGMENT_SHADER;
  }

  void _createDeviceState() {
    super._createDeviceState();
  }


  void _configDeviceState(dynamic props) {
   super._configDeviceState(props);
  }

  void _destroyDeviceState() {
    super._destroyDeviceState();
  }
}

typedef void UniformCallback(String name, int index, String type, int size, WebGLUniformLocation location);

/// A shader program defines how the programmable units of the GPU pipeline function
/// Create using [Device.createShaderProgram]
/// Set using [ImmediateContext.setShaderProgram]
class ShaderProgram extends DeviceChild {
  int vertexShaderHandle;
  int fragmentShaderHandle;
  WebGLProgram _program;
  int numAttributes;
  int numUniforms;

  ShaderProgram(String name, GraphicsDevice device) : super(name, device) {
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

  void _configDeviceState(dynamic props) {
    if (props != null) {
      dynamic o;
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

  bool get linked {
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
      spectreLog.Info('$i - ${UniformType.serialize(activeUniform.type)} ${activeUniform.name} (${activeUniform.size})');
    }
  }

  void refreshAttributes() {
    numAttributes = device.gl.getProgramParameter(_program, WebGLRenderingContext.ACTIVE_ATTRIBUTES);
    spectreLog.Info('$name has $numAttributes attributes');
    for (int i = 0; i < numAttributes; i++) {
      WebGLActiveInfo activeUniform = device.gl.getActiveAttrib(_program, i);
      spectreLog.Info('$i - ${UniformType.serialize(activeUniform.type)} ${activeUniform.name} (${activeUniform.size})');
    }
  }

  void forEachUniforms(UniformCallback callback) {
    numUniforms = device.gl.getProgramParameter(_program, WebGLRenderingContext.ACTIVE_UNIFORMS);
    for (int i = 0; i < numUniforms; i++) {
      WebGLActiveInfo activeUniform = device.gl.getActiveUniform(_program, i);
      WebGLUniformLocation location = device.gl.getUniformLocation(_program, activeUniform.name);
      callback(activeUniform.name, i, UniformType.serialize(activeUniform.type), activeUniform.size, location);
    }
  }
}

class RenderBuffer extends DeviceChild {
  int _target;
  int _width;
  int _height;
  int _format;
  WebGLRenderbuffer _buffer;

  RenderBuffer(String name, GraphicsDevice device) : super(name, device) {

  }

  void _createDeviceState() {
    _buffer = device.gl.createRenderbuffer();
  }

  void _destroyDeviceState() {
    device.gl.deleteRenderbuffer(_buffer);
  }

  void _configDeviceState(dynamic props) {
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

  Texture(String name, GraphicsDevice device) : super(name, device);

  void _createDeviceState() {
    _buffer = device.gl.createTexture();
  }

  void _configDeviceState(dynamic props) {

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
  Texture2D(String name, GraphicsDevice device) : super(name, device) {
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

  void _configDeviceState(dynamic props) {
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
      device.gl.pixelStorei(WebGLRenderingContext.UNPACK_FLIP_Y_WEBGL, 1);
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

  SamplerState(String name, GraphicsDevice device) : super(name, device) {
    _wrapS = TextureWrapRepeat;
    _wrapT = TextureWrapRepeat;
    _minFilter = TextureMinFilterNearestMipmapLinear;
    _magFilter = TextureMagFilterLinear;
  }

  void _createDeviceState() {
    super._createDeviceState();
  }

  dynamic filter(dynamic o) {
    if (o is String) {
      var table = {
        "TextureWrapClampToEdge": WebGLRenderingContext.CLAMP_TO_EDGE,
        "TextureWrapMirroredRepeat": WebGLRenderingContext.MIRRORED_REPEAT,
        "TextureWrapRepeat": WebGLRenderingContext.REPEAT,
        "TextureMagFilterLinear": WebGLRenderingContext.LINEAR,
        "TextureMagFilterNearest": WebGLRenderingContext.NEAREST,
        "TextureMinFilterLinear": WebGLRenderingContext.LINEAR,
        "TextureMinFilterNearest": WebGLRenderingContext.NEAREST,
        "TextureMinFilterNearestMipmapNearest": WebGLRenderingContext.NEAREST_MIPMAP_NEAREST,
        "TextureMinFilterNearestMipmapLinear": WebGLRenderingContext.NEAREST_MIPMAP_LINEAR,
        "TextureMinFilterLinearMipmapNearest": WebGLRenderingContext.LINEAR_MIPMAP_NEAREST,
        "TextureMinFilterLinearMipmapLinear": WebGLRenderingContext.LINEAR_MIPMAP_LINEAR
      };
      return table[o];
    }
    return o;
  }

  void _configDeviceState(dynamic props) {
    if (props != null) {
      dynamic o;
      o = props['wrapS'];
      _wrapS = o != null ? filter(o) : _wrapS;
      o = props['wrapT'];
      _wrapT = o != null ? filter(o) : _wrapT;
      o = props['minFilter'];
      _minFilter = o != null ? filter(o) : _minFilter;
      o = props['magFilter'];
      _magFilter = o != null ? filter(o) : _magFilter;
    }

  }

  void _destroyDeviceState() {
  }
}

class RenderTarget extends DeviceChild {
  WebGLFramebuffer _buffer;
  int _target;
  int _target_param;

  RenderTarget(String name, GraphicsDevice device) : super(name, device) {
    _target = WebGLRenderingContext.FRAMEBUFFER;
    _target_param = WebGLRenderingContext.FRAMEBUFFER_BINDING;
  }

  void _createDeviceState() {
    super._createDeviceState();
    _buffer = device.gl.createFramebuffer();
  }

  void _configDeviceState(dynamic props) {
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
      if (colorType == GraphicsDevice.RenderBufferHandleType) {
        RenderBuffer rb = device.getDeviceChild(colorHandle, true);
        device.gl.framebufferRenderbuffer(_target, WebGLRenderingContext.COLOR_ATTACHMENT0, WebGLRenderingContext.RENDERBUFFER, rb._buffer);
      } else if (colorType == GraphicsDevice.TextureHandleType) {
        Texture2D t2d = device.getDeviceChild(colorHandle, true);
        device.gl.framebufferTexture2D(_target, WebGLRenderingContext.COLOR_ATTACHMENT0, WebGLRenderingContext.TEXTURE_2D, t2d._buffer, 0);
      }
    } else {
      device.gl.framebufferRenderbuffer(_target, WebGLRenderingContext.COLOR_ATTACHMENT0, WebGLRenderingContext.RENDERBUFFER, null);
    }
    if (depthHandle != 0) {
      if (depthType == GraphicsDevice.RenderBufferHandleType) {
        RenderBuffer rb = device.getDeviceChild(depthHandle, true);
        device.gl.framebufferRenderbuffer(_target, WebGLRenderingContext.DEPTH_ATTACHMENT, WebGLRenderingContext.RENDERBUFFER, rb._buffer);
      } else if (depthType == GraphicsDevice.TextureHandleType) {
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

  SpectreBuffer(String name, GraphicsDevice device) : super(name, device) {
    _buffer = null;
  }

  void _createDeviceState() {
    super._createDeviceState();
    _buffer = device.gl.createBuffer();
    _usage = WebGLRenderingContext.DYNAMIC_DRAW;
  }

  void _configDeviceState(dynamic props) {
    super._configDeviceState(props);

    if (props != null) {
      dynamic o;
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

  IndexBuffer(String name, GraphicsDevice device) : super(name, device) {
    _target = WebGLRenderingContext.ELEMENT_ARRAY_BUFFER;
    _param_target = WebGLRenderingContext.ELEMENT_ARRAY_BUFFER_BINDING;
  }

  void _createDeviceState() {
    super._createDeviceState();
  }

  void _configDeviceState(dynamic props) {
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
  VertexBuffer(String name, GraphicsDevice device) : super(name, device) {
    _target = WebGLRenderingContext.ARRAY_BUFFER;
    _param_target = WebGLRenderingContext.ARRAY_BUFFER_BINDING;
  }

  void _createDeviceState() {
    super._createDeviceState();
  }

  void _configDeviceState(dynamic props) {
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

  IndexedMesh(String name, GraphicsDevice device) : super(name, device) {
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

  void _configDeviceState(dynamic props) {
    super._configDeviceState(props);
    if (props != null) {
      dynamic o;

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
          device.context.updateBuffer(vertexArrayHandle, mesh.vertexArray, WebGLRenderingContext.STATIC_DRAW);
          device.context.updateBuffer(indexArrayHandle, mesh.indexArray, WebGLRenderingContext.STATIC_DRAW);
          indexOffset = 0;
          numIndices = mesh.numIndices;
        }
      }

      o = props['UpdateFromMeshMap'];
      if (o != null && o is Map) {
        Map mesh = o['meshes'][0];
        if (o != null && o is Map) {
          var indices = new Uint16Array.fromList(mesh['indices']);
          device.context.updateBuffer(vertexArrayHandle, new Float32Array.fromList(mesh['vertices']), WebGLRenderingContext.STATIC_DRAW);
          device.context.updateBuffer(indexArrayHandle, indices, WebGLRenderingContext.STATIC_DRAW);
          indexOffset = 0;
          numIndices = indices.length;
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

  ArrayMesh(String name, GraphicsDevice device) : super(name, device) {
    vertexArrayHandle = 0;
    numVertices = 0;
    vertexOffset = 0;
  }

  void _createDeviceState() {
    super._createDeviceState();
    vertexArrayHandle = device.createVertexBuffer('${name}.array', {});
  }

  void _configDeviceState(dynamic props) {
    super._configDeviceState(props);
    if (props != null) {
      dynamic o;

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
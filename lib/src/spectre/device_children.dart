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
  DeviceChild fallback;

  String toString() => name;

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

  DeviceChild._internal(this.name, this.device) {
    _status = 0;
    ready = true;
    dirty = false;
  }

  int get hashCode {
    return name.hashCode;
  }

  bool equals(DeviceChild b) => name == b.name && device == b.device;

  void _createDeviceState() {
  }
  void _configDeviceState(Map props) {
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
  ShaderProgram _shaderProgram;

  InputLayout(String name, GraphicsDevice device) : super._internal(name, device) {
    _maxAttributeIndex = 0;
    _elements = null;
    _elementDescription = null;
  }

  void _createDeviceState() {
  }

  void _bind() {
    if (_elementDescription == null ||
        _elementDescription.length <= 0 ||
        _shaderProgram == null) {
      return;
    }

    _InputElementChecker checker = new _InputElementChecker();

    _maxAttributeIndex = -1;
    _elements = new List<_InputLayoutElement>();
    for (InputElementDescription e in _elementDescription) {
      checker.add(e);
      var index = device.gl.getAttribLocation(_shaderProgram._program, e.name);
      if (index == -1) {
        spectreLog.Warning('Can\'t find ${e.name} in ${_shaderProgram.name}');
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

  void _configDeviceState(Map props) {

    dynamic o;

    o = props['shaderProgram'];
    if (o != null && o is ShaderProgram) {
      _shaderProgram = o;
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

  DepthState(String name, GraphicsDevice device) : super._internal(name, device) {
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
  void _configDeviceState(Map props) {
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

  StencilState(String name, GraphicsDevice device) : super._internal(name, device) {

  }

  void _createDeviceState() {

  }

  void _configDeviceState(Map props) {

  }

  void _destroyDeviceState() {

  }
}


class SpectreShader extends DeviceChild {
  String _source;
  WebGLShader _shader;
  int _type;

  SpectreShader(String name, GraphicsDevice device) :
      super._internal(name, device) {
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


  void _configDeviceState(Map props) {
  }

  void _destroyDeviceState() {
    device.gl.deleteShader(_shader);
  }
}

/// A vertex shader
/// Create using [Device.createVertexShader]
/// Must be linked into a ShaderProgram before use
class VertexShader extends SpectreShader {
  VertexShader(String name, GraphicsDevice device) : super(name, device) {
    _type = WebGLRenderingContext.VERTEX_SHADER;
  }


  void _createDeviceState() {
    super._createDeviceState();
  }


  void _configDeviceState(Map props) {
   super._configDeviceState(props);
  }

  void _destroyDeviceState() {
    super._destroyDeviceState();
  }
}

/// A fragment shader
/// Create using [Device.createFragmentShader]
/// Must be linked into a ShaderProgram before use
class FragmentShader extends SpectreShader {
  FragmentShader(String name, GraphicsDevice device) : super(name, device) {
    _type = WebGLRenderingContext.FRAGMENT_SHADER;
  }

  void _createDeviceState() {
    super._createDeviceState();
  }


  void _configDeviceState(Map props) {
   super._configDeviceState(props);
  }

  void _destroyDeviceState() {
    super._destroyDeviceState();
  }
}

/** A shader program attribute input */
class ShaderProgramAttribute {
  final String name;
  final int index;
  final String type;
  final int size;
  final location;
  ShaderProgramAttribute(this.name, this.index, this.type, this.size,
                         this.location);
}

/** A shader program uniform input */
class ShaderProgramUniform {
  final String name;
  final int index;
  final String type;
  final int size;
  final location;
  ShaderProgramUniform(this.name, this.index, this.type, this.size,
                       this.location);
}

/** A shader program sampler input */
class ShaderProgramSampler {
  final String name;
  final int index;
  final String type;
  final int size;
  final location;
  int textureUnit = 0;
  ShaderProgramSampler(this.name, this.index, this.type, this.size,
      this.location);
}

typedef void AttributeCallback(ShaderProgramAttribute attribute);
typedef void UniformCallback(ShaderProgramUniform uniform);
typedef void SamplerCallback(ShaderProgramSampler sampler);

/** A shader program specifies the behaviour of the programmable GPU pipeline.
 * You can create an instance by calling [Graphicsdevice.createShaderProgram].
 * You can apply a shader program to the GPU pipeline with
 * [ImmediateContext.setShaderProgram].
 */
class ShaderProgram extends DeviceChild {
  final Map<String, ShaderProgramUniform> uniforms =
      new Map<String, ShaderProgramUniform>();
  final Map<String, ShaderProgramAttribute> attributes =
      new Map<String, ShaderProgramAttribute>();
  final Map<String, ShaderProgramSampler> samplers =
      new Map<String, ShaderProgramSampler>();

  bool _isLinked = false;
  String _linkLog = '';

  VertexShader vertexShader;
  FragmentShader fragmentShader;
  WebGLProgram _program;

  ShaderProgram(String name, GraphicsDevice device) :
    super._internal(name, device) {
  }

  void _createDeviceState() {
    _program = device.gl.createProgram();
  }

  void _configDeviceState(Map props) {
    if (props != null) {
      dynamic o;
      o = props['VertexProgram'];
      if (o != null && o is VertexShader) {
        detach(vertexShader);
        vertexShader = o;
        attach(vertexShader);
      }
      o = props['FragmentProgram'];
      if (o != null && o is FragmentShader) {
        detach(fragmentShader);
        fragmentShader = o;
        attach(fragmentShader);
      }
      if (vertexShader != null && fragmentShader != null) {
        // relink
        link();
      }
    }
  }

  void _destroyDeviceState() {
    fragmentShader = null;
    vertexShader = null;
    device.gl.deleteProgram(_program);
  }

  /** Detach [shader] from ShaderProgram. */
  void detach(SpectreShader shader) {
    if (shader != null) {
      device.gl.detachShader(_program, shader._shader);
    }
  }

  /** Attach [shader] from ShaderProgram. See also: [link] */
  void attach(SpectreShader shader) {
    if (shader != null) {
      device.gl.attachShader(_program, shader._shader);
    }
  }

  /**
   * Link attached shaders together forming a shader program.
   */
  void link() {
    // Attempt the link.
    device.gl.linkProgram(_program);
    // Grab the log.
    _linkLog = device.gl.getProgramInfoLog(_program);
    // Update the flag.
    _isLinked = device.gl.getProgramParameter(
        _program,
        WebGLRenderingContext.LINK_STATUS);
    if (_linkLog == '') {
      spectreLog.Info('ShaderProgram.Link($name): OKAY.');
    } else {
      spectreLog.Info('''ShaderProgram.Link($name):
$_linkLog''');
    }

    refreshUniforms();
    refreshAttributes();
    logUniforms();
    logSamplers();
    logAttributes();
  }

  bool _isUniformType(int type) {
    return type == WebGLRenderingContext.FLOAT ||
           type == WebGLRenderingContext.FLOAT_VEC2 ||
           type == WebGLRenderingContext.FLOAT_VEC3 ||
           type == WebGLRenderingContext.FLOAT_VEC4 ||
           type == WebGLRenderingContext.FLOAT_MAT2 ||
           type == WebGLRenderingContext.FLOAT_MAT3 ||
           type == WebGLRenderingContext.FLOAT_MAT4 ||
           type == WebGLRenderingContext.BOOL ||
           type == WebGLRenderingContext.BOOL_VEC2 ||
           type == WebGLRenderingContext.BOOL_VEC3 ||
           type == WebGLRenderingContext.BOOL_VEC4 ||
           type == WebGLRenderingContext.INT ||
           type == WebGLRenderingContext.INT_VEC2 ||
           type == WebGLRenderingContext.INT_VEC3 ||
           type == WebGLRenderingContext.INT_VEC4;
  }

  bool _isSamplerType(int type) {
    return type == WebGLRenderingContext.SAMPLER_2D ||
           type == WebGLRenderingContext.SAMPLER_CUBE;
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
      case WebGLRenderingContext.SAMPLER_CUBE:
        return 'samplerCube';
      default:
        return 'unknown code: $type';
    }
  }

  /** Is the shader program linked? */
  bool get linked => _isLinked;

  /** Output from most recent linking. Can be [null] */
  String get linkLog => _linkLog;

  void refreshUniforms() {
    var numUniforms = device.gl.getProgramParameter(
        _program,
        WebGLRenderingContext.ACTIVE_UNIFORMS);
    uniforms.clear();
    samplers.clear();
    int numSamplers = 0;
    for (int i = 0; i < numUniforms; i++) {
      WebGLActiveInfo activeUniform = device.gl.getActiveUniform(_program, i);
      var location = device.gl.getUniformLocation(_program, activeUniform.name);
      if (_isSamplerType(activeUniform.type)) {
        ShaderProgramSampler sampler = new ShaderProgramSampler(
            activeUniform.name,
            i,
            _convertType(activeUniform.type),
            activeUniform.size,
            location);
        samplers[activeUniform.name] = sampler;
        sampler.textureUnit = numSamplers;
        device.gl.uniform1i(location, numSamplers++);
      } else {
        ShaderProgramUniform uniform = new ShaderProgramUniform(
            activeUniform.name,
            i,
            _convertType(activeUniform.type),
            activeUniform.size,
            location);
        uniforms[activeUniform.name] = uniform;
      }
    }
  }

  void refreshAttributes() {
    var numAttributes = device.gl.getProgramParameter(
        _program,
        WebGLRenderingContext.ACTIVE_ATTRIBUTES);
    attributes.clear();
    for (int i = 0; i < numAttributes; i++) {
      WebGLActiveInfo activeAttribute = device.gl.getActiveAttrib(_program, i);
      var location = device.gl.getAttribLocation(_program,
                                                 activeAttribute.name);
      ShaderProgramAttribute attribute = new ShaderProgramAttribute(
          activeAttribute.name,
          i,
          _convertType(activeAttribute.type),
          activeAttribute.size,
          location);
      attributes[activeAttribute.name] = attribute;
    }
  }

  /** Output each uniform variable input to the log. */
  void logUniforms() {
    forEachUniform((uniform) {
      spectreLog.Info('Uniforms[${uniform.index}] ${uniform.type}'
                      ' ${uniform.name} (${uniform.size})');
    });
  }

  /** Output each sampler input to the log. */
  void logSamplers() {
    forEachSampler((sampler) {
      spectreLog.Info('Sampler[${sampler.index}] ${sampler.type}'
                      ' ${sampler.name} (${sampler})');
    });
  }

  /** Output each attribute input to the log. */
  void logAttributes() {
    forEachAttribute((attribute) {
      spectreLog.Info('Attributes[${attribute.index}] ${attribute.type}'
                      ' ${attribute.name} (${attribute.size})');
    });
  }


  /**
   * Iterate over all active uniform inputs and call [callback] for each one.
   *
   * See [UniformCallback].
   */
  void forEachUniform(UniformCallback callback) {
    uniforms.forEach((_, uniform) {
      callback(uniform);
    });
  }

  /**
   * Iteraete over all active sampler inputs and call [callback] for each one.
   *
   * See [SamplerCallback].
   */
  void forEachSampler(SamplerCallback callback) {
    samplers.forEach((_, sampler) {
      callback(sampler);
    });
  }

  /**
   * Iterate over all active attribute inputs and call [callback] for each one.
   *
   * See [AttributeCallback].
   */
  void forEachAttribute(AttributeCallback callback) {
    attributes.forEach((_, attribute) {
      callback(attribute);
    });
  }
}

class RenderBuffer extends DeviceChild {
  int _target;
  int _width;
  int _height;
  int _format;
  WebGLRenderbuffer _buffer;

  RenderBuffer(String name, GraphicsDevice device) : super._internal(name, device) {

  }

  void _createDeviceState() {
    _buffer = device.gl.createRenderbuffer();
  }

  void _destroyDeviceState() {
    device.gl.deleteRenderbuffer(_buffer);
  }

  void _configDeviceState(Map props) {
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
  static final int FormatR = WebGLRenderingContext.RED;
  static final int FormatRG = WebGLRenderingContext.RG;
  static final int FormatRGB = WebGLRenderingContext.RGB;
  static final int FormatRGBA = WebGLRenderingContext.RGBA;
  static final int FormatDepth = WebGLRenderingContext.DEPTH_COMPONENT;

  static final int PixelTypeU8 = WebGLRenderingContext.UNSIGNED_BYTE;
  static final int PixelTypeU16 = WebGLRenderingContext.UNSIGNED_SHORT;
  static final int PixelTypeU32 = WebGLRenderingContext.UNSIGNED_INT;
  static final int PixelTypeS8 = WebGLRenderingContext.BYTE;
  static final int PixelTypeS16 = WebGLRenderingContext.SHORT;
  static final int PixelTypeS32 = WebGLRenderingContext.INT;
  static final int PixelTypeFloat = WebGLRenderingContext.FLOAT;

  int _width;
  int _height;
  int _textureFormat;
  int _pixelFormat;
  int _pixelType;

  int _target;
  int _target_param;
  WebGLTexture _buffer;

  Texture(String name, GraphicsDevice device) : super._internal(name, device);

  void _createDeviceState() {
    _buffer = device.gl.createTexture();
  }

  void _configDeviceState(Map props) {

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
    _textureFormat = Texture.FormatRGBA;
    _pixelFormat = Texture.FormatRGBA;
    _pixelType = Texture.PixelTypeU8;
  }

  void _createDeviceState() {
    super._createDeviceState();
  }

  void _configDeviceState(Map props) {
    super._configDeviceState(props);

    if (props != null && props['pixels'] != null) {
      var pixels = props['pixels'];
      uploadPixelData(pixels);
    } else {
      if (props != null) {
        _width = props['width'] != null ? props['width'] : _width;
        _height = props['height'] != null ? props['height'] : _height;
        _textureFormat = props['textureFormat'] != null ?
            props['textureFormat'] : _textureFormat;
        _pixelFormat = props['pixelFormat'] != null ?
            props['pixelFormat'] : _pixelFormat;
        _pixelType = props['pixelType'] != null ?
            props['pixelType'] : _pixelType;
      }
      // TODO(johnmccutchan): Kill this hack.
      // TODO(johnmccutchan): Support texture properties.
      device.gl.pixelStorei(WebGLRenderingContext.UNPACK_FLIP_Y_WEBGL, 1);
      allocatePixelSpace(_width, _height);
    }
  }

  void allocatePixelSpace(int width, int height, [int level=0]) {
    _width = width;
    _height = height;
    WebGLTexture oldBind = device.gl.getParameter(_target_param);
    device.gl.bindTexture(_target, _buffer);
    device.gl.texImage2D(_target, level, _textureFormat, _width, _height,
                         0, _pixelFormat, _pixelType, null);
    device.gl.bindTexture(_target, oldBind);
  }

  void uploadPixelData(dynamic pixels, [int level=0]) {
    WebGLTexture oldBind = device.gl.getParameter(_target_param);
    device.gl.bindTexture(_target, _buffer);
    device.gl.texImage2D(_target, level, _textureFormat, _pixelFormat,
                         _pixelType, pixels);
    // TODO(johmccutchan): Update _width and _height based on pixels.
    device.gl.bindTexture(_target, oldBind);
  }

  void _destroyDeviceState() {
    super._destroyDeviceState();
  }
}

class RenderTarget extends DeviceChild {
  WebGLFramebuffer _buffer;
  int _target;
  int _target_param;
  DeviceChild _colorTarget;
  DeviceChild _depthTarget;
  DeviceChild get colorTarget => _colorTarget;
  DeviceChild get depthTarget => _depthTarget;
  DeviceChild get stencilTarget => null;

  RenderTarget(String name, GraphicsDevice device) : super._internal(name, device) {
    _target = WebGLRenderingContext.FRAMEBUFFER;
    _target_param = WebGLRenderingContext.FRAMEBUFFER_BINDING;
  }

  void _createDeviceState() {
    super._createDeviceState();
    _buffer = device.gl.createFramebuffer();
  }

  void _configDeviceState(Map props) {
    if (props == null) {
      return;
    }
    if (props['SystemProvided'] == true) {
      device.gl.deleteFramebuffer(_buffer);
      _buffer = null;
      return;
    }
    DeviceChild colorHandle = props['color0'] != null ? props['color0'] : null;
    DeviceChild depthHandle = props['depth'] != null ? props['depth'] : null;
    DeviceChild stencilHandle = props['stencil'] != null ? props['stencil'] : null;
    if (stencilHandle != null) {
      spectreLog.Error('No support for stencil buffers yet.');
    }

    attachColorTarget(colorHandle);
    attachDepthTarget(depthHandle);

    WebGLFramebuffer oldBind = device.gl.getParameter(_target_param);
    device.gl.bindFramebuffer(_target, _buffer);
    int fbStatus = device.gl.checkFramebufferStatus(_target);
    if (fbStatus != WebGLRenderingContext.FRAMEBUFFER_COMPLETE) {
      spectreLog.Error('RenderTarget $name incomplete status = $fbStatus');
    } else {
      spectreLog.Info('RenderTarget $name complete.');
    }
    device.gl.bindFramebuffer(WebGLRenderingContext.FRAMEBUFFER, oldBind);
  }

  void attachColorTarget(dynamic colorTexture) {
    WebGLFramebuffer oldBind = device.gl.getParameter(_target_param);
    device.gl.bindFramebuffer(_target, _buffer);
    if (colorTexture == null) {
      _colorTarget = null;
      device.gl.framebufferRenderbuffer(_target,
                                        WebGLRenderingContext.COLOR_ATTACHMENT0,
                                        WebGLRenderingContext.RENDERBUFFER,
                                        null);
      device.gl.bindFramebuffer(WebGLRenderingContext.FRAMEBUFFER, oldBind);
      return;
    }
    if (colorTexture is RenderBuffer) {
      RenderBuffer rb = colorTexture as RenderBuffer;
      _colorTarget = rb;
      device.gl.framebufferRenderbuffer(_target,
                                        WebGLRenderingContext.COLOR_ATTACHMENT0,
                                        WebGLRenderingContext.RENDERBUFFER,
                                        rb._buffer);
    } else if (colorTexture is Texture2D) {
      Texture2D t2d = colorTexture as Texture2D;
      _colorTarget = t2d;
      device.gl.framebufferTexture2D(_target,
                                     WebGLRenderingContext.COLOR_ATTACHMENT0,
                                     WebGLRenderingContext.TEXTURE_2D,
                                     t2d._buffer, 0);
    } else {
      spectreLog.Error('attachColorTarget invalid target type.');
      assert(false);
    }
    device.gl.bindFramebuffer(WebGLRenderingContext.FRAMEBUFFER, oldBind);
  }

  void attachDepthTarget(dynamic depthTexture) {
    WebGLFramebuffer oldBind = device.gl.getParameter(_target_param);
    device.gl.bindFramebuffer(_target, _buffer);
    if (depthTexture == null) {
      _depthTarget = null;
      device.gl.framebufferRenderbuffer(_target,
                                        WebGLRenderingContext.DEPTH_ATTACHMENT,
                                        WebGLRenderingContext.RENDERBUFFER,
                                        null);
      device.gl.bindFramebuffer(WebGLRenderingContext.FRAMEBUFFER, oldBind);
      return;
    }
    if (depthTexture is RenderBuffer) {
      RenderBuffer rb = depthTexture as RenderBuffer;
      _depthTarget = rb;
      device.gl.framebufferRenderbuffer(_target,
                                        WebGLRenderingContext.DEPTH_ATTACHMENT,
                                        WebGLRenderingContext.RENDERBUFFER,
                                        rb._buffer);
    } else if (depthTexture is Texture2D) {
      Texture2D t2d = depthTexture as Texture2D;
      _depthTarget = t2d;
      device.gl.framebufferTexture2D(_target,
                                     WebGLRenderingContext.DEPTH_ATTACHMENT,
                                     WebGLRenderingContext.TEXTURE_2D,
                                     t2d._buffer, 0);
    } else {
      spectreLog.Error('attachDepthTarget invalid target type.');
      assert(false);
    }
    device.gl.bindFramebuffer(WebGLRenderingContext.FRAMEBUFFER, oldBind);
  }

  void _destroyDeviceState() {
    if (_buffer != null) {
      device.gl.deleteFramebuffer(_buffer);
    }
    super._destroyDeviceState();
  }
}

class SpectreBuffer extends DeviceChild {
  WebGLBuffer _buffer;
  int _target;
  int _param_target;
  int _usage;

  SpectreBuffer(String name, GraphicsDevice device) : super._internal(name, device) {
    _buffer = null;
  }

  void _createDeviceState() {
    super._createDeviceState();
    _buffer = device.gl.createBuffer();
    _usage = WebGLRenderingContext.DYNAMIC_DRAW;
  }

  void _configDeviceState(Map props) {
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

  void _configDeviceState(Map props) {
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

  void _configDeviceState(Map props) {
    super._configDeviceState(props);

  }

  void _destroyDeviceState() {
    super._destroyDeviceState();
  }
}

class IndexedMesh extends DeviceChild {
  VertexBuffer vertexArray;
  IndexBuffer indexArray;
  int numIndices;
  int indexOffset;

  IndexedMesh(String name, GraphicsDevice device) : super._internal(name, device) {
    numIndices = 0;
    indexOffset = 0;
  }

  void _createDeviceState() {
    super._createDeviceState();
    vertexArray = device.createVertexBuffer('${name}.array', {});
    indexArray = device.createIndexBuffer('${name}.index', {});
  }

  void _configDeviceState(Map props) {
    super._configDeviceState(props);
    if (props != null) {
      dynamic o;

      o = props['UpdateFromMeshResource'];
      if (o != null && o is Map) {
        ResourceManager rm = o['resourceManager'];
        MeshResource mesh = o['meshResourceHandle'];
        if (mesh != null) {
          device.context.updateBuffer(vertexArray, mesh.vertexArray, WebGLRenderingContext.STATIC_DRAW);
          device.context.updateBuffer(indexArray, mesh.indexArray, WebGLRenderingContext.STATIC_DRAW);
          indexOffset = 0;
          numIndices = mesh.numIndices;
        }
      }

      o = props['UpdateFromMeshMap'];
      if (o != null && o is Map) {
        Map mesh = o['meshes'][0];
        if (o != null && o is Map) {
          var indices = new Uint16Array.fromList(mesh['indices']);
          device.context.updateBuffer(vertexArray, new Float32Array.fromList(mesh['vertices']), WebGLRenderingContext.STATIC_DRAW);
          device.context.updateBuffer(indexArray, indices, WebGLRenderingContext.STATIC_DRAW);
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
    device.deleteDeviceChild(indexArray);
    device.deleteDeviceChild(vertexArray);
    super._destroyDeviceState();
  }
}

class ArrayMesh extends DeviceChild {
  VertexBuffer vertexArray;
  int numVertices;
  int vertexOffset;

  ArrayMesh(String name, GraphicsDevice device) : super._internal(name, device) {
    numVertices = 0;
    vertexOffset = 0;
  }

  void _createDeviceState() {
    super._createDeviceState();
    vertexArray = device.createVertexBuffer('${name}.array', {});
  }

  void _configDeviceState(Map props) {
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
    device.deleteDeviceChild(vertexArray);
    super._destroyDeviceState();
  }
}
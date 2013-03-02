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

/** A shader program uniform input */
class ShaderProgramUniform {
  final String name;
  final int index;
  final String type;
  final int size;
  final location;
  final UniformSetFunction _apply;
  ShaderProgramUniform(this.name, this.index, this.type, this.size,
                       this.location, this._apply);
}

/** A shader program sampler input */
class ShaderProgramSampler {
  final String name;
  final int index;
  final String type;
  final int size;
  final location;
  int _textureUnit = 0;
  int get textureUnit => _textureUnit;
  ShaderProgramSampler(this.name, this.index, this.type, this.size,
      this.location);
}

/** A shader program attribute input */
class ShaderProgramAttribute {
  final String name;
  final int index;
  final String type;
  final int size;
  int _location;
  int get location => _location;
  ShaderProgramAttribute(this.name, this.index, this.type, this.size,
                         this._location);
}

typedef void AttributeCallback(ShaderProgramAttribute attribute);
typedef void UniformCallback(ShaderProgramUniform uniform);
typedef void SamplerCallback(ShaderProgramSampler sampler);

typedef UniformSetFunction(device, location, argument);

/** A shader program specifies the behaviour of the programmable GPU pipeline.
 * You can create an instance by calling [Graphicsdevice.createShaderProgram].
 * You can apply a shader program to the GPU pipeline with
 * [ImmediateContext.setShaderProgram].
 *
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

  VertexShader _vertexShader;
  VertexShader get vertexShader => _vertexShader;
  set vertexShader(VertexShader vs) {
    if (_vertexShader != null) {
      _detach(_vertexShader);
    }
    _vertexShader = vs;
    _attach(_vertexShader);
  }
  FragmentShader _fragmentShader;
  FragmentShader get fragmentShader => _fragmentShader;
  set fragmentShader(FragmentShader fs) {
    if (_fragmentShader != null) {
      _detach(_fragmentShader);
    }
    _fragmentShader = fs;
    _attach(_fragmentShader);
  }
  WebGLProgram _program;

  ShaderProgram(String name, GraphicsDevice device) :
    super._internal(name, device) {
    _program = device.gl.createProgram();
  }

  void finalize() {
    super.finalize();
    fragmentShader = null;
    vertexShader = null;
    device.gl.deleteProgram(_program);
    _program = null;
  }

  /** Detach [shader] from ShaderProgram. */
  void _detach(SpectreShader shader) {
    if (shader != null) {
      device.gl.detachShader(_program, shader._shader);
    }
  }

  /** Attach [shader] from ShaderProgram. See also: [link] */
  void _attach(SpectreShader shader) {
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
        throw new FallThroughError();
    }
  }

  UniformSetFunction _findUniformSetForType(int type) {
    switch (type) {
      case WebGLRenderingContext.FLOAT:
        return _setUniform1f;
      case WebGLRenderingContext.FLOAT_VEC2:
        return _setUniform2f;
      case WebGLRenderingContext.FLOAT_VEC3:
        return _setUniform3f;
      case WebGLRenderingContext.FLOAT_VEC4:
        return _setUniform4f;
      case WebGLRenderingContext.FLOAT_MAT2:
        return _setUniformMatrix2;
      case WebGLRenderingContext.FLOAT_MAT3:
        return _setUniformMatrix3;
      case WebGLRenderingContext.FLOAT_MAT4:
        return _setUniformMatrix4;
      case WebGLRenderingContext.BOOL:
        return _setUniform1i;
      case WebGLRenderingContext.BOOL_VEC2:
        return _setUniform2i;
      case WebGLRenderingContext.BOOL_VEC3:
        return _setUniform3i;
      case WebGLRenderingContext.BOOL_VEC4:
        return _setUniform4i;
      case WebGLRenderingContext.INT:
        return _setUniform1i;
      case WebGLRenderingContext.INT_VEC2:
        return _setUniform2i;
      case WebGLRenderingContext.INT_VEC3:
        return _setUniform3i;
      case WebGLRenderingContext.INT_VEC4:
        return _setUniform4i;
      default:
        throw new FallThroughError();
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
    if (numUniforms == null) {
      return;
    }
    int numSamplers = 0;
    var oldBind = device.gl.getParameter(WebGLRenderingContext.CURRENT_PROGRAM);
    device.gl.useProgram(_program);
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
        sampler._textureUnit = numSamplers;
        device.gl.uniform1i(location, numSamplers++);
      } else {
        ShaderProgramUniform uniform = new ShaderProgramUniform(
            activeUniform.name,
            i,
            _convertType(activeUniform.type),
            activeUniform.size,
            location,
            _findUniformSetForType(activeUniform.type));
        uniforms[activeUniform.name] = uniform;
      }
    }
    device.gl.useProgram(oldBind);
  }

  void refreshAttributes() {
    var numAttributes = device.gl.getProgramParameter(
        _program,
        WebGLRenderingContext.ACTIVE_ATTRIBUTES);
    attributes.clear();
    if (numAttributes == null) {
      return;
    }
    var oldBind = device.gl.getParameter(WebGLRenderingContext.CURRENT_PROGRAM);
    device.gl.useProgram(_program);
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
    device.gl.useProgram(oldBind);
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

  dynamic _findUniform(String name) {
    ShaderProgramUniform uniform = uniforms[name];
    if (uniform == null) {
      return null;
    }
    return uniform.location;
  }

  void _setUniform1f(GraphicsDevice device, var index, var argument) {
    if (argument is Float32Array) {
      device.gl.uniform1fv(index, argument);
      return;
    } else if (argument is List<num>) {
      device.gl.uniform1f(index, argument[0]);
      return;
    } else if (argument is num) {
      device.gl.uniform1f(index, argument);
      return;
    }
    throw new FallThroughError();
  }

  void _setUniform2f(GraphicsDevice device, var index, var argument) {
    if (argument is Float32Array) {
      device.gl.uniform2fv(index, argument);
      return;
    } else if (argument is List<num>) {
      device.gl.uniform2f(index, argument[0], argument[1]);
      return;
    }
    throw new FallThroughError();
  }

  void _setUniform3f(GraphicsDevice device, var index, var argument) {
    if (argument is Float32Array) {
      device.gl.uniform3fv(index, argument);
      return;
    } else if (argument is List<num>) {
      device.gl.uniform3f(index, argument[0], argument[1], argument[2]);
      return;
    }
    throw new FallThroughError();
  }

  void _setUniform4f(GraphicsDevice device, var index, var argument) {
    if (argument is Float32Array) {
      device.gl.uniform4fv(index, argument);
      return;
    } else if (argument is List<num>) {
      device.gl.uniform4f(index, argument[0], argument[1], argument[2],
                          argument[3]);
      return;
    }
    throw new FallThroughError();
  }

  void _setUniform1i(GraphicsDevice device, var index, var argument) {
    if (argument is Int32Array) {
      device.gl.uniform1iv(index, argument);
      return;
    } else if (argument is List<num>) {
      device.gl.uniform1i(index, argument[0]);
      return;
    } else if (argument is num) {
      device.gl.uniform1i(index, argument);
      return;
    }
    throw new FallThroughError();
  }

  void _setUniform2i(GraphicsDevice device, var index, var argument) {
    if (argument is Int32Array) {
      device.gl.uniform2iv(index, argument);
      return;
    } else if (argument is List<num>) {
      device.gl.uniform2i(index, argument[0], argument[1]);
      return;
    }
    throw new FallThroughError();
  }

  void _setUniform3i(GraphicsDevice device, var index, var argument) {
    if (argument is Int32Array) {
      device.gl.uniform3iv(index, argument);
      return;
    } else if (argument is List<num>) {
      device.gl.uniform3i(index, argument[0], argument[1], argument[2]);
      return;
    }
    throw new FallThroughError();
  }

  void _setUniform4i(GraphicsDevice device, var index, var argument) {
    if (argument is Int32Array) {
      device.gl.uniform4iv(index, argument);
      return;
    } else if (argument is List<num>) {
      device.gl.uniform4i(index, argument[0], argument[1], argument[2],
                          argument[3]);
      return;
    }
    throw new FallThroughError();
  }

  void _setUniformMatrix2(GraphicsDevice device, var index, var argument) {
    if (argument is Float32Array) {
      device.gl.uniformMatrix2fv(index, false, argument);
      return;
    }
    throw new FallThroughError();
  }

  void _setUniformMatrix3(GraphicsDevice device, var index, var argument) {
    if (argument is Float32Array) {
      device.gl.uniformMatrix3fv(index, false, argument);
      return;
    }
    throw new FallThroughError();
  }

  void _setUniformMatrix4(GraphicsDevice device, var index, var argument) {
    if (argument is Float32Array) {
      device.gl.uniformMatrix4fv(index, false, argument);
      return;
    }
    throw new FallThroughError();
  }

  /// Set Uniform variable [name] in this [ShaderProgram].
  void setConstant(String name, var argument) {
    var uniform = uniforms[name];
    if (uniform == null) {
      return;
    }
    var oldBind = device.gl.getParameter(WebGLRenderingContext.CURRENT_PROGRAM);
    device.gl.useProgram(_program);
    uniform._apply(device, uniform.location, argument);
    device.gl.useProgram(oldBind);
  }

  void setSamplerUnit(String name, int unit) {
    var sampler = samplers[name];
    if (sampler == null) {
      return;
    }
    // Set
  }
}

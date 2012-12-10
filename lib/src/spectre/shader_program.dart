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

  dynamic _findUniform(String name) {
    ShaderProgramUniform uniform = uniforms[name];
    if (uniform == null) {
      return null;
    }
    return uniform.location;
  }

  void _setUniform2f(var index, num v0, num v1) {
    device.gl.uniform2f(index,v0, v1);
  }

  /// Set Uniform variable [name] in this [ShaderProgram].
  void setUniform2f(String name, num v0, num v1) {
    var index = _findUniform(name);
    if (index == null) {
      return;
    }
    var oldBind = device.gl.getParameter(WebGLRenderingContext.CURRENT_PROGRAM);
    device.gl.useProgram(_program);
    _setUniform2(index, v0, v1);
    device.gl.useProgram(oldBind);
  }

  void _setUniform3f(var index, num v0, num v1, num v2) {
    device.gl.uniform3f(index,v0, v1, v2);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniform3f(String name, num v0, num v1, num v2) {
    var index = _findUniform(name);
    if (index == null) {
      return;
    }
    var oldBind = device.gl.getParameter(WebGLRenderingContext.CURRENT_PROGRAM);
    device.gl.useProgram(_program);
    _setUniform3f(index, v0, v1, v2);
    device.gl.useProgram(oldBind);
  }

  void _setUniform4f(var index, num v0, num v1, num v2, num v3) {
    device.gl.uniform4f(index,v0, v1, v2, v3);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniform4f(String name, num v0, num v1, num v2, num v3) {
    var index = _findUniform(name);
    if (index == null) {
      return;
    }
    var oldBind = device.gl.getParameter(WebGLRenderingContext.CURRENT_PROGRAM);
    device.gl.useProgram(_program);
    _setUniform4f(index, v0, v1, v2, v3);
    device.gl.useProgram(oldBind);
  }

  void _setUniformInt(var index, int i) {
    device.gl.uniform1i(index, i);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniformInt(String name, int i) {
    var index = _findUniform(name);
    if (index == null) {
      return;
    }
    var oldBind = device.gl.getParameter(WebGLRenderingContext.CURRENT_PROGRAM);
    device.gl.useProgram(_program);
    _setUniformInt(index, i);
    device.gl.useProgram(oldBind);
  }

  void _setUniformNum(var index, num i) {
    device.gl.uniform1f(index, i);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniformNum(String name, num i) {
    var index = _findUniform(name);
    if (index == null) {
      return;
    }
    var oldBind = device.gl.getParameter(WebGLRenderingContext.CURRENT_PROGRAM);
    device.gl.useProgram(_program);
    _setUniformNum(index, i);
    device.gl.useProgram(oldBind);
  }

  void _setUniformMatrix2(var idnex, Float32Array matrix, bool transpose) {
    _device.gl.uniformMatrix2fv(index, transpose, matrix);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniformMatrix2(String name, Float32Array matrix,
                         [bool transpose=false]) {
    var index = _findUniform(name);
    if (index == null) {
      return;
    }
    var oldBind = device.gl.getParameter(WebGLRenderingContext.CURRENT_PROGRAM);
    device.gl.useProgram(_program);
    _setUniformMatrix2(index, vector);
    device.gl.useProgram(oldBind);
  }

  void _setUniformMatrix3(var index, Float32Array matrix, bool transpose) {
    _device.gl.uniformMatrix3fv(index, transpose, matrix);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniformMatrix3(String name, Float32Array matrix,
                         [bool transpose=false]) {
    var index = _findUniform(name);
    if (index == null) {
      return;
    }
    var oldBind = device.gl.getParameter(WebGLRenderingContext.CURRENT_PROGRAM);
    device.gl.useProgram(_program);
    _setUniformMatrix3(index, vector);
    devicegl.useProgram(oldBind);
  }

  void _setUniformMatrix4(var index, Float32Array matrix, bool transpose) {
    device.gl.uniformMatrix4fv(index, transpose, matrix);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniformMatrix4(String name, Float32Array matrix, [bool transpose=false]) {
    var index = _findUniform(name);
    if (index == null) {
      return;
    }
    var oldBind = device.gl.getParameter(WebGLRenderingContext.CURRENT_PROGRAM);
    device.gl.useProgram(_program);
    _setUniformMatrix4(index, vector);
    device.gl.useProgram(oldBind);
  }

  void _setUniformVector2(var index, Float32Array vector) {
    device.gl.uniform2fv(index, vector);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniformVector2(String name, Float32Array vector) {
    var index = _findUniform(name);
    if (index == null) {
      return;
    }
    var oldBind = device.gl.getParameter(WebGLRenderingContext.CURRENT_PROGRAM);
    device.gl.useProgram(_program);
    _setUniformVector2(index, vector);
    device.gl.useProgram(oldBind);
  }

  void _setUniformVector3(var index, Float32Array vector) {
    device.gl.uniform3fv(index, vector);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniformVector3(String name, Float32Array vector) {
    var index = _findUniform(name);
    if (index == null) {
      return;
    }
    var oldBind = device.gl.getParameter(WebGLRenderingContext.CURRENT_PROGRAM);
    device.gl.useProgram(_program);
    _setUniformVector3(index, vector);
    device.gl.useProgram(oldBind);
  }

  void _setUniformVector4(var index, Float32Array vector) {
    device.gl.uniform4fv(index, vector);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniformVector4(String name, Float32Array vector) {
    var index = _findUniform(name);
    if (index == null) {
      return;
    }
    var oldBind = device.gl.getParameter(WebGLRenderingContext.CURRENT_PROGRAM);
    device.gl.useProgram(_program);
    _setUniformVector4(index, vector);
    device.gl.useProgram(oldBind);
  }
}

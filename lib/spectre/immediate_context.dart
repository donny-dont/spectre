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

/** The [ImmediateContext] configures the GPU pipeline and executes draw commands */
class ImmediateContext {
  static final int PrimitiveTopologyTriangles = WebGLRenderingContext.TRIANGLES;
  static final int PrimitiveTopologyLines = WebGLRenderingContext.LINES;
  static final int PrimitiveTopologyPoints = WebGLRenderingContext.POINTS;
  static final int numVertexBuffers = 2;
  static final int numTextures = 3;

  Device _device;
  // Input Assembler
  int _primitiveTopology;
  int _indexBufferHandle;
  List<int> _vertexBufferHandles;
  List<int> _enabledVertexAttributeArrays;
  int _inputLayoutHandle;
  int _preparedInputLayoutHandle;
  // VS and PS stages
  int _shaderProgramHandle;
  List<int> _samplerStateHandles;
  List<int> _textureHandles;
  // Rasterizer
  int _rasterizerStateHandle;
  int _viewportHandle;
  // Output-Merger
  int _blendStateHandle;
  int _depthStateHandle;
  int _stencilStateHandle;
  int _renderTargetHandle;

  void _PrepareTextures() {
  }

  void _logVertexAttributes(int index) {
    var enabled = _device.gl.getVertexAttrib(index, WebGLRenderingContext.VERTEX_ATTRIB_ARRAY_ENABLED);
    var size = _device.gl.getVertexAttrib(index, WebGLRenderingContext.VERTEX_ATTRIB_ARRAY_SIZE);
    var stride = _device.gl.getVertexAttrib(index, WebGLRenderingContext.VERTEX_ATTRIB_ARRAY_STRIDE);
    var type = _device.gl.getVertexAttrib(index, WebGLRenderingContext.VERTEX_ATTRIB_ARRAY_TYPE);
    var normalized = _device.gl.getVertexAttrib(index, WebGLRenderingContext.VERTEX_ATTRIB_ARRAY_NORMALIZED);
    var binding = _device.gl.getVertexAttrib(index, WebGLRenderingContext.VERTEX_ATTRIB_ARRAY_BUFFER_BINDING);
    spectreLog.Info('Vertex Attribute $index $enabled $size $stride $type $normalized $binding');
  }

  void _prepareInputs([bool debug=false]) {
    if (_inputLayoutHandle == 0) {
      spectreLog.Error('Prepare for draw no input layout');
      return;
    }

    InputLayout inputLayout = _device.getDeviceChild(_inputLayoutHandle);
    if (inputLayout == null) {
      spectreLog.Error('Prepare for draw no input layout.');
      return;
    }

    if (_preparedInputLayoutHandle == _inputLayoutHandle) {
      return;
    }

    _preparedInputLayoutHandle = _inputLayoutHandle;

    // Disable old arrays
    for (int index in _enabledVertexAttributeArrays) {
      if (index == 0) {
        continue;
      }
      _device.gl.disableVertexAttribArray(index);
    }
    _enabledVertexAttributeArrays.clear();

    if (inputLayout._elements == null) {
      return;
    }
    
    for (var element in inputLayout._elements) {
      VertexBuffer vb = _device.getDeviceChild(_vertexBufferHandles[element._vboSlot]);
      if (vb == null) {
        spectreLog.Error('Prepare for draw referenced a null vertex buffer object');
        continue;
      }
      _device.gl.enableVertexAttribArray(element._attributeIndex);
      _device.gl.bindBuffer(vb._target, vb._buffer);
      _device.gl.vertexAttribPointer(element._attributeIndex,
        element._attributeFormat.count,
        element._attributeFormat.type,
        element._attributeFormat.normalized,
        element._attributeStride,
        element._vboOffset);
      // Remember that this was enabled.
      _enabledVertexAttributeArrays.add(element._attributeIndex);
      if (debug)
        _logVertexAttributes(element._attributeIndex);
      //_device.gl.bindBuffer(vb._target, null);

    }
    if (_indexBufferHandle != 0) {
      IndexBuffer indexBuffer = _device.getDeviceChild(_indexBufferHandle);
      _device.gl.bindBuffer(indexBuffer._target, indexBuffer._buffer);
      if (debug) {
        print('Binding index buffer');
      }
    } else {
      _device.gl.bindBuffer(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, null);
      if (debug) {
        print('No index buffer');
      }
    }
  }

  void _prepareTextures() {
    // TODO: Need to unbind unused texture channels
    for (int i = 0; i < numTextures; i++) {
      SamplerState s = _device.getDeviceChild(_samplerStateHandles[i]);
      Texture t = _device.getDeviceChild(_textureHandles[i]);
      if (s == null || t == null) {
        continue;
      }
      _device.gl.activeTexture(WebGLRenderingContext.TEXTURE0 + i);
      _device.gl.bindTexture(t._target, t._buffer);
      _device.gl.texParameteri(t._target, WebGLRenderingContext.TEXTURE_WRAP_S, s._wrapS);
      _device.gl.texParameteri(t._target, WebGLRenderingContext.TEXTURE_WRAP_T, s._wrapT);
      _device.gl.texParameteri(t._target, WebGLRenderingContext.TEXTURE_MIN_FILTER, s._minFilter);
      _device.gl.texParameteri(t._target, WebGLRenderingContext.TEXTURE_MAG_FILTER, s._magFilter);
    }
  }

  ImmediateContext(Device device) {
    _device = device;
    _vertexBufferHandles = new List<int>(numVertexBuffers);
    _samplerStateHandles = new List<int>(numTextures);
    _textureHandles = new List<int>(numTextures);
    _enabledVertexAttributeArrays = new List<int>();
  }

  /// Resets the cached GPU pipeline state
  void reset() {
    // TODO: Update GPU state
    _primitiveTopology = 0;
    for (int index in _enabledVertexAttributeArrays) {
      if (index == 0) {
        continue;
      }
      _device.gl.disableVertexAttribArray(index);
    }
    _preparedInputLayoutHandle = 0;
    _enabledVertexAttributeArrays.clear();
    _indexBufferHandle = 0;
    for (int i = 0; i < numVertexBuffers; i++) {
      _vertexBufferHandles[i] = 0;
    }
    _inputLayoutHandle = 0;
    _shaderProgramHandle = 0;
    for (int i = 0; i < numTextures; i++) {
      _samplerStateHandles[i] = 0;
      _textureHandles[i] = 0;
    }
    _rasterizerStateHandle = 0;
    _viewportHandle = 0;
    _blendStateHandle = 0;
    _depthStateHandle = 0;
    _stencilStateHandle = 0;
    _renderTargetHandle = 0;
  }

  /// Configure the primitive topology
  void setPrimitiveTopology(int topology) {
    _primitiveTopology = topology;
  }

  /// Set the IndexBuffer to [indexBufferHandle]
  void setIndexBuffer(int indexBufferHandle) {
    _indexBufferHandle = indexBufferHandle;
  }

  /// Set multiple VertexBuffers in [vertexBufferHandles] starting at [startSlot]
  void setVertexBuffers(int startSlot, List<int> vertexBufferHandles) {
    int limit = vertexBufferHandles.length + startSlot;
    for (int i = startSlot; i < limit; i++) {
      _vertexBufferHandles[i] = vertexBufferHandles[i-startSlot];
    }
  }

  /// Set InputLayout to [inputLayoutHandle]
  void setInputLayout(int inputLayoutHandle) {
    _inputLayoutHandle = inputLayoutHandle;
  }

  void setIndexedMesh(int indexedMeshHandle) {
    IndexedMesh im = _device.getDeviceChild(indexedMeshHandle);
    if (im == null) {
      return;
    }
    setIndexBuffer(im.indexArrayHandle);
    setVertexBuffers(0, [im.vertexArrayHandle]);
  }

  /// Set ShaderProgram to [shaderProgramHandle]
  void setShaderProgram(int shaderProgramHandle) {
    if (_shaderProgramHandle == shaderProgramHandle) {
      return;
    }
    _shaderProgramHandle = shaderProgramHandle;
    ShaderProgram sp = _device.getDeviceChild(shaderProgramHandle);
    _device.gl.useProgram(sp._program);
  }

  /// Set RasterizerState to [rasterizerStateHandle]
  void setRasterizerState(int rasterizerStateHandle) {
    if (_rasterizerStateHandle == rasterizerStateHandle) {
      return;
    }
    _rasterizerStateHandle = rasterizerStateHandle;
    RasterizerState rs = _device.getDeviceChild(rasterizerStateHandle);
    if (rs == null) {
      return;
    }
    _device.gl.lineWidth(rs.lineWidth);
    if (rs.cullEnabled) {
      _device.gl.enable(WebGLRenderingContext.CULL_FACE);
      _device.gl.cullFace(rs.cullMode);
      _device.gl.frontFace(rs.cullFrontFace);
    } else {
      _device.gl.disable(WebGLRenderingContext.CULL_FACE);
    }
  }

  /// Set Viewport to [viewportHandle]
  void setViewport(int viewportHandle) {
    if (_viewportHandle == viewportHandle) {
      return;
    }
    Viewport vp = _device.getDeviceChild(viewportHandle);
    if (vp == null) {
      return;
    }
    _device.gl.viewport(vp.x, vp.y, vp.width, vp.height);
  }

  /// Set BlendState to [blendStateHandle]
  void setBlendState(int blendStateHandle) {
    if (_blendStateHandle == blendStateHandle) {
      return;
    }
    BlendState bs = _device.getDeviceChild(blendStateHandle);
    if (bs == null) {
      return;
    }
    _device.gl.colorMask(bs.writeRenderTargetRed, bs.writeRenderTargetGreen, bs.writeRenderTargetBlue, bs.writeRenderTargetAlpha);
    if (bs.blendEnable == false) {
      _device.gl.disable(WebGLRenderingContext.BLEND);
      return;
    }
    _device.gl.enable(WebGLRenderingContext.BLEND);
    //_device.gl.blendFunc(bs.blendSourceColorFunc, bs.blendDestColorFunc);
    _device.gl.blendFuncSeparate(bs.blendSourceColorFunc, bs.blendDestColorFunc, bs.blendSourceAlphaFunc, bs.blendDestAlphaFunc);
    _device.gl.blendEquationSeparate(bs.blendColorOp, bs.blendAlphaOp);
    _device.gl.blendColor(bs.blendColorRed, bs.blendColorGreen, bs.blendColorBlue, bs.blendColorAlpha);
  }

  /// Set DepthState to [depthStateHandle]
  void setDepthState(int depthStateHandle) {
    if (_depthStateHandle == depthStateHandle) {
      return;
    }
    DepthState ds = _device.getDeviceChild(depthStateHandle);
    if (ds == null) {
      return;
    }
    _device.gl.depthRange(ds.depthNearVal, ds.depthFarVal);
    if (ds.depthTestEnabled == false) {
      _device.gl.disable(WebGLRenderingContext.DEPTH_TEST);
    } else {
      _device.gl.enable(WebGLRenderingContext.DEPTH_TEST);
      _device.gl.depthFunc(ds.depthComparisonOp);
    }

    _device.gl.depthMask(ds.depthWriteEnabled);

    if (ds.polygonOffsetEnabled == false) {
      _device.gl.disable(WebGLRenderingContext.POLYGON_OFFSET_FILL);
    } else {
      _device.gl.enable(WebGLRenderingContext.POLYGON_OFFSET_FILL);
      _device.gl.polygonOffset(ds.polygonOffsetFactor, ds.polygonOffsetUnits);
    }
  }

  /// Set RenderTarget to [renderTargetHandle]
  void setRenderTarget(int renderTargetHandle) {
    if (_renderTargetHandle == renderTargetHandle) {
      return;
    }
    _renderTargetHandle = renderTargetHandle;
    if (_renderTargetHandle == 0) {
      _device.gl.bindFramebuffer(WebGLRenderingContext.FRAMEBUFFER, null);
    } else {
      RenderTarget rt = _device.getDeviceChild(renderTargetHandle);
      _device.gl.bindFramebuffer(rt._target, rt._buffer);  
    }
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniform2f(String name, num v0, num v1) {
    ShaderProgram sp = _device.getDeviceChild(_shaderProgramHandle);
    if (sp == null) {
      spectreLog.Error('Attempting to set uniform with invalid program bound.');
      return;
    }
    var index = _device.gl.getUniformLocation(sp._program, name);
    if (index == -1) {
      spectreLog.Error('Could not find uniform $name in ${sp.name}');
      return;
    }
    _device.gl.uniform2f(index,v0, v1);
  }
  
  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniform3f(String name, num v0, num v1, num v2) {
    ShaderProgram sp = _device.getDeviceChild(_shaderProgramHandle);
    if (sp == null) {
      spectreLog.Error('Attempting to set uniform with invalid program bound.');
      return;
    }
    var index = _device.gl.getUniformLocation(sp._program, name);
    if (index == -1) {
      spectreLog.Error('Could not find uniform $name in ${sp.name}');
      return;
    }
    _device.gl.uniform3f(index,v0, v1, v2);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniform4f(String name, num v0, num v1, num v2, num v3) {
    ShaderProgram sp = _device.getDeviceChild(_shaderProgramHandle);
    if (sp == null) {
      spectreLog.Error('Attempting to set uniform with invalid program bound.');
      return;
    }
    var index = _device.gl.getUniformLocation(sp._program, name);
    if (index == -1) {
      spectreLog.Error('Could not find uniform $name in ${sp.name}');
      return;
    }
    _device.gl.uniform4f(index,v0, v1, v2, v3);
  }
  
  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniformMatrix3(String name, Float32Array matrix, [bool transpose=false]) {
    ShaderProgram sp = _device.getDeviceChild(_shaderProgramHandle);
    if (sp == null) {
      spectreLog.Error('Attempting to set uniform with invalid program bound.');
      return;
    }
    var index = _device.gl.getUniformLocation(sp._program, name);
    if (index == -1) {
      spectreLog.Error('Could not find uniform $name in ${sp.name}');
      return;
    }
    _device.gl.uniformMatrix3fv(index, transpose, matrix);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniformInt(String name, int i) {
    ShaderProgram sp = _device.getDeviceChild(_shaderProgramHandle);
    if (sp == null) {
      spectreLog.Error('Attempting to set uniform with invalid program bound.');
      return;
    }
    var index = _device.gl.getUniformLocation(sp._program, name);
    if (index == -1) {
      spectreLog.Error('Could not find uniform $name in ${sp.name}');
      return;
    }
    _device.gl.uniform1i(index, i);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniformNum(String name, num i) {
    ShaderProgram sp = _device.getDeviceChild(_shaderProgramHandle);
    if (sp == null) {
      spectreLog.Error('Attempting to set uniform with invalid program bound.');
      return;
    }
    var index = _device.gl.getUniformLocation(sp._program, name);
    if (index == -1) {
      spectreLog.Error('Could not find uniform $name in ${sp.name}');
      return;
    }
    _device.gl.uniform1f(index, i);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniformMatrix4(String name, Float32Array matrix, [bool transpose=false]) {
    ShaderProgram sp = _device.getDeviceChild(_shaderProgramHandle);
    if (sp == null) {
      spectreLog.Error('Attempting to set uniform with invalid program bound.');
      return;
    }
    var index = _device.gl.getUniformLocation(sp._program, name);
    if (index == -1) {
      spectreLog.Error('Could not find uniform $name in ${sp.name}');
      return;
    }
    _device.gl.uniformMatrix4fv(index, transpose, matrix);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniformVector4(String name, Float32Array vector) {
    ShaderProgram sp = _device.getDeviceChild(_shaderProgramHandle);
    if (sp == null) {
      spectreLog.Error('Attempting to set uniform with invalid program bound.');
      return;
    }
    var index = _device.gl.getUniformLocation(sp._program, name);
    if (index == -1) {
      spectreLog.Error('Could not find uniform $name in ${sp.name}');
      return;
    }
    _device.gl.uniform4fv(index, vector);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniformVector3(String name, Float32Array vector) {
    ShaderProgram sp = _device.getDeviceChild(_shaderProgramHandle);
    if (sp == null) {
      spectreLog.Error('Attempting to set uniform with invalid program bound.');
      return;
    }
    var index = _device.gl.getUniformLocation(sp._program, name);
    if (index == -1) {
      spectreLog.Error('Could not find uniform $name in ${sp.name}');
      return;
    }
    _device.gl.uniform3fv(index, vector);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniformVector2(String name, Float32Array vector) {
    ShaderProgram sp = _device.getDeviceChild(_shaderProgramHandle);
    if (sp == null) {
      spectreLog.Error('Attempting to set uniform with invalid program bound.');
      return;
    }
    var index = _device.gl.getUniformLocation(sp._program, name);
    if (index == -1) {
      spectreLog.Error('Could not find uniform $name in ${sp.name}');
      return;
    }
    _device.gl.uniform2fv(index, vector);
  }

  
  void setUniformFloat4Array(String name, Float32Array array) {
    ShaderProgram sp = _device.getDeviceChild(_shaderProgramHandle);
    if (sp == null) {
      spectreLog.Error('Attempting to set uniform with invalid program bound.');
      return;
    }
    var index = _device.gl.getUniformLocation(sp._program, name);
    if (index == -1) {
      spectreLog.Error('Could not find uniform $name in ${sp.name}');
      return;
    }
    _device.gl.uniform4fv(index, array);
  }

  /// Update the contents of [bufferHandle] with the contents of [data]
  void updateBuffer(int bufferHandle, ArrayBufferView data, [int usage = null]) {
    SpectreBuffer buffer = _device.getDeviceChild(bufferHandle);
    var correctType = buffer is SpectreBuffer;
    if (correctType == false) {
      return;
    }
    var target = buffer._target;
    var oldBind = _device.gl.getParameter(buffer._param_target);
    _device.gl.bindBuffer(buffer._target, buffer._buffer);
    _device.gl.bufferData(buffer._target, data, usage != null ? usage : buffer._usage);
    _device.gl.bindBuffer(buffer._target, oldBind);
  }

  /// Update the contents of [bufferHandle] with the contents of [data] starting at [offset]
  void updateSubBuffer(int bufferHandle, ArrayBufferView data, num offset) {
    SpectreBuffer buffer = _device.getDeviceChild(bufferHandle);
    var correctType = buffer is SpectreBuffer;
    if (correctType == false) {
      return;
    }
    var target = buffer._target;
    var oldBind = _device.gl.getParameter(buffer._param_target);
    _device.gl.bindBuffer(buffer._target, buffer._buffer);
    _device.gl.bufferSubData(buffer._target, offset, data);
    _device.gl.bindBuffer(buffer._target, oldBind);
  }

  /// Update the pixels of [textureHandle] from the [imageResourceHandle]
  ///
  /// Only updates the top level mip map
  void updateTexture2DFromResource(int textureHandle, int imageResourceHandle, ResourceManager rm) {
    ImageResource ir = rm.getResource(imageResourceHandle);
    if (ir == null) {
      return;
    }
    Texture2D tex = _device.getDeviceChild(textureHandle, true);
    if (tex == null) {
      return;
    }
    _device.gl.activeTexture(WebGLRenderingContext.TEXTURE0);
    var oldBind = _device.gl.getParameter(tex._target_param);
    _device.gl.bindTexture(tex._target, tex._buffer);
    _device.gl.texImage2D(tex._target, 0, tex._textureFormat, tex._textureFormat, tex._pixelFormat, ir.image);
    _device.gl.bindTexture(tex._target, oldBind);
  }

  /// Generate the full mipmap pyramid for [textureHandle]
  void generateMipmap(int textureHandle) {
    Texture2D tex = _device.getDeviceChild(textureHandle, true);
    if (tex == null) {
      return;
    }
    _device.gl.activeTexture(WebGLRenderingContext.TEXTURE0);
    var oldBind = _device.gl.getParameter(tex._target_param);
    _device.gl.bindTexture(tex._target, tex._buffer);
    _device.gl.generateMipmap(tex._target);
    _device.gl.bindTexture(tex._target, oldBind);
    tex.ready = true;
  }

  void compileShader(int shaderHandle, String source) {
    Shader shader = _device.getDeviceChild(shaderHandle);
    shader.source = source;
    shader.compile();
    String shaderCompileLog = _device.gl.getShaderInfoLog(shader._shader);
    spectreLog.Info('Compiled ${shader.name} - $shaderCompileLog');
  }

  void clearColorBuffer(num r, num g, num b, num a) {
    _device.gl.clearColor(r, g, b, a);
    _device.gl.clear(WebGLRenderingContext.COLOR_BUFFER_BIT);
  }

  void clearDepthBuffer(num depth) {
    _device.gl.clearDepth(depth);
    _device.gl.clear(WebGLRenderingContext.DEPTH_BUFFER_BIT);
  }

  void clearStencilBuffer(int stencil) {
    _device.gl.clearStencil(stencil);
    _device.gl.clear(WebGLRenderingContext.STENCIL_BUFFER_BIT);
  }

  void compileShaderFromResource(int shaderHandle, int shaderSourceHandle, ResourceManager rm) {
    ShaderResource sr = rm.getResource(shaderSourceHandle);
    if (sr == null) {
      return;
    }
    compileShader(shaderHandle, sr.source);
  }

  void linkShaderProgram(int shaderProgramHandle, int vertexShaderHandle, int fragmentShaderHandle) {
    ShaderProgram sp = _device.getDeviceChild(shaderProgramHandle);
    VertexShader vs = _device.getDeviceChild(vertexShaderHandle);
    FragmentShader fs = _device.getDeviceChild(fragmentShaderHandle);
    _device.gl.attachShader(sp._program, vs._shader);
    _device.gl.attachShader(sp._program, fs._shader);
    sp.link();
  }

  /// Sets a list of [textureHandles] starting at [texUnitOffset]
  void setTextures(int texUnitOffset, List<int> textureHandles) {
    for (int i = texUnitOffset; i < textureHandles.length; i++) {
      _textureHandles[i] = textureHandles[i-texUnitOffset];
    }
  }

  /// Sets a list of [samplerHandles] starting at [texUnitOffset]
  void setSamplers(int texUnitOffset, List<int> samplerHandles) {
    for (int i = texUnitOffset; i < samplerHandles.length; i++) {
      _samplerStateHandles[i] = samplerHandles[i-texUnitOffset];
    }
  }

  /// Draw an indexed mesh with [numIndices] starting at [indexOffset]
  void drawIndexed(int numIndices, int indexOffset) {
    if (numIndices == 0) {
      return;
    }
    _prepareInputs();
    _prepareTextures();
    _device.gl.drawElements(_primitiveTopology, numIndices, WebGLRenderingContext.UNSIGNED_SHORT, indexOffset);
  }

  void drawIndexedMesh(int indexedMeshHandle) {
    IndexedMesh im = _device.getDeviceChild(indexedMeshHandle);
    if (im == null) {
      return;
    }
    drawIndexed(im.numIndices, im.indexOffset);
  }

  /// Draw a mesh with [numVertices] starting at [vertexOffset]
  void draw(int numVertices, int vertexOffset) {
    if (numVertices == 0) {
      return;
    }
    _prepareInputs();
    _prepareTextures();
    _device.gl.drawArrays(_primitiveTopology, vertexOffset, numVertices);
  }
}

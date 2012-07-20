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
  final int numVertexBuffers = 1;
  final int numTextures = 1;

  // Input Assembler
  int _primitiveTopology;
  int _indexBufferHandle;
  List<int> _vertexBufferHandles;
  int _vertexAttributeArrayEnabledIndex;
  int _inputLayoutHandle;
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
    var enabled = webGL.getVertexAttrib(index, WebGLRenderingContext.VERTEX_ATTRIB_ARRAY_ENABLED);
    var size = webGL.getVertexAttrib(index, WebGLRenderingContext.VERTEX_ATTRIB_ARRAY_SIZE);
    var stride = webGL.getVertexAttrib(index, WebGLRenderingContext.VERTEX_ATTRIB_ARRAY_STRIDE);
    var type = webGL.getVertexAttrib(index, WebGLRenderingContext.VERTEX_ATTRIB_ARRAY_TYPE);
    var normalized = webGL.getVertexAttrib(index, WebGLRenderingContext.VERTEX_ATTRIB_ARRAY_NORMALIZED);
    var binding = webGL.getVertexAttrib(index, WebGLRenderingContext.VERTEX_ATTRIB_ARRAY_BUFFER_BINDING);
    spectreLog.Info('Vertex Attribute $index $enabled $size $stride $type $normalized $binding');
  }

  void _prepareInputs([bool debug=false]) {
    if (_inputLayoutHandle == 0) {
      spectreLog.Error('Prepare for draw no input layout');
      return;
    }

    InputLayout inputLayout = spectreDevice.getDeviceChild(_inputLayoutHandle);
    // TODO: Need to disable unneeded vertex attribute arrays.

    for (var element in inputLayout._elements) {
      VertexBuffer vb = spectreDevice.getDeviceChild(_vertexBufferHandles[element._vboSlot]);
      if (vb == null) {
        spectreLog.Error('Prepare for draw referenced a null vertex buffer object');
        continue;
      }
      webGL.enableVertexAttribArray(element._attributeIndex);
      webGL.bindBuffer(vb._target, vb._buffer);
      webGL.vertexAttribPointer(element._attributeIndex,
        element._attributeFormat.count,
        element._attributeFormat.type,
        element._attributeFormat.normalized,
        element._attributeStride,
        element._vboOffset);
      if (debug)
        _logVertexAttributes(element._attributeIndex);
      //webGL.bindBuffer(vb._target, null);

    }
    if (_indexBufferHandle != 0) {
      IndexBuffer indexBuffer = spectreDevice.getDeviceChild(_indexBufferHandle);
      webGL.bindBuffer(indexBuffer._target, indexBuffer._buffer);
      if (debug) {
        print('Binding index buffer');
      }
    } else {
      webGL.bindBuffer(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, null);
      if (debug) {
        print('No index buffer');
      }
    }
  }

  void _prepareTextures() {
    // TODO: Need to unbind unused texture channels
    for (int i = 0; i < numTextures; i++) {
      SamplerState s = spectreDevice.getDeviceChild(_samplerStateHandles[i]);
      Texture t = spectreDevice.getDeviceChild(_textureHandles[i]);
      if (s == null || t == null) {
        continue;
      }
      webGL.activeTexture(WebGLRenderingContext.TEXTURE0 + i);
      webGL.bindTexture(t._target, t._buffer);
      webGL.texParameteri(t._target, WebGLRenderingContext.TEXTURE_WRAP_S, s._wrap_s);
      webGL.texParameteri(t._target, WebGLRenderingContext.TEXTURE_WRAP_T, s._wrap_t);
      webGL.texParameteri(t._target, WebGLRenderingContext.TEXTURE_MIN_FILTER, s._min_filter);
      webGL.texParameteri(t._target, WebGLRenderingContext.TEXTURE_MAG_FILTER, s._mag_filter);
    }
  }

  ImmediateContext() {
    _vertexBufferHandles = new List<int>(numVertexBuffers);
    _samplerStateHandles = new List<int>(numTextures);
    _textureHandles = new List<int>(numTextures);
    _vertexAttributeArrayEnabledIndex = 0;
  }

  /// Resets the cached GPU pipeline state
  void reset() {
    // TODO: Update state
    _primitiveTopology = 0;
    _vertexAttributeArrayEnabledIndex = 0;
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

  /// Set ShaderProgram to [shaderProgramHandle]
  void setShaderProgram(int shaderProgramHandle) {
    if (_shaderProgramHandle == shaderProgramHandle) {
      return;
    }
    _shaderProgramHandle = shaderProgramHandle;
    ShaderProgram sp = spectreDevice.getDeviceChild(shaderProgramHandle);
    webGL.useProgram(sp._program);
  }

  /// Set RasterizerState to [rasterizerStateHandle]
  void setRasterizerState(int rasterizerStateHandle) {
    if (_rasterizerStateHandle == rasterizerStateHandle) {
      return;
    }
    _rasterizerStateHandle = rasterizerStateHandle;
    RasterizerState rs = spectreDevice.getDeviceChild(rasterizerStateHandle);
    if (rs == null) {
      return;
    }
    webGL.lineWidth(rs.lineWidth);
    if (rs.cullEnabled) {
      webGL.enable(WebGLRenderingContext.CULL_FACE);
      webGL.cullFace(rs.cullMode);
      webGL.frontFace(rs.cullFrontFace);
    } else {
      webGL.disable(WebGLRenderingContext.CULL_FACE);
    }
  }

  /// Set Viewport to [viewportHandle]
  void setViewport(int viewportHandle) {
    if (_viewportHandle == viewportHandle) {
      return;
    }
    Viewport vp = spectreDevice.getDeviceChild(viewportHandle);
    if (vp == null) {
      return;
    }
    webGL.viewport(vp.x, vp.y, vp.width, vp.height);
  }

  /// Set BlendState to [blendStateHandle]
  void setBlendState(int blendStateHandle) {
    if (_blendStateHandle == blendStateHandle) {
      return;
    }
    BlendState bs = spectreDevice.getDeviceChild(blendStateHandle);
    if (bs == null) {
      return;
    }
    webGL.colorMask(bs.writeRenderTargetRed, bs.writeRenderTargetGreen, bs.writeRenderTargetBlue, bs.writeRenderTargetAlpha);
    if (bs.blendEnable == false) {
      webGL.disable(WebGLRenderingContext.BLEND);
      return;
    }
    webGL.enable(WebGLRenderingContext.BLEND);
    webGL.blendFuncSeparate(bs.blendSourceColorFunc, bs.blendDestColorFunc, bs.blendSourceAlphaFunc, bs.blendDestAlphaFunc);
    webGL.blendEquationSeparate(bs.blendColorOp, bs.blendAlphaOp);
    webGL.blendColor(bs.blendColorRed, bs.blendColorGreen, bs.blendColorBlue, bs.blendColorAlpha);
  }

  /// Set DepthState to [depthStateHandle]
  void setDepthState(int depthStateHandle) {
    if (_depthStateHandle == depthStateHandle) {
      return;
    }
    DepthState ds = spectreDevice.getDeviceChild(depthStateHandle);
    if (ds == null) {
      return;
    }
    webGL.depthRange(ds.depthNearVal, ds.depthFarVal);
    if (ds.depthTestEnabled == false) {
      webGL.disable(WebGLRenderingContext.DEPTH_TEST);
    } else {
      webGL.enable(WebGLRenderingContext.DEPTH_TEST);
      webGL.depthFunc(ds.depthComparisonOp);
    }

    webGL.depthMask(ds.depthWriteEnabled);

    if (ds.polygonOffsetEnabled == false) {
      webGL.disable(WebGLRenderingContext.POLYGON_OFFSET_FILL);
    } else {
      webGL.enable(WebGLRenderingContext.POLYGON_OFFSET_FILL);
      webGL.polygonOffset(ds.polygonOffsetFactor, ds.polygonOffsetUnits);
    }
  }

  /// Set RenderTarget to [renderTargetHandle]
  void setRenderTarget(int renderTargetHandle) {
    if (_renderTargetHandle == renderTargetHandle) {
      return;
    }
    RenderTarget rt = spectreDevice.getDeviceChild(renderTargetHandle);
    webGL.bindFramebuffer(rt._target, rt._buffer);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniform3f(String name, num v0, num v1, num v2) {
    ShaderProgram sp = spectreDevice.getDeviceChild(_shaderProgramHandle);
    if (sp == null) {
      spectreLog.Error('Attempting to set uniform with invalid program bound.');
      return;
    }
    var index = webGL.getUniformLocation(sp._program, name);
    if (index == -1) {
      spectreLog.Error('Could not find uniform $name in ${sp.name}');
      return;
    }
    webGL.uniform3f(index,v0, v1, v2);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniform4f(String name, num v0, num v1, num v2, num v3) {
    ShaderProgram sp = spectreDevice.getDeviceChild(_shaderProgramHandle);
    if (sp == null) {
      spectreLog.Error('Attempting to set uniform with invalid program bound.');
      return;
    }
    var index = webGL.getUniformLocation(sp._program, name);
    if (index == -1) {
      spectreLog.Error('Could not find uniform $name in ${sp.name}');
      return;
    }
    webGL.uniform4f(index,v0, v1, v2, v3);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniformMatrix3(String name, Float32Array matrix, [bool transpose=false]) {
    ShaderProgram sp = spectreDevice.getDeviceChild(_shaderProgramHandle);
    if (sp == null) {
      spectreLog.Error('Attempting to set uniform with invalid program bound.');
      return;
    }
    var index = webGL.getUniformLocation(sp._program, name);
    if (index == -1) {
      spectreLog.Error('Could not find uniform $name in ${sp.name}');
      return;
    }
    webGL.uniformMatrix3fv(index, transpose, matrix);
  }

  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniformMatrix4(String name, Float32Array matrix, [bool transpose=false]) {
    ShaderProgram sp = spectreDevice.getDeviceChild(_shaderProgramHandle);
    if (sp == null) {
      spectreLog.Error('Attempting to set uniform with invalid program bound.');
      return;
    }
    var index = webGL.getUniformLocation(sp._program, name);
    if (index == -1) {
      spectreLog.Error('Could not find uniform $name in ${sp.name}');
      return;
    }
    webGL.uniformMatrix4fv(index, transpose, matrix);
  }

  /// Update the contents of [bufferHandle] with the contents of [data]
  void updateBuffer(int bufferHandle, ArrayBufferView data) {
    SpectreBuffer buffer = spectreDevice.getDeviceChild(bufferHandle);
    var correctType = buffer is SpectreBuffer;
    if (correctType == false) {
      return;
    }
    var target = buffer._target;
    var oldBind;
    if (buffer is VertexBuffer) {
      oldBind = webGL.getParameter(WebGLRenderingContext.ARRAY_BUFFER_BINDING);
    } else if (buffer is IndexBuffer) {
      oldBind = webGL.getParameter(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER_BINDING);
    }
    webGL.bindBuffer(buffer._target, buffer._buffer);
    webGL.bufferData(buffer._target, data, buffer._usage);
    //int size = webGL.getBufferParameter(buffer._target, WebGLRenderingContext.BUFFER_SIZE);
    //int usage = webGL.getBufferParameter(buffer._target, WebGLRenderingContext.BUFFER_USAGE);
    //spectreLog.Info('updated buffer (${buffer._target}, $size, $usage) with ${data.byteLength}');
    webGL.bindBuffer(buffer._target,  oldBind);
  }

  /// Update the contents of [bufferHandle] with the contents of [data] starting at [offset]
  void updateSubBuffer(int bufferHandle, ArrayBufferView data, num offset) {
    SpectreBuffer buffer = spectreDevice.getDeviceChild(bufferHandle);
    var correctType = buffer is SpectreBuffer;
    if (correctType == false) {
      return;
    }
    var target = buffer._target;
    var oldBind;
    if (buffer is VertexBuffer) {
      oldBind = webGL.getParameter(WebGLRenderingContext.ARRAY_BUFFER_BINDING);
    } else if (buffer is IndexBuffer) {
      oldBind = webGL.getParameter(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER_BINDING);
    }
    webGL.bindBuffer(buffer._target, buffer._buffer);
    webGL.bufferSubData(buffer._target, offset, data);
    webGL.bindBuffer(buffer._target, oldBind);
  }

  /// Update the pixels of [textureHandle] from the [imageResourceHandle]
  ///
  /// Only updates the top level mip map
  void updateTexture2DFromResource(int textureHandle, int imageResourceHandle) {
    ImageResource ir = spectreRM.getResource(imageResourceHandle);
    if (ir == null) {
      return;
    }
    Texture2D tex = spectreDevice.getDeviceChild(textureHandle);
    webGL.activeTexture(WebGLRenderingContext.TEXTURE0);
    var oldBind = webGL.getParameter(tex._target_param);
    webGL.bindTexture(tex._target, tex._buffer);
    webGL.texImage2D(tex._target, 0, tex._textureFormat, tex._textureFormat, tex._pixelFormat, ir.image);
    webGL.bindTexture(tex._target, oldBind);
  }

  /// Generate the full mipmap pyramid for [textureHandle]
  void generateMipmap(int textureHandle) {
    Texture2D tex = spectreDevice.getDeviceChild(textureHandle);
    webGL.activeTexture(WebGLRenderingContext.TEXTURE0);
    var oldBind = webGL.getParameter(tex._target_param);
    webGL.bindTexture(tex._target, tex._buffer);
    webGL.generateMipmap(tex._target);
    webGL.bindTexture(tex._target, oldBind);
  }

  void compileShader(int shaderHandle, String source) {
    Shader shader = spectreDevice.getDeviceChild(shaderHandle);
    shader.source = source;
    shader.compile();
    String shaderCompileLog = webGL.getShaderInfoLog(shader._shader);
    spectreLog.Info('Compiled ${shader.name} - $shaderCompileLog');
  }

  void compileShaderFromResource(int shaderHandle, int shaderSourceHandle) {
    ShaderResource sr = spectreRM.getResource(shaderSourceHandle);
    if (sr == null) {
      return;
    }
    compileShader(shaderHandle, sr.source);
  }

  void linkShaderProgram(int shaderProgramHandle, int vertexShaderHandle, int fragmentShaderHandle) {
    ShaderProgram sp = spectreDevice.getDeviceChild(shaderProgramHandle);
    VertexShader vs = spectreDevice.getDeviceChild(vertexShaderHandle);
    FragmentShader fs = spectreDevice.getDeviceChild(fragmentShaderHandle);
    webGL.attachShader(sp._program, vs._shader);
    webGL.attachShader(sp._program, fs._shader);
    sp.link();
  }

  /// Sets a list of [textureHandles] starting at [texUnitOffset]
  void setTextures(int texUnitOffset, List<int> textureHandles) {
    for (int i = texUnitOffset; i < numTextures; i++) {
      _textureHandles[i] = textureHandles[i-texUnitOffset];
    }
  }

  /// Sets a list of [samplerHandles] starting at [texUnitOffset]
  void setSamplers(int texUnitOffset, List<int> samplerHandles) {
    for (int i = texUnitOffset; i < numTextures; i++) {
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
    webGL.drawElements(_primitiveTopology, numIndices, WebGLRenderingContext.UNSIGNED_SHORT, indexOffset);
  }

  /// Draw a mesh with [numVertices] starting at [vertexOffset]
  void draw(int numVertices, int vertexOffset) {
    if (numVertices == 0) {
      return;
    }
    _prepareInputs();
    _prepareTextures();
    webGL.drawArrays(_primitiveTopology, vertexOffset, numVertices);
  }
}

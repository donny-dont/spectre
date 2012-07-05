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
  IndexBuffer _indexBuffer;
  List<VertexBuffer> _vertexBuffers;
  int _vertexAttributeArrayEnabledIndex;
  InputLayout _inputLayout;
  // VS and PS stages
  ShaderProgram _shaderProgram;
  List<SamplerState> _samplerStates;
  List<Texture> _textures;
  // Rasterizer
  RasterizerState _rasterizerState;
  Viewport _viewport;
  // Output-Merger
  BlendState _blendState;
  DepthState _depthState;
  StencilState _stencilState;
  RenderTarget _renderTarget;
  
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
    if (_inputLayout == null) {
      spectreLog.Error('Prepare for draw no input layout');
      return;
    }
    
    // TODO: Need to disable unneeded vertex attribute arrays.
    
    for (var element in _inputLayout._elements) {
      VertexBuffer vb = _vertexBuffers[element._vboSlot];
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
    if (_indexBuffer != null) {
      webGL.bindBuffer(_indexBuffer._target, _indexBuffer._buffer);
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
      SamplerState s = _samplerStates[i];
      Texture t = _textures[i];
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
    _vertexBuffers = new List<VertexBuffer>(numVertexBuffers);
    _samplerStates = new List<SamplerState>(numTextures);
    _textures = new List<Texture>(numTextures);
    _vertexAttributeArrayEnabledIndex = 0;
  }

  /// Resets the cached GPU pipeline state
  void reset() {
    // TODO: Update state
    _primitiveTopology = 0;
    _vertexAttributeArrayEnabledIndex = 0;
    _indexBuffer = null;
    for (int i = 0; i < numVertexBuffers; i++) {
      _vertexBuffers[i] = null;
    }
    _inputLayout = null;
    _shaderProgram = null;
    for (int i = 0; i < numTextures; i++) {
      _samplerStates[i] = null;
      _textures[i] = null;
    }
    _rasterizerState = null;
    _viewport = null;
    _blendState = null;
    _depthState = null;
    _stencilState = null;
    _renderTarget = null;
  }

  /// Configure the primitive topology
  void setPrimitiveTopology(int topology) {
    _primitiveTopology = topology;
  }

  /// Set the [IndexBuffer] [ib]
  void setIndexBuffer(IndexBuffer ib) {
    if (_indexBuffer == ib) {
      return;
    }
    _indexBuffer = ib;
  }

  /// Set multiple [VertexBuffers] in [vbs] starting at [startSlot]
  void setVertexBuffers(int startSlot, List<VertexBuffer> vbs) {
    int limit = vbs.length + startSlot;
    for (int i = startSlot; i < limit; i++) {
      _vertexBuffers[i] = vbs[i-startSlot];
    }
  }
  
  /// Set [InputLayout] [il]
  void setInputLayout(InputLayout il) {
    _inputLayout = il;
  }

  /// Set [ShaderProgram] [sp]
  void setShaderProgram(ShaderProgram sp) {
    if (sp == null) {
      return;
    }
    if (_shaderProgram == sp) {
      return;
    }
    _shaderProgram = sp;
    webGL.useProgram(_shaderProgram._program);
  }

  /// Set [RasterizerState] [rs]
  void setRasterizerState(RasterizerState rs) {
    if (rs == null) {
      return;
    }
    if (_rasterizerState == rs) {
      return;
    }
    _rasterizerState = rs;
    
    webGL.lineWidth(rs.lineWidth);
    if (rs.cullEnabled) {
      webGL.enable(WebGLRenderingContext.CULL_FACE);
      webGL.cullFace(rs.cullMode);
      webGL.frontFace(rs.cullFrontFace);
    } else {
      webGL.disable(WebGLRenderingContext.CULL_FACE);
    }
  }

  /// Set [Viewport] [vp]
  void setViewport(Viewport vp) {
    if (vp == null) {
      return;
    }
    if (_viewport == vp) {
      return;
    }
    _viewport = vp;
    webGL.viewport(vp.x, vp.y, vp.width, vp.height);
    //print('(${vp.x},${vp.y}) -> (${vp.width}, ${vp.height})');
  }

  /// Set [BlendState] [bs]
  void setBlendState(BlendState bs) {
    if (bs == null) {
      return;
    }
    if (_blendState == bs) {
      return;
    }
    
    _blendState = bs;
    
    webGL.colorMask(bs.writeRenderTargetRed, bs.writeRenderTargetGreen, bs.writeRenderTargetBlue, bs.writeRenderTargetAlpha);
    
    if (_blendState.blendEnable == false) {
      webGL.disable(WebGLRenderingContext.BLEND);
      return;
    }
    
    webGL.enable(WebGLRenderingContext.BLEND);
    webGL.blendFuncSeparate(bs.blendSourceColorFunc, bs.blendDestColorFunc, bs.blendSourceAlphaFunc, bs.blendDestAlphaFunc);
    webGL.blendEquationSeparate(bs.blendColorOp, bs.blendAlphaOp);
    webGL.blendColor(bs.blendColorRed, bs.blendColorGreen, bs.blendColorBlue, bs.blendColorAlpha);
  }

  /// Set [DepthState] [ds]
  void setDepthState(DepthState ds) {
    if (ds == null) {
      return;
    }
    if (_depthState == ds) {
      return;
    }
    _depthState = ds;

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

  /// Set [RenderTarget] [rt]
  void setRenderTarget(RenderTarget rt) {
    if (_renderTarget == rt) {
      return;
    }
    _renderTarget = rt;
    webGL.bindFramebuffer(rt._target, rt._buffer);
  }
  
  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniform3f(String name, num v0, num v1, num v2) {
    if (_shaderProgram == null) {
      spectreLog.Error('Attempting to set uniform with no program bound.');
      return;
    }
    var index = webGL.getUniformLocation(_shaderProgram._program, name);
    if (index == -1) {
      spectreLog.Error('Could not find uniform $name in ${_shaderProgram.name}');
      return;
    }
    webGL.uniform3f(index,v0, v1, v2);
  }
  
  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniform4f(String name, num v0, num v1, num v2, num v3) {
    if (_shaderProgram == null) {
      spectreLog.Error('Attempting to set uniform with no program bound.');
      return;
    }
    var index = webGL.getUniformLocation(_shaderProgram._program, name);
    if (index == -1) {
      spectreLog.Error('Could not find uniform $name in ${_shaderProgram.name}');
      return;
    }
    webGL.uniform4f(index,v0, v1, v2, v3);
  }
  
  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniformMatrix3(String name, Float32Array matrix, [bool transpose=false]) {
    if (_shaderProgram == null) {
      spectreLog.Error('Attempting to set uniform with no program bound.');
      return;
    }
    var index = webGL.getUniformLocation(_shaderProgram._program, name);
    if (index == -1) {
      spectreLog.Error('Could not find uniform $name in ${_shaderProgram.name}');
      return;
    }
    webGL.uniformMatrix3fv(index, transpose, matrix);
  }
  
  /// Set Uniform variable [name] in current [ShaderProgram]
  void setUniformMatrix4(String name, Float32Array matrix, [bool transpose=false]) {
    if (_shaderProgram == null) {
      spectreLog.Error('Attempting to set uniform with no program bound.');
      return;
    }
    var index = webGL.getUniformLocation(_shaderProgram._program, name);
    if (index == -1) {
      spectreLog.Error('Could not find uniform $name in ${_shaderProgram.name}');
      return;
    }
    webGL.uniformMatrix4fv(index, transpose, matrix);
    //spectreLog.Info('Setting $name to ${matrix[0]} ${matrix[1]} ${matrix[2]} ${matrix[3]}');
  }
  
  /// Update the contents of [buffer] with the contents of [data]
  void updateBuffer(SpectreBuffer buffer, ArrayBufferView data) {
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
  
  /// Update the contents of [buffer] with the contents of [data] starting at [offset]
  void updateSubBuffer(SpectreBuffer buffer, ArrayBufferView data, num offset) {
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
  
  /// Update the pixels of [tex] with the pixels of [img]
  ///
  /// Only updates the top level mip map
  void updateTexture2D(Texture2D tex, ImageElement img) {
    webGL.activeTexture(WebGLRenderingContext.TEXTURE0);
    var oldBind = webGL.getParameter(tex._target_param);
    webGL.bindTexture(tex._target, tex._buffer);
    webGL.texImage2D(tex._target, 0, tex._textureFormat, tex._textureFormat, tex._pixelFormat, img);
    webGL.bindTexture(tex._target, oldBind);
  }
  
  /// Generate the full mipmap pyramid for [tex]
  void generateMipmap(Texture2D tex) {
    webGL.activeTexture(WebGLRenderingContext.TEXTURE0);
    var oldBind = webGL.getParameter(tex._target_param);
    webGL.bindTexture(tex._target, tex._buffer);
    webGL.generateMipmap(tex._target);
    webGL.bindTexture(tex._target, oldBind);
  }
  
  /// Sets a list of [textures] starting at [texUnitOffset]
  void setTextures(int texUnitOffset, List<Texture> textures) {
    for (int i = texUnitOffset; i < numTextures; i++) {
      _textures[i] = textures[i-texUnitOffset];
    }
  }
  
  /// Sets a list of [samplers] starting at [texUnitOffset]
  void setSamplers(int texUnitOffset, List<SamplerState> samplers) {
    for (int i = texUnitOffset; i < numTextures; i++) {
      _samplerStates[i] = samplers[i-texUnitOffset];
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

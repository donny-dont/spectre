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

/** The [GraphicsContext] configures the GPU pipeline and executes draw commands */
class GraphicsContext {
  static final int PrimitiveTopologyTriangles = WebGLRenderingContext.TRIANGLES;
  static final int PrimitiveTopologyLines = WebGLRenderingContext.LINES;
  static final int PrimitiveTopologyPoints = WebGLRenderingContext.POINTS;
  static final int numVertexBuffers = 2;
  static final int numTextures = 3;
  final GraphicsDevice device;

  // Input Assembler
  int _primitiveTopology;
  IndexBuffer _indexBufferHandle;
  List<VertexBuffer> _vertexBufferHandles;
  List<int> _enabledVertexAttributeArrays;
  InputLayout _inputLayoutHandle;
  InputLayout _preparedInputLayoutHandle;
  // VS and PS stages
  ShaderProgram _shaderProgramHandle;
  List<SamplerState> _samplerStateHandles;
  List<Texture> _textureHandles;
  // Rasterizer
  RasterizerState _rasterizerStateHandle;
  Viewport _viewportHandle;
  // Output-Merger
  BlendState _blendStateHandle;
  DepthState _depthStateHandle;
  StencilState _stencilStateHandle;
  RenderTarget _renderTargetHandle;

  void _PrepareTextures() {
  }

  void _prepareInputs([bool debug=false]) {
    if (_inputLayoutHandle == 0) {
      spectreLog.Error('Prepare for draw no input layout');
      return;
    }

    InputLayout inputLayout = _inputLayoutHandle;
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
      device.gl.disableVertexAttribArray(index);
    }
    _enabledVertexAttributeArrays.clear();

    inputLayout.elements.forEach((element) {
      VertexBuffer vb = _vertexBufferHandles[element.vboSlot];
      if (vb == null) {
        spectreLog.Error('Prepare for draw referenced a null vertex buffer object');
        return;
      }
      device.gl.enableVertexAttribArray(element.attributeIndex);
      vb._bind();
      device.gl.vertexAttribPointer(element.attributeIndex,
        element.attributeFormat.count,
        element.attributeFormat.type,
        element.attributeFormat.normalized,
        element.attributeStride,
        element.attributeOffset);
      // Remember that this was enabled.
      _enabledVertexAttributeArrays.add(element.attributeIndex);
    });
    if (_indexBufferHandle != null) {
      IndexBuffer indexBuffer = _indexBufferHandle;
      indexBuffer._bind();
    } else {
      device.gl.bindBuffer(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, null);
    }
  }

  void _prepareTextures() {
    // TODO: Need to unbind unused texture channels
    for (int i = 0; i < numTextures; i++) {
      SamplerState sampler = _samplerStateHandles[i];
      Texture texture = _textureHandles[i];
      if (sampler == null || texture == null) {
        continue;
      }
      texture._bind(WebGLRenderingContext.TEXTURE0 + i);
      texture._applySampler(sampler);
    }
  }

  GraphicsContext(this.device) {
    _vertexBufferHandles = new List<VertexBuffer>(numVertexBuffers);
    _samplerStateHandles = new List<SamplerState>(numTextures);
    _textureHandles = new List<Texture>(numTextures);
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
      device.gl.disableVertexAttribArray(index);
    }
    _preparedInputLayoutHandle = null;
    _enabledVertexAttributeArrays.clear();
    _indexBufferHandle = null;
    for (int i = 0; i < numVertexBuffers; i++) {
      _vertexBufferHandles[i] = null;
    }
    _inputLayoutHandle = null;
    _shaderProgramHandle = null;
    for (int i = 0; i < numTextures; i++) {
      _samplerStateHandles[i] = null;
      _textureHandles[i] = null;
    }
    _rasterizerStateHandle = null;
    _viewportHandle = null;
    _blendStateHandle = null;
    _depthStateHandle = null;
    _stencilStateHandle = null;
    _renderTargetHandle = null;
  }

  /// Configure the primitive topology
  void setPrimitiveTopology(int topology) {
    _primitiveTopology = topology;
  }

  /// Set the IndexBuffer to [indexBufferHandle]
  void setIndexBuffer(IndexBuffer indexBufferHandle) {
    _indexBufferHandle = indexBufferHandle;
  }

  /// Set multiple VertexBuffers in [vertexBufferHandles] starting at [startSlot]
  void setVertexBuffers(int startSlot, List<VertexBuffer> vertexBufferHandles) {
    int limit = vertexBufferHandles.length + startSlot;
    for (int i = startSlot; i < limit; i++) {
      _vertexBufferHandles[i] = vertexBufferHandles[i-startSlot];
    }
  }

  /// Set InputLayout to [inputLayoutHandle]
  void setInputLayout(InputLayout inputLayoutHandle) {
    _inputLayoutHandle = inputLayoutHandle;
  }

  void setIndexedMesh(SingleArrayIndexedMesh indexedMesh) {
    if (indexedMesh == null) {
      return;
    }
    setIndexBuffer(indexedMesh.indexArray);
    setVertexBuffers(0, [indexedMesh.vertexArray]);
  }

  void setMesh(SingleArrayMesh mesh) {
    if (mesh == null) {
      return;
    }
    setIndexBuffer(null);
    setVertexBuffers(0, [mesh.vertexArray]);
  }

  /// Set ShaderProgram to [shaderProgramHandle]
  void setShaderProgram(ShaderProgram shaderProgramHandle) {
    if (_shaderProgramHandle == shaderProgramHandle) {
      return;
    }
    _shaderProgramHandle = shaderProgramHandle;
    ShaderProgram sp = shaderProgramHandle;
    device.gl.useProgram(sp._program);
  }

  /// Set RasterizerState to [rasterizerStateHandle]
  void setRasterizerState(RasterizerState rasterizerStateHandle) {
    if (_rasterizerStateHandle == rasterizerStateHandle) {
      return;
    }
    _rasterizerStateHandle = rasterizerStateHandle;
    RasterizerState rs = rasterizerStateHandle;
    if (rs == null) {
      return;
    }
    device.gl.lineWidth(rs.lineWidth);
    if (rs.cullEnabled) {
      device.gl.enable(WebGLRenderingContext.CULL_FACE);
      device.gl.cullFace(rs.cullMode);
      device.gl.frontFace(rs.cullFrontFace);
    } else {
      device.gl.disable(WebGLRenderingContext.CULL_FACE);
    }
  }

  /// Set Viewport to [viewportHandle]
  void setViewport(Viewport vp) {
    if (vp == _viewportHandle) {
      return;
    }
    _viewportHandle = vp;
    if (vp == null) {
      return;
    }
    device.gl.viewport(vp.x, vp.y, vp.width, vp.height);
  }

  /// Set BlendState to [blendStateHandle]
  void setBlendState(BlendState bs) {
    if (_blendStateHandle == bs) {
      return;
    }
    _blendStateHandle = bs;
    if (bs == null) {
      return;
    }
    device.gl.colorMask(bs.writeRenderTargetRed,
                         bs.writeRenderTargetGreen,
                         bs.writeRenderTargetBlue,
                         bs.writeRenderTargetAlpha);
    if (bs.enabled == false) {
      device.gl.disable(WebGLRenderingContext.BLEND);
      return;
    }
    device.gl.enable(WebGLRenderingContext.BLEND);
    device.gl.blendFuncSeparate(bs.colorSourceBlend,
                                bs.colorDestinationBlend,
                                bs.alphaSourceBlend,
                                bs.alphaDestinationBlend);
    device.gl.blendEquationSeparate(bs.colorBlendOperation, bs.alphaBlendOperation);

    vec4 blendFactor = bs.blendFactor;
    device.gl.blendColor(blendFactor.r, blendFactor.g, blendFactor.b, blendFactor.a);
  }

  /// Set DepthState to [depthStateHandle]
  void setDepthState(DepthState ds) {
    if (_depthStateHandle == ds) {
      return;
    }
    if (ds == null) {
      return;
    }
    device.gl.depthRange(ds.depthNearVal, ds.depthFarVal);
    if (ds.depthTestEnabled == false) {
      device.gl.disable(WebGLRenderingContext.DEPTH_TEST);
    } else {
      device.gl.enable(WebGLRenderingContext.DEPTH_TEST);
      device.gl.depthFunc(ds.depthComparisonOp);
    }

    device.gl.depthMask(ds.depthWriteEnabled);

    if (ds.polygonOffsetEnabled == false) {
      device.gl.disable(WebGLRenderingContext.POLYGON_OFFSET_FILL);
    } else {
      device.gl.enable(WebGLRenderingContext.POLYGON_OFFSET_FILL);
      device.gl.polygonOffset(ds.polygonOffsetFactor, ds.polygonOffsetUnits);
    }
  }

  /// Set RenderTarget to [renderTargetHandle]
  void setRenderTarget(RenderTarget renderTargetHandle) {
    if (_renderTargetHandle == renderTargetHandle) {
      return;
    }
    _renderTargetHandle = renderTargetHandle;
    if (_renderTargetHandle == null) {
      RenderTarget.systemRenderTarget._bind();
    } else {
      RenderTarget rt = renderTargetHandle;
      rt._bind();
    }
  }

  ShaderProgramUniform _findUniform(String name) {
    ShaderProgram sp = _shaderProgramHandle;
    if (sp == null) {
      return null;
    }
    return sp.uniforms[name];
  }

  void setConstant(String name, var argument) {
    ShaderProgramUniform uniform = _findUniform(name);
    if (uniform != null) {
      uniform._apply(device, uniform.location, argument);
    } else if (_shaderProgramHandle == null ){
      spectreLog.Error('Cannot set $name: no ShaderProgram bound.');
    } else {
      //spectreLog.Error('Cannot set $name: not found.');
    }
  }

  void clearColorBuffer(num r, num g, num b, num a) {
    device.gl.clearColor(r, g, b, a);
    device.gl.clear(WebGLRenderingContext.COLOR_BUFFER_BIT);
  }

  void clearDepthBuffer(num depth) {
    device.gl.clearDepth(depth);
    device.gl.clear(WebGLRenderingContext.DEPTH_BUFFER_BIT);
  }

  void clearStencilBuffer(int stencil) {
    device.gl.clearStencil(stencil);
    device.gl.clear(WebGLRenderingContext.STENCIL_BUFFER_BIT);
  }

  /// Sets a list of [textureHandles] starting at [texUnitOffset]
  void setTextures(int texUnitOffset, List<Texture> textureHandles) {
    for (int i = texUnitOffset; i < textureHandles.length; i++) {
      _textureHandles[i] = textureHandles[i-texUnitOffset];
    }
  }

  /// Sets a list of [samplerHandles] starting at [texUnitOffset]
  void setSamplers(int texUnitOffset, List<SamplerState> samplerHandles) {
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
    device.gl.drawElements(_primitiveTopology, numIndices,
                           WebGLRenderingContext.UNSIGNED_SHORT, indexOffset);
  }

  void drawIndexedMesh(SingleArrayIndexedMesh indexedMesh) {
    if (indexedMesh == null) {
      return;
    }
    drawIndexed(indexedMesh.numIndices, 0);
  }

  void drawMesh(SingleArrayMesh mesh) {
    if (mesh == null) {
      return;
    }
    draw(mesh.numVertices, 0);
  }

  /// Draw a mesh with [numVertices] starting at [vertexOffset]
  void draw(int numVertices, int vertexOffset) {
    if (numVertices == 0) {
      return;
    }
    _prepareInputs();
    _prepareTextures();
    device.gl.drawArrays(_primitiveTopology, vertexOffset, numVertices);
  }
}

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

/// The [GraphicsContext] configures the GPU pipeline and executes draw commands.
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
  List<SpectreTexture> _textureHandles;
  // Rasterizer
  RasterizerState _rasterizerStateHandle;
  Viewport _viewportHandle;
  // Output-Merger
  DepthState _depthStateHandle;
  StencilState _stencilStateHandle;
  RenderTarget _renderTargetHandle;

  //---------------------------------------------------------------------
  // Default variables
  //---------------------------------------------------------------------

  /// The default [BlendState] to use.
  /// Constructed with the values in [BlendState.opaque].
  BlendState _blendStateDefault;
  /// The default [RasterizerState] to use.
  /// Constructed with the values in [RasterizerState.cullClockwise].
  RasterizerState _rasterizerStateDefault;

  //---------------------------------------------------------------------
  // State variables
  //---------------------------------------------------------------------

  /// The current [BlendState] of the pipeline.
  BlendState _blendState;
  /// The current [RasterizerState] of the pipeline.
  RasterizerState _rasterizerState;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  GraphicsContext(this.device) {
    _vertexBufferHandles = new List<VertexBuffer>(numVertexBuffers);
    _samplerStateHandles = new List<SamplerState>(numTextures);
    _textureHandles = new List<SpectreTexture>(numTextures);
    _enabledVertexAttributeArrays = new List<int>();

    _initializeState();
    reset();
  }

  /// Initialize the WebGL pipeline state.
  /// Creates all the default state values and applies them to the pipeline.
  void _initializeState() {
    // BlendState setup
    _blendStateDefault = new BlendState.opaque('BlendStateDefault', device);
    _blendState = new BlendState.opaque('CurrentBlendState', device);

    device.gl.disable(WebGLRenderingContext.BLEND);
    device.gl.blendFuncSeparate(
      _blendState.colorSourceBlend,
      _blendState.colorDestinationBlend,
      _blendState.alphaSourceBlend,
      _blendState.alphaDestinationBlend
    );
    device.gl.blendEquationSeparate(_blendState.colorBlendOperation, _blendState.alphaBlendOperation);
    device.gl.colorMask(
      _blendState.writeRenderTargetRed,
      _blendState.writeRenderTargetGreen,
      _blendState.writeRenderTargetBlue,
      _blendState.writeRenderTargetAlpha
    );
    device.gl.blendColor(
      _blendState.blendFactorRed,
      _blendState.blendFactorGreen,
      _blendState.blendFactorBlue,
      _blendState.blendFactorAlpha
    );

    // RasterizerState setup
    _rasterizerStateDefault = new RasterizerState.cullClockwise('RasterizerStateDefault', device);
    _rasterizerState = new RasterizerState.cullClockwise('CurrentRasterizerState', device);

    device.gl.enable(WebGLRenderingContext.CULL_FACE);
    device.gl.cullFace(_rasterizerState.cullMode);
    device.gl.frontFace(_rasterizerState.frontFace);

    device.gl.disable(WebGLRenderingContext.POLYGON_OFFSET_FILL);
    device.gl.polygonOffset(_rasterizerState.depthBias, _rasterizerState.slopeScaleDepthBias);

    device.gl.disable(WebGLRenderingContext.SCISSOR_TEST);
  }

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
      SpectreTexture texture = _textureHandles[i];
      if (sampler == null || texture == null) {
        continue;
      }
      texture._bind(WebGLRenderingContext.TEXTURE0 + i);
      texture._applySampler(sampler);
    }
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
    _depthStateHandle = null;
    _stencilStateHandle = null;
    _renderTargetHandle = null;

    setBlendState(_blendStateDefault);
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
    setPrimitiveTopology(indexedMesh.primitiveTopology);
    setIndexBuffer(indexedMesh.indexArray);
    setVertexBuffers(0, [indexedMesh.vertexArray]);
  }

  void setMesh(SingleArrayMesh mesh) {
    if (mesh == null) {
      return;
    }
    setPrimitiveTopology(mesh.primitiveTopology);
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

  /// Sets the current [BlendState] to use on the pipeline.
  ///
  /// If [blendState] is null all values of the pipeline associated with blending
  /// will be reset to their defaults.
  void setBlendState(BlendState blendState) {
    if (blendState == null) {
      setBlendState(_blendStateDefault);
      return;
    }

    // Disable/Enable blending if necessary
    if (_blendState.enabled != blendState.enabled) {
      if (blendState.enabled) {
        device.gl.enable(WebGLRenderingContext.BLEND);
      } else {
        device.gl.disable(WebGLRenderingContext.BLEND);
      }

      _blendState.enabled = blendState.enabled;
    }

    // Modify the color write channels if necessary
    if ((_blendState.writeRenderTargetRed   != blendState.writeRenderTargetRed)   ||
        (_blendState.writeRenderTargetGreen != blendState.writeRenderTargetGreen) ||
        (_blendState.writeRenderTargetBlue  != blendState.writeRenderTargetBlue)  ||
        (_blendState.writeRenderTargetAlpha != blendState.writeRenderTargetAlpha))
    {
      device.gl.colorMask(
        blendState.writeRenderTargetRed,
        blendState.writeRenderTargetGreen,
        blendState.writeRenderTargetBlue,
        blendState.writeRenderTargetAlpha
      );

      _blendState.writeRenderTargetRed   = blendState.writeRenderTargetRed;
      _blendState.writeRenderTargetGreen = blendState.writeRenderTargetGreen;
      _blendState.writeRenderTargetBlue  = blendState.writeRenderTargetBlue;
      _blendState.writeRenderTargetAlpha = blendState.writeRenderTargetAlpha;
    }

    // If blending is enabled enable all the functionality
    if (_blendState.enabled) {
      // Modify the blend functions if necessary
      if ((_blendState.colorSourceBlend      != blendState.colorSourceBlend)      ||
          (_blendState.colorDestinationBlend != blendState.colorDestinationBlend) ||
          (_blendState.alphaSourceBlend      != blendState.alphaSourceBlend)      ||
          (_blendState.alphaDestinationBlend != blendState.alphaDestinationBlend))
      {
        device.gl.blendFuncSeparate(
          blendState.colorSourceBlend,
          blendState.colorDestinationBlend,
          blendState.alphaSourceBlend,
          blendState.alphaDestinationBlend
        );

        _blendState.colorSourceBlend      = blendState.colorSourceBlend;
        _blendState.colorDestinationBlend = blendState.colorDestinationBlend;
        _blendState.alphaSourceBlend      = blendState.alphaSourceBlend;
        _blendState.alphaDestinationBlend = blendState.alphaDestinationBlend;
      }

      // Modify the blend operations if necessary
      if ((_blendState.colorBlendOperation != blendState.colorBlendOperation) ||
          (_blendState.alphaBlendOperation != blendState.alphaBlendOperation))
      {
        device.gl.blendEquationSeparate(blendState.colorBlendOperation, blendState.alphaBlendOperation);

        _blendState.colorBlendOperation = blendState.colorBlendOperation;
        _blendState.alphaBlendOperation = blendState.alphaBlendOperation;
      }

      // Modify the blend factor if necessary
      if ((_blendState.blendFactorRed   != blendState.blendFactorRed)   ||
          (_blendState.blendFactorGreen != blendState.blendFactorGreen) ||
          (_blendState.blendFactorBlue  != blendState.blendFactorBlue)  ||
          (_blendState.blendFactorAlpha != blendState.blendFactorAlpha))
      {
        device.gl.blendColor(
          blendState.blendFactorRed,
          blendState.blendFactorGreen,
          blendState.blendFactorBlue,
          blendState.blendFactorAlpha
        );

        _blendState.blendFactorRed   = blendState.blendFactorRed;
        _blendState.blendFactorGreen = blendState.blendFactorGreen;
        _blendState.blendFactorBlue  = blendState.blendFactorBlue;
        _blendState.blendFactorAlpha = blendState.blendFactorAlpha;
      }
    }
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

  /// Sets the current [RasterizerState] to use on the pipeline.
  ///
  /// If [rasterizerState] is null all values of the pipeline associated with blending
  /// will be reset to their defaults.
  void setRasterizerState(RasterizerState rasterizerState) {
    if (rasterizerState == null) {
      setRasterizerState(_rasterizerStateDefault);
    }

    // Disable/Enable culling if necessary
    if (_rasterizerState.cullMode != rasterizerState.cullMode) {
      if (rasterizerState.cullMode == CullMode.None) {
        device.gl.disable(WebGLRenderingContext.CULL_FACE);
      } else {
        device.gl.enable(WebGLRenderingContext.CULL_FACE);
      }

      _rasterizerState.cullMode = rasterizerState.cullMode;
    }

    // If culling is enabled enable culling mode and winding order
    if (_rasterizerState.cullMode != CullMode.None) {
      // Modify the cull mode if necessary
      if (_rasterizerState.cullMode != rasterizerState.cullMode) {
        device.gl.cullFace(rasterizerState.cullMode);

        _rasterizerState.cullMode = rasterizerState.cullMode;
      }

      // Modify the front face if necessary
      if (_rasterizerState.frontFace != rasterizerState.frontFace) {
        device.gl.frontFace(rasterizerState.frontFace);

        _rasterizerState.frontFace = rasterizerState.frontFace;
      }
    }

    bool offsetEnabled = ((_rasterizerState.depthBias != 0.0) || (_rasterizerState.slopeScaleDepthBias != 0.0));

    if ((rasterizerState.depthBias != 0.0) || (rasterizerState.slopeScaleDepthBias != 0)) {
      // Enable polygon offset
      if (!offsetEnabled) {
        device.gl.enable(WebGLRenderingContext.POLYGON_OFFSET_FILL);
      }

      // Modify the polygon offset if necessary
      if ((_rasterizerState.depthBias           != rasterizerState.depthBias) ||
          (_rasterizerState.slopeScaleDepthBias != rasterizerState.slopeScaleDepthBias))
      {
        device.gl.polygonOffset(rasterizerState.depthBias, rasterizerState.slopeScaleDepthBias);

        _rasterizerState.depthBias           = rasterizerState.depthBias;
        _rasterizerState.slopeScaleDepthBias = rasterizerState.slopeScaleDepthBias;
      }
    } else {
      // Disable polygon offset
      if (offsetEnabled) {
        device.gl.disable(WebGLRenderingContext.POLYGON_OFFSET_FILL);
      }
    }

    // Disable/Enable scissor test if necessary
    if (_rasterizerState.scissorTestEnabled != rasterizerState.scissorTestEnabled) {
      if (rasterizerState.scissorTestEnabled) {
        device.gl.enable(WebGLRenderingContext.SCISSOR_TEST);
      } else {
        device.gl.disable(WebGLRenderingContext.SCISSOR_TEST);
      }

      _rasterizerState.scissorTestEnabled = rasterizerState.scissorTestEnabled;
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
  void setTextures(int texUnitOffset, List<SpectreTexture> textureHandles) {
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
    drawIndexed(indexedMesh.count, 0);
  }

  void drawMesh(SingleArrayMesh mesh) {
    if (mesh == null) {
      return;
    }
    draw(mesh.count, 0);
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

/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

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

part of spectre_renderer;

/** Spectre Renderer. The renderer holds global GPU resources such as
 * depth buffers, color buffers, and the canvas front buffer. A renderer
 * draws the world a layer at a time. A [Layer] can render all renderables or
 * do a full screen scene pass.
 */
class Renderer {
  final GraphicsDevice device;
  final CanvasElement frontBuffer;
  final AssetManager assetManager;
  AssetPack _rendererPack;
  AssetPack _fullscreenEffectsPack;
  final Map<String, Texture2D> colorBuffers = new Map<String, Texture2D>();
  final Map<String, RenderBuffer> depthBuffers =
      new Map<String, RenderBuffer>();
  final Map<String, RenderTarget> renderTargets =
      new Map<String, RenderTarget>();

  Viewport _frontBufferViewport;
  Viewport get frontBufferViewport => _frontBufferViewport;

  MaterialShader _blitMaterialShader;

  BlendState _clearBlendState;
  DepthState _clearDepthState;
  SamplerState NPOTSampler;
  SingleArrayMesh _fullscreenMesh;
  InputLayout _fullscreenMeshInputLayout;

  double time = 0.0;

  void _dispose() {
    _rendererPack.clear();
    colorBuffers.forEach((_, t) {
      t.dispose();
    });
    colorBuffers.clear();
    depthBuffers.forEach((_, t) {
      t.dispose();
    });
    depthBuffers.clear();
    renderTargets.forEach((_, t) {
      t.dispose();
    });
    renderTargets.clear();
  }

  void _makeColorBuffer(Map target) {
    String name = target['name'];
    int width = target['width'];
    int height = target['height'];
    if (name == null || width == null || height == null) {
      throw new ArgumentError('Invalid target description.');
    }
    Texture2D buffer = new Texture2D(name, device);
    buffer.uploadPixelArray(width, height, new Uint8List(width*height*4));
    colorBuffers[name] = buffer;
    var asset =
        _rendererPack.registerAsset(name, 'ColorBuffer', '', '', {}, {});
    asset.imported = buffer;
  }

  void _makeDepthBuffer(Map target) {
    String name = target['name'];
    int width = target['width'];
    int height = target['height'];
    if (name == null || width == null || height == null) {
      throw new ArgumentError('Invalid target description.');
    }
    RenderBuffer buffer = new RenderBuffer(name, device);
    buffer.allocateStorage(width, height, RenderBuffer.FormatDepth);
    depthBuffers[name] = buffer;
    var asset =
        _rendererPack.registerAsset(name, 'DepthBuffer', '', '', {}, {});
    asset.imported = buffer;
  }

  void _makeRenderTarget(Map target) {
    // TODO: Support stencil buffers.
    var name = target['name'];
    if (name == null) {
      throw new ArgumentError('Render target requires a name.');
    }
    var colorBufferName = target['colorBuffer'];
    var depthBufferName = target['depthBuffer'];
    var stencilBufferName = target['stencilBuffer'];
    var colorBuffer = colorBuffers[colorBufferName];
    var depthBuffer = depthBuffers[depthBufferName];
    //XXX var stencilBuffer = stencilBuffers[stencilTarget];
    if (colorBuffer == null && depthBuffer == null) {
      throw new ArgumentError('Render target needs a color or a depth buffer.');
    }
    RenderTarget renderTarget = new RenderTarget(name, device);
    renderTarget.colorTarget = colorBuffer;
    renderTarget.depthTarget = depthBuffer;
    renderTargets[name]= renderTarget;
    var asset = _rendererPack.registerAsset(name, 'RenderTarget', '', '', {},
                                            {});
    asset.imported = renderTarget;
  }

  void _configureFrontBuffer(Map target) {
    int width = target['width'];
    int height = target['height'];
    if (width == null || height == null) {
      throw new ArgumentError('Invalid front buffer description.');
    }
    frontBuffer.width = width;
    frontBuffer.height = height;
    _frontBufferViewport.width = frontBuffer.width;
    _frontBufferViewport.height = frontBuffer.height;
    renderTargets['frontBuffer'] = RenderTarget.systemRenderTarget;
    if (_rendererPack['frontBuffer'] == null) {
      var asset = _rendererPack.registerAsset('frontBuffer', 'RenderTarget', '',
                                              '', {}, {});
      asset.imported =  RenderTarget.systemRenderTarget;
    }
  }

  /// Clear render targets.
  void clear() {
    _dispose();
  }

  void fromJson(Map config) {
    clear();
    List<Map> buffers = config['buffers'];
    List<Map> targets = config['targets'];
    if (buffers != null) {
      buffers.forEach((bufferDescription) {
        if (bufferDescription['type'] == 'color') {
          _makeColorBuffer(bufferDescription);
        } else if (bufferDescription['type'] == 'depth') {
          _makeDepthBuffer(bufferDescription);
        }
      });
    }
    if (targets != null) {
      targets.forEach((target) {
        if (target['name'] == 'frontBuffer') {
          _configureFrontBuffer(target);
        } else {
          _makeRenderTarget(target);
        }
      });
    }
  }

  dynamic toJson() {

  }

  List<Renderable> _determineVisibleSet(List<Renderable> renderables,
                                        Camera camera) {
    if (renderables == null) {
      return null;
    }
    List<Renderable> visibleSet = new List<Renderable>();
    int numRenderables = renderables.length;
    for (int i = 0; i < numRenderables; i++) {
      Renderable renderable = renderables[i];
      bool visible = true; // drawable.visibleTo(camera);
      if (!visible)
        continue;
      visibleSet.add(renderable);
    }
    return visibleSet;
  }

  void _sortDrawables(List<Renderable> visibleSet, int sortMode) {
  }

  void _applyMaterial(Material material) {
    var constant = material.constants['time'];
    if (constant != null) {
      constant.value[0] = time / 1000.0;
    }
    material.apply(device);
  }

  /// Takes two materials [primary] and [fallback] and configures the GPU
  /// to draw using the material. Any material properties not defined in
  /// [primary] will be looked in [fallback] before falling back to the
  /// defaults specified by the shader.
  /// NOTE: [primary] and [fallback] must have the same shader.
  void applyMaterial(Material primary, Material fallback) {
    if (fallback != null) {
      assert(primary.shader == fallback.shader);
    }
    _applyMaterial(primary);
  }

  /// Draws a single triangle covering the entire viewport. Useful for
  /// doing full screen passes.
  void renderFullscreenMesh(Material material) {
    _fullscreenMeshInputLayout.shaderProgram = material.shader.shader;
    device.context.setInputLayout(_fullscreenMeshInputLayout);
    device.context.setMesh(_fullscreenMesh);
    device.context.drawMesh(_fullscreenMesh);
  }

  void _renderSceneLayer(Layer layer, List<Renderable> renderables,
                         Camera camera) {
    for (int i = 0; i < renderables.length; i++) {

    }
  }

  void _renderLayer(Layer layer, List<Renderable> renderables, Camera camera) {
    RenderTarget renderTarget = _rendererPack[layer.renderTarget];
    if (renderTarget == null) {
      print('Render target ${layer.renderTarget} cannot be found...');
      print('... skipping ${layer.name}');
      return;
    }
    device.context.setRenderTarget(renderTarget);
    if (layer.clearColorTarget) {
      device.context.setBlendState(_clearBlendState);
      device.context.clearColorBuffer(layer.clearColorR, layer.clearColorG,
                                      layer.clearColorB, layer.clearColorA);
    }
    if (layer.clearDepthTarget) {
      device.context.setDepthState(_clearDepthState);
      device.context.clearDepthBuffer(layer.clearDepthValue);
    }
    layer.render(this, renderables, camera);
  }

  void render(List<Layer> layers, List<Renderable> renderables, Camera camera) {
    frontBufferViewport.width = frontBuffer.width;
    frontBufferViewport.height = frontBuffer.height;
    List<Renderable> visibleSet;
    visibleSet = _determineVisibleSet(renderables, camera);
    final int numLayers = layers.length;
    for (int layerIndex = 0; layerIndex < numLayers; layerIndex++) {
      _renderLayer(layers[layerIndex], visibleSet, camera);
    }
  }

  void _buildFullscreenMesh() {
    _fullscreenMesh = new SingleArrayMesh('Renderer.FullscreenMesh', device);
    Float32List fullscreenVertexArray = new Float32List(12);
    // Vertex 0
    fullscreenVertexArray[0] = -1.0;
    fullscreenVertexArray[1] = -1.0;
    fullscreenVertexArray[2] = 0.0;
    fullscreenVertexArray[3] = 0.0;
    // Vertex 1
    fullscreenVertexArray[4] = 3.0;
    fullscreenVertexArray[5] = -1.0;
    fullscreenVertexArray[6] = 2.0;
    fullscreenVertexArray[7] = 0.0;
    // Vertex 2
    fullscreenVertexArray[8] = -1.0;
    fullscreenVertexArray[9] = 3.0;
    fullscreenVertexArray[10] = 0.0;
    fullscreenVertexArray[11] = 2.0;
    _fullscreenMesh.vertexArray.uploadData(fullscreenVertexArray,
                                           SpectreBuffer.UsageStatic);
    _fullscreenMesh.attributes['vPosition'] = new SpectreMeshAttribute(
        'vPosition',
        'float',
        2,
        0,
        16,
        false);
    _fullscreenMesh.attributes['vTexCoord'] = new SpectreMeshAttribute(
        'vTexCoord',
        'float',
        2,
        8,
        16,
        false);
    _fullscreenMesh.count = 3;
    _fullscreenMeshInputLayout = new InputLayout('fullscreen', device);
    _fullscreenMeshInputLayout.mesh = _fullscreenMesh;
  }

  void _buildFullscreenBlitMaterial() {
    _blitMaterialShader = new MaterialShader('blit', this);
    _blitMaterialShader.vertexShader = '''
precision highp float;
attribute vec2 vPosition;
attribute vec2 vTexCoord;
varying vec2 samplePoint;

uniform float time;
uniform vec2 cursor;
uniform vec2 renderTargetResolution;

void main() {
  vec4 vPosition4 = vec4(vPosition.x, vPosition.y, 1.0, 1.0);
  gl_Position = vPosition4;
  samplePoint = vTexCoord;
}
''';
    _blitMaterialShader.fragmentShader = '''
precision mediump float;

uniform float time;
uniform vec2 cursor;
uniform vec2 renderTargetResolution;

varying vec2 samplePoint;
uniform sampler2D source;

void main() {
  gl_FragColor = texture2D(source, samplePoint);
}
''';
    Material blitMaterial = new Material('blit fullscreen', _blitMaterialShader,
                                         this);
    var asset = _fullscreenEffectsPack.registerAsset('blit', 'material', '', '',
                                                     {}, {});
    asset.imported = blitMaterial;
  }

  void _buildFullscreenPassData() {
    NPOTSampler = new SamplerState.linearClamp('Renderer.NPOTSampler', device);
    _buildFullscreenMesh();
    _buildFullscreenBlitMaterial();
  }

  Renderer(this.frontBuffer, this.device, this.assetManager) {
    _clearDepthState = new DepthState('clear depth state', device);
    _clearDepthState.depthBufferWriteEnabled = true;
    _clearBlendState = new BlendState('clear blend state', device);
    _clearBlendState.writeRenderTargetRed = true;
    _clearBlendState.writeRenderTargetGreen = true;
    _clearBlendState.writeRenderTargetBlue = true;
    _clearBlendState.writeRenderTargetAlpha = true;
    _rendererPack = assetManager.registerPack('renderer', '');
    _fullscreenEffectsPack = assetManager.registerPack('fullscreenEffects','');
    _buildFullscreenPassData();
    _frontBufferViewport = new Viewport('Renderer.Viewport', device);
    _frontBufferViewport.width = frontBuffer.width;
    _frontBufferViewport.height = frontBuffer.height;
  }
}

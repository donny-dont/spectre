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
 * draws the world a layer at a time. A layer can render all renderables or
 * do a full screen scene pass.
 */
class Renderer {
  final GraphicsDevice device;
  final CanvasElement frontBuffer;
  final AssetManager assetManager;
  final Map<String, Texture2D> colorBuffers = new Map<String, Texture2D>();
  final Map<String, RenderBuffer> depthBuffers =
      new Map<String, RenderBuffer>();
  final Map<String, RenderTarget> renderTargets =
      new Map<String, RenderTarget>();

  Viewport _frontBufferViewport;
  Viewport get frontBufferViewport => _frontBufferViewport;
  SamplerState _npotSampler;

  void _dispose() {
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
    buffer.uploadPixelArray(width, height, null);
    colorBuffers[name] = buffer;
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
  }

  void _configureFrontBuffer(Map target) {
    int width = target['width'];
    int height = target['height'];
    if (width == null || height == null) {
      throw new ArgumentError('Invalid front buffer description.');
    }
    frontBuffer.width = width;
    frontBuffer.height = height;
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

  void applyCameraUniforms() {
    // Walk over shaders
  }

  List<Renderable> _determineVisibleSet(List<Renderable> renderables,
                                        Camera camera) {
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

  /*
  void _renderPassLayer(Layer layer, List<Renderable> renderables,
                        Camera camera, Viewport viewport) {
    renderables.forEach((renderable) {
      renderable.material.updateCameraConstants(camera);
      renderable.material.updateObjectTransformConstant(renderable.T);
      renderable.material.updateViewportConstants(viewport);
      renderable._render();
    });
  }

  void _renderFullscreenLayer(Layer layer, List<Renderable> drawables,
                              Camera camera, Viewport viewport) {
    String process = layer.properties['process'];
    String source = layer.properties['source'];
    if (process != null && source != null) {
      Texture2D colorTexture = _colorTargets[source];
      Map arguments = {
                       'textures': [colorTexture],
                       'samplers': [_npotSampler],
      };
      SpectrePost.pass(process, layer.renderTarget, arguments);
    }
  }

  void _setupLayer(Layer layer) {
    device.context.setRenderTarget(layer.renderTarget);
    if (layer.clearColorTarget == true) {
      num r = layer.clearColorR;
      num g = layer.clearColorG;
      num b = layer.clearColorB;
      num a = layer.clearColorA;
      device.context.clearColorBuffer(r, g, b, a);
    }
    if (layer.clearDepthTarget == true) {
      num v = layer.clearDepthValue;
      device.context.clearDepthBuffer(v);
    }
  }*/

  void render(List<Renderable> renderables, Camera camera, Viewport viewport) {
    frontBufferViewport.width = frontBuffer.width;
    frontBufferViewport.height = frontBuffer.height;
    device.context.setViewport(viewport);
    List<Renderable> visibleSet;
    visibleSet = _determineVisibleSet(renderables, camera);
    return;
    /*
    int numLayers = layerConfig.layers.length;
    for (int layerIndex = 0; layerIndex < numLayers; layerIndex++) {
      Layer layer = layerConfig.layers[layerIndex];
      _setupLayer(layer);
      if (layer.type == 'pass') {
        _renderPassLayer(layer, renderables, camera, viewport);
      } else if (layer.type == 'fullscreen') {
        _renderFullscreenLayer(layer, renderables, camera, viewport);
      }
    }
    */
  }

  Renderer(this.frontBuffer, this.device, this.assetManager) {
    SpectrePost.init(device);
    _npotSampler = new SamplerState.pointClamp('Renderer.NPOTSampler', device);
    _frontBufferViewport = new Viewport('Renderer.Viewport', device);
    _frontBufferViewport.width = frontBuffer.width;
    _frontBufferViewport.height = frontBuffer.height;
  }
}

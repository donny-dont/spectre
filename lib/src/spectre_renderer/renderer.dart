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
  final Map<String, Texture2D> _colorBuffers = new Map<String, Texture2D>();
  final Map<String, RenderBuffer> _depthBuffers =
      new Map<String, RenderBuffer>();
  final Map<String, RenderTarget> _renderTargets =
      new Map<String, RenderTarget>();

  Viewport _frontBufferViewport;
  Viewport get frontBufferViewport => _frontBufferViewport;
  SamplerState _npotSampler;

  void _makeColorBuffer(Map target) {
    String name = target['name'];
    if (name == null) {
      throw new ArgumentError('A color buffer requires a name.');
    }
    int width = target['width'];
    if (width == null) {
      throw new ArgumentError('A color buffer requires a width.');
    }
    int height = target['height'];
    if (height == null) {
      throw new ArgumentError('A color buffer requires a height.');
    }
    Texture2D buffer = new Texture2D(name, device);
    buffer.uploadPixelArray(width, height, null);
    _colorBuffers[name] = buffer;
  }

  void _makeDepthBuffer(Map target) {
    String name = target['name'];
    if (name == null) {
      throw new ArgumentError('A depth buffer requires a name.');
    }
    int width = target['width'];
    if (width == null) {
      throw new ArgumentError('A depth buffer requires a width.');
    }
    int height = target['height'];
    if (height == null) {
      throw new ArgumentError('A depth buffer requires a height.');
    }
    RenderBuffer buffer = new RenderBuffer(name, device);
    buffer.allocateStorage(width, height, RenderBuffer.FormatDepth);
    _depthBuffers[name] = buffer;
  }

  void _makeRenderTarget(Map configuration) {
    var colorBufferName = configuration['color'];
    var depthBufferName = configuration['depth'];
    var name = configuration['name'];
    if (name == null) {
      throw new ArgumentError('A render targat requires a name.');
    }
    if (colorBufferName == null && depthBufferName == null) {
      throw new ArgumentError(
          'A render target requires a depth buffer or a color buffer');
    }
    var colorBuffer = _colorBuffers[colorBufferName];
    var depthBuffer = _depthBuffers[depthBufferName];
    if (colorBufferName != null && colorBuffer == null) {
      throw new ArgumentError(
          'Cannot find the color buffer named $colorBufferName referenced'
          'by the render target ${name}.');
    }
    if (depthBufferName != null && depthBuffer == null) {
      throw new ArgumentError(
          'Cannot find the depth buffer named $depthBufferName referenced'
          'by the render target ${name}.');
    }
    RenderTarget renderTarget = new RenderTarget(name, device);
    renderTarget.colorTarget = colorBuffer;
    renderTarget.depthTarget = depthBuffer;
    _renderTargets[name] = renderTarget;
  }

  RenderTarget _getRenderTarget(String name) {
    if (name == 'system') {
      return RenderTarget.systemRenderTarget;
    }
    return _renderTargets[name];
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
  }

  void _dispose() {
    _colorBuffers.forEach((_, cb) {
      cb.dispose();
    });
    _colorBuffers.clear();
    _depthBuffers.forEach((_, db) {
      db.dispose();
    });
    _depthBuffers.clear();
    _renderTargets.forEach((_, rt) {
      rt.dispose();
    });
    _renderTargets.clear();
  }

  void _setup(Map configuration) {
    var buffers = configuration['buffers'];
    var targets = configuration['targets'];
    if (buffers != null) {
      buffers.forEach((b) {
        _makeColorBuffer(b);
      });
    }
    if (targets != null) {
      targets.forEach((t) {
        _makeRenderTarget(t);
      });
    }
  }

  set config(Map configuration) {
    _dispose();
    _setup(configuration);
  }

  void render(List<Renderable> renderables, Camera camera, Viewport viewport) {
    frontBufferViewport.width = frontBuffer.width;
    frontBufferViewport.height = frontBuffer.height;
    device.context.setViewport(viewport);
    List<Renderable> visibleSet;
    visibleSet = _determineVisibleSet(renderables, camera);
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

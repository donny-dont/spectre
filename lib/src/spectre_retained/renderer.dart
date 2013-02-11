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

part of spectre_retained;

class Renderer {
  final GraphicsDevice device;
  final CanvasElement frontBuffer;
  final AssetManager assetManager;

  Viewport _frontBufferViewport;
  Viewport get frontBufferViewport => _frontBufferViewport;
  GlobalResources _globalResources;
  GlobalResources get globalResources => _globalResources;
  LayerConfig _layerConfig;
  LayerConfig get layerConfig => _layerConfig;
  SamplerState _npotSampler;

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
      // TODO(johnmccutchan): Support better post process setup.
      Texture2D colorTexture = globalResources.findColorTarget(source);
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

  void render(List<Renderable> renderables, Camera camera, Viewport viewport) {
    frontBufferViewport.width = frontBuffer.width;
    frontBufferViewport.height = frontBuffer.height;
    device.context.setViewport(viewport);
    List<Renderable> visibleSet;
    visibleSet = _determineVisibleSet(renderables, camera);
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
  }

  Renderer(this.frontBuffer, this.device, this.assetManager) {
    _globalResources = new GlobalResources(this, frontBuffer);
    _layerConfig = new LayerConfig(this);
    SpectrePost.init(device);
    _npotSampler = device.createSamplerState('_npotSampler');
    _npotSampler.wrapS = SamplerState.TextureWrapClampToEdge;
    _npotSampler.wrapT = SamplerState.TextureWrapClampToEdge;
    _npotSampler.minFilter = SamplerState.TextureMinFilterNearest;
    _npotSampler.magFilter = SamplerState.TextureMagFilterNearest;
    _frontBufferViewport = device.createViewport('Renderer.Viewport');
    _frontBufferViewport.width = frontBuffer.width;
    _frontBufferViewport.height = frontBuffer.height;
  }
}

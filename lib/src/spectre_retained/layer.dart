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

class Layer {
  final String name;
  final String type;
  final Map properties;
  final RenderTarget renderTarget;
  bool clearColorTarget = false;
  bool clearDepthTarget = false;
  bool clearStencilTarget = false;
  num clearColorR = 0.0;
  num clearColorG = 0.0;
  num clearColorB = 0.0;
  num clearColorA = 1.0;
  num clearDepthValue = 1.0;
  static const int SortModeNone = 0;
  static const int SortModeBackToFront = 1;
  static const int SortModeFrontToBack = 2;
  final int sortMode;
  Layer(this.name, this.type, this.renderTarget, this.sortMode,
        this.properties);
}

class LayerConfig {
  final Renderer renderer;
  final List<Layer> layers = new List<Layer>();

  LayerConfig(this.renderer);

  void _clearLayers() {
    layers.clear();
  }

  int _sortMode(String sortMode) {
    if (sortMode == "BackToFront") {
      return Layer.SortModeBackToFront;
    } else if (sortMode == "FrontToBack") {
      return Layer.SortModeFrontToBack;
    }
    return Layer.SortModeNone;
  }

  void _makeLayer(Map layerConfig) {
    String type = layerConfig['type'];
    RenderTarget renderTarget;
    renderTarget = renderer.globalResources.findRenderTarget(
        layerConfig['colorTarget'],
        layerConfig['depthTarget'],
        layerConfig['stencilTarget']);
    if (renderTarget == null) {
      renderTarget = renderer.globalResources.makeRenderTarget(
          layerConfig['colorTarget'],
          layerConfig['depthTarget'],
          layerConfig['stencilTarget']);
    }
    assert(renderTarget != null);
    int sortMode = _sortMode(layerConfig['sort']);
    Layer layer = new Layer(layerConfig['name'], type, renderTarget, sortMode,
                            layerConfig);
    layer.clearColorTarget = layerConfig['clearColorTarget'] != null ?
                             layerConfig['clearColorTarget'] : false;
    layer.clearDepthTarget = layerConfig['clearDepthTarget'] != null ?
                             layerConfig['clearDepthTarget'] : false;
    List<double> clearColor = layerConfig['clearColor'];
    if (clearColor != null) {
      layer.clearColorR = clearColor[0];
      layer.clearColorG = clearColor[1];
      layer.clearColorB = clearColor[2];
      layer.clearColorA = clearColor[3];
    }
    double clearDepth = layerConfig['clearDepth'];
    if (clearDepth != null) {
      layer.clearDepthValue = clearDepth;
    }
    layers.add(layer);
  }

  void load(Map config) {
    _clearLayers();
    List<Map> layersConfig = config['layers'];
    layersConfig.forEach((layer) {
      _makeLayer(layer);
    });
  }
}
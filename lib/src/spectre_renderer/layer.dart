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

/** A layer describes one rendering pass.
 *
 * A layer has a type: full screen pass or a scene pass. A full screen pass
 * is typically a post-processing effect such as blur or shadow map.
 * A scene pass sorts the renderables in the scene and then draws them.
 *
 * A layer selects the color and depth buffers being written to.
 *
 * A layer controls whether or not the depth and color buffers are cleared
 * before drawing and what value they should be cleared to.
 *
 * The material used to draw a renderable is controlled by the layer name.
 */
class Layer {
  static const int SortModeNone = 0;
  static const int SortModeBackToFront = 1;
  static const int SortModeFrontToBack = 2;
  int _sortMode = SortModeNone;
  int get sortMode => _sortMode;
  set sortMode(int sm) {
    if (sm != SortModeNone && sm != SortModeBackToFront &&
        sm != SortModeFrontToBack) {
      throw new ArgumentError('sortMode invalid.');
    }
    _sortMode = sm;
  }

  final String name;
  final String type;

  String _depthTarget = 'system';
  String get depthTarget => _depthTarget;
  set depthTarget(String name) {
    _depthTarget = name;
    _link();
  }

  String _colorTarget = 'system';
  String get colorTarget => _colorTarget;
  set colorTarget(String name) {
    _colorTarget = name;
    _link();
  }

  bool clearColorTarget = false;
  bool clearDepthTarget = false;
  num clearColorR = 0.0;
  num clearColorG = 0.0;
  num clearColorB = 0.0;
  num clearColorA = 1.0;
  num clearDepthValue = 1.0;

  Layer(this.name, this.type) {
    _link();
  }

  Layer.json(Map json) : name = json['name'], type = json['type'] {
    fromJson(json);
    _link();
  }

  void _link() {
    _invalidate();
  }

  void _invalidate() {
    _renderTarget = null;
  }

  RenderTarget _renderTarget;

  void fromJson(Map json) {
    colorTarget = json['colorTarget'];
    depthTarget = json['depthTarget'];
    clearColorTarget = json['clearColorTarget'];
    clearColorR = json['clearColorR'];
    clearColorG = json['clearColorG'];
    clearColorB = json['clearColorB'];
    clearColorA = json['clearColorA'];
    clearDepthTarget = json['clearDepthTarget'];
    clearDepthValue = json['clearDepthValue'];
  }

  dynamic toJson() {
    Map json = new Map();
    json['name'] = name;
    json['type'] = type;
    json['colorTarget'] = colorTarget;
    json['depthTarget'] = depthTarget;
    json['clearColorTarget'] = clearColorTarget;
    json['clearColorR'] = clearColorR;
    json['clearColorG'] = clearColorG;
    json['clearColorB'] = clearColorB;
    json['clearColorA'] = clearColorA;
    json['clearDepthTarget'] = clearDepthTarget;
    json['clearDepthValue'] = clearDepthValue;
  }
}

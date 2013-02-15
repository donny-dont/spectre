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

class GlobalResources {
  final Renderer renderer;
  final CanvasElement frontBuffer;
  final Map<String, Texture2D> _colorTargets = new Map<String, Texture2D>();
  final Map<String, RenderBuffer> _depthTargets = new Map<String, RenderBuffer>();
  final List<RenderTarget> _renderTargets = new List<RenderTarget>();

  GlobalResources(this.renderer, this.frontBuffer);

  void _clearTargets() {
    _colorTargets.forEach((_, t) {
      t.dispose();
    });
    _colorTargets.clear();
    _depthTargets.forEach((_, t) {
      t.dispose();
    });
    _depthTargets.clear();
    _renderTargets.forEach((t) {
      t.dispose();
    });
    _renderTargets.clear();
  }

  void _makeColorTarget(Map target) {
    String name = target['name'];
    assert(name != null);
    Texture2D buffer = new Texture2D(name, renderer.device);
    int width = target['width'];
    int height = target['height'];
    buffer.uploadPixelArray(width, height, null);
    assert(buffer != null);
    _colorTargets[name] = buffer;
  }

  void _makeDepthTarget(Map target) {
    String name = target['name'];
    assert(name != null);
    RenderBuffer buffer = new RenderBuffer(name, renderer.device);
    int width = target['width'];
    int height = target['height'];
    buffer.allocateStorage(width, height, RenderBuffer.FormatDepth);
    assert(buffer != null);
    _depthTargets[name] = buffer;
  }

  void _configureFrontBuffer(Map target) {
    int width = target['width'];
    int height = target['height'];
    frontBuffer.width = width;
    frontBuffer.height = height;
  }

  Texture2D findColorTarget(String colorTarget) {
    return _colorTargets[colorTarget];
  }

  RenderBuffer findDepthBuffer(String depthTarget) {
    return _depthTargets[depthTarget];
  }

  RenderTarget findRenderTarget(String colorTarget, String depthTarget,
                                String stencilTarget) {
    if (colorTarget == 'frontBuffer' ||
        depthTarget == 'frontBuffer' ||
        stencilTarget == 'frontBuffer') {
      return RenderTarget.systemRenderTarget;
    }
    var colorBuffer = _colorTargets[colorTarget];
    var depthBuffer = _depthTargets[depthTarget];
    for (int i = 0; i < _renderTargets.length; i++) {
      RenderTarget rt = _renderTargets[i];
      if (rt.colorTarget == colorBuffer && rt.depthTarget == depthBuffer) {
        return rt;
      }
    }
    return null;
  }

  RenderTarget makeRenderTarget(String colorTarget, String depthTarget,
                                String stencilTarget) {
    var colorBuffer = _colorTargets[colorTarget];
    var depthBuffer = _depthTargets[depthTarget];
    String name = 'RT:';
    if (colorBuffer != null) {
      name = '$name CB: ${colorBuffer.name}';
    }
    if (depthBuffer != null) {
      name = '$name DB: ${depthBuffer.name}';
    }
    RenderTarget renderTarget = new RenderTarget(name, renderer.device);
    renderTarget.colorTarget = colorBuffer;
    renderTarget.depthTarget = depthBuffer;
    assert(renderTarget != null);
    _renderTargets.add(renderTarget);
    return renderTarget;
  }

  void load(Map config) {
    _clearTargets();
    List<Map> targets = config['targets'];
    targets.forEach((target) {
      if (target['type'] == 'color') {
        _makeColorTarget(target);
      } else if (target['type'] == 'depth') {
        _makeDepthTarget(target);
      } else {
        assert(target['name'] == 'frontBuffer');
        _configureFrontBuffer(target);
      }
    });
  }
}

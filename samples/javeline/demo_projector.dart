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

class JavelineProjector extends JavelineBaseDemo {
  Loader _loader;
  Scene _scene;
  
  JavelineProjector(Device device, ResourceManager resourceManager, DebugDrawManager debugDrawManager) : super(device, resourceManager, debugDrawManager) {
    _scene = new Scene(device, resourceManager);
    _loader = new Loader(_scene, device, resourceManager);
  }
  
  String get demoDescription() => 'Projector';
  
  Future<JavelineDemoStatus> startup() {
    Future<JavelineDemoStatus> base = super.startup();
    return base.chain((r) {
      return _loader.loadFromUrl('/scenes/test.scene');
    });
  }
  
  Future<JavelineDemoStatus> shutdown() {
    Future<JavelineDemoStatus> base = super.shutdown();
    return base;
  }
  
  void update(num time, num dt) {
    super.update(time, dt);
    _scene.update(time, dt);
    _scene.render(camera, {
      'projectionTransform': projectionTransform,
      'viewTransform': viewTransform,
      'projectionViewTransform': projectionViewTransform,
      'normalTransform': normalTransform
    });
    drawHolodeck(4);
    debugDrawManager.prepareForRender();
    debugDrawManager.render(camera);
  }
}

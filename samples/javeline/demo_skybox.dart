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

class JavelineSkyboxDemo extends JavelineBaseDemo {
  Skybox _skybox;
  num _blendT;
  num _blendTDirection;
  JavelineSkyboxDemo(Device device, ResourceManager resourceManager, DebugDrawManager debugDrawManager) : super(device, resourceManager, debugDrawManager) {
    _skybox = new Skybox(device, resourceManager, '/textures/skybox1.png', '/textures/skybox2.png');
    _blendT = 0.0;
    _blendTDirection = 0.05;
  }

  String get demoDescription() => 'Sky Box';
  
  Future<JavelineDemoStatus> startup() {
    Future<JavelineDemoStatus> base = super.startup();
    _skybox.init();
    return base;
  }

  Future<JavelineDemoStatus> shutdown() {
    Future<JavelineDemoStatus> base = super.shutdown();
    _skybox.fini();
    return base;
  }

  void _updateBlendT(num dt) {
    _blendT += dt * _blendTDirection;
    if (_blendT > 1.0) {
      _blendT = 1.0;
      _blendTDirection *= -1.0;
    } else if (_blendT < 0.0) {
      _blendT = 0.0;
      _blendTDirection *= -1.0;
    }
  }

  void update(num time, num dt) {
    Profiler.enter('Demo Update');
    Profiler.enter('super.update');
    super.update(time, dt);
    Profiler.exit();
    _updateBlendT(dt);
    drawGrid(20);
    _skybox.draw(camera, _blendT);
    debugDrawManager.prepareForRender();
    debugDrawManager.render(camera);
    Profiler.exit();
  }
}

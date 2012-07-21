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

class JavelineDebugDrawTest extends JavelineBaseDemo {
  
  Map<String, vec4> _colors;
  vec3 _origin;
  vec3 _unitX;
  vec3 _unitY;
  vec3 _unitZ;
  mat4x4 _rotateX;
  mat4x4 _rotateY;
  mat4x4 _rotateZ;
  num _angle;
  
  JavelineDebugDrawTest(Device device, ResourceManager resourceManager, DebugDrawManager debugDrawManager) : super(device, resourceManager, debugDrawManager) {
    _colors = new Map<String, vec4>();
    _colors['Red'] = new vec4(1.0, 0.0, 0.0, 1.0);
    _colors['Green'] = new vec4(0.0, 1.0, 0.0, 1.0);
    _colors['Blue'] = new vec4(0.0, 0.0, 1.0, 1.0);
    _colors['Gray'] = new vec4(0.3, 0.3, 0.3, 1.0);
    _colors['White'] = new vec4(1.0, 1.0, 1.0, 1.0);
    _colors['Orange'] = new vec4(1.0, 0.6475, 0.0, 1.0);
    _origin = new vec3(0.0, 0.0, 0.0);
    _unitX = new vec3(1.0, 0.0, 0.0);
    _unitY = new vec3(0.0, 1.0, 0.0);
    _unitZ = new vec3(0.0, 0.0, 1.0);
    _angle = 0.0;
    _rotateX = new mat4x4.identity();
    _rotateY = new mat4x4.identity();
    _rotateZ = new mat4x4.identity();
  }
  
  Future<JavelineDemoStatus> startup() {
    Future<JavelineDemoStatus> base = super.startup();
    print('Startup');
    return base;
  }
  
  Future<JavelineDemoStatus> shutdown() {
    Future<JavelineDemoStatus> base = super.shutdown();
    return base;
  }
  
  void update(num time, num dt) {
    super.update(time, dt);
    
    _angle += dt * 3.14159;
    _rotateX.setRotationAroundX(_angle);
    _rotateY.setRotationAroundY(_angle);
    _rotateZ.setRotationAroundZ(_angle);
    
    // Global Axis
    debugDrawManager.addLine(_origin, _unitX * 20.0, _colors['Red']);
    debugDrawManager.addLine(_origin, _unitY * 20.0, _colors['Green']);
    debugDrawManager.addLine(_origin, _unitZ * 20.0, _colors['Blue']);
    
    // Rotating transformations
    {
      mat4x4 T = null;
      T = new mat4x4.translateRaw(5.0, 0.0, 0.0) * _rotateX;
      debugDrawManager.addAxes(T, 4.0);
      T = new mat4x4.translateRaw(0.0, 5.0, 0.0) * _rotateY;
      debugDrawManager.addAxes(T, 4.0);
      T = new mat4x4.translateRaw(0.0, 0.0, 5.0) * _rotateZ;
      debugDrawManager.addAxes(T, 4.0);
    }
    
    // Rotating circles
    {
      debugDrawManager.addCircle(new vec3(0.0, 10.0, 0.0), _rotateY.transform3(_unitX), 3.14, _colors['Red']);
      debugDrawManager.addCircle(new vec3(0.0, 0.0, 10.0), _rotateZ.transform3(_unitY), 3.14, _colors['Green']);
      debugDrawManager.addCircle(new vec3(10.0, 0.0, 0.0), _rotateX.transform3(_unitZ), 3.14, _colors['Blue']);
    }
    
    // AABB and a line from min to max
    {
      debugDrawManager.addAABB(new vec3(5.0, 5.0, 5.0), new vec3(10.0, 10.0, 10.0), _colors['Gray']);
      debugDrawManager.addCross(new vec3(5.0, 5.0, 5.0), _colors['White']);
      debugDrawManager.addCross(new vec3(10.0, 10.0, 10.0), _colors['White']);
      debugDrawManager.addLine(new vec3(5.0, 5.0, 5.0), new vec3(10.0, 10.0, 10.0), _colors['Orange']);
    }
    
    debugDrawManager.prepareForRender();
    debugDrawManager.render(_camera);
  }
}

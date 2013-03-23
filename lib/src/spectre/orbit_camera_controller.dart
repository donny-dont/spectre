/*
  Copyright (C) 2013 Spectre Authors

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

part of spectre;

class OrbitCameraController extends CameraController {
  num mouseSensitivity;

  int accumDX;
  int accumDY;
  int accumDZ;
  
  num yaw;
  num pitch;
  num radius;
  
  num minYaw;
  num maxYaw;
  num minRadius;
  num maxRadius;
  
  vec2 momentum;
  
  num friction;

  OrbitCameraController() {
    accumDX = 0;
    accumDY = 0;
    accumDZ = 0;
    mouseSensitivity = 360.0;
    
    pitch = 0;
    yaw = 0;
    radius = 100;
    
    minYaw = -Math.PI * 0.25;
    maxYaw = Math.PI * 0.33;
    
    minRadius = 50.0;
    maxRadius = 200.0;
    
    friction = 1.0;
    momentum = new vec2();
  }

  void updateCamera(num seconds, Camera cam) {
    if(accumDX != 0 || accumDY != 0) {
      momentum.x = accumDX/mouseSensitivity;
      momentum.y = accumDY/mouseSensitivity;

      accumDX = 0;
      accumDY = 0;
    }
    
    num momentumLen = momentum.length;
    
    if(momentumLen == 0.0) {
      return;
    }
    
    _RotateView(seconds, cam, momentum.x, momentum.y);
    
    momentumLen = max(0.0, momentumLen - (friction * seconds));
    
    momentum.normalize();
    momentum.scale(momentumLen);
  }

  void _RotateView(num dt, Camera cam, num yawDelta, num pitchDelta) {
    yaw += yawDelta;
    pitch = (pitch + pitchDelta).clamp(minYaw, maxYaw);
    
    vec3 offset = new vec3.raw(
      radius * cos(yaw) * cos(pitch),
      radius * sin(pitch),
      radius * sin(yaw) * cos(pitch)
    );

    cam.position = cam.focusPosition + offset;
  }
  
  void _ZoomView(num dt, Camera cam, num zoomDelta) {
    yaw += yawDelta;
    pitch = (pitch + pitchDelta).clamp(minYaw, maxYaw);
    
    vec3 offset = new vec3.raw(
      radius * cos(yaw) * cos(pitch),
      radius * sin(pitch),
      radius * sin(yaw) * cos(pitch)
    );

    cam.position = cam.focusPosition + offset;
  }
}



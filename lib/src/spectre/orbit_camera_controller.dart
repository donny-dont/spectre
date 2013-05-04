/*
  Copyright (C) 2013 John McCutchan

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
  num mouseSensitivity = 360.0;
  num zoomSpeed = 10.0;

  num accumDX = 0.0;
  num accumDY = 0.0;
  num accumDZ = 0.0;

  num yaw = 0.0;
  num pitch = 0.0;
  num radius = 100.0;

  num minYaw = -Math.PI * 0.25;
  num maxYaw = Math.PI * 0.33;
  num minRadius = 50.0;
  num maxRadius = 250.0;

  num momentumDuration = 0.650;

  bool hasMomentum = true;
  bool hasFriction = true;

  vec2 _momentum = new vec2.zero();
  num _momentumTime = 0;

  OrbitCameraController() {

  }

  void updateCamera(num dt, Camera cam) {
    if(accumDX != 0 || accumDY != 0) {
      _momentum.x = accumDX/mouseSensitivity;
      _momentum.y = accumDY/mouseSensitivity;

      accumDX = 0;
      accumDY = 0;

      _momentumTime = 0;
    }

    if(accumDZ !=0) {
      _ZoomView(dt, accumDZ);
      accumDZ = 0;
    }

    _RotateView(dt, cam, _momentum.x, _momentum.y);

    _ApplyFriction(dt);
  }

  double _clamp(double v, double min, double max) {
    if (v > maxRadius) {
      return maxRadius;
    }
    if (v < minRadius) {
      return minRadius;
    }
    return v;
  }
  
  void _ZoomView(num dt, num zoomDelta) {
    radius = _clamp(radius + zoomDelta, minRadius, maxRadius);
    // TODO: Exponential zoom?
    // TODO: Incorporate dt
  }

  void _RotateView(num dt, Camera cam, num yawDelta, num pitchDelta) {
    yaw += yawDelta;
    pitch = _clamp(pitch + pitchDelta, minYaw, maxYaw);
    vec3 offset = new vec3(
      radius * Math.cos(yaw) * Math.cos(pitch),
      radius * Math.sin(pitch),
      radius * Math.sin(yaw) * Math.cos(pitch)
    );

    cam.position = cam.focusPosition + offset;
  }

  void _ApplyFriction(num dt) {
    if(!hasMomentum) {
      _momentum.x = 0.0;
      _momentum.y = 0.0;
      return;
    }

    if(!hasFriction) {
      return;
    }

    num momentumLen = _momentum.length;
    if(momentumLen == 0.0) {
      return;
    }

    _momentumTime += dt;

    if(_momentumTime >= momentumDuration) {
      _momentum.x = 0.0;
      _momentum.y = 0.0;
      return;
    }

    momentumLen -= momentumLen * (_momentumTime / momentumDuration);
    _momentum.normalize();
    _momentum.scale(momentumLen);
  }
}



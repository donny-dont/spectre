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

class FpsFlyCameraController extends CameraController {
  bool up;
  bool down;
  bool strafeLeft;
  bool strafeRight;
  bool forward;
  bool backward;

  num floatVelocity;
  num strafeVelocity;
  num forwardVelocity;
  num mouseSensitivity;

  int accumDX;
  int accumDY;

  FpsFlyCameraController() {
    floatVelocity = 5.0;
    strafeVelocity = 5.0;
    forwardVelocity = 5.0;
    up = false;
    down = false;
    strafeLeft = false;
    strafeRight = false;
    forward = false;
    backward = false;
    accumDX = 0;
    accumDY = 0;
    mouseSensitivity = 360.0;
  }

  void updateCamera(num seconds, Camera cam) {
    _MoveFloat(seconds, up, down, cam);
    _MoveStrafe(seconds, strafeRight, strafeLeft, cam);
    _MoveForward(seconds, forward, backward, cam);
    _RotateView(seconds, cam);
  }

  void _MoveFloat(num dt, bool positive, bool negative, Camera cam) {
    num scale = 0.0;
    if (positive) {
      scale += 1.0;
    }
    if (negative) {
      scale -= 1.0;
    }
    if (scale == 0.0) {
      return;
    }
    scale = scale * dt * floatVelocity;
    vec3 upDirection = new vec3(0.0, 1.0, 0.0);
    upDirection.scale(scale);
    cam.focusPosition.add(upDirection);
    cam.position.add(upDirection);
  }

  void _MoveStrafe(num dt, bool positive, bool negative, Camera cam) {
    num scale = 0.0;
    if (positive) {
      scale += 1.0;
    }
    if (negative) {
      scale -= 1.0;
    }
    if (scale == 0.0) {
      return;
    }
    scale = scale * dt * strafeVelocity;
    vec3 frontDirection = cam.frontDirection;
    frontDirection.normalize();
    vec3 upDirection = new vec3(0.0, 1.0, 0.0);
    vec3 strafeDirection = frontDirection.cross(upDirection);
    strafeDirection.scale(scale);
    cam.focusPosition.add(strafeDirection);
    cam.position.add(strafeDirection);
  }

  void _MoveForward(num dt, bool positive, bool negative, Camera cam) {
    num scale = 0.0;
    if (positive) {
      scale += 1.0;
    }
    if (negative) {
      scale -= 1.0;
    }
    if (scale == 0.0) {
      return;
    }
    scale = scale * dt * forwardVelocity;

    vec3 frontDirection = cam.frontDirection;
    frontDirection.normalize();
    frontDirection.scale(scale);
    cam.focusPosition.add(frontDirection);
    cam.position.add(frontDirection);
  }

  void _RotateView(num dt, Camera cam) {
    vec3 frontDirection = cam.frontDirection;
    frontDirection.normalize();
    vec3 upDirection = new vec3(0.0, 1.0, 0.0);
    vec3 strafeDirection = frontDirection.cross(upDirection);
    strafeDirection.normalize();

    num mouseYawDelta = accumDX/mouseSensitivity;
    num mousePitchDelta = accumDY/mouseSensitivity;
    accumDX = 0;
    accumDY = 0;

    final num f_dot_up = frontDirection.dot(upDirection);
    final num pitchAngle = acos(f_dot_up);
    final num minPitchAngle = 0.785398163;
    final num maxPitchAngle = 2.35619449;
    final num pitchDegrees = degrees(pitchAngle);
    final num minPitchDegrees = degrees(minPitchAngle);
    final num maxPitchDegrees = degrees(maxPitchAngle);
    if (pitchAngle+mousePitchDelta <= maxPitchAngle &&
        pitchAngle+mousePitchDelta >= minPitchAngle) {
      _RotateEyeAndLook(mousePitchDelta, strafeDirection, cam);
    }
    _RotateEyeAndLook(mouseYawDelta, upDirection, cam);
  }

  void _RotateEyeAndLook(num delta_angle, vec3 axis, Camera cam) {
    quat q = new quat.axisAngle(axis, delta_angle);
    vec3 frontDirection = cam.frontDirection;
    frontDirection.normalize();
    q.rotate(frontDirection);
    frontDirection.normalize();
    cam.focusPosition = cam.position + frontDirection;
  }
}

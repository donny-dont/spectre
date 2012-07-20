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

class MouseKeyboardCameraController implements CameraController {
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

  MouseKeyboardCameraController() {
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

  void UpdateCamera(num seconds, Camera cam) {
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
    vec3 upDirection = new vec3.raw(0.0, 1.0, 0.0);
    upDirection.selfScale(scale);
    cam.lookAtPosition.selfAdd(upDirection);
    cam.eyePosition.selfAdd(upDirection);
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
    vec3 upDirection = new vec3.raw(0.0, 1.0, 0.0);
    vec3 strafeDirection = frontDirection.cross(upDirection);
    strafeDirection.selfScale(scale);
    cam.lookAtPosition.selfAdd(strafeDirection);
    cam.eyePosition.selfAdd(strafeDirection);
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
    //print('$frontDirection');
    frontDirection.normalize();
    frontDirection.selfScale(scale);
    cam.lookAtPosition.selfAdd(frontDirection);
    cam.eyePosition.selfAdd(frontDirection);
  }

  void _RotateView(num dt, Camera cam) {
    vec3 frontDirection = cam.frontDirection;
    frontDirection.normalize();
    vec3 upDirection = new vec3.raw(0.0, 1.0, 0.0);
    vec3 strafeDirection = frontDirection.cross(upDirection);
    strafeDirection.normalize();

    num mouseYawDelta = accumDX/mouseSensitivity;
    num mousePitchDelta = accumDY/mouseSensitivity;
    accumDX = 0;
    accumDY = 0;

    // pitch rotation
    {
      bool above = false;
      if (frontDirection.y > 0.0) {
        above = true;
      }
      num f_dot_up = frontDirection.dot(upDirection);
      num pitchAngle = acos(f_dot_up);
      num pitchDegrees = degrees(pitchAngle);

      final num minPitchAngle = 0.785398163;
      final num maxPitchAngle = 2.35619449;
      final num minPitchDegrees = degrees(minPitchAngle);
      final num maxPitchDegrees = degrees(maxPitchAngle);

      _RotateEyeAndLook(mousePitchDelta, strafeDirection, cam);

      if (above) {
        if (pitchAngle > minPitchAngle || (pitchAngle <= minPitchAngle && mousePitchDelta > 0.0)) {
          _RotateEyeAndLook(mousePitchDelta, strafeDirection, cam);
        }
      } else {
        if (pitchAngle < maxPitchAngle || (pitchAngle >= maxPitchAngle && mousePitchDelta < 0.0)) {
          _RotateEyeAndLook(mousePitchDelta, strafeDirection, cam);
        }
      }
    }

    _RotateEyeAndLook(mouseYawDelta, upDirection, cam);
  }

  void _RotateEyeAndLook(num delta_angle, vec3 axis, Camera cam) {
    quat q = new quat(axis, delta_angle);
    vec3 frontDirection = cam.frontDirection;
    frontDirection.normalize();
    q.rotateSelf(frontDirection);
    frontDirection.normalize();
    cam.lookAtPosition = cam.eyePosition + frontDirection;
  }
}

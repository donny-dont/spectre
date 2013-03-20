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

  OrbitCameraController() {
    accumDX = 0;
    accumDY = 0;
    mouseSensitivity = 360.0;
  }

  void updateCamera(num seconds, Camera cam) {
    _RotateView(seconds, cam);
  }

  void _RotateView(num dt, Camera cam) {
    if(accumDX == 0 && accumDY == 0) {
      return;
    }
    
    num mouseYawDelta = accumDX/mouseSensitivity;
    num mousePitchDelta = accumDY/mouseSensitivity;
    accumDX = 0;
    accumDY = 0;
    
    vec3 upDirection = new vec3.raw(0.0, 1.0, 0.0);
    vec3 posToFocus = cam.focusPosition - cam.position;
    quat q;
    
    /*q = new quat(strafeDirection, mousePitchDelta);
    q.rotate(posToFocus);*/
    
    q = new quat(upDirection, mouseYawDelta);
    q.rotate(posToFocus);
    
    cam.position = cam.focusPosition + posToFocus;
  }
}



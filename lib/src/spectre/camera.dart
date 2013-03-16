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

class Camera {
  vec3 position;
  vec3 upDirection;
  vec3 focusPosition;
  num zNear;
  num zFar;
  num aspectRatio;
  num FOV;

  String toString() {
    return '$position -> $focusPosition';
  }

  Camera() {
    position = new vec3.raw(0.0, 0.0, 0.0);
    focusPosition = new vec3.raw(0.0, 0.0, -1.0);
    upDirection = new vec3.raw(0.0, 1.0, 0.0);

    FOV = 0.785398163; // 2*45 degrees
    zNear = 1.0;
    zFar = 1000.0;
    aspectRatio = 1.7777778;
  }

  num get yaw {
    vec3 z = new vec3(0.0, 0.0, 1.0);
    vec3 forward = frontDirection;
    forward.normalize();
    num d = degrees(acos(forward.dot(z)));
    return d;
  }

  num get pitch {
    vec3 y = new vec3(0.0, 1.0, 0.0);
    vec3 forward = frontDirection;
    forward.normalize();
    num d = degrees(acos(forward.dot(y)));
    return d;
  }

  mat4 get projectionMatrix {
    return makePerspectiveMatrix(FOV, aspectRatio, zNear, zFar);
  }

  mat4 get viewMatrix {
    return makeViewMatrix(position, focusPosition, upDirection);
  }

  void copyProjectionMatrixIntoArray(Float32Array pm) {
    mat4 m = makePerspectiveMatrix(FOV, aspectRatio, zNear, zFar);
    m.copyIntoArray(pm);
  }

  void copyViewMatrixIntoArray(Float32Array vm) {
    mat4 m = makeViewMatrix(position, focusPosition, upDirection);
    m.copyIntoArray(vm);
  }

  void copyNormalMatrixIntoArray(Float32Array nm) {
    mat4 m = makeViewMatrix(position, focusPosition, upDirection);
    m.copyIntoArray(nm);
  }

  void copyProjectionMatrix(mat4 pm) {
    mat4 m = makePerspectiveMatrix(FOV, aspectRatio, zNear, zFar);
    m.copyInto(pm);
  }

  void copyViewMatrix(mat4 vm) {
    mat4 m = makeViewMatrix(position, focusPosition, upDirection);
    m.copyInto(vm);
  }

  void copyNormalMatrix(mat4 nm) {
    mat4 m = makeViewMatrix(position, focusPosition, upDirection);
    m.copyInto(nm);
  }

  void copyEyePosition(vec3 ep) {
    position.copyInto(ep);
  }

  void copyLookAtPosition(vec3 lap) {
    focusPosition.copyInto(lap);
  }

  vec3 get frontDirection =>  (focusPosition-position).normalize();
}

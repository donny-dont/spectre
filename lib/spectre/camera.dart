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

class Camera {
  vec3 eyePosition;
  vec3 upDirection;
  vec3 lookAtPosition;
  num zNear;
  num zFar;
  num aspectRatio;
  num FOV;

  String toString() {
    return '$eyePosition -> $lookAtPosition';
  }

  Camera() {
    eyePosition = new vec3.raw(0.0, 2.0, 2.0);
    lookAtPosition = new vec3.raw(0.0, 2.0, 0.0);
    upDirection = new vec3.raw(0.0, 1.0, 0.0);

    FOV = 0.785398163; // 2*45 degrees
    zNear = 1.0;
    zFar = 1000.0;
    aspectRatio = 1.7777778;
  }

  num get yaw() {
    vec3 z = new vec3(0.0, 0.0, 1.0);
    vec3 forward = frontDirection;
    forward.normalize();
    num d = degrees(acos(forward.dot(z)));
    return d;
  }

  num get pitch() {
    vec3 y = new vec3(0.0, 1.0, 0.0);
    vec3 forward = frontDirection;
    forward.normalize();
    num d = degrees(acos(forward.dot(y)));
    return d;
  }

  mat4x4 get projectionMatrix() {
    return makePerspective(FOV, aspectRatio, zNear, zFar);
  }

  mat4x4 get lookAtMatrix() {
    return makeLookAt(eyePosition, lookAtPosition, upDirection);
  }

  void copyProjectionMatrixIntoArray(Float32Array pm) {
    mat4x4 m = makePerspective(FOV, aspectRatio, zNear, zFar);
    m.copyIntoArray(pm);
  }

  void copyViewMatrixIntoArray(Float32Array vm) {
    mat4x4 m = makeLookAt(eyePosition, lookAtPosition, upDirection);
    m.copyIntoArray(vm);
  }

  void copyNormalMatrixIntoArray(Float32Array nm) {
    mat4x4 m = makeLookAt(eyePosition, lookAtPosition, upDirection);
    m.copyIntoArray(nm);
  }

  void copyProjectionMatrix(mat4x4 pm) {
    mat4x4 m = makePerspective(FOV, aspectRatio, zNear, zFar);
    m.copyIntoMatrix(pm);
  }

  void copyViewMatrix(mat4x4 vm) {
    mat4x4 m = makeLookAt(eyePosition, lookAtPosition, upDirection);
    m.copyIntoMatrix(vm);
  }

  void copyNormalMatrix(mat4x4 nm) {
    mat4x4 m = makeLookAt(eyePosition, lookAtPosition, upDirection);
    m.copyIntoMatrix(nm);
  }

  void copyEyePosition(vec3 ep) {
    eyePosition.copyIntoVector(ep);
  }

  void copyLookAtPosition(vec3 lap) {
    lookAtPosition.copyIntoVector(lap);
  }

  vec3 get frontDirection() => lookAtPosition - eyePosition;
}
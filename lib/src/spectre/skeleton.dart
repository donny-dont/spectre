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

/// Bone.
class Bone {
  final String boneName;
  final Float32List localTransform = new Float32List(16);
  final Float32List offsetTransform = new Float32List(16);
  final List<Bone> children = new List<Bone>();
  Bone _parent;
  int _boneIndex = -1;

  Bone(this.boneName, List<num> local, List<num> offset) {
    if (local != null) {
      for (int i = 0; i < 16; i++) {
        localTransform[i] = local[i].toDouble();
      }
    } else {
      localTransform[0] = 1.0;
      localTransform[5] = 1.0;
      localTransform[10] = 1.0;
      localTransform[15] = 1.0;
    }
    if (offset != null) {
      for (int i = 0; i < 16; i++) {
        offsetTransform[i] = offset[i].toDouble();
      }
    } else {
      offsetTransform[0] = 1.0;
      offsetTransform[5] = 1.0;
      offsetTransform[10] = 1.0;
      offsetTransform[15] = 1.0;
    }
  }

  int get boneIndex => _boneIndex;

  /// Parent bone.
  Bone get parent => _parent;
  set parent(Bone parent) {
    _parent = parent;
  }
}

/// Skeleton.
class Skeleton {
  final String name;
  final Float32List globalOffsetTransform = new Float32List(16);
  final List<Bone> boneList;
  final Map<String, Bone> bones = new Map<String, Bone>();
  Skeleton(this.name, int length) :
      boneList = new List<Bone>(length);
}

/// Skeleton ready to be used for skinning.
class PosedSkeleton {
  final Skeleton skeleton;
  final List<Float32List> globalTransforms;
  final List<Float32List> skinningTransforms;
  final List<Float32x4List> globalTransforms4;
  final List<Float32x4List> skinningTransforms4;
  PosedSkeleton(this.skeleton, int length) :
    globalTransforms = new List<Float32List>(length),
    skinningTransforms = new List<Float32List>(length),
    globalTransforms4 = new List<Float32x4List>(length),
    skinningTransforms4 = new List<Float32x4List>(length) {
    for (int i = 0; i < length; i++) {
      globalTransforms[i] = new Float32List(16);
      globalTransforms4[i] = new Float32x4List.view(globalTransforms[i]);
      skinningTransforms[i] = new Float32List(16);
      skinningTransforms4[i] = new Float32x4List.view(skinningTransforms[i]);
    }
  }
}

abstract class SkeletonPoser {
  /// Poses [skeleton] using [animation] at time [t]. Posed skeleton
  /// is stored in [posedSkeleton].
  pose(Skeleton skeleton, SkeletonAnimation animation,
       PosedSkeleton posedSkeleton, double t);
}

class SimpleSkeletonPoser implements SkeletonPoser {
  final Float32List _scratchMatrix = new Float32List(16);

  void mul44(Float32List out, Float32List a, Float32List b) {
    var a00 = a[0], a01 = a[1], a02 = a[2], a03 = a[3],
        a10 = a[4], a11 = a[5], a12 = a[6], a13 = a[7],
        a20 = a[8], a21 = a[9], a22 = a[10], a23 = a[11],
        a30 = a[12], a31 = a[13], a32 = a[14], a33 = a[15];

    var b0  = b[0], b1 = b[1], b2 = b[2], b3 = b[3];
    out[0] = b0*a00 + b1*a10 + b2*a20 + b3*a30;
    out[1] = b0*a01 + b1*a11 + b2*a21 + b3*a31;
    out[2] = b0*a02 + b1*a12 + b2*a22 + b3*a32;
    out[3] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

    b0 = b[4]; b1 = b[5]; b2 = b[6]; b3 = b[7];
    out[4] = b0*a00 + b1*a10 + b2*a20 + b3*a30;
    out[5] = b0*a01 + b1*a11 + b2*a21 + b3*a31;
    out[6] = b0*a02 + b1*a12 + b2*a22 + b3*a32;
    out[7] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

    b0 = b[8]; b1 = b[9]; b2 = b[10]; b3 = b[11];
    out[8] = b0*a00 + b1*a10 + b2*a20 + b3*a30;
    out[9] = b0*a01 + b1*a11 + b2*a21 + b3*a31;
    out[10] = b0*a02 + b1*a12 + b2*a22 + b3*a32;
    out[11] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

    b0 = b[12]; b1 = b[13]; b2 = b[14]; b3 = b[15];
    out[12] = b0*a00 + b1*a10 + b2*a20 + b3*a30;
    out[13] = b0*a01 + b1*a11 + b2*a21 + b3*a31;
    out[14] = b0*a02 + b1*a12 + b2*a22 + b3*a32;
    out[15] = b0*a03 + b1*a13 + b2*a23 + b3*a33;
  }

  void updateGlobalTransform(
      Bone bone,
      Float32List parentTransform,
      SkeletonAnimation animation,
      PosedSkeleton posedSkeleton,
      double t) {
    int boneIndex = bone._boneIndex;
    final Float32List nodeTransform = _scratchMatrix;
    final Float32List globalTransform =
        posedSkeleton.globalTransforms[boneIndex];
    BoneAnimation boneData = animation.boneList[boneIndex];
    if (boneData != null) {
      boneData.setBoneMatrixAtTime(t, nodeTransform);
    } else {
      for (int i = 0; i < 16; i++) {
        nodeTransform[i] = bone.localTransform[i];
      }
    }
    mul44(globalTransform, parentTransform, nodeTransform);
    for (int i = 0; i < bone.children.length; i++) {
      Bone childBone = bone.children[i];
      updateGlobalTransform(childBone, globalTransform, animation,
                            posedSkeleton, t);
    }
  }

  void updateSkinningTransform(PosedSkeleton posedSkeleton, Skeleton skeleton) {
    for (int i = 0; i < skeleton.boneList.length; i++) {
      final Float32List globalTransform = posedSkeleton.globalTransforms[i];
      final Float32List skinningTransform = posedSkeleton.skinningTransforms[i];
      final Float32List offsetTransform = skeleton.boneList[i].offsetTransform;
      mul44(skinningTransform, globalTransform, offsetTransform);
      mul44(skinningTransform, skeleton.globalOffsetTransform,
            skinningTransform);
    }
  }

  pose(Skeleton skeleton, SkeletonAnimation animation,
      PosedSkeleton posedSkeleton, double t) {
    Float32List parentTransform = new Float32List(16);
    parentTransform[0] = 1.0;
    parentTransform[5] = 1.0;
    parentTransform[10] = 1.0;
    parentTransform[15] = 1.0;
    updateGlobalTransform(skeleton.boneList[0], parentTransform, animation,
                          posedSkeleton, t);
    updateSkinningTransform(posedSkeleton, skeleton);
  }
}
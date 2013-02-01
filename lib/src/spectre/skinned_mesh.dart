part of spectre;

/*

  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

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

class Float32ListHelpers {
  static void copy(Float32List dst, Float32List src) {
    assert(dst.length == src.length);
    for (int i = 0; i < dst.length; i++) {
      dst[i] = src[i];
    }
  }

  static void transpose44(Float32List out) {
    Float32List a = out;
    var a01 = a[1], a02 = a[2], a03 = a[3],
        a12 = a[6], a13 = a[7],
        a23 = a[11];

    out[1] = a[4];
    out[2] = a[8];
    out[3] = a[12];
    out[4] = a01;
    out[6] = a[9];
    out[7] = a[13];
    out[8] = a02;
    out[9] = a12;
    out[11] = a[14];
    out[12] = a03;
    out[13] = a13;
    out[14] = a23;
  }

  static void mul44(Float32List out, Float32List a, Float32List b) {
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
}

class _AnimationBoneData {
  // 1 float per key data
  Float32List _positionTimes;
  // 4 floats per key data
  Float32List _positions;
  // 1 float per key data
  Float32List _scaleTimes;
  // 4 floats pey key data
  Float32List _scales;
  // 1 float per key data
  Float32List _rotationTimes;
  // 4 floats per key data
  Float32List _rotations;

  int _findTime(Float32List timeList, double t) {
    for (int i = 0; i < timeList.length-1; i++) {
      if (t < timeList[i+1]) {
        return i;
      }
    }
    return -1;
  }

  // Returns the index in the animation data that corresponds to the time [t].
  // Returns -1 if not found.
  int _findPositionIndex(double t) {
    return _findTime(_positionTimes, t) << 2;
  }
  int _findScaleIndex(double t) {
    return _findTime(_scaleTimes, t) << 2;
  }
  int _findRotationIndex(double t) {
    return _findTime(_rotationTimes, t) << 2;
  }
}

class Animation {
  final String name;
  Animation(this.name);
  double _runTime = 0.0;
  double get runTime => _runTime;
  // Per bone animation data.
  List<_AnimationBoneData> _boneData;
}

class SkinnedMesh extends SpectreMesh {
  VertexBuffer _deviceVertexBuffer;
  IndexBuffer _deviceIndexBuffer;
  IndexBuffer get indexArray => _deviceIndexBuffer;
  VertexBuffer get vertexArray => _deviceVertexBuffer;
  final List<Map> meshes = new List<Map>();

  SkinnedMesh(String name, GraphicsDevice device) :
      super(name, device);

  void _createDeviceState() {
    super._createDeviceState();
    _deviceVertexBuffer = device.createVertexBuffer('$name[VB]');
    _deviceIndexBuffer = device.createIndexBuffer('$name[IB]');
  }

  void _destroyDeviceState() {
    if (_deviceVertexBuffer != null) {
      device.deleteDeviceChild(_deviceVertexBuffer);
      _deviceVertexBuffer = null;
    }
    if (_deviceIndexBuffer != null) {
      device.deleteDeviceChild(_deviceIndexBuffer);
      _deviceIndexBuffer = null;
    }
    count = 0;
    super._destroyDeviceState();
  }

  Float32List baseVertexData; // The unanimated reference data.
  Float32List vertexData; // The animated vertex data.

  final Float32List globalInverseTransform = new Float32List(16);

  // These are indexed together.
  Float32List weightData;
  Int16List boneData;

  // These are indexed together.
  final Map<String, int> boneNameMapping = new Map<String, int>();
  Int16List boneParents;
  Int16List boneChildrenOffsets;
  final List<Float32List> boneOffsetTransforms = new List<Float32List>();
  final List<Float32List> boneTransforms = new List<Float32List>();
  final List<Float32List> fullBoneTransforms = new List<Float32List>();
  final List<Float32List> finalBoneTransforms = new List<Float32List>();

  // boneChildren[i] will be -1 when no more children.
  Int16List boneChildrenIds;

  // current time.
  double _currentTime = 0.0;

  final Map<String, Animation> animations = new Map<String,Animation>();
  Animation _currentAnimation;
  String get currentAnimation => _currentAnimation.name;
  set currentAnimation(String name) {
    _currentAnimation = animations[name];
  }

  void update(double dt) {
    _currentTime += dt;
    // Wrap.
    while (_currentTime >= _currentAnimation.runTime) {
      _currentTime -= _currentAnimation.runTime;
    }
    Float32List parentTransform = new Float32List(16);
    parentTransform[0] = 1.0;
    parentTransform[5] = 1.0;
    parentTransform[10] = 1.0;
    parentTransform[15] = 1.0;
    _updateBones(0, parentTransform);
    _updateVertices();
  }

  final Float32List _scratchMatrix = new Float32List(16);
  // Updates the bone hierarchy to match the current animation and time.
  void _updateBones(final int boneIndex, final Float32List parentTransform) {
    if (boneIndex < 0 || boneIndex >= boneTransforms.length) {
      return;
    }
    final Float32List nodeTransform = _scratchMatrix;
    if (false) {
      // bone has animation data:
      // build nodeTransform.
    } else {
      // no bone animation data.
      // copy bone transform
      Float32ListHelpers.copy(nodeTransform, boneTransforms[boneIndex]);
    }
    // Compute bone's full transform by computing:
    // Node * Parent.
    final Float32List fullTransform = fullBoneTransforms[boneIndex];
    Float32ListHelpers.mul44(fullTransform, nodeTransform, parentTransform);
    // Compute bone's final transform by computing:
    // globalInverseTransform * fullTransorm * boneOffset
    final Float32List finalTransform = finalBoneTransforms[boneIndex];
    Float32ListHelpers.mul44(finalTransform, fullTransform,
                             boneOffsetTransforms[boneIndex]);
    //Float32ListHelpers.mul44(finalTransform, globalInverseTransform,
    //    finalTransform);
    // Recursively iterate over children bones, updating them.
    int childOffset = boneChildrenOffsets[boneIndex];
    int childIndex = boneChildrenIds[childOffset++];
    while (childIndex != -1) {
      // We pass in fullTransform (this node's transform) as the new
      // parent transformation.
      _updateBones(childIndex, fullTransform);
      childIndex = boneChildrenIds[childOffset++];
    }
  }

  // Transform baseVertexData into vertexData based on bone hierarchy.
  void _updateVertices() {
    return;
    // temporary copy here until actual animation data is computed.
    for (int i = 0; i < baseVertexData.length; i++) {
      vertexData[i] = baseVertexData[i];
    }
    vertexArray.uploadSubData(0, vertexData);
  }
}

SkinnedMesh importSkinnedMesh(String name, GraphicsDevice device, Map json) {
  SkinnedMesh mesh = new SkinnedMesh(name, device);
  List attributes = json['attributes'];
  List vertices = json['vertices'];
  List indices = json['indices'];
  List meshes = json['meshes'];
  List bones = json['bones'];
  List animations = json['animations'];

  // static mesh data begins.
  attributes.forEach((a) {
    String name = a['name'];
    int offset = a['offset'];
    int stride = a['stride'];
    print(a);
    mesh.attributes[name] = new SpectreMeshAttribute(name, 'float', 4,
                                                     offset, stride, false);
  });
  meshes.forEach((m) {
    mesh.meshes.add(m);
  });
  mesh._createDeviceState();
  mesh.vertexArray.uploadData(new Float32Array.fromList(json['vertices']),
                              SpectreBuffer.UsageDynamic);
  mesh.indexArray.uploadData(new Uint16Array.fromList(json['indices']),
                             SpectreBuffer.UsageStatic);
  // static mesh ends.

  // bone hierarchy begins.
  int numChildren = 0;
  bones.forEach((b) {
    String name = b['name'];
    List<double> transform = b['transform'];
    Expect.equals(16, transform.length);
    List<double> offsetTransform = b['offsetTransform'];
    Expect.equals(16, offsetTransform.length);
    List<String> children = b['children'];
    // HACK around broken bone hierarchy.
    if (name == "origin") {
      children = ["sheath", "pubis"];
    }
    if (children == null) {
      children = [];
    }
    numChildren += children.length + 1;
    int id = mesh.boneOffsetTransforms.length;
    mesh.boneNameMapping[name] = id;
    print('mapping $name -> $id');
    mesh.boneOffsetTransforms.add(new Float32List(16));
    for (int i = 0; i < 16; i++) {
      mesh.boneOffsetTransforms[id][i] = offsetTransform[i].toDouble();
    }
    Float32ListHelpers.transpose44(mesh.boneOffsetTransforms[id]);
    mesh.boneTransforms.add(new Float32List(16));
    for (int i = 0; i < 16; i++) {
      mesh.boneTransforms[id][i] = transform[i].toDouble();
    }
    Float32ListHelpers.transpose44(mesh.boneTransforms[id]);
    mesh.fullBoneTransforms.add(new Float32List(16));
    mesh.finalBoneTransforms.add(new Float32List(16));
  });
  mesh.boneParents = new Int16List(bones.length);
  mesh.boneChildrenOffsets = new Int16List(bones.length);
  mesh.boneChildrenIds = new Int16List(numChildren);
  int boneChildrenIdCursor = 0;
  int boneIndex = 0;
  bones.forEach((b) {
    int boneId = boneIndex++;
    String name = b['name'];
    List<String> children = b['children'];
    // HACK around broken bone hierarchy.
    if (name == "origin") {
      children = ["sheath", "pubis"];
    }
    if (children == null) {
      children = [];
    }
    mesh.boneChildrenOffsets[boneId] = boneChildrenIdCursor;
    children.forEach((c) {
      int childId = mesh.boneNameMapping[c];
      Expect.isNotNull(childId);
      mesh.boneChildrenIds[boneChildrenIdCursor++] = childId;
      mesh.boneParents[childId] = boneId;
    });
    mesh.boneChildrenIds[boneChildrenIdCursor++] = -1; // sentinal
  });
  Expect.equals(numChildren, boneChildrenIdCursor);
  // verify children indices:
  boneIndex = 0;
  bones.forEach((b) {
    int boneId = boneIndex++;
    String name = b['name'];
    List<String> children = b['children'];
    // HACK around broken bone hierarchy.
    if (name == "origin") {
      children = ["sheath", "pubis"];
    }
    if (children == null) {
      children = [];
    }
    int offset = mesh.boneChildrenOffsets[boneId];
    int childCount = 0;
    while (mesh.boneChildrenIds[offset] != -1) {
      int childId = mesh.boneChildrenIds[offset];
      // Verify parents
      Expect.equals(mesh.boneParents[childId], boneId);
      childCount++;
      offset++;
    }
    // Verify children count.
    Expect.equals(children.length, childCount);
  });
  // bone hierarchy ends.
  // animation begins:
  animations.forEach((a) {
    String name = a['name'];
    Expect.isNotNull(name, 'animations require a name');
    Expect.notEquals("", name, "Name cannot be empty string.");
    num ticksPerSecond = a['ticksPerSecond'];
    num duration = a['duration'];
    Expect.isNotNull(ticksPerSecond);
    Expect.isNotNull(duration);
    mesh.animations[name] = new Animation(name);
    // TODO: Is ticksPerSecond in the animation data or in the skinned mesh data?
    mesh.animations[name]._runTime = duration.toDouble();
    mesh._currentAnimation = mesh.animations[name];
    // TODO: Add key frame data.
  });
  // animation ends.
  // update the bone matrices.
  mesh.update(0.0);
  return mesh;
}
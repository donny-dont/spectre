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

  static void identity(Float32List out) {
    out[0] = 1.0;
    out[1] = 0.0;
    out[2] = 0.0;
    out[3] = 0.0;

    out[4] = 0.0;
    out[5] = 1.0;
    out[6] = 0.0;
    out[7] = 0.0;

    out[8] = 0.0;
    out[9] = 0.0;
    out[10] = 1.0;
    out[11] = 0.0;

    out[12] = 0.0;
    out[13] = 0.0;
    out[14] = 0.0;
    out[15] = 1.0;
  }

  static void normalize4(Float32List a) {
    var x = a[0],
        y = a[1],
        z = a[2],
        w = a[3];
    var len = x*x + y*y + z*z + w*w;
    if (len > 0) {
        len = 1.0 / Math.sqrt(len);
        a[0] = a[0] * len;
        a[1] = a[1] * len;
        a[2] = a[2] * len;
        a[3] = a[3] * len;
    }
  }
  static void zero(Float32List out) {
    out[0] = 0.0;
    out[1] = 0.0;
    out[2] = 0.0;
    out[3] = 0.0;

    out[4] = 0.0;
    out[5] = 0.0;
    out[6] = 0.0;
    out[7] = 0.0;

    out[8] = 0.0;
    out[9] = 0.0;
    out[10] = 0.0;
    out[11] = 0.0;

    out[12] = 0.0;
    out[13] = 0.0;
    out[14] = 0.0;
    out[15] = 0.0;
  }


  static void translate(Float32List out, Float32List v, int offset) {
    var x = v[offset+0], y = v[offset+1], z = v[offset+2];
    out[12] = out[0] * x + out[4] * y + out[8] * z + out[12];
    out[13] = out[1] * x + out[5] * y + out[9] * z + out[13];
    out[14] = out[2] * x + out[6] * y + out[10] * z + out[14];
    out[15] = out[3] * x + out[7] * y + out[11] * z + out[15];
  }

  static void rotateTranslate(Float32List out,
                              Float32List v,
                              int vIndex,
                              Float32List q,
                              int qIndex) {
    var x = q[qIndex+0], y = q[qIndex+1], z = q[qIndex+2], w = q[qIndex+3],
        x2 = x + x,
        y2 = y + y,
        z2 = z + z,

        xx = x * x2,
        xy = x * y2,
        xz = x * z2,
        yy = y * y2,
        yz = y * z2,
        zz = z * z2,
        wx = w * x2,
        wy = w * y2,
        wz = w * z2;

    out[0] = 1.0 - (yy + zz);
    out[1] = xy + wz;
    out[2] = xz - wy;
    out[3] = 0.0;
    out[4] = xy - wz;
    out[5] = 1 - (xx + zz);
    out[6] = yz + wx;
    out[7] = 0.0;
    out[8] = xz + wy;
    out[9] = yz - wx;
    out[10] = 1.0 - (xx + yy);
    out[11] = 0.0;
    out[12] = v[vIndex+0];
    out[13] = v[vIndex+1];
    out[14] = v[vIndex+2];
    out[15] = 1.0;
  }

  static void fromQuat(Float32List out, Float32List q, int offset) {
    var x = q[offset+0], y = q[offset+1], z = q[offset+2], w = q[offset+3],
        x2 = x + x,
        y2 = y + y,
        z2 = z + z,

        xx = x * x2,
        xy = x * y2,
        xz = x * z2,
        yy = y * y2,
        yz = y * z2,
        zz = z * z2,
        wx = w * x2,
        wy = w * y2,
        wz = w * z2;

    out[0] = 1.0 - (yy + zz);
    out[1] = xy + wz;
    out[2] = xz - wy;
    out[3] = 0.0;

    out[4] = xy - wz;
    out[5] = 1.0 - (xx + zz);
    out[6] = yz + wx;
    out[7] = 0.0;

    out[8] = xz + wy;
    out[9] = yz - wx;
    out[10] = 1.0 - (xx + yy);
    out[11] = 0.0;

    out[12] = 0.0;
    out[13] = 0.0;
    out[14] = 0.0;
    out[15] = 1.0;

  }

  static void transform(out,
                        a, int ii,
                        m) {
    var x = a[ii+0], y = a[ii+1], z = a[ii+2], w = a[ii+3];
    out[0] += (m[0] * x + m[4] * y + m[8] * z + m[12] * w);
    out[1] += (m[1] * x + m[5] * y + m[9] * z + m[13] * w);
    out[2] += (m[2] * x + m[6] * y + m[10] * z + m[14] * w);
    out[3] += (m[3] * x + m[7] * y + m[11] * z + m[15] * w);
  }

  static void addScale44(out, input, scale) {
    out[0] += input[0] * scale;
    out[1] += input[1] * scale;
    out[2] += input[2] * scale;
    out[3] += input[3] * scale;
    out[4] += input[4] * scale;
    out[5] += input[5] * scale;
    out[6] += input[6] * scale;
    out[7] += input[7] * scale;
    out[8] += input[8] * scale;
    out[9] += input[9] * scale;
    out[10] += input[10] * scale;
    out[11] += input[11] * scale;
    out[12] += input[12] * scale;
    out[13] += input[13] * scale;
    out[14] += input[14] * scale;
    out[15] += input[15] * scale;
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

  void _loadPositions(List positions) {
    _positionTimes = new Float32List(positions.length);
    _positions = new Float32List(positions.length*4);
    for (int i = 0; i < _positionTimes.length; i++) {
      _positionTimes[i] = positions[i]['time'].toDouble();
      _positions[i*4+0] = positions[i]['value'][0].toDouble();
      _positions[i*4+1] = positions[i]['value'][1].toDouble();
      _positions[i*4+2] = positions[i]['value'][2].toDouble();
      _positions[i*4+3] = 1.0;
    }
  }

  void _loadRotations(List rotations) {
    _rotationTimes = new Float32List(rotations.length);
    _rotations = new Float32List(rotations.length*4);
    for (int i = 0; i < _rotationTimes.length; i++) {
      _rotationTimes[i] = rotations[i]['time'].toDouble();
      _rotations[i*4+0] = rotations[i]['value'][0].toDouble();
      _rotations[i*4+1] = rotations[i]['value'][1].toDouble();
      _rotations[i*4+2] = rotations[i]['value'][2].toDouble();
      _rotations[i*4+3] = rotations[i]['value'][3].toDouble();
    }
  }

  void _loadScales(List scales) {
    _scaleTimes = new Float32List(scales.length);
    _scales = new Float32List(scales.length*4);
    for (int i = 0; i < _scaleTimes.length; i++) {
      _scaleTimes[i] = scales[i]['time'].toDouble();
      _scales[i*4+0] = scales[i]['value'][0].toDouble();
      _scales[i*4+1] = scales[i]['value'][1].toDouble();
      _scales[i*4+2] = scales[i]['value'][2].toDouble();
      _scales[i*4+3] = 1.0;
    }
  }

  _AnimationBoneData(List positions, List rotations, List scales) {
    _loadPositions(positions);
    _loadRotations(rotations);
    _loadScales(scales);
  }

  int _findTime(Float32List timeList, double t) {
    for (int i = 0; i < timeList.length-1; i++) {
      if (t < timeList[i+1]) {
        return i;
      }
    }
    return 0;
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
  final List<_AnimationBoneData> _boneData;
  Animation(this.name, final int length) :
      _boneData = new List<_AnimationBoneData>.fixedLength(length) {
  }
  double _runTime = 0.0;
  double get runTime => _runTime;
  double _timeScale = 1.0/24.0;
  double get timeScale => _timeScale;
}

class SkinnedMesh extends SpectreMesh {
  VertexBuffer _deviceVertexBuffer;
  IndexBuffer _deviceIndexBuffer;
  IndexBuffer get indexArray => _deviceIndexBuffer;
  VertexBuffer get vertexArray => _deviceVertexBuffer;
  final List<Map> meshes = new List<Map>();

  SkinnedMesh(String name, GraphicsDevice device) :
      super(name, device) {
    _deviceVertexBuffer = new VertexBuffer(name, device);
    _deviceIndexBuffer = new IndexBuffer(name, device);
  }

  void finalize() {
    _deviceVertexBuffer.dispose();
    _deviceIndexBuffer.dispose();
    _deviceVertexBuffer = null;
    _deviceIndexBuffer = null;
    count = 0;
  }

  Float32List baseVertexData; // The unanimated reference data.
  Float32Array vertexData; // The animated vertex data.
  int _floatsPerVertex;
  final Float32List globalInverseTransform = new Float32List(16);

  // These are indexed together.
  Float32List weightData;
  Int16List boneData;

  // index: vertex id
  // output: index into boneData and weightData.
  Int32List vertexSkinningOffsets;

  // These are indexed together.
  final Map<String, int> boneNameMapping = new Map<String, int>();
  Int16List boneParents;
  Int16List boneChildrenOffsets;
  final List<Float32List> boneOffsetTransforms = new List<Float32List>();
  final List<Float32List> localBoneTransforms = new List<Float32List>();
  final List<Float32List> globalBoneTransforms = new List<Float32List>();
  final List<Float32List> skinningBoneTransforms = new List<Float32List>();

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
    Expect.isNotNull(_currentAnimation);
    _currentTime += dt * _currentAnimation._timeScale;
    // Wrap.
    while (_currentTime >= _currentAnimation.runTime) {
      _currentTime -= _currentAnimation.runTime;
    }
    Float32List parentTransform = new Float32List(16);
    parentTransform[0] = 1.0;
    parentTransform[5] = 1.0;
    parentTransform[10] = 1.0;
    parentTransform[15] = 1.0;
    _updateGlobalBoneTransforms(0, parentTransform);
    _updateSkinningBoneTransforms();
    _updateVertices();
  }

  void _updateSkinningBoneTransforms() {
    for (int i = 0; i < skinningBoneTransforms.length; i++) {
      final Float32List globalTransform = globalBoneTransforms[i];
      final Float32List skinningTransform = skinningBoneTransforms[i];
      final Float32List offsetTransform = boneOffsetTransforms[i];
      Float32ListHelpers.mul44(skinningTransform,
                               globalTransform,
                               offsetTransform
                               );
      Float32ListHelpers.mul44(skinningTransform, globalInverseTransform, skinningTransform);
    }
  }

  final Float32List _scratchMatrix = new Float32List(16);
  void _updateGlobalBoneTransforms(final int boneIndex, final Float32List parentTransform) {
    if (boneIndex < 0 || boneIndex >= localBoneTransforms.length) {
      return;
    }
    final Float32List nodeTransform = _scratchMatrix;
    final Float32List globalTransform = globalBoneTransforms[boneIndex];

    if (_currentAnimation._boneData[boneIndex] != null) {
      _AnimationBoneData boneData = _currentAnimation._boneData[boneIndex];
      final Float32List positions = boneData._positions;
      final Float32List rotations = boneData._rotations;
      final Float32List scales = boneData._scales;
      int positionIndex = boneData._findPositionIndex(_currentTime);
      int rotationIndex = boneData._findRotationIndex(_currentTime);
      int scaleIndex = boneData._findScaleIndex(_currentTime);
      Expect.isTrue(positionIndex >= 0);
      Expect.isTrue(rotationIndex >= 0);
      Float32ListHelpers.rotateTranslate(nodeTransform,
                                         positions, positionIndex,
                                         rotations, rotationIndex);
    } else {
      Float32ListHelpers.copy(nodeTransform, localBoneTransforms[boneIndex]);
    }
    Float32ListHelpers.mul44(globalTransform, parentTransform, nodeTransform);
    int childOffset = boneChildrenOffsets[boneIndex];
    int childIndex = boneChildrenIds[childOffset++];
    while (childIndex != -1) {
      _updateGlobalBoneTransforms(childIndex, globalTransform);
      childIndex = boneChildrenIds[childOffset++];
    }
  }

  // Transform baseVertexData into vertexData based on bone hierarchy.
  void _updateVertices() {
    int numVertices = baseVertexData.length~/_floatsPerVertex;
    int vertexBase = 0;
    Float32List m = new Float32List(16);
    Float32List vertex = new Float32List(_floatsPerVertex);

    Stopwatch sw = new Stopwatch();
    sw.start();
    // 80 ms

    for (int v = 0; v < numVertices; v++) {
      // Zero vertices.
      vertex[0] = 0.0;
      vertex[1] = 0.0;
      vertex[2] = 0.0;
      vertex[3] = 0.0;
      for (int i = 4; i < _floatsPerVertex; i++) {
        vertex[i] = baseVertexData[vertexBase+i];
      }
      /*
       * // 30 ms
      vertexData[vertexBase+0] = 0.0;
      vertexData[vertexBase+1] = 0.0;
      vertexData[vertexBase+2] = 0.0;
      vertexData[vertexBase+3] = 0.0;
      for (int i = 4; i < _floatsPerVertex; i++) {
        vertexData[vertexBase+i] = baseVertexData[vertexBase+i];
      }
      */

      int skinningDataOffset = vertexSkinningOffsets[v];
      Float32ListHelpers.zero(m);
      while (boneData[skinningDataOffset] != -1) {
        final int boneId = boneData[skinningDataOffset];
        final double weight = weightData[skinningDataOffset];
        Float32ListHelpers.addScale44(m, skinningBoneTransforms[boneId], weight);
        skinningDataOffset++;
      }
      Float32ListHelpers.transform(vertex,
          baseVertexData, vertexBase, m);

      for (int i = 0; i < _floatsPerVertex; i++) {
        vertexData[vertexBase+i] = vertex[i];
      }

      //Expect.approxEquals(1.0, vertexData[vertexBase+3]);
      vertexBase += _floatsPerVertex;
    }
    sw.stop();
    print(sw.elapsedMilliseconds);
    vertexArray.uploadSubData(0, vertexData);
  }
}

void importMesh(SkinnedMesh mesh, Map json) {
  mesh.meshes.add(json);
}

void importAttribute(SkinnedMesh mesh, Map json) {
  String name = json['name'];
  int offset = json['offset'];
  int stride = json['stride'];
  mesh.attributes[name] = new SpectreMeshAttribute(name, 'float', 4,
      offset, stride, false);
}

void importAnimationFrames(Animation animation, int boneId, Map ba) {
  Expect.isTrue(boneId >= 0 && boneId < animation._boneData.length);
  Expect.isNull(animation._boneData[boneId]);

  List positions = ba['positions'];
  List rotations = ba['rotations'];
  List scales = ba['scales'];

  _AnimationBoneData boneData = new _AnimationBoneData(positions,
                                                       rotations,
                                                       scales);
  animation._boneData[boneId] = boneData;
}

void importAnimation(SkinnedMesh mesh, Map json) {
  String name = json['name'];
  Expect.isNotNull(name, 'animations require a name');
  Expect.notEquals("", name, "Name cannot be empty string.");
  num ticksPerSecond = json['ticksPerSecond'];
  num duration = json['duration'];
  Expect.isNotNull(ticksPerSecond);
  Expect.isNotNull(duration);
  Animation animation = new Animation(name, mesh.boneParents.length);
  animation._runTime = duration.toDouble();
  animation._timeScale = ticksPerSecond.toDouble();
  mesh.animations[name] = animation;
  mesh._currentAnimation = mesh.animations[name];
  json['boneAnimations'].forEach((ba) {
    int id = mesh.boneNameMapping[ba['name']];
    Expect.isNotNull(id);
    importAnimationFrames(animation, id, ba);
  });
}

class SkinnedVertex {
  final int vertexId;
  final List<int> bones = new List<int>();
  final List<double> weights = new List<double>();
  SkinnedVertex(this.vertexId);
}

SkinnedMesh importSkinnedMesh(String name, GraphicsDevice device, Map json) {
  SkinnedMesh mesh = new SkinnedMesh(name, device);
  List attributes = json['attributes'];
  List vertices = json['vertices'];
  List indices = json['indices'];
  List meshes = json['meshes'];
  List bones = json['bones'];
  List animations = json['animations'];
  List inverseRootTransform = json['inverseRootTransform'];
  for (int i = 0; i < inverseRootTransform.length; i++) {
    mesh.globalInverseTransform[i] = inverseRootTransform[i].toDouble();
  }
  // static mesh data begins.
  attributes.forEach((a) {
    importAttribute(mesh, a);
  });
  int attributeStride = attributes[0]['stride']~/4;
  mesh._floatsPerVertex = attributeStride;
  print('attribute stride: ${attributeStride}');
  meshes.forEach((m) {
    importMesh(mesh, m);
  });
  mesh.vertexData = new Float32Array.fromList(json['vertices']);
  mesh.baseVertexData = new Float32List(mesh.vertexData.length);
  for (int i = 0; i < mesh.vertexData.length; i++) {
    mesh.baseVertexData[i] = mesh.vertexData[i];
  }
  mesh.vertexArray.uploadData(mesh.vertexData,
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
    numChildren += children.length + 1;
    int id = mesh.boneOffsetTransforms.length;
    mesh.boneNameMapping[name] = id;
    //print('mapping $name -> $id');
    mesh.boneOffsetTransforms.add(new Float32List(16));
    for (int i = 0; i < 16; i++) {
      mesh.boneOffsetTransforms[id][i] = offsetTransform[i].toDouble();
    }
    Float32ListHelpers.transpose44(mesh.boneOffsetTransforms[id]);
    mesh.localBoneTransforms.add(new Float32List(16));
    for (int i = 0; i < 16; i++) {
      mesh.localBoneTransforms[id][i] = transform[i].toDouble();
    }
    Float32ListHelpers.transpose44(mesh.localBoneTransforms[id]);
    mesh.globalBoneTransforms.add(new Float32List(16));
    mesh.skinningBoneTransforms.add(new Float32List(16));
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
  Map<int, SkinnedVertex> skinnedVertices = new Map<int, SkinnedVertex>();
  bones.forEach((b) {
    final String boneName = b['name'];
    final List vertices = b['vertices'];
    final List weights = b['weights'];
    if (vertices == null || weights == null) {
      print('no weight data for bone ${boneName}');
      return;
    }
    Expect.equals(vertices.length, weights.length);
    final int boneId = mesh.boneNameMapping[boneName];
    Expect.isNotNull(boneId);
    for (int i = 0; i < vertices.length; i++) {
      final int vertexId = vertices[i].toInt();
      final double vertexWeight = weights[i].toDouble();
      SkinnedVertex sv = skinnedVertices[vertexId];
      if (sv == null) {
        sv = new SkinnedVertex(vertexId);
        skinnedVertices[vertexId] = sv;
      }
      sv.bones.add(boneId);
      sv.weights.add(vertexWeight);
    }
  });
  List perVertexWeights = skinnedVertices.values.toList();
  perVertexWeights.sort((a, b) => a.vertexId - b.vertexId);
  {
    List<int> boneId = new List<int>();
    List<double> weights = new List<double>();
    mesh.vertexSkinningOffsets = new Int32List(mesh.vertexData.length~/attributeStride);
    int outputIndex = 0;
    perVertexWeights.forEach((sv) {
      final int vertexId = sv.vertexId;
      int dataCursor = boneId.length;
      while (outputIndex < vertexId) {
        boneId.add(-1);
        weights.add(0.0);
        mesh.vertexSkinningOffsets[outputIndex] = dataCursor++;
        outputIndex++;
      }
      mesh.vertexSkinningOffsets[outputIndex] = dataCursor;
      double totalWeight = 0.0;
      for (int i = 0; i < sv.bones.length; i++) {
        //print('${vertexId} has ${sv.bones.length} influencers.');
        boneId.add(sv.bones[i]);
        weights.add(sv.weights[i]);
        totalWeight += sv.weights[i];
        dataCursor++;
      }
      //Expect.approxEquals(1.0, totalWeight);
      boneId.add(-1);
      weights.add(0.0);
      outputIndex++;
    });
    Expect.equals(outputIndex, mesh.vertexSkinningOffsets.length);
    Expect.equals(boneId.length, weights.length);
    mesh.boneData = new Int16List(boneId.length);
    mesh.weightData = new Float32List(boneId.length);
    for (int i = 0; i < boneId.length; i++) {
      mesh.boneData[i] = boneId[i];
      mesh.weightData[i] = weights[i];
    }
  }
  // verify children indices:
  boneIndex = 0;
  bones.forEach((b) {
    int boneId = boneIndex++;
    String name = b['name'];
    List<String> children = b['children'];
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
    importAnimation(mesh, a);
  });
  // animation ends.
  // update the bone matrices.
  return mesh;
}
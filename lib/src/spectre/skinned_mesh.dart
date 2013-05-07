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

class Float32ListHelpers {
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

  static void zeroSIMD(Float32x4List out) {
    var z = new Float32x4.zero();
    out[0] = z;
    out[1] = z;
    out[2] = z;
    out[3] = z;
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

  static void transform(out,
                        a, int ii,
                        m) {
    var x = a[ii+0], y = a[ii+1], z = a[ii+2], w = a[ii+3];
    out[0] += (m[0] * x + m[4] * y + m[8] * z + m[12] * w);
    out[1] += (m[1] * x + m[5] * y + m[9] * z + m[13] * w);
    out[2] += (m[2] * x + m[6] * y + m[10] * z + m[14] * w);
    out[3] += (m[3] * x + m[7] * y + m[11] * z + m[15] * w);
  }

  static void transformSIMD(Float32x4List out, Float32x4List a, int ii,
                            Float32x4List m4) {
    Float32x4 v = a[ii];
    Float32x4 xxxx = v.xxxx;
    Float32x4 z = new Float32x4.zero();
    z += xxxx * m4[0];
    Float32x4 yyyy = v.yyyy;
    z += yyyy * m4[1];
    Float32x4 zzzz = v.zzzz;
    z += zzzz * m4[2];
    z += m4[3];
    out[0] = z;
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


class Animation {
  final String name;
  final List<BoneAnimation> _boneData;
  Animation(this.name, final int length) :
      _boneData = new List<BoneAnimation>(length) {
  }
  BoneAnimation getDataForBone(int boneIndex) {
    if (boneIndex >= _boneData.length) {
      return null;
    }
    return _boneData[boneIndex];
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
    animations['null'] = new SkeletonAnimation('null', 0);
    currentAnimation = 'null';
  }

  void finalize() {
    _deviceVertexBuffer.dispose();
    _deviceIndexBuffer.dispose();
    _deviceVertexBuffer = null;
    _deviceIndexBuffer = null;
    count = 0;
  }

  Float32List baseVertexData; // The unanimated reference data.
  Float32List vertexData; // The animated vertex data.
  Float32x4List baseVertexData4;
  Float32x4List vertexData4;
  int _floatsPerVertex;
  final Float32List globalInverseTransform = new Float32List(16);

  // These are indexed together.
  Float32List weightData;
  Int16List boneData;

  // index: vertex id
  // output: index into boneData and weightData.
  Int32List vertexSkinningOffsets;

  Skeleton skeleton;
  PosedSkeleton posedSkeleton;

  // current time.
  double _currentTime = 0.0;

  final Map<String, SkeletonAnimation> animations =
      new Map<String,SkeletonAnimation>();
  SkeletonAnimation _currentAnimation;
  String get currentAnimation => _currentAnimation.name;
  set currentAnimation(String name) {
    _currentAnimation = animations[name];
  }
  
  SkeletonPoser skeletonPoser = new SimpleSkeletonPoser();
  SkeletonPoser skeletonPoserSIMD = new SIMDSkeletonPoser();

  void update(double dt, bool useSimdPosing, bool useSimdSkinning) {
    assert(_currentAnimation != null);
    _currentTime += dt * _currentAnimation.timeScale;

    // Wrap.
    if (_currentAnimation.runTime == 0.0) {
      _currentTime = 0.0;
    } else {
      while (_currentTime >= _currentAnimation.runTime) {
        _currentTime -= _currentAnimation.runTime;
      }
    }
    
    if(useSimdPosing) {
      skeletonPoserSIMD.pose(skeleton, _currentAnimation, posedSkeleton,
          _currentTime);
    } else {
      skeletonPoser.pose(skeleton, _currentAnimation, posedSkeleton,
          _currentTime);
    }
    
    if (useSimdSkinning) {
      _updateVerticesSIMD();
    } else {
      _updateVertices();
    }
  }

  final Float32List m = new Float32List(16);
  final Float32List vertex = new Float32List(12);

  // Transform baseVertexData into vertexData based on bone hierarchy.
  void _updateVertices() {
    int numVertices = baseVertexData.length~/_floatsPerVertex;
    int vertexBase = 0;
    sw.reset();
    sw.start();
    for (int v = 0; v < numVertices; v++) {
      // Zero vertices.
      vertex[0] = 0.0;
      vertex[1] = 0.0;
      vertex[2] = 0.0;
      vertex[3] = 0.0;
      for (int i = 4; i < _floatsPerVertex; i++) {
        vertexData[i] = baseVertexData[vertexBase+i];
      }
      int skinningDataOffset = vertexSkinningOffsets[v];
      Float32ListHelpers.zero(m);
      while (boneData[skinningDataOffset] != -1) {
        final int boneId = boneData[skinningDataOffset];
        final double weight = weightData[skinningDataOffset];
        Float32ListHelpers.addScale44(m,
                                      posedSkeleton.skinningTransforms[boneId],
                                      weight);
        skinningDataOffset++;
      }
      Float32ListHelpers.transform(vertex,
          baseVertexData, vertexBase, m);

      for (int i = 0; i < 4; i++) {
        vertexData[vertexBase+i] = vertex[i];
      }

      //Expect.approxEquals(1.0, vertexData[vertexBase+3]);
      vertexBase += _floatsPerVertex;
    }
    sw.stop();
    //print('double: ${sw.elapsedMicroseconds}');
    vertexArray.uploadSubData(0, vertexData);
  }

  // Transform baseVertexData into vertexData based on bone hierarchy.
  final Float32x4List m4 = new Float32x4List(4);
  final Float32x4List vertex4 = new Float32x4List(3);
  final Stopwatch sw = new Stopwatch();
  void _updateVerticesSIMD() {
    int numVertices = baseVertexData.length~/_floatsPerVertex;
    int vertexBase = 0;
    sw.reset();
    sw.start();
    for (int v = 0; v < numVertices; v++) {
      vertexData4[1] = baseVertexData4[vertexBase+1];
      vertexData4[2] = baseVertexData4[vertexBase+2];
      int skinningDataOffset = vertexSkinningOffsets[v];
      Float32ListHelpers.zeroSIMD(m4);
      while (boneData[skinningDataOffset] != -1) {
        final int boneId = boneData[skinningDataOffset];
        final double weight = weightData[skinningDataOffset];
        Float32x4 weight4 = new Float32x4.splat(weight);
        Float32x4List boneMatrix = posedSkeleton.skinningTransforms4[boneId];
        m4[0] += boneMatrix[0] * weight4;
        m4[1] += boneMatrix[1] * weight4;
        m4[2] += boneMatrix[2] * weight4;
        m4[3] += boneMatrix[3] * weight4;
        skinningDataOffset++;
      }
      Float32ListHelpers.transformSIMD(vertex4, baseVertexData4, vertexBase, m4);
      vertexData4[vertexBase] = vertex4[0];
      vertexBase += _floatsPerVertex ~/ 4;
    }
    sw.stop();
    //print('SIMD: ${sw.elapsedMicroseconds}');
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

void importAnimationFrames(SkeletonAnimation animation, int boneId, Map ba) {
  assert(boneId >= 0 && boneId < animation.boneList.length);
  assert(animation.boneList[boneId] == null);

  List positions = ba['positions'];
  List rotations = ba['rotations'];
  List scales = ba['scales'];

  BoneAnimation boneData = new BoneAnimation('', boneId, positions, rotations,
                                             scales);
  animation.boneList[boneId] = boneData;
}

void importAnimation(SkinnedMesh mesh, Map json) {
  String name = json['name'];
  assert(name != null);
  assert(name != "");
  num ticksPerSecond = json['ticksPerSecond'];
  num duration = json['duration'];
  assert(ticksPerSecond != null);
  assert(duration != null);
  var animation = new SkeletonAnimation(name, mesh.skeleton.boneList.length);
  animation.runTime = duration.toDouble();
  animation.timeScale = ticksPerSecond.toDouble();
  mesh.animations[name] = animation;
  mesh._currentAnimation = mesh.animations[name];
  json['boneAnimations'].forEach((ba) {
    Bone bone = mesh.skeleton.bones[ba['name']];
    if (bone == null) {
      print('Cannot find ${ba['name']}');
      return;
    }
    int id = bone._boneIndex;
    importAnimationFrames(animation, id, ba);
  });
}

class SkinnedVertex {
  final int vertexId;
  final List<int> bones = new List<int>();
  final List<double> weights = new List<double>();
  SkinnedVertex(this.vertexId);
}

SkinnedMesh importSkinnedMesh2(String name, GraphicsDevice device, Map json) {
  SkinnedMesh mesh = new SkinnedMesh(name, device);



  List attributes = json['attributes'];
  // static mesh data begins.
  attributes.forEach((a) {
    importAttribute(mesh, a);
  });
  mesh._floatsPerVertex = attributes[0]['stride']~/4;;

  List vertices = json['vertices'];
  mesh.vertexData4 = new Float32x4List(json['vertices'].length~/4);
  mesh.baseVertexData4 = new Float32x4List(mesh.vertexData4.length);
  mesh.vertexData = new Float32List.view(mesh.vertexData4);
  mesh.baseVertexData = new Float32List.view(mesh.baseVertexData4);
  for (int i = 0; i < json['vertices'].length; i++) {
    mesh.vertexData[i] = json['vertices'][i].toDouble();
    mesh.baseVertexData[i] = json['vertices'][i].toDouble();
  }
  mesh.vertexArray.uploadData(mesh.vertexData4,
                              SpectreBuffer.UsageDynamic);
  List indices = json['indices'];
  mesh.indexArray.uploadData(new Uint16List.fromList(json['indices']),
                             SpectreBuffer.UsageStatic);
  List meshes = json['meshes'];
  meshes.forEach((m) {
    importMesh(mesh, m);
  });
  List bones = json['boneTable'];
  mesh.skeleton = new Skeleton(name, bones.length);
  // TODO: FIX THIS.
  mesh.skeleton.globalOffsetTransform[0] = 1.0;
  mesh.skeleton.globalOffsetTransform[6] = -1.0;
  mesh.skeleton.globalOffsetTransform[9] = 1.0;
  mesh.skeleton.globalOffsetTransform[15] = 1.0;
  // Bone table.
  bones.forEach((b) {
    String boneName = b['name'];
    List<double> transform = b['localTransform'];
    List<double> offsetTransform = b['offsetTransform'];
    int index = b['index'];
    assert(16 == transform.length);
    assert(16 == offsetTransform.length);
    Bone bone = new Bone(boneName, transform, offsetTransform);
    mesh.skeleton.boneList[index] = bone;
    mesh.skeleton.boneList[index]._boneIndex = index;
    mesh.skeleton.bones[boneName] = bone;
  });
  // Bone hierarchy.
  bones.forEach((b) {
    String boneName = b['name'];
    Bone parentBone = mesh.skeleton.bones[boneName];
    List<String> children = b['children'];
    for (int i = 0; i < children.length; i++) {
      Bone childBone = mesh.skeleton.bones[children[i]];
      if (childBone == null) {
        print('Could not find ${children[i]}');
        continue;
      }
      assert(childBone.parent == null);
      childBone.parent = parentBone;
      parentBone.children.add(childBone);
    }
  });
  mesh.posedSkeleton = new PosedSkeleton(mesh.skeleton, bones.length);

  {
    Map perVertexWeights = json['vertexWeight'];
    List sortedVertexIndexes = perVertexWeights.keys.toList();
    sortedVertexIndexes.sort((a,b) => int.parse(a) - int.parse(b));
    List<int> boneId = new List<int>();
    List<double> weights = new List<double>();
    mesh.vertexSkinningOffsets = new Int32List(
        mesh.vertexData.length ~/ mesh._floatsPerVertex);
    int outputIndex = 0;
    for (int i = 0; i < sortedVertexIndexes.length; i++) {
      final String vertexLabel = sortedVertexIndexes[i];
      final int vertexId = int.parse(vertexLabel);
      final List vertexWeights = perVertexWeights[vertexLabel];
      int dataCursor = boneId.length;
      while (outputIndex < vertexId) {
        boneId.add(-1);
        weights.add(0.0);
        mesh.vertexSkinningOffsets[outputIndex] = dataCursor++;
        outputIndex++;
      }
      mesh.vertexSkinningOffsets[outputIndex] = dataCursor;
      double totalWeight = 0.0;
      for (int i = 0; i < vertexWeights.length; i += 2) {
        boneId.add(vertexWeights[i]);
        weights.add(vertexWeights[i+1].toDouble());
        dataCursor++;
      }
      boneId.add(-1);
      weights.add(0.0);
      outputIndex++;
    }
    assert(outputIndex == mesh.vertexSkinningOffsets.length);
    assert(boneId.length == weights.length);
    mesh.boneData = new Int16List(boneId.length);
    mesh.weightData = new Float32List(boneId.length);
    for (int i = 0; i < boneId.length; i++) {
      mesh.boneData[i] = boneId[i];
      mesh.weightData[i] = weights[i];
    }
  }
  return mesh;
}
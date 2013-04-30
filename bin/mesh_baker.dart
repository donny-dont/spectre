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

library mesh_baker;

import 'dart:io';
import 'dart:typed_data';
import 'dart:json' as JSON;

class MeshBone {
  final String name;
  final Float32List localTransform = new Float32List(16);
  final Float32List offsetTransform = new Float32List(16);
  final MeshBone parent;
  final List<MeshBone> children = new List<MeshBone>();
  MeshBone(this.name, this.parent);
  void clear() {
    for (int i = 0; i < children.length; i++) {
      children[i].clear();
    }
    children.clear();
  }

  dump(int depth) {
    String indent = '';
    for (int i = 0; i < depth; i++) {
      indent += ' ';
    }
    print('$indent $name $localTransform $offsetTransform');
    children.forEach((c) => c.dump(depth+1));
  }

  MeshBone findNode(String needle) {
    if (name == needle) {
      return this;
    }
    for (int i = 0; i < children.length; i++) {
      var r = children[i].findNode(needle);
      if (r != null) {
        return r;
      }
    }
  }
}

class MeshDraw {
  final int baseVertex;
  final int baseIndex;
  final int numIndices;
  MeshDraw(this.baseVertex, this.baseIndex, this.numIndices);
}

class MeshVertexStream {
  final String name;
  final int components;
  final List<double> data = new List<double>();
  MeshVertexStream(this.name, this.components);
}

class MeshVertexBuffer {
  final Map<String, MeshVertexStream> streams =
      new Map<String, MeshVertexStream>();

  void clear() {
    streams.clear();
  }
}

class MeshBaker {
  final Map inputMesh;
  final MeshBone root = new MeshBone('root', null);
  final MeshVertexBuffer vertexBuffer = new MeshVertexBuffer();
  final List<MeshDraw> draws = new List<MeshDraw>();
  MeshBaker(this.inputMesh);

  clear() {
    root.clear();
    vertexBuffer.clear();
    draws.clear();
  }

  fillBoneNode(Map nodeDescription, MeshBone node) {
    for (int i = 0; i < 16; i++) {
      node.localTransform[i] = nodeDescription['transformation'][i].toDouble();
    }
  }

  buildBoneNode(Map nodeDescription, MeshBone node) {
    fillBoneNode(nodeDescription, node);
    List children = nodeDescription['children'];
    if (children == null) {
      return;
    }
    children.forEach((cn) {
      MeshBone childNode = new MeshBone(cn['name'], node);
      buildBoneNode(cn, childNode);
      node.children.add(childNode);
    });
  }

  buildBones() {
    if (inputMesh['rootnode'] == null) {
      return;
    }
    buildBoneNode(inputMesh['rootnode'], root);
  }

  fillOffsetTransforms() {
    List meshes = inputMesh['meshes'];
    if (meshes == null) {
      return;
    }
    for (int i = 0; i < meshes.length; i++) {
      List bones = meshes[i]['bones'];
      if (bones == null) {
        continue;
      }
      for (int b = 0; b < bones.length; b++) {
        String boneName = bones[b]['name'];
        MeshBone bone = root.findNode(boneName);
        if (bone == null) {
          print('could not find $boneName');
          continue;
        }
        for (int ii = 0; ii < 16; ii++) {
          bone.offsetTransform[ii] = bones[b]['offsetmatrix'][ii].toDouble();
        }
      }
    }
  }

  bake() {
    clear();
    buildBones();
    fillOffsetTransforms();
    root.dump(0);
  }
}

main() {
  File f = new File("/Users/johnmccutchan/Downloads/hellknight.json");
  String inputString = f.readAsStringSync();
  Map inputMesh = JSON.parse(inputString);
  MeshBaker mb = new MeshBaker(inputMesh);
  mb.bake();
}

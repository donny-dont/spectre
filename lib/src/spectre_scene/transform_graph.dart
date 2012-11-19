part of spectre_scene;

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

class TransformGraphNode {
  TransformGraphNode parent;
  int childCount;
  int childCountSort;
  mat4 localTransform;
  mat4 worldTransform;
  Float32Array worldTransformArray;
  TransformGraphNode._internal() {
    localTransform = new mat4.identity();
    worldTransform = new mat4.identity();
    worldTransformArray = new Float32Array(16);
    reset();
  }
  void reset() {
    parent = null;
    childCount = 0;
    childCountSort = 0;
  }
}

class TransformGraph {
  List<TransformGraphNode> _nodes;
  List<TransformGraphNode> _sortedNodes;

  TransformGraph() {
    _nodes = new List<TransformGraphNode>();
    _sortedNodes = new List<TransformGraphNode>();
  }

  /// Create a new transform node. The node has no parent and is the identity.
  TransformGraphNode createNode() {
    TransformGraphNode node = new TransformGraphNode._internal();
    _nodes.add(node);
    return node;
  }

  void _unparentChildren(TransformGraphNode parent) {
    for (int i = 0; i < _nodes.length; i++) {
      if (_nodes[i].parent == parent) {
        unparent(_nodes[i]);
      }
    }
  }

  void _swapAndPop(int index) {
    // Move end of list into index we are removing.
    TransformGraphNode last = _nodes.last();
    _nodes[index] = last;
    // Remove last node.
    _nodes.removeLast();
  }

  /// Delete an existing transform node [node]
  void deleteNode(TransformGraphNode node) {
    if (node == null) {
      return;
    }
    int index = _nodes.indexOf(node, 0);
    assert(index >= 0);
    _swapAndPop(index);
  }

  /// Make [node] a leaf node
  void unparent(TransformGraphNode node) {
    TransformGraphNode parent = node.parent;
    // Cleanup parent
    if (parent == null) {
      return;
    }
    parent.childCount--;
    assert(parent.childCount >= 0);
  }

  /// Make [node] a child of [parent]
  void reparent(TransformGraphNode node, TransformGraphNode parent) {
    if (node == null) {
      return;
    }
    // Unparent
    unparent(node);
    if (parent == null) {
      return;
    }
    node.parent = parent;
    parent.childCount++;
  }

  /// Must be called after modifying the transform graph
  void updateGraph() {
    // Find leafs
    Queue<TransformGraphNode> leafs = new Queue<TransformGraphNode>();
    for (int i = 0; i < _nodes.length; i++) {
      _nodes[i].childCountSort = _nodes[i].childCount;
      if (_nodes[i].childCount == 0) {
        leafs.add(_nodes[i]);
      }
    }
    while (leafs.length > 0) {
      TransformGraphNode leaf = leafs.removeLast();
      _sortedNodes.add(leaf);
      if (leaf.parent != null) {
        leaf.parent.childCountSort--;
        if (leaf.parent.childCountSort == 0) {
          leafs.add(leaf.parent);
        }
      }
    }
  }

  /// Get a copy of the world transform for [nodeHandle]
  void getWorldMatrix(int nodeHandle, mat4 out) {
    if (nodeHandle == 0) {
      return;
    }
    if (_handleSystem.validHandle(nodeHandle) == false) {
      return;
    }
    int index = Handle.getIndex(nodeHandle);
    _worldTransforms[index].copyInto(out);
  }

  /// Get a reference to the world transform for [node]
  mat4 refWorldMatrix(TransformGraphNode node) {
    if (node == null) {
      return null;
    }
    return node.worldTransform;
  }

  Float32Array refWorldMatrixArray(TransformGraphNode node) {
    if (node == null) {
      return null;
    }
    return node.worldTransformArray;
  }

  /// Set the local transform for [node]
  void setLocalMatrix(TransformGraphNode node, mat4 m) {
    if (node == null) {
      return null;
    }
    node.localTransform.copyFrom(m);
  }

  /// Get a reference to the local transform for [node]
  mat4 refLocalMatrix(TransformGraphNode node) {
    if (node == null) {
      return null;
    }
    return node.localTransform;
  }

  /// Updates the world transformation matrices for all nodes in the graph
  void updateWorldMatrices() {
    for (int i = _sortedNodes.length-1; i >= 0 ; i--) {
      TransformGraphNode node = _sortedNodes[i];
      if (node.parent != null) {
        node.worldTransform.copyFrom(node.parent.worldTransform);
        node.worldTransform.multiply(node.localTransform);
      } else {
        node.worldTransform.copyFrom(node.localTransform);
      }
      node.worldTransform.copyIntoArray(node.worldTransformArray, 0);
    }
  }
}
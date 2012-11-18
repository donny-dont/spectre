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

class _TransformGraphNode {
  int parentId;
  int childCount;
  int childCountSort;
  int selfId;
  void reset() {
    parentId = 0;
    childCount = 0;
    childCountSort = 0;
    selfId = 0;
  }
}

class TransformGraph {
  HandleSystem _handleSystem;
  List<mat4> _localTransforms;
  List<mat4> _worldTransforms;
  List<Float32Array> _worldTransformArrays;
  List<_TransformGraphNode> _nodes;
  List<int> _sortedNodes;
  int _sortedNodesCursor;
  int _nodeCount;
  final int _maxNodes;

  TransformGraph(this._maxNodes) {
    _handleSystem = new HandleSystem(_maxNodes, 0);
    _localTransforms = new List<mat4>(_maxNodes);
    _worldTransforms = new List<mat4>(_maxNodes);
    _worldTransformArrays = new List<Float32Array>(_maxNodes);
    _nodes = new List<_TransformGraphNode>(_maxNodes);
    _sortedNodes = new List<int>(_maxNodes);
    _sortedNodesCursor = 0;
    _nodeCount = 0;
    for (int i = 0; i < _maxNodes; i++) {
      _localTransforms[i] = new mat4.identity();
      _worldTransforms[i] = new mat4.identity();
      _worldTransformArrays[i] = new Float32Array(16);
      _nodes[i] = new _TransformGraphNode();
      _nodes[i].reset();
    }
  }

  /// Create a new transform node. The node has no parent and is the identity.
  int createNode() {
    int nodeHandle = _handleSystem.allocateHandle(0x1);
    if (nodeHandle == Handle.BadHandle) {
      return 0;
    }
    int index = Handle.getIndex(nodeHandle);
    _nodes[index].selfId = nodeHandle;
    _nodeCount++;
    return nodeHandle;
  }

  void _unparentChildren(int parentNode) {
    for (int i = 0; i < _maxNodes; i++) {
      if (_nodes[i].parentId == parentNode) {
        unparent(_nodes[i].selfId);
      }
    }
  }

  /// Delete an existing transform node [nodeHandle]
  void deleteNode(int nodeHandle) {
    if (nodeHandle == 0) {
      return;
    }
    if (_handleSystem.validHandle(nodeHandle) == false) {
      return;
    }
    int index = Handle.getIndex(nodeHandle);
    if (_nodes[index].childCount > 0) {
      _unparentChildren(nodeHandle);
    }
    _handleSystem.freeHandle(nodeHandle);
    _localTransforms[index].setIdentity();
    assert(_nodes[index].childCount == 0);
    _nodes[index].reset();
    _nodeCount--;
    assert(_nodeCount >= 0);
  }

  /// Makes [nodeHandle] a leaf node
  void unparent(int nodeHandle) {
    if (nodeHandle == 0) {
      return;
    }
    if (_handleSystem.validHandle(nodeHandle) == false) {
      return;
    }
    int index = Handle.getIndex(nodeHandle);
    int parentNodeHandle = _nodes[index].parentId;
    _nodes[index].parentId = 0;
    // Cleanup parent
    if (parentNodeHandle == 0) {
      return;
    }
    if (_handleSystem.validHandle(parentNodeHandle) == false) {
      return;
    }
    int parentIndex = Handle.getIndex(parentNodeHandle);
    _nodes[parentIndex].childCount--;
    assert(_nodes[parentIndex].childCount >= 0);
  }

  /// Makes [nodeHandle] a child of [parentNodeHandle]
  void reparent(int nodeHandle, int parentNodeHandle) {
    // Unparent
    unparent(nodeHandle);

    if (parentNodeHandle == 0) {
      return;
    }
    if (nodeHandle == 0) {
      return;
    }
    if (_handleSystem.validHandle(nodeHandle) == false) {
      return;
    }
    int index = Handle.getIndex(nodeHandle);
    if (_handleSystem.validHandle(parentNodeHandle) == false) {
      return;
    }
    int parentIndex = Handle.getIndex(parentNodeHandle);

    _nodes[index].parentId = parentNodeHandle;
    _nodes[parentIndex].childCount++;
  }

  /// Must be called after modifying the transform graph
  void updateGraph() {
    _sortedNodesCursor = 0;
    // Find leafs
    Queue<int> leafs = new Queue<int>();
    for (int i = 0; i < _maxNodes; i++) {
      _nodes[i].childCountSort = _nodes[i].childCount;
      if (_nodes[i].selfId != 0 && _nodes[i].childCount == 0) {
        leafs.add(_nodes[i].selfId);
      }
    }
    while (leafs.length > 0) {
      int id = leafs.removeLast();
      _sortedNodes[_sortedNodesCursor++] = id;
      int parentId = _nodes[Handle.getIndex(id)].parentId;
      int parentIndex = Handle.getIndex(parentId);
      _nodes[parentIndex].childCountSort--;
      if (_nodes[parentIndex].childCountSort == 0) {
        leafs.add(parentId);
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

  /// Get a reference to the world transform for [nodeHandle]
  mat4 refWorldMatrix(int nodeHandle) {
    if (nodeHandle == 0) {
      return null;
    }
    if (_handleSystem.validHandle(nodeHandle) == false) {
      return null;
    }
    int index = Handle.getIndex(nodeHandle);
    return _worldTransforms[index];
  }

  Float32Array refWorldMatrixArray(int nodeHandle) {
    if (nodeHandle == 0) {
      return null;
    }
    if (_handleSystem.validHandle(nodeHandle) == false) {
      return null;
    }
    int index = Handle.getIndex(nodeHandle);
    return _worldTransformArrays[index];
  }

  /// Set the local transform for [nodeHandle]
  void setLocalMatrix(int nodeHandle, mat4 m) {
    if (nodeHandle == 0) {
      return;
    }
    if (_handleSystem.validHandle(nodeHandle) == false) {
      return;
    }
    int index = Handle.getIndex(nodeHandle);
    _localTransforms[index].copyFrom(m);
  }

  /// Get a reference to the local transform for [nodeHandle]
  mat4 refLocalMatrix(int nodeHandle) {
    if (nodeHandle == 0) {
      return null;
    }
    if (_handleSystem.validHandle(nodeHandle) == false) {
      return null;
    }
    int index = Handle.getIndex(nodeHandle);
    return _localTransforms[index];
  }

  /// Updates the world transformation matrices for all nodes in the graph
  void updateWorldMatrices() {
    //print('Updating world.');
    for (int i = _sortedNodesCursor-1; i >= 0 ; i--) {
      int nodeIndex = Handle.getIndex(_sortedNodes[i]);
      _TransformGraphNode node = _nodes[nodeIndex];
      if (_sortedNodes[i] == 286261249) {
        //print('updating cone world.');
        //print('${node.parentId}');
        //print('${node.selfId}');
        //print('$nodeIndex');
      }
      if (node.parentId != 0) {
        int parentNodeIndex = Handle.getIndex(node.parentId);
        _worldTransforms[nodeIndex].copyFrom(_worldTransforms[parentNodeIndex]);
        _worldTransforms[nodeIndex].multiply(_localTransforms[nodeIndex]);
      } else {
        _worldTransforms[nodeIndex].copyFrom(_localTransforms[nodeIndex]);
      }
      _worldTransforms[nodeIndex].copyIntoArray(_worldTransformArrays[nodeIndex], 0);
    }
  }
}
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
  List<_TransformGraphNode> _nodes;
  List<int> _sortedNodes;
  int _sortedNodesCursor;
  int _nodeCount;
  final int _maxNodes;
  
  TransformGraph(this._maxNodes) {
    _handleSystem = new HandleSystem(_maxNodes, 0);
    _localTransforms = new List<mat4>(_maxNodes);
    _worldTransforms = new List<mat4>(_maxNodes);
    _nodes = new List<_TransformGraphNode>(_maxNodes);
    _sortedNodes = new List<int>(_maxNodes);
    _nodeCount = 0;
    for (int i = 0; i < _maxNodes; i++) {
      _localTransforms[i] = new mat4.identity();
      _worldTransforms[i] = new mat4.identity();
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
  
  /// Delete an existing transform node [nodeHandle]
  void deleteNode(int nodeHandle) {
    if (nodeHandle == 0) {
      return;
    }
    if (_handleSystem.validHandle(nodeHandle) == false) {
      return;
    }
    _handleSystem.freeHandle(nodeHandle);
    int index = Handle.getIndex(nodeHandle);
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
    _nodes[index].parentId = 0;
    // Cleanup parent
    int parentNodeHandle = _nodes[index].parentId;
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
    for (int i = _sortedNodesCursor-1; i >= 0 ; i--) {
      int nodeIndex = Handle.getIndex(_sortedNodes[i]);
      _TransformGraphNode node = _nodes[nodeIndex];
      if (node.parentId != 0) {
        int parentNodeIndex = Handle.getIndex(node.parentId);
        _worldTransforms[nodeIndex].copyFrom(_worldTransforms[parentNodeIndex]);
        _worldTransforms[nodeIndex].multiply(_localTransforms[nodeIndex]);
      } else {
        _worldTransforms[nodeIndex].copyFrom(_localTransforms[nodeIndex]);
      }
    }
  }
}
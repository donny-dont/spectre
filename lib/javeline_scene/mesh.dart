
class Mesh extends SceneChild {
  int indexedMesh;
  Map attributes;
  Mesh(String name, Scene scene) : super(name, scene) {
    indexedMesh = 0;
  }
  
  void delete() {
    if (indexedMesh != 0) {
      scene.device.deleteDeviceChild(indexedMesh);
    }
  }
  
  void load(Map o) {
    int resourceHandle = scene.resourceManager.getResourceHandle(name);
    MeshResource mr = scene.resourceManager.getResource(resourceHandle);
    if (mr == null) {
      spectreLog.Error('Could not find $name');
      return;
    }
    if (indexedMesh == 0) {
      indexedMesh = scene.device.createIndexedMesh(name, {
        'UpdateFromMeshResource': {
          'resourceManager': scene.resourceManager,
          'meshResourceHandle': resourceHandle
        }
      });
    } else {
      scene.device.configureDeviceChild(indexedMesh, {
        'UpdateFromMeshResource': {
          'resourceManager': scene.resourceManager,
          'meshResourceHandle': resourceHandle
        }
      });
    }
    attributes = mr.meshData['meshes'][0]['attributes'];
  }
  
  void preDraw() {
    IndexedMesh im = scene.device.getDeviceChild(indexedMesh);
    scene.device.immediateContext.setPrimitiveTopology(ImmediateContext.PrimitiveTopologyTriangles);
    scene.device.immediateContext.setIndexBuffer(im.indexArrayHandle);
    scene.device.immediateContext.setVertexBuffers(0, [im.vertexArrayHandle]);
  }
  
  void draw() {
    IndexedMesh im = scene.device.getDeviceChild(indexedMesh);
    scene.device.immediateContext.drawIndexed(im.numIndices, im.indexOffset);
  }
}

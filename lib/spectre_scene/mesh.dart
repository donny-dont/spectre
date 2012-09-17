
class Mesh extends SceneChild {
  int indexedMesh;
  Map layout;
  Mesh(String name, Scene scene) : super(name, scene) {
    indexedMesh = 0;
    layout = null;
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
  }
}

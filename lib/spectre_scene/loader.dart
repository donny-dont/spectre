
class Loader {
  List<int> _resourceHandleTable;
  List<int> _deviceHandleTable;
  Map _sceneDescription;
  Scene _scene;
  Device _device;
  ResourceManager _resourceManager;
  
  Loader(this._scene, this._device, this._resourceManager) {
  }
  
  Future loadFromUrl(String url) {
    int handle = _resourceManager.registerResource(url);
    Future r = _resourceManager.loadResource(handle);
    return r.chain((result) {
      SceneResource sr = _resourceManager.getResource(handle);
      return load(sr.sceneDescription);
    });
  }
  
  Future _loadResources(Map sceneDescription) {
    Set<String> resources = new Set<String>();
    sceneDescription['resources'].forEach((r) {
      resources.add(r);
    });
    sceneDescription['entities'].forEach((e) {
      if (e['mesh'] != null) {
        resources.add(e['mesh']);
      }
      if (e['shader'] != null) {
        resources.add(e['shader']);
      }
      if (e['textures'] != null) {
        e['textures'].forEach((t) {
          resources.add(t);
        });
      }
    });
    resources.forEach((r) {
      _resourceHandleTable.add(_resourceManager.registerResource(r));
    });
    return _resourceManager.loadResources(_resourceHandleTable);
  }
  
  Mesh _loadMesh(Map entity) {
    final String name = entity['mesh'];
    Mesh mesh = _scene.meshes[name];
    if (mesh == null) {
      mesh = new Mesh(name, _scene);
      mesh.load({});
      print('loaded $name');
    }
    return mesh;
  }
  
  Material _loadMaterial(Map entity) {
    final String name = entity['shader'];
    Material material = _scene.materials[name];
    if (material == null) {
      material = new Material(name, _scene);
      material.load({});
      print('loaded $name');
    }
    return material;
  }
  
  Future _loadEntities(bool resourcesLoaded) {
    Completer<bool> completer = new Completer<bool>();
    if (!resourcesLoaded) {
      completer.complete(false);
      return completer.future;
    }
    print('Create entities.');
    _sceneDescription['entities'].forEach((e) {
      if (e['mesh'] != null) {
        _loadMesh(e);
      }
      if (e['shader'] != null) {
        _loadMaterial(e);
      }
    });
    completer.complete(true);
    return completer.future;
  }
  
  Future load(Map sceneDescription) {
    _resourceHandleTable = new List<int>();
    _deviceHandleTable = new List<int>();
    _sceneDescription = sceneDescription;
    return _loadResources(sceneDescription).chain(_loadEntities);
  }
  
  void setupScene() {
    print('setup scene!');
  }
}
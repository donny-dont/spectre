
class Loader {
  Set<int> _resourceHandleTable;
  Set<int> _deviceHandleTable;
  Map _sceneDescription;
  Scene _scene;
  Device _device;
  ResourceManager _resourceManager;
  
  Loader(this._scene, this._device, this._resourceManager) {
    _resourceHandleTable = new Set<int>();
    _deviceHandleTable = new Set<int>();
  }
  
  void reload(int type, SceneResource resource) {
    print('reloading');
    load(resource.sceneDescription);
  }
  
  Future loadFromUrl(String url) {
    int handle = _resourceManager.registerResource(url);
    _resourceManager.addEventCallback(handle, ResourceEvents.TypeUpdate, reload);
    return _resourceManager.loadResource(handle);
    /*
    Future r = _resourceManager.loadResource(handle);
    return r.chain((result) {
      SceneResource sr = _resourceManager.getResource(handle);
      return load(sr.sceneDescription);
    });
    */
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
      _scene.meshes[name] = mesh;
    }
    mesh.load({});
    print('loaded $name');
    return mesh;
  }
  
  Material _loadMaterial(Map entity) {
    final String name = entity['shader'];
    Material material = _scene.materials[name];
    if (material == null) {
      material = new Material(name, _scene);
      _scene.materials[name] = material;
    }
    material.load({});
    print('loaded $name');
    return material;
  }
  
  void _spawnSkybox(Map entity) {
    if (_scene.skybox != null) {
      _scene.skybox.fini();
      _scene.skybox = null;
    }
    String texture0 = entity['textures'][0];
    String texture1 = entity['textures'][1];
    _scene.skybox = new Skybox(_device, _resourceManager, texture0, texture1);
    _scene.skybox.init();
  }
  
  void _spawnModel(Map entity) {
    Material mat = _scene.materials[entity['shader']];
    Mesh mesh = _scene.meshes[entity['mesh']];
    Model model = _scene.models[entity['name']];
    if (model == null) {
      model = new Model(entity['name'], _scene);
      _scene.models[entity['name']] = model;
    }
    model.update(mat, mesh, entity['meshinputs']);
  }
  
  void _setModelTransform(String name, Map transform) {
    Model model = _scene.models[name];
    if (model == null) {
      return;
    }
    int xformHandle = model.transformHandle;
    if (name == 'cone') {
      print('Cone model. $xformHandle');
    }
    mat4 T = _scene.transformGraph.refLocalMatrix(xformHandle);
    T.setIdentity();
    num rotateX = transform['rotateX'];
    num rotateY = transform['rotateY'];
    num rotateZ = transform['rotateZ'];
    List<num> translate = transform['translate'];
    List<num> scale = transform['scale'];
    if (rotateX != null) {
      T.rotateX(rotateX);
    }
    if (rotateY != null) {
      T.rotateY(rotateY);
    }
    if (rotateZ != null) {
      T.rotateZ(rotateZ);
    }
    if (translate != null) {
      T.translate(translate[0], translate[1], translate[2]);
    }
    if (scale != null) {
      T.scale(scale[0], scale[1], scale[2]);
    }
    String parent = transform['parent'];
    if (parent != null) {
      Model parentModel = _scene.models[parent];
      if (parentModel != null) {
        _scene.transformGraph.reparent(xformHandle, parentModel.transformHandle);  
      }
    }
  }
  
  void _spawnUniformset(Map entity) {
  }
  
  Future _loadEntities(bool resourcesLoaded) {
    Completer<bool> completer = new Completer<bool>();
    if (!resourcesLoaded) {
      completer.complete(false);
      return completer.future;
    }
    // Create entities
    _sceneDescription['entities'].forEach((e) {
      if (e['mesh'] != null) {
        _loadMesh(e);
      }
      if (e['shader'] != null) {
        _loadMaterial(e);
      }
      
      if (e['type'] == 'skybox') {
        _spawnSkybox(e);
      }
      if (e['type'] == 'model') {
        _spawnModel(e);
      }
      if (e['type'] == 'uniformset') {
        _spawnUniformset(e);
      }
    });
    
    // Setup transforms
    _sceneDescription['entities'].forEach((e) {
      if (e['type'] != 'model') {
        return;
      }
      Map transform = e['transform'];
      if (transform == null) {
        return;
      }
      _setModelTransform(e['name'], transform);
    });
    
    _scene.reloaded();
    
    completer.complete(true);
    return completer.future;
  }
  
  Future load(Map sceneDescription) {
    if (_sceneDescription != null) {
      _sceneDescription = sceneDescription;
      // TODO: Compute delta
      return _loadResources(sceneDescription).chain(_loadEntities);
    } else {
      _sceneDescription = sceneDescription;
      return _loadResources(sceneDescription).chain(_loadEntities);
    }
  }
  
  void setupScene() {
    print('setup scene!');
  }
}
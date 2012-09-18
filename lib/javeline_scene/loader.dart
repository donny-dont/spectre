
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
    var en = sceneDescription['entities'];
    en.forEach((Map e) {
      String mesh = e['mesh'];
      Map<String, String> textures = e['textures'];
      if (mesh != null) {
        resources.add(mesh);
      }
      if (textures != null) {
        textures.forEach((k, v) {
          resources.add(v);
        });
      }
    });
    en = sceneDescription['materials'];
    en.forEach((Map e) {
      resources.add(e['shader']);
      Map<String, String> textures = e['textures'];
      if (textures != null) {
        textures.forEach((k, v) {
          resources.add(v);
        });
      }
    });
    resources.forEach((r) {
      int handle = _resourceManager.getResourceHandle(r);
      if (handle != Handle.BadHandle) {
        // Duplicate
        return;
      }
      handle = _resourceManager.registerResource(r);
      ResourceBase rb = _resourceManager.getResource(handle);
      if (rb is ImageResource) {
        int textureHandle = _device.createTexture2D(rb.url, {});
        _resourceManager.addEventCallback(handle, ResourceEvents.TypeUpdate, (type, resource) {
          _device.immediateContext.updateTexture2DFromResource(textureHandle, handle, _resourceManager);
          _device.immediateContext.generateMipmap(textureHandle);
          spectreLog.Info('Updated texture - ${rb.url}');
        });
        _deviceHandleTable.add(textureHandle);
      }
      _resourceHandleTable.add(handle);
    });
    return _resourceManager.loadResources(_resourceHandleTable, false);
  }
  
  Mesh _loadMesh(Map entity) {
    final String name = entity['mesh'];
    Mesh mesh = _scene.meshes[name];
    if (mesh == null) {
      mesh = new Mesh(name, _scene);
      _scene.meshes[name] = mesh;
    }
    mesh.load({});
    return mesh;
  }
  
  Material _loadMaterial(Map entity) {
    final String name = entity['name'];
    Material material = _scene.materials[name];
    if (material == null) {
      material = new Material(name, _scene);
      _scene.materials[name] = material;
    }
    material.load(entity);
    return material;
  }
  
  MaterialInstance _loadMaterialInstance(Map entity) {
    String materialName = entity['material'];
    if (materialName == null) {
      return null;
    }
    Material material = _scene.materials[materialName];
    if (material == null) {
      spectreLog.Error('No material named $materialName');
      return null;
    }
    String materialInstanceName = '${entity['material']}.${entity['name']}';
    MaterialInstance materialInstance = _scene.materialInstances[materialInstanceName];
    if (materialInstance == null) {
      materialInstance = new MaterialInstance(materialInstanceName, material, _scene);
      _scene.materialInstances[materialInstanceName] = materialInstance;
    }
    materialInstance.load(entity);
    return materialInstance;
  }
  
  void _spawnSkybox(Map entity) {
    if (_scene.skybox != null) {
      _scene.skybox.fini();
      _scene.skybox = null;
    }
    String texture0 = entity['textures']['0'];
    String texture1 = entity['textures']['1'];
    int texture0Handle = _scene.device.getDeviceChildHandle(texture0);
    int texture1Handle = _scene.device.getDeviceChildHandle(texture1);
    _scene.skybox = new Skybox(_device, _resourceManager,
                                texture0Handle,
                                texture1Handle);
    _scene.skybox.init();
  }
  
  void _spawnModel(Map entity) {
    String materialInstanceName = '${entity['material']}.${entity['name']}';
    MaterialInstance materialInstance = _scene.materialInstances[materialInstanceName];
    Mesh mesh = _scene.meshes[entity['mesh']];
    Model model = _scene.models[entity['name']];
    if (model == null) {
      model = new Model(entity['name'], _scene);
      _scene.models[entity['name']] = model;
    }
    model.update(materialInstance, mesh, materialInstance.material.meshinputs);
  }
  
  void _setModelTransform(String name, Map transform) {
    Model model = _scene.models[name];
    if (model == null) {
      return;
    }
    int xformHandle = model.transformHandle;
    if (name == 'cone') {
      //print('Cone model. $xformHandle');
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
      _scene.transformGraph.unparent(xformHandle);
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
    // Materials
    _sceneDescription['materials'].forEach((m) {
      _loadMaterial(m);
    });
   
    var foo = _sceneDescription['entities'];
    print('$foo');
    _sceneDescription['entities'].forEach((e) {
      _loadMaterialInstance(e);
    });
    
    Set<String> existingModels = new Set<String>();
    // Create entities
    _sceneDescription['entities'].forEach((e) {
      if (e['mesh'] != null) {
        _loadMesh(e);
      }
      if (e['type'] == 'skybox') {
        _spawnSkybox(e);
      }
      if (e['type'] == 'model') {
        existingModels.add(e['name']);
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
    
    _scene.reloaded(existingModels);
    
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
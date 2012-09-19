class Scene {
  Device device;
  ResourceManager resourceManager;
  Skybox skybox;
  int skyboxVertexShader;
  int skyboxFragmentShader;
  int skyboxShaderProgram;
  TransformGraph transformGraph;
  Map<String, Mesh> meshes;
  Map<String, Material> materials;
  Map<String, MaterialInstance> materialInstances;
  Map<String, Model> models;
  num _blendT;
  num _blendTDirection;

  Scene(this.device, this.resourceManager) {
    transformGraph = new TransformGraph(1024);
    transformGraph.updateWorldMatrices();
    meshes = new Map<String, Mesh>();
    materials = new Map<String, Material>();
    materialInstances = new Map<String, MaterialInstance>();
    models = new Map<String, Model>();
    _blendT = 0;
    _blendTDirection = 1.0;
  }

  void shutdown() {
    materialInstances.forEach((k,SceneChild v) {
      v.delete();
    });
    meshes.forEach((k, SceneChild v) {
      v.delete();
    });
    materials.forEach((k, SceneChild v) {
      v.delete();
    });
    models.forEach((k, SceneChild v) {
      v.delete();
    });
    skybox.fini();
    if (skyboxFragmentShader != null) {
      device.deleteDeviceChild(skyboxFragmentShader);
    }
    if (skyboxVertexShader != null) {
      device.deleteDeviceChild(skyboxVertexShader);
    }
    if (skyboxShaderProgram != null) {
      device.deleteDeviceChild(skyboxShaderProgram);
    }
  }
  
  void removeModel(String name) {
    Model m = models[name];
    if (m == null) {
      return;
    }
    models.remove(name);
    transformGraph.deleteNode(m.transformHandle);
  }

  void reloaded(Set<String> existingModels) {
    Set<String> deadModels = new Set<String>();
    models.forEach((k,v) {
      if (!existingModels.contains(k)) {
        deadModels.add(k);
      }
    });
    deadModels.forEach(removeModel);
    transformGraph.updateGraph();
  }

  void _updateBlendT(num dt) {
    _blendT += dt * _blendTDirection;
    if (_blendT > 1.0) {
      _blendT = 1.0;
      _blendTDirection *= -1.0;
    } else if (_blendT < 0.0) {
      _blendT = 0.0;
      _blendTDirection *= -1.0;
    }
  }

  void update(num time, num dt) {
    _updateBlendT(dt);
    models.forEach((k,v) {
      if (v.controller != null) {
        v.controller.control(dt);
      }
    });
    transformGraph.updateWorldMatrices();
  }

  void render(Camera camera, Map globalUniforms) {
    if (skybox != null) {
      skybox.draw(camera, _blendT);
    }
    models.forEach((k,v) {
      v.draw(camera, globalUniforms);
    });
  }
}
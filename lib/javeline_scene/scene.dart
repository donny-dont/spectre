class Scene {
  Device device;
  ResourceManager resourceManager;
  Skybox skybox;
  TransformGraph transformGraph;
  Map<String, Mesh> meshes;
  Map<String, Material> materials;
  Map<String, Model> models;
  num _blendT;
  num _blendTDirection;
  
  Scene(this.device, this.resourceManager) {
    transformGraph = new TransformGraph(1024);
    transformGraph.updateWorldMatrices();
    meshes = new Map<String, Mesh>();
    materials = new Map<String, Material>();
    models = new Map<String, Model>();
    _blendT = 0;
    _blendTDirection = 1.0;
  }
  
  void reloaded() {
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
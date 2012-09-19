
class Model extends SceneChild {
  MaterialInstance _materialInstance;
  Mesh _mesh;
  int _inputLayoutHandle;
  int transformHandle;

  Model(String name, Scene scene) : super(name, scene) {
    _inputLayoutHandle = 0;
    transformHandle = scene.transformGraph.createNode();
    print('Spawned $name with $transformHandle');
  }
  
  void delete() {
    scene.device.deleteDeviceChild(_inputLayoutHandle);
  }
  
  void update(MaterialInstance materialInstance, Mesh mesh, List layout) {
    _materialInstance = materialInstance;
    _mesh = mesh;
    if (_inputLayoutHandle == 0) {
      _inputLayoutHandle = scene.device.createInputLayout('$name.il', {});
    }
    List<InputElementDescription> descriptions = new List<InputElementDescription>();
    layout.forEach((e) {
      InputLayoutDescription ild = new InputLayoutDescription(e['name'], 0, e['type']);
      InputElementDescription ied = InputLayoutHelper.inputElementDescriptionFromAttributes(ild, _mesh.attributes);
      descriptions.add(ied);
    });
    
    scene.device.configureDeviceChild(_inputLayoutHandle, {
      'shaderProgram': _materialInstance.material.shaderProgramHandle,
      'elements': descriptions
    });
  }
  
  void draw(Camera camera, Map globalUniforms) {
    scene.device.immediateContext.setInputLayout(_inputLayoutHandle);
    _mesh.preDraw();
    _materialInstance.preDraw();
    globalUniforms.forEach((k,v) {
      scene.device.immediateContext.setUniformMatrix4(k, v);
    });
    Float32Array objectTransformArray = scene.transformGraph.refWorldMatrixArray(transformHandle);
    scene.device.immediateContext.setUniformMatrix4('objectTransform', objectTransformArray);
    _mesh.draw();
  }
}

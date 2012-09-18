class MaterialUniform {
  final String name;
  final int uniformIndex;
  final String type;
  final int size;
  MaterialUniform(this.name, this.uniformIndex, this.type, this.size);
}

class Material extends SceneChild {
  int vertexShaderHandle;
  int fragmentShaderHandle;
  int shaderProgramHandle;
  Map<String, MaterialUniform> uniforms;
  
  Material(String name, Scene scene) : super(name, scene) {
    vertexShaderHandle = 0;
    fragmentShaderHandle = 0;
    shaderProgramHandle = 0;
  }
  
  void uniformCallback(String name, int index, String type, int size) {
    //print('$type $name [$index] $size');
    uniforms[name] = new MaterialUniform(name, index, type, size);
  }
  
  void loadUniforms() {
    uniforms = new Map<String, MaterialUniform>();
    scene.device.getDeviceChild(shaderProgramHandle).forEachUniforms(uniformCallback);
  }
  
  int uniformIndex(String name) {
    MaterialUniform uniform = uniforms[name];
    if (uniform != null) {
      return uniform.uniformIndex;
    }
    return -1;
  }
  
  void load(Map o) {
    int handle = scene.resourceManager.getResourceHandle(name);
    ShaderProgramResource spr = scene.resourceManager.getResource(handle);
    if (spr == null) {
      spectreLog.Error('Could not load $name');
      return;
    }
    if (vertexShaderHandle == 0) {
      vertexShaderHandle = scene.device.createVertexShader('${name}.vs', {});
    }
    if (fragmentShaderHandle == 0) {
      fragmentShaderHandle = scene.device.createFragmentShader('${name}.fs', {});
    }
    if (shaderProgramHandle == 0) {
      shaderProgramHandle = scene.device.createShaderProgram('${name}.shader', {});  
    }
    
    scene.device.getDeviceChild(vertexShaderHandle).source = spr.vertexShaderSource;
    scene.device.getDeviceChild(vertexShaderHandle).compile();
    scene.device.getDeviceChild(fragmentShaderHandle).source = spr.fragmentShaderSource;
    scene.device.getDeviceChild(fragmentShaderHandle).compile();
    scene.device.configureDeviceChild(shaderProgramHandle, {
      'VertexProgram': vertexShaderHandle,
      'FragmentProgram': fragmentShaderHandle,
    });
    loadUniforms();
  }
  
  void preDraw() {
    scene.device.immediateContext.setShaderProgram(shaderProgramHandle);
  }
}
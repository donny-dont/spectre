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
  int blendStateHandle;
  int depthStateHandle;
  int rasterizerStateHandle;
  Map entity;
  Map<String, MaterialUniform> uniforms;
  List<Map> meshinputs;
  Material(String name, Scene scene) : super(name, scene) {
    vertexShaderHandle = 0;
    fragmentShaderHandle = 0;
    shaderProgramHandle = 0;
    blendStateHandle = 0;
    depthStateHandle = 0;
    rasterizerStateHandle = 0;
  }
  
  void uniformCallback(String name, int index, String type, int size) {
    uniforms[name] = new MaterialUniform(name, index, type, size);
  }
  
  void loadUniforms() {
    uniforms = new Map<String, MaterialUniform>();
    scene.device.getDeviceChild(shaderProgramHandle).forEachUniforms(uniformCallback);
    spectreLog.Info('$uniforms');
  }
  
  int uniformIndex(String name) {
    MaterialUniform uniform = uniforms[name];
    if (uniform != null) {
      return uniform.uniformIndex;
    }
    return -1;
  }
  
  void load(Map o) {
    entity = o;
    meshinputs = o['meshinputs'];
    String shaderName = o['shader'];
    int handle = scene.resourceManager.getResourceHandle(shaderName);
    ShaderProgramResource spr = scene.resourceManager.getResource(handle);
    if (spr == null) {
      spectreLog.Error('Could not load $name');
      return;
    }
    if (vertexShaderHandle == 0) {
      vertexShaderHandle = scene.device.createVertexShader('$shaderName.vs', {});
    }
    if (fragmentShaderHandle == 0) {
      fragmentShaderHandle = scene.device.createFragmentShader('$shaderName.fs', {});
    }
    if (shaderProgramHandle == 0) {
      shaderProgramHandle = scene.device.createShaderProgram('$shaderName.sp', {});  
    }
    if (blendStateHandle == 0) {
      blendStateHandle = scene.device.createBlendState('$name.bs', {});
    }
    if (depthStateHandle == 0) {
      depthStateHandle = scene.device.createDepthState('$name.ds', {});
    }
    if (rasterizerStateHandle == 0) {
      rasterizerStateHandle = scene.device.createRasterizerState('$name.rs', {});
    }
    bool relink = false;
    VertexShader vs = scene.device.getDeviceChild(vertexShaderHandle);
    if (vs.source != spr.vertexShaderSource) {
      vs.source = spr.vertexShaderSource;
      vs.compile();
      relink = true;
    }
    
    FragmentShader fs = scene.device.getDeviceChild(fragmentShaderHandle);
    if (fs.source != spr.fragmentShaderSource) {
      fs.source = spr.fragmentShaderSource;
      fs.compile();
      relink = true;
    }
    
    ShaderProgram sp = scene.device.getDeviceChild(shaderProgramHandle);
    if (!sp.linked || relink) {
      scene.device.configureDeviceChild(shaderProgramHandle, {
        'VertexProgram': vertexShaderHandle,
        'FragmentProgram': fragmentShaderHandle,
      });
      loadUniforms();  
    }
  }
  
  void preDraw() {
    scene.device.immediateContext.setShaderProgram(shaderProgramHandle);
  }
}

class Material extends SceneChild {
  int vertexShaderHandle;
  int fragmentShaderHandle;
  int shaderProgramHandle;
  Map<String, int> uniforms;
  
  Material(String name, Scene scene) : super(name, scene) {
    vertexShaderHandle = 0;
    fragmentShaderHandle = 0;
    shaderProgramHandle = 0;
    uniforms = new Map<String, int>();
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
  }
}
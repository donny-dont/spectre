
class Material extends SceneChild {
  int shaderProgramHandle;
  Map<String, int> uniforms;
  
  Material(String name, Scene scene) : super(name, scene);
  
  void load(Map o) {
    uniforms = new Map<String, int>();
  }
}
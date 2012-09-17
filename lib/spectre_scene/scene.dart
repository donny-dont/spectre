class Scene {
  Device device;
  ResourceManager resourceManager;
  
  Map<String, Mesh> meshes;
  Map<String, Material> materials;
  Scene(this.device, this.resourceManager) {
    meshes = new Map<String, Mesh>();
    materials = new Map<String, Material>();
  }
}
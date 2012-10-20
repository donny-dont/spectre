
class SpectrePostFragment extends SpectrePostPass {
  final int shaderProgram;
  final List<InputElementDescription> elements;
  int inputLayout;
  SpectrePostFragment(GraphicsDevice device,
                      String name,
                      this.shaderProgram,
                      this.elements) : super() {
    inputLayout = device.createInputLayout('SpectrePost.InputLayout[$name]', {
      'shaderProgram': shaderProgram,
      'elements': elements
    });
  }

  void cleanup(GraphicsDevice device) {
    device.deleteDeviceChild(shaderProgram);
    device.deleteDeviceChild(inputLayout);
  }

  void setup(GraphicsDevice device, Map<String, Dynamic> args) {
    List<int> textures = args['textures'];
    List<int> samplers = args['samplers'];
    device.immediateContext.setTextures(0, textures);
    device.immediateContext.setSamplers(0, samplers);
    device.immediateContext.setShaderProgram(shaderProgram);
    device.immediateContext.setInputLayout(inputLayout);
  }
}

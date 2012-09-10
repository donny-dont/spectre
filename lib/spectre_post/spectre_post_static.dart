class SpectrePost {
  static Device _device = null;
  static Map<String, SpectrePostPass> _passes = null;
  static int _rasterizerState = null;
  static int _depthState = null;
  static int _blendState = null;
  static int vertexBuffer = null;
  static int vertexShader = null;
  static List<InputElementDescription> elements  = null;
  
  static void init(Device device) {
    if (_device == null) {
      _device = device;
      _rasterizerState = _device.createRasterizerState('SpectrePost.RS', {'cullEnabled': false});
      _depthState = _device.createDepthState('SpectrePost.DS', {});
      _blendState = _device.createBlendState('SpectrePost.PS', {'blendEnable':true, 'blendSourceColorFunc': BlendState.BlendSourceShaderAlpha, 'blendDestColorFunc': BlendState.BlendSourceShaderInverseAlpha, 'blendSourceAlphaFunc': BlendState.BlendSourceShaderAlpha, 'blendDestAlphaFunc': BlendState.BlendSourceShaderInverseAlpha});
      _passes = new Map<String, SpectrePostPass>();
      int numFloats = 6 * (3+2);
      Float32Array verts = new Float32Array(6*(3+2));
      elements = [new InputElementDescription('vPosition', Device.DeviceFormatFloat3, 20, 0, 0),
                  new InputElementDescription('vTexCoord', Device.DeviceFormatFloat2, 20, 0, 12)
                  ];
      int index = 0;
      num depth = -1.0;
      // Triangle 1
      {
        // Vertex 1
        verts[index++] = -1.0;
        verts[index++] = -1.0;
        verts[index++] = depth;
        verts[index++] = 0.0;
        verts[index++] = 0.0;
        
        // Vertex 2
        verts[index++] = 1.0;
        verts[index++] = -1.0;
        verts[index++] = depth;
        verts[index++] = 1.0;
        verts[index++] = 0.0;
        
        // Vertex 3
        verts[index++] = 1.0;
        verts[index++] = 1.0;
        verts[index++] = depth;
        verts[index++] = 1.0;
        verts[index++] = 1.0;
      }
      // Triangle 2
      {
        // Vertex 1
        verts[index++] = -1.0;
        verts[index++] = -1.0;
        verts[index++] = depth;
        verts[index++] = 0.0;
        verts[index++] = 0.0;
        
        // Vertex 2
        verts[index++] = 1.0;
        verts[index++] = 1.0;
        verts[index++] = depth;
        verts[index++] = 1.0;
        verts[index++] = 1.0;
        
        // Vertex 3
        verts[index++] = -1.0;
        verts[index++] = 1.0;
        verts[index++] = depth;
        verts[index++] = 0.0;
        verts[index++] = 1.0;
      }
      assert(index == numFloats);
      vertexBuffer = _device.createVertexBuffer('SpectrePost.VBO', {
        'usage': 'static'
      });
      _device.immediateContext.updateBuffer(vertexBuffer, verts);
      vertexShader = _device.createVertexShader('SpectrePost.VS', {});
      VertexShader vs = _device.getDeviceChild(vertexShader);
      _device.immediateContext.compileShader(vertexShader, '''
precision highp float;

attribute vec3 vPosition;
attribute vec2 vTexCoord;

varying vec2 samplePoint;

uniform vec2 texScale;

void main() {
    vec4 vPosition4 = vec4(vPosition.x, vPosition.y, vPosition.z, 1.0);
    gl_Position = vPosition4;
    samplePoint = vTexCoord * texScale;
}
''');
      addFragmentPass('blit', '''
precision mediump float;

varying vec2 samplePoint;
uniform sampler2D blitSource;

void main() {
    gl_FragColor = texture2D(blitSource, samplePoint);
}''');

      addFragmentPass('testblit', '''
precision mediump float;

varying vec2 samplePoint;
uniform sampler2D blitSource;

void main() {
    gl_FragColor = vec4(1.0, 0.5, 0.5, 1.0);
}''');
    } else {
      // already initialized...
      spectreLog.Error('Cannot initialize SpectrePost more than once.');
    }
  }
  
  static void cleanup() {
    _passes.forEach((k,v) {
      spectreLog.Info('Cleaning up spectre post process $k');
      v.cleanup(_device);
    });
    _passes.clear();
    _device.deleteDeviceChild(vertexBuffer);
    _device.deleteDeviceChild(vertexShader);
    _device.deleteDeviceChild(_rasterizerState);
    _device.deleteDeviceChild(_blendState);
    _device.deleteDeviceChild(_depthState);
  }
  
  static void addPass(String name, SpectrePostPass pass) {
    if (_passes[name] != null) {
      spectreLog.Error('Attempt to add pass that already exists- $name');
      return;
    }
    _passes[name] = pass;
  }
  
  static void addFragmentPass(String name, String fragmentSource) {
    if (_passes[name] != null) {
      spectreLog.Error('Attempt to add pass that already eists- $name');
      return;
    }
    int fragmentShader = _device.createFragmentShader('SpectrePost.FS[$name]', {});
    _device.immediateContext.compileShader(fragmentShader, fragmentSource);
    int passProgram = _device.createShaderProgram('SpectrePost.Program[$name]', {
      'VertexProgram': vertexShader,
      'FragmentProgram': fragmentShader
    });
    SpectrePostFragment spf = new SpectrePostFragment(_device, name, passProgram, elements);
    _passes[name] = spf;
  }
  
  static void removePass(String name) {
    SpectrePostPass pass = _passes[name];
    if (pass != null) {
      _passes.remove(name);
      pass.cleanup(_device);
    }
  }
  
  static void pass(String name, int renderTargetHandle, Map<String, Dynamic> arguments) {
    SpectrePostPass pass = _passes[name];
    if (pass == null) {
      spectreLog.Error('Post process $name does not exist. Cannot do pass.');
      return;
    }
    pass.setup(_device, arguments);
    _device.immediateContext.setVertexBuffers(0, [vertexBuffer]);
    _device.immediateContext.setIndexBuffer(0);
    _device.immediateContext.setRasterizerState(_rasterizerState);
    _device.immediateContext.setDepthState(_depthState);
    _device.immediateContext.setBlendState(_blendState);
    // FIXME: Make the following dynamic:
    _device.immediateContext.setUniform2f('texScale', 0.833, 0.46875);
    _device.immediateContext.setPrimitiveTopology(ImmediateContext.PrimitiveTopologyTriangles);
    _device.immediateContext.setRenderTarget(renderTargetHandle);
    _device.immediateContext.draw(6, 0);
  }
}
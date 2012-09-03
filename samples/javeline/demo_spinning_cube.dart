/*

  Copyright (C) 2012 John McCutchan <john@johnmccutchan.com>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

*/

class JavelineSpinningCube extends JavelineBaseDemo {
  int cubeMeshResource;
  int cubeVertexBuffer;
  int cubeIndexBuffer;
  int cubeNumIndices;
  int cubeVertexShaderResource;
  int cubeVertexShader;
  int cubeFragmentShaderResource;
  int cubeFragmentShader;
  int cubeTextureResource;
  int cubeProgram;
  int texture;
  int sampler;
  int rs;
  int il;
  Float32Array cameraTransform;
  Float32Array objectTransform;
  num _angle;
  List _frameProgram;
  List _shutdownProgram;
  TransformGraph _transformGraph;
  List<int> _transformNodes;
  JavelineSpinningCube(Device device, ResourceManager resourceManager, DebugDrawManager debugDrawManager) : super(device, resourceManager, debugDrawManager) {
    cubeMeshResource = 0;
    cubeVertexShaderResource = 0;
    cubeFragmentShaderResource = 0;
    cubeTextureResource = 0;
    cameraTransform = new Float32Array(16);
    objectTransform = new Float32Array(16);
    _angle = 0.0;
    _transformGraph = new TransformGraph(16);
    _transformNodes = new List<int>();
    _transformNodes.add(_transformGraph.createNode());
    _transformNodes.add(_transformGraph.createNode());
    _transformNodes.add(_transformGraph.createNode());
    _transformNodes.add(_transformGraph.createNode());
    _transformGraph.reparent(_transformNodes[3], _transformNodes[2]);
    _transformGraph.reparent(_transformNodes[2], _transformNodes[1]);
    _transformGraph.reparent(_transformNodes[1], _transformNodes[0]);
    _transformGraph.updateGraph();
  }

  /*
   * fix loading of input layout
   */
  Future<JavelineDemoStatus> startup() {
    Future<JavelineDemoStatus> base = super.startup();

    Completer<JavelineDemoStatus> complete = new Completer<JavelineDemoStatus>();
    base.then((value) {
      // Once the base is done, we load our resources
      cubeMeshResource = resourceManager.registerResource('/meshes/TexturedCube.mesh');
      cubeVertexShaderResource = resourceManager.registerResource('/shaders/simple_texture.vs');
      cubeFragmentShaderResource = resourceManager.registerResource('/shaders/simple_texture.fs');
      cubeTextureResource = resourceManager.registerResource('/textures/WoodPlank.jpg');
      cubeVertexShader = device.createVertexShader('Cube Vertex Shader',{});
      cubeFragmentShader = device.createFragmentShader('Cube Fragment Shader', {});
      sampler = device.createSamplerState('Cube Texture Sampler', {});
      rs = device.createRasterizerState('Cube Rasterizer State', {'cullEnabled': true, 'cullMode': RasterizerState.CullBack, 'cullFrontFace': RasterizerState.FrontCCW});
      texture = device.createTexture2D('Cube Texture', { 'width': 512, 'height': 512, 'textureFormat' : Texture.TextureFormatRGB, 'pixelFormat': Texture.PixelFormatUnsignedByte});
      cubeVertexBuffer = device.createVertexBuffer('Cube Vertex Buffer', {'usage':'static'});
      cubeIndexBuffer = device.createIndexBuffer('Cube Index Buffer', {'usage':'static'});
      cubeProgram = device.createShaderProgram('Cube Program', {});
      il = device.createInputLayout('Cube Input Layout', {});
      resourceManager.addEventCallback(cubeMeshResource, ResourceEvents.TypeUpdate, (type, resource) {
        MeshResource cube = resource;
        var elements = [InputLayoutHelper.inputElementDescriptionFromMesh(new InputLayoutDescription('vPosition', 0, 'POSITION'), cube),
                        InputLayoutHelper.inputElementDescriptionFromMesh(new InputLayoutDescription('vTexCoord', 0, 'TEXCOORD0'), cube)];
        
        device.configureDeviceChild(il, {'elements': elements});
        device.configureDeviceChild(il, {'shaderProgram': cubeProgram});
        
        cubeNumIndices = cube.numIndices;
        
        immediateContext.updateBuffer(cubeVertexBuffer, cube.vertexArray);
        immediateContext.updateBuffer(cubeIndexBuffer, cube.indexArray);
        
        // Build frame program
        ProgramBuilder pb = new ProgramBuilder();
        pb.setPrimitiveTopology(ImmediateContext.PrimitiveTopologyTriangles);
        pb.setRasterizerState(rs);
        pb.setShaderProgram(cubeProgram);
        pb.setUniformMatrix4('objectTransform', objectTransform);
        pb.setUniformMatrix4('cameraTransform', cameraTransform);
        pb.setTextures(0, [texture]);
        pb.setSamplers(0, [sampler]);
        pb.setInputLayout(il);
        pb.setIndexBuffer(cubeIndexBuffer);
        pb.setVertexBuffers(0, [cubeVertexBuffer]);
        pb.drawIndexed(cubeNumIndices, 0);
        _frameProgram = pb.ops;
      });
      
      resourceManager.addEventCallback(cubeTextureResource, ResourceEvents.TypeUpdate, (type, resource) {
        immediateContext.updateTexture2DFromResource(texture, cubeTextureResource, resourceManager);
        immediateContext.generateMipmap(texture);
      });
      
      resourceManager.addEventCallback(cubeVertexShaderResource, ResourceEvents.TypeUpdate, (type, resource) {
        immediateContext.compileShaderFromResource(cubeVertexShader, cubeVertexShaderResource, resourceManager);
        device.configureDeviceChild(cubeProgram, { 'VertexProgram': cubeVertexShader });
      });
      
      resourceManager.addEventCallback(cubeFragmentShaderResource, ResourceEvents.TypeUpdate, (type, resource) {
        immediateContext.compileShaderFromResource(cubeFragmentShader, cubeFragmentShaderResource, resourceManager);
        device.configureDeviceChild(cubeProgram, { 'FragmentProgram': cubeFragmentShader });
      });
      
      resourceManager.loadResource(cubeVertexShaderResource);
      resourceManager.loadResource(cubeFragmentShaderResource);
      resourceManager.loadResource(cubeMeshResource);
      resourceManager.loadResource(cubeTextureResource);
      
      complete.complete(new JavelineDemoStatus(JavelineDemoStatus.DemoStatusOKAY, ''));
    });
    return complete.future;
  }

  Future<JavelineDemoStatus> shutdown() {
    Interpreter interpreter = new Interpreter();
    // Build shutdown program
    ProgramBuilder pb = new ProgramBuilder();
    pb.deregisterResources([cubeMeshResource, cubeVertexShaderResource, cubeFragmentShaderResource, cubeTextureResource]);
    pb.deleteDeviceChildren([il, rs, sampler, texture, cubeProgram, cubeVertexBuffer, cubeIndexBuffer, cubeVertexShader, cubeFragmentShader]);
    _shutdownProgram = pb.ops;

    interpreter.run(_shutdownProgram, device, resourceManager, immediateContext);
    Future<JavelineDemoStatus> base = super.shutdown();
    return base;
  }

  void drawCube(mat4 T) {
    {
      mat4 pm = camera.projectionMatrix;
      mat4 la = camera.lookAtMatrix;
      pm.multiply(la);
      pm.copyIntoArray(cameraTransform);
      T.copyIntoArray(objectTransform);
    }
    Interpreter interpreter = new Interpreter();
    interpreter.run(_frameProgram, device, resourceManager, immediateContext);
  }

  void update(num time, num dt) {
    super.update(time, dt);
    _angle += dt * 3.14159;
    drawGrid(20);
    debugDrawManager.prepareForRender();
    debugDrawManager.render(camera);
    num h = sin(_angle);
    _transformGraph.setLocalMatrix(_transformNodes[2], new mat4.scaleRaw(1.0, 2.0, 3.0));
    _transformGraph.setLocalMatrix(_transformNodes[0], new mat4.translationRaw(h, 0.0, 1-h));
    _transformGraph.setLocalMatrix(_transformNodes[1], new mat4.rotationZ(_angle));
    _transformGraph.updateWorldMatrices();
    drawCube(_transformGraph.refWorldMatrix(_transformNodes[3]));
  }
}

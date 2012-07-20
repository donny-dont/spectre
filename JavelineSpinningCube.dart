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

  JavelineSpinningCube() {
    cubeMeshResource = 0;
    cubeVertexShaderResource = 0;
    cubeFragmentShaderResource = 0;
    cubeTextureResource = 0;
    cameraTransform = new Float32Array(16);
    objectTransform = new Float32Array(16);
    _angle = 0.0;
  }

  Future<JavelineDemoStatus> startup() {
    Future<JavelineDemoStatus> base = super.startup();

    cubeMeshResource = spectreRM.registerResource('/meshes/TexturedCube.mesh');
    cubeVertexShaderResource = spectreRM.registerResource('/shaders/simple_texture.vs');
    cubeFragmentShaderResource = spectreRM.registerResource('/shaders/simple_texture.fs');
    cubeTextureResource = spectreRM.registerResource('/textures/WoodPlank.jpg');
    cubeVertexShader = spectreDevice.createVertexShader('Cube Vertex Shader',{});
    cubeFragmentShader = spectreDevice.createFragmentShader('Cube Fragment Shader', {});
    sampler = spectreDevice.createSamplerState('Cube Texture Sampler', {});
    rs = spectreDevice.createRasterizerState('Cube Rasterizer State', {'cullEnabled': true, 'cullMode': RasterizerState.CullBack, 'cullFrontFace': RasterizerState.FrontCCW});
    texture = spectreDevice.createTexture2D('Cube Texture', { 'width': 512, 'height': 512, 'textureFormat' : Texture.TextureFormatRGB, 'pixelFormat': Texture.PixelFormatUnsignedByte});


    List loadedResources = [];
    base.then((value) {
      // Once the base is done, we load our resources
      loadedResources.add(spectreRM.loadResource(cubeMeshResource));
      loadedResources.add(spectreRM.loadResource(cubeVertexShaderResource));
      loadedResources.add(spectreRM.loadResource(cubeFragmentShaderResource));
      loadedResources.add(spectreRM.loadResource(cubeTextureResource));
    });

    Future allLoaded = Futures.wait(loadedResources);
    Completer<JavelineDemoStatus> complete = new Completer<JavelineDemoStatus>();
    allLoaded.then((list) {
      // After our resources are loaded, we build the scene
      spectreImmediateContext.compileShaderFromResource(cubeVertexShader, cubeVertexShaderResource);
      spectreImmediateContext.compileShaderFromResource(cubeFragmentShader, cubeFragmentShaderResource);
      cubeProgram = spectreDevice.createShaderProgram('Cube Program', { 'VertexProgram': cubeVertexShader, 'FragmentProgram': cubeFragmentShader});
      spectreImmediateContext.updateTexture2DFromResource(texture, cubeTextureResource);
      spectreImmediateContext.generateMipmap(texture);

      {
        MeshResource cube = spectreRM.getResource(cubeMeshResource);
        var elements = [InputLayoutHelper.inputElementDescriptionFromMesh('vPosition', 0, 'POSITION', cube),
                        InputLayoutHelper.inputElementDescriptionFromMesh('vTexCoord', 0, 'TEXCOORD0', cube)];
        il = spectreDevice.createInputLayout('Cube Input Layout', elements, cubeProgram);
        cubeVertexBuffer = spectreDevice.createVertexBuffer('Cube Vertex Buffer', {'usage': 'static', 'size': cube.vertexArray.byteLength});
        cubeIndexBuffer = spectreDevice.createIndexBuffer('Cube Index Buffer', {'usage':'static', 'size': cube.indexArray.byteLength});
        cubeNumIndices = cube.numIndices;
        spectreImmediateContext.updateBuffer(cubeVertexBuffer, cube.vertexArray);
        spectreImmediateContext.updateBuffer(cubeIndexBuffer, cube.indexArray);
      }

      ProgramBuilder pb;

      // Build shutdown program
      pb = new ProgramBuilder();
      pb.deregisterAndUnloadResources([cubeMeshResource, cubeVertexShaderResource, cubeFragmentShaderResource, cubeTextureResource]);
      pb.deleteDeviceChildren([il, rs, sampler, texture, cubeProgram, cubeVertexBuffer, cubeIndexBuffer, cubeVertexShader, cubeFragmentShader]);
      _shutdownProgram = pb.ops;

      // Build frame program
      pb = new ProgramBuilder();
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

      complete.complete(new JavelineDemoStatus(JavelineDemoStatus.DemoStatusOKAY, ''));
    });

    return complete.future;
  }

  Future<JavelineDemoStatus> shutdown() {
    Interpreter interpreter = new Interpreter();
    interpreter.run(_shutdownProgram, spectreDevice, spectreRM, spectreImmediateContext);
    Future<JavelineDemoStatus> base = super.shutdown();
    return base;
  }

  void drawCube(mat4x4 T) {
    {
      mat4x4 pm = _camera.projectionMatrix;
      mat4x4 la = _camera.lookAtMatrix;
      pm.selfMultiply(la);
      pm.copyIntoArray(cameraTransform);
      T.copyIntoArray(objectTransform);
    }
    Interpreter interpreter = new Interpreter();
    interpreter.run(_frameProgram, spectreDevice, spectreRM, spectreImmediateContext);
  }

  void update(num time, num dt) {
    super.update(time, dt);
    _angle += dt * 3.14159;
    drawGrid(20);
    spectreDDM.prepareForRender();
    spectreDDM.render(_camera);
    mat4x4 I = new mat4x4.rotationY(_angle);
    drawCube(I);
  }
}

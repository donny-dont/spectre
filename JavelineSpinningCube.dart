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
  MeshResource cube;
  VertexShaderResource vertexShader;
  FragmentShaderResource fragmentShader;
  ImageResource textureImage;
  ShaderProgram cubeProgram;
  Texture2D texture;
  SamplerState sampler;
  RasterizerState rs;
  InputLayout il;
  Float32Array cameraTransform;
  Float32Array objectTransform;
  num _angle;
  JavelineSpinningCube() {
    cube = null;
    vertexShader = null;
    fragmentShader = null;
    cameraTransform = new Float32Array(16);
    objectTransform = new Float32Array(16);
    _angle = 0.0;
  }
  
  Future<JavelineDemoStatus> startup() {
    Future<JavelineDemoStatus> base = super.startup();
    Completer<JavelineDemoStatus> complete = new Completer<JavelineDemoStatus>();
    base.then((value) {
      List loadedResources = [];
      loadedResources.add(spectreRM.load('/meshes/TexturedCube.mesh'));
      loadedResources.add(spectreRM.load('/shaders/simple_texture.vs'));
      loadedResources.add(spectreRM.load('/shaders/simple_texture.fs'));
      loadedResources.add(spectreRM.load('/textures/WoodPlank.jpg'));
      Future allLoaded = Futures.wait(loadedResources);
      allLoaded.then((list) {
        cube = list[0];
        vertexShader = list[1];
        fragmentShader = list[2];
        textureImage = list[3];
        cubeProgram = spectreDevice.createShaderProgram('Cube Program', { 'VertexProgram': vertexShader.shader, 'FragmentProgram': fragmentShader.shader});
        texture = spectreDevice.createTexture2D('Cube Texture', { 'width': 512, 'height': 512, 'textureFormat' : Texture.TextureFormatRGB, 'pixelFormat': Texture.PixelFormatUnsignedByte});
        spectreImmediateContext.updateTexture2D(texture, textureImage.image);
        spectreImmediateContext.generateMipmap(texture);
        sampler = spectreDevice.createSamplerState('Cube Texture Sampler', {});
        rs = spectreDevice.createRasterizerState('Cube Rasterizer State', {'cullEnabled': true, 'cullMode': RasterizerState.CullBack, 'cullFrontFace': RasterizerState.FrontCCW});
        {
          var elements = [InputLayoutHelper.inputElementDescriptionFromMesh('vPosition', 0, 'POSITION', cube),
                          InputLayoutHelper.inputElementDescriptionFromMesh('vTexCoord', 0, 'TEXCOORD0', cube)];
          il = spectreDevice.createInputLayout('Cube Input Layout', elements, cubeProgram);
        }
        complete.complete(new JavelineDemoStatus(JavelineDemoStatus.DemoStatusOKAY, ''));
      });  
    });
    return complete.future;
  }
  
  Future<JavelineDemoStatus> shutdown() {
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
    spectreImmediateContext.setPrimitiveTopology(ImmediateContext.PrimitiveTopologyTriangles);
    spectreImmediateContext.setRasterizerState(rs);
    spectreImmediateContext.setShaderProgram(cubeProgram);
    spectreImmediateContext.setUniformMatrix4('objectTransform', objectTransform);
    spectreImmediateContext.setUniformMatrix4('cameraTransform', cameraTransform);
    spectreImmediateContext.setTextures(0, [texture]);
    spectreImmediateContext.setSamplers(0, [sampler]);
    spectreImmediateContext.setInputLayout(il);
    spectreImmediateContext.setIndexBuffer(cube.indexBuffer);
    spectreImmediateContext.setVertexBuffers(0, [cube.vertexBuffer]);
    spectreImmediateContext.drawIndexed(cube.numIndices, 0);
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

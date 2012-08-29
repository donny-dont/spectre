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

class JavelineParticlesDemo extends JavelineBaseDemo {
  int _particlesVBOHandle;
  int _particlesVSResourceHandle;
  int _particlesFSResourceHandle;
  int _particlesVSHandle;
  int _particlesFSHandle;
  int _particlesInputLayoutHandle;
  int _particlesShaderProgramHandle;
  int _particlePointSpriteResourceHandle;
  int _particlePointSpriteHandle;
  int _particlePointSpriteSamplerHandle;
  int _particleDepthStateHandle;
  int _particleBlendStateHandle;
  
  Float32Array _particlesVertexData;
  
  ParticleSystemBackend _particles;
  
  int _numParticles;
  int _particleVertexSize;
  
  JavelineParticlesDemo(Device device, ResourceManager resourceManager, DebugDrawManager debugDrawManager) : super(device, resourceManager, debugDrawManager) {
    _numParticles = 100;
    _particleVertexSize = 6;
    _particles = new ParticleSystemBackendDVM(_numParticles);
    // Position+Color
    _particlesVertexData = new Float32Array(_numParticles*_particleVertexSize);
    for (int i = 0; i < _numParticles; i++) {
      int index = i * _particleVertexSize;
      _particlesVertexData[index+0] = 0.0;
      _particlesVertexData[index+1] = 0.0;
      _particlesVertexData[index+2] = 0.0;
      
      // Color
      _particlesVertexData[index+3] = 1.0;
      _particlesVertexData[index+4] = 0.0;
      _particlesVertexData[index+5] = 0.0;
      if (i > ((_numParticles ~/ 3) * 2)) {
        _particlesVertexData[index+3] = 0.0;
        _particlesVertexData[index+4] = 0.0;
        _particlesVertexData[index+5] = 1.0;
      } else if (i > (_numParticles ~/ 3)) {
        _particlesVertexData[index+3] = 0.0;
        _particlesVertexData[index+4] = 1.0;
        _particlesVertexData[index+5] = 0.0;  
      } 
    }
  }
  
  Future<JavelineDemoStatus> startup() {
    Future<JavelineDemoStatus> base = super.startup();
    
    _particlesVBOHandle = device.createVertexBuffer('Particles Vertex Buffer', {'usage':'stream', 'size':_numParticles*_particleVertexSize});
    _particlesVSResourceHandle = resourceManager.registerResource('/shaders/simple_particle.vs');
    _particlesFSResourceHandle = resourceManager.registerResource('/shaders/simple_particle.fs');
    _particlesVSHandle = device.createVertexShader('Particle Vertex Shader',{});
    _particlesFSHandle = device.createFragmentShader('Particle Fragment Shader', {});
    _particlePointSpriteResourceHandle = resourceManager.registerResource('/textures/particle.png');
    _particlePointSpriteHandle = device.createTexture2D('Particle Texture', { 'width': 128, 'height': 128, 'textureFormat' : Texture.TextureFormatRGBA, 'pixelFormat': Texture.PixelFormatUnsignedByte});
    _particlePointSpriteSamplerHandle = device.createSamplerState('Particle Sampler', {'wrapS':SamplerState.TextureWrapClampToEdge, 'wrapT':SamplerState.TextureWrapClampToEdge,'minFilter':SamplerState.TextureMagFilterNearest,'magFilter':SamplerState.TextureMagFilterLinear});
    _particleDepthStateHandle = device.createDepthState('Particle Depth State', {});
    _particleBlendStateHandle = device.createBlendState('Particle Blend State', {'blendEnable':true, 'blendSourceColorFunc': BlendState.BlendSourceShaderAlpha, 'blendDestColorFunc': BlendState.BlendSourceShaderInverseAlpha, 'blendSourceAlphaFunc': BlendState.BlendSourceShaderAlpha, 'blendDestAlphaFunc': BlendState.BlendSourceShaderInverseAlpha}); 
    List loadedResources = [];
    base.then((value) {
      // Once the base is done, we load our resources
      loadedResources.add(resourceManager.loadResource(_particlesVSResourceHandle));
      loadedResources.add(resourceManager.loadResource(_particlesFSResourceHandle));
      loadedResources.add(resourceManager.loadResource(_particlePointSpriteResourceHandle));
    });
    
    Future allLoaded = Futures.wait(loadedResources);
    Completer<JavelineDemoStatus> complete = new Completer<JavelineDemoStatus>();
    allLoaded.then((list) {
      immediateContext.compileShaderFromResource(_particlesVSHandle, _particlesVSResourceHandle, resourceManager);
      immediateContext.compileShaderFromResource(_particlesFSHandle, _particlesFSResourceHandle, resourceManager);
      _particlesShaderProgramHandle = device.createShaderProgram('Particle Shader Program', { 'VertexProgram': _particlesVSHandle, 'FragmentProgram': _particlesFSHandle});
      int vertexStride = _particleVertexSize*4;
      var elements = [new InputElementDescription('vPosition', Device.DeviceFormatFloat3, vertexStride, 0, 0),
                      new InputElementDescription('vColor', Device.DeviceFormatFloat3, vertexStride, 0, 12)];
      _particlesInputLayoutHandle = device.createInputLayout('Particles Input Layout', {'elements':elements, 'shaderProgram':_particlesShaderProgramHandle});
      immediateContext.updateTexture2DFromResource(_particlePointSpriteHandle, _particlePointSpriteResourceHandle, resourceManager);
      immediateContext.generateMipmap(_particlePointSpriteHandle);
      complete.complete(new JavelineDemoStatus(JavelineDemoStatus.DemoStatusOKAY, ''));
    });
    return complete.future;
  }
  
  Future<JavelineDemoStatus> shutdown() {
    Future<JavelineDemoStatus> base = super.shutdown();
    _particlesVertexData = null;
    resourceManager.batchDeregister([_particlesVSResourceHandle, _particlesFSResourceHandle, _particlePointSpriteResourceHandle]);
    device.batchDeleteDeviceChildren([_particlesVBOHandle, _particlesShaderProgramHandle, _particlesVSHandle, _particlesFSHandle, _particlesInputLayoutHandle, _particlePointSpriteHandle, _particleDepthStateHandle, _particleBlendStateHandle, _particlePointSpriteSamplerHandle]);
    return base;
  }
  
  void updateParticles() {
    device.immediateContext.updateBuffer(_particlesVBOHandle, _particlesVertexData);
  }
  
  void drawParticles() {
    device.immediateContext.setInputLayout(_particlesInputLayoutHandle);
    device.immediateContext.setVertexBuffers(0, [_particlesVBOHandle]);
    device.immediateContext.setIndexBuffer(0);
    device.immediateContext.setDepthState(_particleDepthStateHandle);
    device.immediateContext.setBlendState(_particleBlendStateHandle);
    device.immediateContext.setPrimitiveTopology(ImmediateContext.PrimitiveTopologyPoints);
    device.immediateContext.setShaderProgram(_particlesShaderProgramHandle);
    device.immediateContext.setTextures(0, [_particlePointSpriteHandle]);
    device.immediateContext.setSamplers(0, [_particlePointSpriteSamplerHandle]);
    device.immediateContext.setUniformMatrix4('projectionViewTransform', projectionViewTransform);
    device.immediateContext.setUniformMatrix4('projectionTransform', projectionTransform);
    device.immediateContext.setUniformMatrix4('viewTransform', viewTransform);
    device.immediateContext.setUniformMatrix4('normalTransform', normalTransform);
    device.immediateContext.draw(_numParticles, 0);
  }
  
  void update(num time, num dt) {
    Profiler.enter('Demo Update');
    Profiler.enter('super.update');
    super.update(time, dt);
    Profiler.exit(); // Super.update
        
    {
      quat q = new quat.axisAngle(new vec3.raw(0.0, 0.0, 1.0), 0.0174532925);
      //q.rotate(_particles.gravityDirection);
    }
    Profiler.enter('particles update');
    _particles.update();
    _particles.copyPositions(_particlesVertexData, _particleVertexSize);
    updateParticles();
    Profiler.exit();
    
    Profiler.exit(); // Demo update
    
    drawGrid(20);
    debugDrawManager.prepareForRender();
    debugDrawManager.render(camera);
    
    Profiler.enter('Demo draw');
    drawParticles();
    Profiler.exit();
    
  }
}

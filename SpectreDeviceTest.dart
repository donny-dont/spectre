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

#import('dart:html');
#import('Spectre.dart');
#import('VectorMath/VectorMath.dart');

class SpectreDeviceTest {
  
  Viewport vp;
  BlendState bs;
  DepthState ds;
  RasterizerState rs;
  RenderTarget renderTarget;
  RenderBuffer depthBuffer;
  RenderBuffer colorBuffer;
  
  ShaderProgram sp;
  
  InputLayout il1;
  MeshResource m1;
  InputLayout il2;
  MeshResource m2;
  
  Camera c;
  MouseKeyboardCameraController mkcc;
  
  Float32Array projectionUniform;
  Float32Array viewUniform;
  Float32Array objectTransformUniform;
  
  final int width = 640;
  final int height = 360;

  num lastTime;
  
  SpectreDeviceTest() {
    lastTime = 0;
    projectionUniform = new Float32Array(16);
    viewUniform = new Float32Array(16);
    objectTransformUniform = new Float32Array(16);
  }

  bool frameCallback(num highResTime) {
    num dt = highResTime - lastTime;
    lastTime = highResTime;
    
    mkcc.UpdateCamera(0.016, c);
    // Update state
    {
      mat4x4 pm = c.projectionMatrix;
      mat4x4 la = c.lookAtMatrix;
      pm = pm * la;
      //pm.selfMultiply(la);
      pm.copyIntoArray(projectionUniform);
    }
    c.copyViewMatrixIntoArray(viewUniform);
    mat4x4 Ry = new mat4x4.rotationY(highResTime/1000.0);
    mat4x4 Rx = new mat4x4.rotationX(highResTime/1000.0);
    mat4x4 T1 = new mat4x4.translateRaw(3.0, 0.0, -5.0);
    mat4x4 T2 = new mat4x4.translateRaw(-3.0, 0.0, -5.0);
    mat4x4 om1 = T1 * Ry;
    mat4x4 om2 = T2 * Rx;
    
    
    // Clear
    num color = Math.sin(highResTime/1000).abs();
    webGL.clearColor(color, color, color, 1.0);
    webGL.clear(WebGLRenderingContext.COLOR_BUFFER_BIT);
    
    // Draw calls
    spectreImmediateContext.reset();
    
    spectreImmediateContext.setBlendState(bs);
    
    spectreImmediateContext.setRasterizerState(rs);
    
    spectreImmediateContext.setDepthState(ds);
    
    spectreImmediateContext.setViewport(vp);
    

    spectreImmediateContext.setShaderProgram(sp);
    spectreImmediateContext.setUniformMatrix4('cameraTransform', viewUniform);
    spectreImmediateContext.setUniformMatrix4('viewTransform', projectionUniform);
    
    om1.copyIntoArray(objectTransformUniform);
    spectreImmediateContext.setUniformMatrix4('objectTransform', objectTransformUniform);
    spectreImmediateContext.setPrimitiveTopology(ImmediateContext.PrimitiveTopologyTriangles);
    spectreImmediateContext.setVertexBuffers(0, [m1.vertexBuffer]);
    spectreImmediateContext.setIndexBuffer(m1.indexBuffer);
    spectreImmediateContext.setInputLayout(il1);
    spectreImmediateContext.drawIndexed(m1.numIndices, 0);
    
    om2.copyIntoArray(objectTransformUniform);
    spectreImmediateContext.setUniformMatrix4('objectTransform', objectTransformUniform);
    spectreImmediateContext.setPrimitiveTopology(ImmediateContext.PrimitiveTopologyTriangles);
    spectreImmediateContext.setVertexBuffers(0, [m2.vertexBuffer]);
    spectreImmediateContext.setIndexBuffer(m2.indexBuffer);
    spectreImmediateContext.setInputLayout(il2);
    spectreImmediateContext.drawIndexed(m2.numIndices, 0);
    
    spectreDDM.update(dt/1000.0);
    spectreDDM.addCircle(new vec3(0.0, 0.0, 0.0), new vec3(0.0, 1.0, 0.0), 4.0, new vec4(1.0, 0.0, 1.0, 1.0));
    spectreDDM.addLine(new vec3(0.0, 0.0, 0.0), new vec3(10.0, 0.0, 0.0), new vec4(1.0, 0.0, 0.0, 1.0));
    spectreDDM.addLine(new vec3(0.0, 0.0, 0.0), new vec3(0.0, 10.0, 0.0), new vec4(0.0, 1.0, 0.0, 1.0));
    spectreDDM.addLine(new vec3(0.0, 0.0, 0.0), new vec3(0.0, 0.0, 10.0), new vec4(0.0, 0.0, 1.0, 1.0));
    spectreDDM.prepareForRender();
    spectreDDM.render(c);
    
    //spectreImmediateContext.setRenderTarget(renderTarget);
    // Request callback for next frame
    window.requestAnimationFrame(frameCallback);
    return true;
  }

  void run() {
    updateStatus("(Dart Is Running)");
    spectreLog = new HtmlLogger('#SpectreLog');
    initSpectre("#webGLFrontBuffer");
    webGL.clearColor(0.0, 0.0, 0.0, 1.0);
    webGL.clear(WebGLRenderingContext.COLOR_BUFFER_BIT);
    c = new Camera();
    mkcc = new MouseKeyboardCameraController();
    mkcc.installEventHandlers();
    
    // Pipeline state objects
    {
      vp = spectreDevice.createViewport('Default VP', {'x':0, 'y':0, 'width':width, 'height':height});
      bs = spectreDevice.createBlendState('Default BS', {});
      ds = spectreDevice.createDepthState('Default DS', {});
      rs = spectreDevice.createRasterizerState('Default RS', {});
    }

    {
      depthBuffer = spectreDevice.createRenderBuffer('DepthBuffer', {'width':width,'height':height,'format':'DEPTH32'});
      colorBuffer = spectreDevice.createRenderBuffer('ColorBuffer', {'width':width,'height':height,'format':'R8G8B8A8'});
      renderTarget = spectreDevice.createRenderTarget('RenderTarget', {'depth':depthBuffer,'color0':colorBuffer,'stencil':null});
    }
    
    // Resources
    {
      List loadedResources = [];
      loadedResources.add(spectreRM.load('/meshes/TexturedPlane.mesh'));
      loadedResources.add(spectreRM.load('/meshes/Teapot.mesh'));
      loadedResources.add(spectreRM.load('/shaders/test.vs'));
      loadedResources.add(spectreRM.load('/shaders/test.fs'));
      Future allLoaded = Futures.wait(loadedResources);
      allLoaded.then((list) {
        m1 = list[0];
        m2 = list[1];
        VertexShaderResource v = list[2];
        FragmentShaderResource f = list[3];
        spectreLog.Info('Loaded ${m1.name} ${m2.name} ${v.name} and ${f.name}');
        sp = spectreDevice.createShaderProgram('test', {'VertexProgram':v.shader,'FragmentProgram':f.shader});
        {
          var elements = [InputLayoutHelper.inputElementDescriptionFromMesh('vPosition', 0, 'POSITION', m1),
                          InputLayoutHelper.inputElementDescriptionFromMesh('vNormal', 0, 'NORMAL', m1)];
          il1 = spectreDevice.createInputLayout('Plane', elements, sp);
        }
        {
          var elements = [InputLayoutHelper.inputElementDescriptionFromMesh('vPosition', 0, 'POSITION', m2),
                          InputLayoutHelper.inputElementDescriptionFromMesh('vNormal', 0, 'NORMAL', m2)];
          il2 = spectreDevice.createInputLayout('Teapot', elements, sp);
        }
        window.requestAnimationFrame(frameCallback);
      });
      allLoaded.handleException((exception) {
        spectreLog.Error('Error loading resources');
        return true;
      });
    }
  }

  void updateStatus(String message) {
    // the HTML library defines a global "document" variable
    document.query('#DartStatus').innerHTML = message;
  }
}

void main() {
  new SpectreDeviceTest().run();
}
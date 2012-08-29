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

class JavelineHFluidDemo extends JavelineBaseDemo {
  HeightFieldFluid _fluid;
  int _fluidVBOHandle;
  int _centerColumnIndex;
  int _fluidVSResourceHandle;
  int _fluidFSResourceHandle;
  int _fluidVSHandle;
  int _fluidFSHandle;
  int _fluidInputLayoutHandle;
  int _fluidShaderProgramHandle;
  
  Float32Array _fluidVertexData;
  int _fluidNumVertices;
  Float32Array _lightDirection;
  
  JavelineHFluidDemo(Device device, ResourceManager resourceManager, DebugDrawManager debugDrawManager) : super(device, resourceManager, debugDrawManager) {
    _fluid = new HeightFieldFluid(25, 1.0);
    _centerColumnIndex = 12;
  }
  
  Future<JavelineDemoStatus> startup() {
    Future<JavelineDemoStatus> base = super.startup();
    _lightDirection = new Float32Array(3);
    int numColumns = (_fluid.columnsWide-2)*(_fluid.columnsWide-2);
    int vboSize = (numColumns)*2*6; // two triangles per column, triangle needs 3 vertices and 3 normals 
    _fluidNumVertices = (numColumns)*2*3;
    // Each vertex/normal needs three floats
    vboSize *= 3;
    _fluidVertexData = new Float32Array(vboSize);
    // Each float needs 4 bytes
    vboSize *= 4;
    _fluidVBOHandle = device.createVertexBuffer('Fluid Vertex Buffer', {'usage':'stream', 'size':vboSize});
    _fluidVSResourceHandle = resourceManager.registerResource('/shaders/simple_fluid.vs');
    _fluidFSResourceHandle = resourceManager.registerResource('/shaders/simple_fluid.fs');
    _fluidVSHandle = device.createVertexShader('Fluid Vertex Shader',{});
    _fluidFSHandle = device.createFragmentShader('Fluid Fragment Shader', {});
    
    List loadedResources = [];
    base.then((value) {
      // Once the base is done, we load our resources
      loadedResources.add(resourceManager.loadResource(_fluidVSResourceHandle));
      loadedResources.add(resourceManager.loadResource(_fluidFSResourceHandle));
    });
    
    Future allLoaded = Futures.wait(loadedResources);
    Completer<JavelineDemoStatus> complete = new Completer<JavelineDemoStatus>();
    allLoaded.then((list) {
      immediateContext.compileShaderFromResource(_fluidVSHandle, _fluidVSResourceHandle, resourceManager);
      immediateContext.compileShaderFromResource(_fluidFSHandle, _fluidFSResourceHandle, resourceManager);
      _fluidShaderProgramHandle = device.createShaderProgram('Fluid Shader Program', { 'VertexProgram': _fluidVSHandle, 'FragmentProgram': _fluidFSHandle});
      int vertexStride = 2*3*4;
      var elements = [new InputElementDescription('vPosition', Device.DeviceFormatFloat3, vertexStride, 0, 0),
                      new InputElementDescription('vNormal', Device.DeviceFormatFloat3, vertexStride, 0, 12)];
      _fluidInputLayoutHandle = device.createInputLayout('Fluid Input Layout', {'elements':elements, 'shaderProgram':_fluidShaderProgramHandle});
      complete.complete(new JavelineDemoStatus(JavelineDemoStatus.DemoStatusOKAY, ''));
    });
    return complete.future;
  }
  
  Future<JavelineDemoStatus> shutdown() {
    Future<JavelineDemoStatus> base = super.shutdown();
    _fluidVertexData = null;
    resourceManager.batchDeregister([_fluidVSResourceHandle, _fluidFSResourceHandle]);
    device.batchDeleteDeviceChildren([_fluidVBOHandle, _fluidShaderProgramHandle, _fluidVSHandle, _fluidFSHandle, _fluidInputLayoutHandle]);
    return base;
  }
  
  void _drawFluid() {
    device.immediateContext.setInputLayout(_fluidInputLayoutHandle);
    device.immediateContext.setVertexBuffers(0, [_fluidVBOHandle]);
    device.immediateContext.setIndexBuffer(0);
    device.immediateContext.setPrimitiveTopology(ImmediateContext.PrimitiveTopologyTriangles);
    device.immediateContext.setShaderProgram(_fluidShaderProgramHandle);
    device.immediateContext.setUniformMatrix4('projectionViewTransform', projectionViewTransform);
    device.immediateContext.setUniformMatrix4('projectionTransform', projectionTransform);
    device.immediateContext.setUniformMatrix4('viewTransform', viewTransform);
    device.immediateContext.setUniformMatrix4('normalTransform', normalTransform);
    device.immediateContext.setUniformVector3('lightDir', _lightDirection);
    device.immediateContext.draw(_fluidNumVertices, 0);
  }
  
  void _updateFluidVertexData() {
    device.immediateContext.updateBuffer(_fluidVBOHandle, _fluidVertexData);
  }
  
  void _buildFluidVertexData() {
    final num scale = 1.0;
    int vertexDataIndex = 0;
    for (int i = 1; i < _fluid.columnsWide-1; i++) {
      for (int j = 1; j < _fluid.columnsWide-1; j++) {
        final int index = _fluid.columnIndex(i, j);
        final int indexEast = _fluid.columnIndex(i+1, j);
        final int indexNorth = _fluid.columnIndex(i, j+1);
        final int indexNorthEast = _fluid.columnIndex(i+1, j+1);
        final num height = _fluid.columns[index].height;
        final num heightEast = _fluid.columns[indexEast].height;
        final num heightNorth = _fluid.columns[indexNorth].height;
        final num heightNorthEast = _fluid.columns[indexNorthEast].height;
        
        vec3 n1;
        {
          vec3 v0 = new vec3.raw(i, height, j);
          vec3 v1 = new vec3.raw(i+1, heightEast, j);
          vec3 v2 = new vec3.raw(i+1, heightNorthEast, j+1);
          n1 = (v2 - v1).cross(v1 - v0);
          n1.normalize();
        }
        // Normal for Tri 0 (1, heightEast-height,          0)
        //                  (0, heightNorthEast-heightEast, 1)
        // == (heightEast-height, -1, heightNorthEast-heightEast)
        // v0
        _fluidVertexData[vertexDataIndex++] = i;
        _fluidVertexData[vertexDataIndex++] = height;
        _fluidVertexData[vertexDataIndex++] = j;
        _fluidVertexData[vertexDataIndex++] = n1.x;
        _fluidVertexData[vertexDataIndex++] = n1.y;
        _fluidVertexData[vertexDataIndex++] = n1.z;
        {
          vec3 s = new vec3(i, height, j);
          vec3 e = s + n1;
          //debugDrawManager.addLine(s, e, new vec4(1.0, 1.0, 1.0, 1.0));  
        }
        // v1
        _fluidVertexData[vertexDataIndex++] = i+1;
        _fluidVertexData[vertexDataIndex++] = heightEast;
        _fluidVertexData[vertexDataIndex++] = j;
        _fluidVertexData[vertexDataIndex++] = n1.x;
        _fluidVertexData[vertexDataIndex++] = n1.y;
        _fluidVertexData[vertexDataIndex++] = n1.z;
        // v2
        _fluidVertexData[vertexDataIndex++] = i+1;
        _fluidVertexData[vertexDataIndex++] = heightNorthEast;
        _fluidVertexData[vertexDataIndex++] = j+1;
        _fluidVertexData[vertexDataIndex++] = n1.x;
        _fluidVertexData[vertexDataIndex++] = n1.y;
        _fluidVertexData[vertexDataIndex++] = n1.z;
        vec3 n2;
        {
          vec3 v0 = new vec3.raw(i, height, j);
          vec3 v1 = new vec3.raw(i+1, heightNorthEast, j+1);
          vec3 v2 = new vec3.raw(i, heightNorth, j+1);
          n2 = (v2 - v1).cross(v1 - v0);
          n2.normalize();
        }
        // Normal for Tri 1 (1, heightNorthEast-height, 1)
        //                  (-1, heightNorth-heightNorthEast, 0);
        // == (-(heightNorth-heightNorthEast), -1, (heightNorth-heightNorthEast)+(heightNorthEast-height)) 
        // v0
        _fluidVertexData[vertexDataIndex++] = i;
        _fluidVertexData[vertexDataIndex++] = height;
        _fluidVertexData[vertexDataIndex++] = j;
        _fluidVertexData[vertexDataIndex++] = n2.x;
        _fluidVertexData[vertexDataIndex++] = n2.y;
        _fluidVertexData[vertexDataIndex++] = n2.z;
        {
          vec3 s = new vec3(i, height, j);
          vec3 e = s + n2;
          //debugDrawManager.addLine(s, e, new vec4(1.0, 1.0, 1.0, 1.0));  
        }
        // v1
        _fluidVertexData[vertexDataIndex++] = i+1;
        _fluidVertexData[vertexDataIndex++] = heightNorthEast;
        _fluidVertexData[vertexDataIndex++] = j+1;
        _fluidVertexData[vertexDataIndex++] = n2.x;
        _fluidVertexData[vertexDataIndex++] = n2.y;
        _fluidVertexData[vertexDataIndex++] = n2.z;
        // v2
        _fluidVertexData[vertexDataIndex++] = i;
        _fluidVertexData[vertexDataIndex++] = heightNorth;
        _fluidVertexData[vertexDataIndex++] = j+1;
        _fluidVertexData[vertexDataIndex++] = n2.x;
        _fluidVertexData[vertexDataIndex++] = n2.y;
        _fluidVertexData[vertexDataIndex++] = n2.z;
      }
    }
  }
  
  void _makeWave(int column, num h) {
    for (int j = 1; j < _fluid.columnsWide-1; j++) {
      int columnIndex = _fluid.columnIndex(column, j);
      _fluid.columns[columnIndex].height += h;
    }
  }
  
  void _makeDrop(int column, num h) {
    int columnIndex = _fluid.columnIndex(column, column);
    _fluid.columns[columnIndex].height += h;
  }
  
  void update(num time, num dt) {
    Profiler.enter('Demo Update');
    Profiler.enter('super.update');
    super.update(time, dt);
    Profiler.exit();
        
    if (keyboard.pressed(JavelineKeyCodes.KeyP)) {
      _makeWave(2, 0.3);
      
    }
    if (keyboard.pressed(JavelineKeyCodes.KeyO)) {
      _makeDrop(_centerColumnIndex, 0.8);
    }
    
    drawGrid(20);
    Profiler.enter('fluid update');
    _fluid.update();
    _fluid.setReflectiveBoundaryAll();
    //_fluid.setFlowBoundary(HeightFieldFluid.BoundaryNorth, 0.1);
    //_fluid.setFlowBoundary(HeightFieldFluid.BoundarySouth, -0.05);
    //_fluid.setReflectiveBoundary(HeightFieldFluid.BoundaryNorth);
    //_fluid.setReflectiveBoundary(HeightFieldFluid.BoundaryWest);
    //_fluid.setReflectiveBoundary(HeightFieldFluid.BoundarySouth);
    //_fluid.setReflectiveBoundary(HeightFieldFluid.BoundaryEast);
    //_fluid.setOpenBoundary(HeightFieldFluid.BoundaryEast);
    //_fluid.setOpenBoundaryAll();
    Profiler.exit();
    
    Profiler.enter('fluid prepare to draw');
    _buildFluidVertexData();
    _updateFluidVertexData();
    Profiler.exit();
    
    { 
      vec3 lightDirection = new vec3(1.0, -1.0, 1.0);
      lightDirection.normalize();
      normalMatrix.transformDirect3(lightDirection);
      lightDirection.normalize();
      lightDirection.copyIntoArray(_lightDirection);
    }
    Profiler.enter('fluid draw');
    _drawFluid();
    Profiler.exit();

    Profiler.exit();
    debugDrawManager.prepareForRender();
    debugDrawManager.render(camera);
    Profiler.exit();
  }
}

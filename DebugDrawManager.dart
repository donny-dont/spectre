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

class _DebugDrawVertex {
  vec3 position;
  vec4 color;
  num duration;
}

class _DebugDrawVertexManager {
  static final int DebugDrawVertexSize = 7; // 3 (position) + 4 (color)
  int _maxVertices;
  List<_DebugDrawVertex> _vertices;
  Float32Array _vboStorage;
  int _vboUsed;
  VertexBuffer _vbo;
  InputLayout _vboLayout;
  ShaderProgram _lineShader;
  
  _DebugDrawVertexManager(String name, int vboSize, this._lineShader) {
    _maxVertices = vboSize;
    _vertices = new List<_DebugDrawVertex>();
    _vboUsed = 0;
    _vboStorage = new Float32Array(vboSize*DebugDrawVertexSize);
    _vbo = spectreDevice.createVertexBuffer(name, {'usage': 'dynamic', 'size': vboSize*DebugDrawVertexSize});
    List inputElements = [new InputElementDescription('vPosition', Device.DeviceFormatFloat3, 7*4, 0, 0),
                          new InputElementDescription('vColor', Device.DeviceFormatFloat4, 7*4, 0, 3*4)];
    _vboLayout = spectreDevice.createInputLayout('$name Layout', inputElements, _lineShader);
  }
  
  bool hasRoomFor(int vertexCount) {
    int current = _vertices.length;
    return current+vertexCount < _maxVertices;
  }
  
  void add(_DebugDrawVertex v) {
    _vertices.add(v);
  }
  
  void _prepareForRender() {
    _vboUsed = 0;
    for (int i = 0; i < _vertices.length; i++) {
      _DebugDrawVertex v = _vertices[i];
      _vboStorage[_vboUsed] = v.position.x;
      _vboUsed++;
      _vboStorage[_vboUsed] = v.position.y;
      _vboUsed++;
      _vboStorage[_vboUsed] = v.position.z;
      _vboUsed++;
      
      _vboStorage[_vboUsed] = v.color.x;
      _vboUsed++;
      _vboStorage[_vboUsed] = v.color.y;
      _vboUsed++;
      _vboStorage[_vboUsed] = v.color.z;
      _vboUsed++;
      _vboStorage[_vboUsed] = v.color.w;
      _vboUsed++;
    }

    spectreImmediateContext.updateBuffer(_vbo, _vboStorage);
  }
  
  int get vertexCount() => _vboUsed ~/ DebugDrawVertexSize;

  void update(num dt) {
    for (int i = 0; i < _vertices.length;) {
      _DebugDrawVertex v = _vertices[i];
      v.duration -= dt;
      if (v.duration < 0.0) {
        _vertices.removeRange(i, 1);
        continue;
      }
      i++;
    }
  }
  
  void render(Float32Array cameraMatrix) {
    if (_vertices.length == 0) {
      return;
    }
    int verts = _vboUsed~/DebugDrawVertexSize;
    spectreImmediateContext.setShaderProgram(_lineShader);
    spectreImmediateContext.setUniformMatrix4('cameraTransform', cameraMatrix);
    spectreImmediateContext.setPrimitiveTopology(ImmediateContext.PrimitiveTopologyLines);
    spectreImmediateContext.setVertexBuffers(0, [_vbo]);
    spectreImmediateContext.setIndexBuffer(null);
    spectreImmediateContext.setInputLayout(_vboLayout);
    spectreImmediateContext.draw(verts, 0);
  }
}

class _DebugDrawSphere {
  vec3 center;
  vec4 color;
  num radius;
  num duration;
}

class _DebugDrawSphereManager {
  int _maxSpheres;
  List<_DebugDrawSphere> _spheres;
  MeshResource _unitSphere;
  InputLayout _vboLayout;
  ShaderProgram _sphereShader;
  Float32Array _sphereColor;
  
  _DebugDrawSphereManager(MeshResource unitSphere, int maxSpheres) {
    _unitSphere = unitSphere;
    _maxSpheres = maxSpheres;
    _spheres = new List<_DebugDrawSphere>();
  }
  
  bool hasRoomFor(int sphereCount) {
    int current = _spheres.length;
    return current+sphereCount < _maxSpheres;
  }
  
  void _prepareForRender() {
  }

  void add(_DebugDrawSphere sphere) {
    return;
    _spheres.add(sphere);
  }
  
  void update(num dt) {
    return;
    for (int i = 0; i < _spheres.length;) {
      _DebugDrawSphere s = _spheres[i];
      s.duration -= dt;
      if (s.duration < 0.0) {
        _spheres.removeRange(i, 1);
        continue;
      }
      i++;
    }
  }
  
  void render(Float32Array cameraMatrix) {
    if (_spheres.length == 0) {
      return;
    }
    // DRAW HERE
  }
}

/** DebugDrawManager allows you to draw the following primitives:
  *
  * - Lines
  * - Crosses
  * - Spheres
  * - Circles
  * - Transformations (coordinate axes)
  * - Triangles
  * - AABB (Axis Aligned Bounding Boxes)
  *
  * Each of the above primitives can be displayed for a specific time period, for example, 1.5 seconds
  *
  * Each of the above primitives can have depth testing enabled or disabled
  *
  * Most of the above primitives can be configured with size and / or color
  *
  * You will have to call update, prepareForRender, and render once per frame 
  */
class DebugDrawManager {
  DepthState _depthEnabledState;
  DepthState _depthDisabledState;
  BlendState _blendState;
  RasterizerState _rasterState;
  CommandBuffer _commandBuffer;
  
  _DebugDrawVertexManager _depthEnabled;
  _DebugDrawVertexManager _depthDisabled;
  _DebugDrawSphereManager _depthEnabledSpheres;
  _DebugDrawSphereManager _depthDisabledSpheres;
  Float32Array _cameraMatrix;
  
  final String _depthStateEnabledName = 'Debug Depth Enabled State';
  final String _depthStateDisabledName = 'Debug Depth Disabled State';
  final String _blendStateName = 'Debug Blend State';
  final String _rasterStateName = 'Debug Rasterizer State';
  final String _lineShaderProgramName = 'Debug Line Program';
  final String _depthEnabledLineVBOName = 'Debug Draw Depth Enabled VBO';
  final String _depthDisabledLineVBOName = 'Debug Draw Depth Disabled VBO';
  final String _cameraTransformUniformName = 'cameraTransform';
  
  DebugDrawManager() {
    _depthEnabledState = spectreDevice.createDepthState(_depthStateEnabledName, {'depthTestEnabled': true, 'depthWriteEnabled': true, 'depthComparisonOp': DepthState.DepthComparisonOpLess});
    _depthDisabledState = spectreDevice.createDepthState(_depthStateDisabledName, {'depthTestEnabled': false, 'depthWriteEnabled': false});
    _blendState = spectreDevice.createBlendState(_blendStateName, {});
    _rasterState = spectreDevice.createRasterizerState(_rasterStateName, {'cullEnabled': false, 'lineWidth': 2.0});
    _cameraMatrix = new Float32Array(16);
    _commandBuffer = new CommandBuffer();
  }
  
  void Init(VertexShaderResource lineVShader, FragmentShaderResource linePShader, VertexShaderResource sphereVShader, FragmentShaderResource spherePShader, MeshResource unitSphere, [int vboSize=4096, int maxSpheres=1024]) {
    ShaderProgram lineProgram = spectreDevice.createShaderProgram(_lineShaderProgramName, {'VertexProgram':lineVShader.shader, 'FragmentProgram':linePShader.shader});
    _depthEnabled = new _DebugDrawVertexManager(_depthEnabledLineVBOName, vboSize, lineProgram);
    _depthDisabled = new _DebugDrawVertexManager(_depthDisabledLineVBOName, vboSize, lineProgram);
    _depthEnabledSpheres = new _DebugDrawSphereManager(unitSphere, maxSpheres);
    _depthDisabledSpheres = new _DebugDrawSphereManager(unitSphere, maxSpheres);
  }
  
  /// Add a line segment from [start] to [finish] with [color]
  ///  
  /// Options: [duration] and [depthEnabled]
  void addLine(vec3 start, vec3 finish, vec4 color, [num duration = 0.0, bool depthEnabled=true]) {
    _DebugDrawVertex v1 = new _DebugDrawVertex();
    v1.color = new vec4.copy(color);
    v1.position = new vec3.copy(start);
    v1.duration = duration;
    _DebugDrawVertex v2 = new _DebugDrawVertex();
    v2.color = new vec4.copy(color);
    v2.position = new vec3.copy(finish);
    v2.duration = duration;
    if (depthEnabled && _depthEnabled.hasRoomFor(2)) {
      _depthEnabled.add(v1);
      _depthEnabled.add(v2);
    } else if (_depthDisabled.hasRoomFor(2)){
      _depthDisabled.add(v1);
      _depthDisabled.add(v2);
    }
  }
  
  /// Add a cross at [point] with [color]
  ///
  /// Options: [size], [duration], and [depthEnabled]
  void addCross(vec3 point, vec4 color, [num size = 1.0, num duration = 0.0, bool depthEnabled=true]) {
    num half_size = size * 0.5;
    addLine(point, point + new vec3(half_size, 0.0, 0.0), color, duration, depthEnabled);
    addLine(point, point + new vec3(-half_size, 0.0, 0.0), color, duration, depthEnabled);
    addLine(point, point + new vec3(0.0, half_size, 0.0), color, duration, depthEnabled);
    addLine(point, point + new vec3(0.0, -half_size, 0.0), color, duration, depthEnabled);
    addLine(point, point + new vec3(0.0, 0.0, half_size), color, duration, depthEnabled);
    addLine(point, point + new vec3(0.0, 0.0, -half_size), color, duration, depthEnabled);
  }
  
  /// Add a sphere located at [center] with [radius] and [color]
  ///
  /// Options: [duration] and [depthEnabled]
  void addSphere(vec3 center, num radius, vec4 color, [num duration = 0.0, bool depthEnabled = true]) {
    _DebugDrawSphere sphere = new _DebugDrawSphere();
    sphere.color = new vec4.copy(color);
    sphere.radius = radius;
    sphere.center = new vec3.copy(center);
    sphere.duration = duration;
    if (depthEnabled) {
      _depthEnabledSpheres.add(sphere);
    } else {
      _depthDisabledSpheres.add(sphere);
    }
  }
  
  /// Add a circle located at [center] perpindicular to [planeNormal] with [radius] and [color]
  ///
  /// Options: [duration] and [depthEnabled]
  void addCircle(vec3 center, vec3 planeNormal, num radius, vec4 color, [num duration = 0.0, bool depthEnabled = true, int numSegments = 12]) {
    vec3 u = new vec3.zero();
    vec3 v = new vec3.zero();
    buildPlaneVectors(planeNormal, u, v);
    num alpha = 0.0;
    num twoPi = (2.0 * 3.141592653589793238462643);
    num _step = twoPi/numSegments;

    vec3 last = center + u * radius;

    for (alpha = _step; alpha <= twoPi; alpha += _step) {
      vec3 p = center + (u * (radius * cos(alpha))) + (v * (radius * sin(alpha)));
      addLine(last, p, color, duration);
      last = p;
    }
    addLine(last, center + u * radius, color, duration);
  }
  
  /// Add a transformation (rotation & translation) from [xform]. Size is controlled with [size] 
  ///
  /// X,Y, and Z axes are colored Red,Green, and Blue
  ///
  /// Options: [duration] and [depthEnabled]
  void addAxes(mat4x4 xform, num size, [num duration = 0.0, bool depthEnabled = true]) {
    vec4 origin = new vec4.raw(0.0, 0.0, 0.0, 1.0);
    num size_90p = 0.9 * size;
    num size_10p = 0.1 * size;

    vec4 color;

    vec4 X = new vec4.raw(size, 0.0, 0.0, 1.0);
    vec4 X_head_0 = new vec4.raw(size_90p, size_10p, 0.0, 1.0);
    vec4 X_head_1 = new vec4.raw(size_90p, -size_10p, 0.0, 1.0);
    vec4 X_head_2 = new vec4.raw(size_90p, 0.0, size_10p, 1.0);
    vec4 X_head_3 = new vec4.raw(size_90p, 0.0, -size_10p, 1.0);

    vec4 Y = new vec4.raw(0.0, size, 0.0, 1.0);
    vec4 Y_head_0 = new vec4.raw(size_10p, size_90p, 0.0, 1.0);
    vec4 Y_head_1 = new vec4.raw(-size_10p, size_90p, 0.0, 1.0);
    vec4 Y_head_2 = new vec4.raw(0.0, size_90p, size_10p, 1.0);
    vec4 Y_head_3 = new vec4.raw(0.0, size_90p, -size_10p, 1.0);


    vec4 Z = new vec4.raw(0.0, 0.0, size, 1.0);
    vec4 Z_head_0 = new vec4.raw(size_10p, 0.0, size_90p, 1.0);
    vec4 Z_head_1 = new vec4.raw(-size_10p, 0.0, size_90p, 1.0);
    vec4 Z_head_2 = new vec4.raw(0.0, size_10p, size_90p, 1.0);
    vec4 Z_head_3 = new vec4.raw(0.0, -size_10p, size_90p, 1.0);

    origin = xform * origin;

    X = xform * X;
    X_head_0 = xform * X_head_0;
    X_head_1 = xform * X_head_1;
    X_head_2 = xform * X_head_2;
    X_head_3 = xform * X_head_3;

    color = new vec4.raw(1.0, 0.0, 0.0, 1.0);
    addLine(origin.xyz, X.xyz, color, duration, depthEnabled);
    addLine(X.xyz, X_head_0.xyz, color,duration, depthEnabled);
    addLine(X.xyz, X_head_1.xyz, color, duration, depthEnabled);
    addLine(X.xyz, X_head_2.xyz, color, duration, depthEnabled);
    addLine(X.xyz, X_head_3.xyz, color, duration, depthEnabled);

    Y = xform * Y;
    Y_head_0 = xform * Y_head_0;
    Y_head_1 = xform * Y_head_1;
    Y_head_2 = xform * Y_head_2;
    Y_head_3 = xform * Y_head_3;

    color = new vec4.raw(0.0, 1.0, 0.0, 1.0);
    addLine(origin.xyz, Y.xyz, color, duration, depthEnabled);
    addLine(Y.xyz, Y_head_0.xyz, color, duration, depthEnabled);
    addLine(Y.xyz, Y_head_1.xyz, color, duration, depthEnabled);
    addLine(Y.xyz, Y_head_2.xyz, color, duration, depthEnabled);
    addLine(Y.xyz, Y_head_3.xyz, color, duration, depthEnabled);

    Z = xform * Z;
    Z_head_0 = xform * Z_head_0;
    Z_head_1 = xform * Z_head_1;
    Z_head_2 = xform * Z_head_2;
    Z_head_3 = xform * Z_head_3;

    color = new vec4.raw(0.0, 0.0, 1.0, 1.0);
    addLine(origin.xyz, Z.xyz, color, duration, depthEnabled);
    addLine(Z.xyz, Z_head_0.xyz, color, duration, depthEnabled);
    addLine(Z.xyz, Z_head_1.xyz, color, duration, depthEnabled);
    addLine(Z.xyz, Z_head_2.xyz, color, duration, depthEnabled);
    addLine(Z.xyz, Z_head_3.xyz, color, duration, depthEnabled);
  }
  
  /// Add a triangle with vertices [vertex0], [vertex1], and [vertex2]. Color [color]
  ///
  /// Options: [duration] and [depthEnabled] 
  void addTriangle(vec3 vertex0, vec3 vertex1, vec3 vertex2, vec4 color, [num duration = 0.0, bool depthEnabled = true]) {
    addLine(vertex0, vertex1, color, duration, depthEnabled);
    addLine(vertex1, vertex2, color, duration, depthEnabled);
    addLine(vertex2, vertex0, color, duration, depthEnabled);
  }
  
  /// Add an AABB from [boxMin] to [boxMax] with [color].
  ///
  /// Options: [duration] and [depthEnabled]
  void addAABB(vec3 boxMin, vec3 boxMax, vec4 color, [num duration = 0.0, bool depthEnabled = true]) {
    vec3 vertex_a;
    vec3 vertex_b;
    
    vertex_a = new vec3.copy(boxMin);
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[0] = boxMax[0];
    addLine(vertex_a, vertex_b, color, duration, depthEnabled);
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[1] = boxMax[1];
    addLine(vertex_a, vertex_b, color, duration, depthEnabled);
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[2] = boxMax[2];
    addLine(vertex_a, vertex_b, color, duration, depthEnabled);
    vertex_a[1] = boxMax[1];
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[0] = boxMax[0];
    addLine(vertex_a, vertex_b, color, duration, depthEnabled);
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[2] = boxMax[2];
    addLine(vertex_a, vertex_b, color, duration, depthEnabled);
    vertex_a = new vec3.copy(boxMin);
    vertex_a[0] = boxMax[0];
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[1] = boxMax[1];
    addLine(vertex_a, vertex_b, color, duration, depthEnabled);
    vertex_a = new vec3.copy(boxMax);
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[0] = boxMin[0];
    addLine(vertex_a, vertex_b, color, duration, depthEnabled);
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[1] = boxMin[1];
    addLine(vertex_a, vertex_b, color, duration, depthEnabled);
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[2] = boxMin[2];
    addLine(vertex_a, vertex_b, color, duration, depthEnabled);
    vertex_a[1] = boxMin[1];
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[0] = boxMin[0];
    addLine(vertex_a, vertex_b, color, duration, depthEnabled);
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[2] = boxMin[2];
    addLine(vertex_a, vertex_b, color, duration, depthEnabled);
    vertex_a = new vec3.copy(boxMin);
    vertex_a[2] = boxMax[2];
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[1] = boxMax[1];
    addLine(vertex_a, vertex_b, color, duration, depthEnabled);
  }
  
  /// Prepare to render debug primitives
  void prepareForRender() {
    _depthEnabled._prepareForRender();
    _depthDisabled._prepareForRender();
    _depthEnabledSpheres._prepareForRender();
    _depthDisabledSpheres._prepareForRender();
    _commandBuffer.clear();
    _commandBuffer.addCommand(new CommandSetBlendState(_blendStateName));
    _commandBuffer.addCommand(new CommandSetRasterizerState(_rasterStateName));
    _commandBuffer.addCommand(new CommandSetDepthState(_depthStateEnabledName));
    _commandBuffer.addCommand(new CommandSetShaderProgram(_lineShaderProgramName));
    _commandBuffer.addCommand(new CommandSetUniformMatrix4(_cameraTransformUniformName, _cameraMatrix));
    _commandBuffer.addCommand(new CommandSetPrimitiveTopology(ImmediateContext.PrimitiveTopologyLines));
    _commandBuffer.addCommand(new CommandSetVertexBuffers(0, [_depthEnabledLineVBOName]));
    _commandBuffer.addCommand(new CommandSetIndexBuffer(null));
    _commandBuffer.addCommand(new CommandSetInputLayout('$_depthEnabledLineVBOName Layout'));
    _commandBuffer.addCommand(new CommandDraw(_depthEnabled.vertexCount, 0));
    _commandBuffer.addCommand(new CommandSetDepthState(_depthStateDisabledName));
    _commandBuffer.addCommand(new CommandSetVertexBuffers(0, [_depthDisabledLineVBOName]));
    _commandBuffer.addCommand(new CommandSetInputLayout('$_depthDisabledLineVBOName Layout'));
    _commandBuffer.addCommand(new CommandDraw(_depthDisabled.vertexCount, 0));
  }
  
  /// Render debug primitives for [Camera] [cam]
  void render(Camera cam) {
    {
      mat4x4 pm = cam.projectionMatrix;
      mat4x4 la = cam.lookAtMatrix;
      pm.selfMultiply(la);
      pm.copyIntoArray(_cameraMatrix);
    }
    _commandBuffer.apply(spectreRM, spectreDevice, spectreImmediateContext);
  }
  
  /// Update time [seconds], removing any dead debug primitives
  void update(num seconds) {
    _depthEnabled.update(seconds);
    _depthDisabled.update(seconds);
    _depthEnabledSpheres.update(seconds);
    _depthDisabledSpheres.update(seconds);
  }
}

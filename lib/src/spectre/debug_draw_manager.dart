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

class _DebugLine implements Hashable {
  vec3 positionStart;
  vec3 positionEnd;
  vec4 colorStart;
  vec4 colorEnd;
  num duration;
}

class _DebugDrawLineManager {
  static final int DebugDrawVertexSize = 7; // 3 (position) + 4 (color)
  Set<_DebugLine> _lines;

  int _maxVertices;
  Float32Array _vboStorage;

  int _vboUsed;
  int _vbo;
  int _vboLayout;

  _DebugDrawLineManager(GraphicsDevice device, String name, int vboSize, int lineShaderHandle) {
    _maxVertices = vboSize;
    _lines = new Set<_DebugLine>();
    _vboUsed = 0;
    _vboStorage = new Float32Array(vboSize*DebugDrawVertexSize);
    _vbo = device.createVertexBuffer(name, {'usage': 'dynamic', 'size': vboSize*DebugDrawVertexSize});
    List inputElements = [new InputElementDescription('vPosition', GraphicsDevice.DeviceFormatFloat3, 7*4, 0, 0),
                          new InputElementDescription('vColor', GraphicsDevice.DeviceFormatFloat4, 7*4, 0, 3*4)];
    _vboLayout = device.createInputLayout('$name Layout', {'shaderProgram': lineShaderHandle, 'elements':inputElements});
  }

  bool hasRoomFor(int lineCount) {
    int current = _lines.length;
    return current+(lineCount*2) < _maxVertices;
  }

  void add(_DebugLine line) {
    _lines.add(line);
  }

  void _prepareForRender(GraphicsContext context) {
    _vboUsed = 0;
    for (_DebugLine line in _lines) {
      _vboStorage[_vboUsed] = line.positionStart.x;
      _vboUsed++;
      _vboStorage[_vboUsed] = line.positionStart.y;
      _vboUsed++;
      _vboStorage[_vboUsed] = line.positionStart.z;
      _vboUsed++;

      _vboStorage[_vboUsed] = line.colorStart.x;
      _vboUsed++;
      _vboStorage[_vboUsed] = line.colorStart.y;
      _vboUsed++;
      _vboStorage[_vboUsed] = line.colorStart.z;
      _vboUsed++;
      _vboStorage[_vboUsed] = line.colorStart.w;
      _vboUsed++;

      _vboStorage[_vboUsed] = line.positionEnd.x;
      _vboUsed++;
      _vboStorage[_vboUsed] = line.positionEnd.y;
      _vboUsed++;
      _vboStorage[_vboUsed] = line.positionEnd.z;
      _vboUsed++;

      _vboStorage[_vboUsed] = line.colorEnd.x;
      _vboUsed++;
      _vboStorage[_vboUsed] = line.colorEnd.y;
      _vboUsed++;
      _vboStorage[_vboUsed] = line.colorEnd.z;
      _vboUsed++;
      _vboStorage[_vboUsed] = line.colorEnd.w;
      _vboUsed++;
    }

    context.updateBuffer(_vbo, _vboStorage);
  }

  int get vertexCount() => _vboUsed ~/ DebugDrawVertexSize;

  void update(num dt) {
    Profiler.enter('update');
    for (_DebugLine line in _lines) {
      line.duration -= dt;
      if (line.duration < 0.0) {
        _lines.remove(line);
      }
    }
    Profiler.exit();
  }
}

class _DebugDrawSphere {
  Float32Array sphereCenterAndRadius;
  Float32Array sphereColor;
  num duration;
  _DebugDrawSphere(vec3 center, vec4 color, num radius) {
    sphereCenterAndRadius = new Float32Array(4);
    sphereColor = new Float32Array(4);
    sphereCenterAndRadius[0] = center.x;
    sphereCenterAndRadius[1] = center.y;
    sphereCenterAndRadius[2] = center.z;
    sphereCenterAndRadius[3] = radius;
    sphereColor[0] = color.x;
    sphereColor[1] = color.y;
    sphereColor[2] = color.z;
    sphereColor[3] = color.w;
  }

  void destroy() {
    sphereCenterAndRadius = null;
    sphereColor = null;
  }
}

class _DebugDrawSphereManager {
  int _maxSpheres;
  List<_DebugDrawSphere> _spheres;

  int _unitSphereMeshHandle;
  int _unitSphereMeshInputLayoutHandle;
  int _unitSphereShaderProgram;

  List _drawProgram;

  int _sphereProgramHandle;
  int _sphereIndexedMeshHandle;
  int _sphereVertexBuffer;
  int _sphereIndexBuffer;
  int _sphereNumIndices;
  int _sphereInputLayout;
  _DebugDrawSphereManager(int sphereProgramHandle, int sphereIndexedMeshHandle, int sphereInputLayout, int maxSpheres) {
    _sphereInputLayout = sphereInputLayout;
    _sphereProgramHandle = sphereProgramHandle;
    _sphereIndexedMeshHandle = sphereIndexedMeshHandle;
    _maxSpheres = maxSpheres;
    _spheres = new List<_DebugDrawSphere>();
    _drawProgram = new List();
  }

  bool hasRoomFor(int sphereCount) {
    int current = _spheres.length;
    return current+sphereCount < _maxSpheres;
  }

  void _prepareForRender(GraphicsContext context, Float32Array cameraMatrix) {
    // Reset draw program
    _drawProgram.clear();
    ProgramBuilder pb = new ProgramBuilder.append(_drawProgram);
    pb.setShaderProgram(_sphereProgramHandle);
    pb.setUniformMatrix4('cameraTransform', cameraMatrix);
    pb.setPrimitiveTopology(GraphicsContext.PrimitiveTopologyLines);
    pb.setIndexedMesh(_sphereIndexedMeshHandle);
    pb.setInputLayout(_sphereInputLayout);
    for (final _DebugDrawSphere sphere in _spheres) {
      pb.setUniformVector4('debugSphereCenterAndRadius', sphere.sphereCenterAndRadius);
      pb.setUniformVector4('debugSphereColor', sphere.sphereColor);
      pb.drawIndexedMesh(_sphereIndexedMeshHandle);
    }
  }

  void _render(GraphicsDevice device, Float32Array cameraMatrix) {
    Interpreter interpreter = new Interpreter();
    interpreter.run(_drawProgram, device, null, device.context);
  }

  void add(_DebugDrawSphere sphere) {
    _spheres.add(sphere);
  }

  void update(num dt) {
    for (int i = 0; i < _spheres.length;) {
      _DebugDrawSphere s = _spheres[i];
      s.duration -= dt;
      if (s.duration < 0.0) {
        s.destroy();
        _spheres.removeRange(i, 1);
        continue;
      }
      i++;
    }
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
  static final int _depthEnabledStateHandleIndex = 0;
  static final int _depthDisabledStateHandleIndex = 1;
  static final int _blendStateHandleIndex = 2;
  static final int _rasterizerStateHandleIndex = 3;
  static final int _lineVertexShaderHandleIndex = 4;
  static final int _lineFragmentShaderHandleIndex = 5;
  static final int _lineShaderProgramHandleIndex = 6;
  static final int _sphereVertexShaderHandleIndex = 7;
  static final int _sphereFragmentShaderHandleIndex = 8;
  static final int _sphereShaderProgramHandleIndex = 9;
  static final int _sphereIndexedMeshHandleIndex = 10;

  static final String _depthStateEnabledName = 'Debug Depth Enabled State';
  static final String _depthStateDisabledName = 'Debug Depth Disabled State';
  static final String _blendStateName = 'Debug Blend State';
  static final String _rasterizerStateName = 'Debug Rasterizer State';
  static final String _lineVertexShaderName = 'Debug Line Vertex Shader';
  static final String _lineFragmentShaderName = 'Debug Line Fragment Shader';
  static final String _lineShaderProgramName = 'Debug Line Program';
  static final String _depthEnabledLineVBOName = 'Debug Draw Depth Enabled VBO';
  static final String _depthDisabledLineVBOName = 'Debug Draw Depth Disabled VBO';
  static final String _cameraTransformUniformName = 'cameraTransform';
  static final String _sphereVertexShaderName = 'Debug Sphere Vertex Shader';
  static final String _sphereFragmentShaderName = 'Debug Sphere Fragment Shader';
  static final String _sphereShaderProgramName = 'Debug Sphere Shader Program';
  static final String _sphereIndexedMeshName = 'Debug Sphere Indexed Mesh';

  List<int> _handles;

  List _startupCommands;
  List _drawCommands;

  _DebugDrawLineManager _depthEnabledLines;
  _DebugDrawLineManager _depthDisabledLines;
  _DebugDrawSphereManager _depthEnabledSpheres;
  _DebugDrawSphereManager _depthDisabledSpheres;
  Float32Array _cameraMatrix;

  GraphicsDevice _device;
  GraphicsContext _context;

  DebugDrawManager() {
    _handles = new List<int>();
    _cameraMatrix = new Float32Array(16);
  }

  // ResourceManager rm
  // int lineVSResourceHandle
  // int lineFSResourceHandle
  // int sphereVSResourceHandle
  // int sphereFSResourceHandle
  // int sphereMeshResourceHandle,

  void init(GraphicsDevice device, [int vboSize=4096, int maxSpheres=1024]) {
    _device = device;
    _context = device.context;

    int handle;

    handle = _device.createDepthState(_depthStateEnabledName, {'depthTestEnabled': true, 'depthWriteEnabled': true, 'depthComparisonOp': DepthState.DepthComparisonOpLess});
    _handles.add(handle);
    handle = _device.createDepthState(_depthStateDisabledName, {'depthTestEnabled': false, 'depthWriteEnabled': false});
    _handles.add(handle);
    handle = _device.createBlendState(_blendStateName, {});
    _handles.add(handle);
    handle = _device.createRasterizerState(_rasterizerStateName, {'cullEnabled': true, 'lineWidth': 1.0});
    _handles.add(handle);

    handle = _device.createVertexShader(_lineVertexShaderName, {});
    _handles.add(handle);
    handle = _device.createFragmentShader(_lineFragmentShaderName, {});
    _handles.add(handle);
    handle = _device.createShaderProgram(_lineShaderProgramName, {});
    _handles.add(handle);

    _context.compileShader(_handles[_lineVertexShaderHandleIndex],
                           _debugLineVertexShader);
    _context.compileShader(_handles[_lineFragmentShaderHandleIndex],
                           _debugLineFragmentShader);
    _context.linkShaderProgram(_handles[_lineShaderProgramHandleIndex],
                               _handles[_lineVertexShaderHandleIndex],
                               _handles[_lineFragmentShaderHandleIndex]);

    handle = _device.createVertexShader(_sphereVertexShaderName, {});
    _handles.add(handle);
    handle = _device.createFragmentShader(_sphereFragmentShaderName, {});
    _handles.add(handle);
    handle = _device.createShaderProgram(_sphereShaderProgramName, {});
    _handles.add(handle);

    _context.compileShader(_handles[_sphereVertexShaderHandleIndex],
                           _debugSphereVertexShader);
    _context.compileShader(_handles[_sphereFragmentShaderHandleIndex],
                           _debugSphereFragmentShader);
    _context.linkShaderProgram(_handles[_sphereShaderProgramHandleIndex],
                               _handles[_sphereVertexShaderHandleIndex],
                               _handles[_sphereFragmentShaderHandleIndex]);

    handle = device.createIndexedMesh(_sphereIndexedMeshName, {
      'UpdateFromMeshMap': _debugSphereMesh
    });
    _handles.add(handle);

    // Sphere startup
    int sphereInputLayout;
    {
      var elements = [InputLayoutHelper.inputElementDescriptionFromMeshMap(new InputLayoutDescription('vPosition', 0, 'POSITION'), _debugSphereMesh)];
      sphereInputLayout = device.createInputLayout('Debug Sphere Input', {'elements':elements, 'shaderProgram':_handles[_sphereShaderProgramHandleIndex]});
    }

    _depthEnabledLines = new _DebugDrawLineManager(device, _depthEnabledLineVBOName, vboSize, _handles[_lineShaderProgramHandleIndex]);
    _depthDisabledLines = new _DebugDrawLineManager(device, _depthDisabledLineVBOName, vboSize, _handles[_lineShaderProgramHandleIndex]);
    _depthEnabledSpheres = new _DebugDrawSphereManager(_handles[_sphereShaderProgramHandleIndex], _handles[_sphereIndexedMeshHandleIndex], sphereInputLayout, maxSpheres);
    _depthDisabledSpheres = new _DebugDrawSphereManager(_handles[_sphereShaderProgramHandleIndex], _handles[_sphereIndexedMeshHandleIndex], sphereInputLayout, maxSpheres);

    // Build the program
    ProgramBuilder pb = new ProgramBuilder();
    // General
    pb.setBlendState(_handles[_blendStateHandleIndex]);
    pb.setRasterizerState(_handles[_rasterizerStateHandleIndex]);
    pb.setShaderProgram(_handles[_lineShaderProgramHandleIndex]);
    pb.setUniformMatrix4('cameraTransform', _cameraMatrix);
    pb.setPrimitiveTopology(GraphicsContext.PrimitiveTopologyLines);
    pb.setIndexBuffer(0);
    // Depth enabled lines
    pb.setDepthState(_handles[_depthEnabledStateHandleIndex]);
    pb.setVertexBuffers(0, [_depthEnabledLines._vbo]);
    pb.setInputLayout(_depthEnabledLines._vboLayout);
    // draw Indirect takes vertexCount from register 0
    // draw Indirect takes vertexOffset from register 1
    pb.drawIndirect(Handle.makeRegisterHandle(0), Handle.makeRegisterHandle(1));
    // Depth disabled lines
    pb.setDepthState(_handles[_depthDisabledStateHandleIndex]);
    pb.setVertexBuffers(0, [_depthDisabledLines._vbo]);
    pb.setInputLayout(_depthDisabledLines._vboLayout);
    // draw Indirect takes vertexCount from register 2
    // draw Indirect takes vertexOffset from register 3
    pb.drawIndirect(Handle.makeRegisterHandle(2), Handle.makeRegisterHandle(3));
    // Save built program
    _drawCommands = pb.ops;
  }

  /// Add a line segment from [start] to [finish] with [color]
  ///
  /// Options: [duration] and [depthEnabled]
  void addLine(vec3 start, vec3 finish, vec4 color, [num duration = 0.0, bool depthEnabled=true]) {
    _DebugLine line = new _DebugLine();
    line.colorStart = new vec4.copy(color);
    line.colorEnd = line.colorStart;
    line.positionStart = new vec3.copy(start);
    line.positionEnd = new vec3.copy(finish);
    line.duration = duration;
    if (depthEnabled && _depthEnabledLines.hasRoomFor(1)) {
      _depthEnabledLines.add(line);
    } else if (depthEnabled == false && _depthDisabledLines.hasRoomFor(1)){
      _depthDisabledLines.add(line);
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
    _DebugDrawSphere sphere = new _DebugDrawSphere(center, color, radius);
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
  void addAxes(mat4 xform, num size, [num duration = 0.0, bool depthEnabled = true]) {
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
    Profiler.enter('DebugDrawManager.prepareForRender');
    _depthEnabledLines._prepareForRender(_context);
    _depthDisabledLines._prepareForRender(_context);
    _depthEnabledSpheres._prepareForRender(_context, _cameraMatrix);
    _depthDisabledSpheres._prepareForRender(_context, _cameraMatrix);
    Profiler.exit();
  }

  /// Render debug primitives for [Camera] [cam]
  void render(Camera cam) {
    Profiler.enter('DebugDrawManager.render');
    {
      mat4 pm = cam.projectionMatrix;
      mat4 la = cam.lookAtMatrix;
      pm.multiply(la);
      pm.copyIntoArray(_cameraMatrix);
    }
    {
      Interpreter interpreter = new Interpreter();
      // Set registers
      interpreter.setRegister(0, _depthEnabledLines.vertexCount);
      interpreter.setRegister(1, 0);
      interpreter.setRegister(2, _depthDisabledLines.vertexCount);
      interpreter.setRegister(3, 0);
      interpreter.run(_drawCommands, _device, null, _context);
    }
    _device.context.setDepthState(_handles[_depthEnabledStateHandleIndex]);
    _depthEnabledSpheres._render(_device, _cameraMatrix);
    _depthDisabledSpheres._render(_device, _cameraMatrix);
    Profiler.exit();
  }

  /// Update time [seconds], removing any dead debug primitives
  void update(num seconds) {
    Profiler.enter('DebugDrawManager.update');

    {
      Profiler.enter('lines');
      Profiler.enter('depth enabled');
      _depthEnabledLines.update(seconds);
      Profiler.exit();
      Profiler.enter('depth disabled');
      _depthDisabledLines.update(seconds);
      Profiler.exit();
      Profiler.exit();
    }

    _depthEnabledSpheres.update(seconds);
    _depthDisabledSpheres.update(seconds);
    Profiler.exit();
  }
}

final String _debugLineVertexShader = '''
precision highp float;

// Input attributes
attribute vec3 vPosition;
attribute vec4 vColor;
// Input uniforms
uniform mat4 cameraTransform;
// Varying outputs
varying vec4 fColor;

void main() {
    fColor = vColor;
    vec4 vPosition4 = vec4(vPosition.x, vPosition.y, vPosition.z, 1.0);
    gl_Position = cameraTransform*vPosition4;
}
''';

final String _debugLineFragmentShader = '''
precision mediump float;

varying vec4 fColor;

void main() {
    gl_FragColor = fColor;
}
''';

final String _debugSphereVertexShader = '''
precision highp float;

// Input attributes
attribute vec3 vPosition;

// Input uniforms
uniform mat4 cameraTransform;
uniform vec4 debugSphereCenterAndRadius;

void main() {
    vec3 center = debugSphereCenterAndRadius.xyz;
    float scale = debugSphereCenterAndRadius.w;
    vec4 vPosition4 = vec4((vPosition * scale) + center, 1.0);
    gl_Position = cameraTransform*vPosition4;
}
''';

final String _debugSphereFragmentShader = '''
precision mediump float;

uniform vec4 debugSphereColor;

void main() {
    gl_FragColor = debugSphereColor.rgba;
}
''';


final Map _debugSphereMesh =
{
"header" : {
"filename" : "debugsphere.obj"
},
"meshes" : [
{
"indexWidth" : 2,
"attributes" : {
"POSITION" : {
"name" : "POSITION",
"type" : "float",
"numElements" : 3,
"normalized" : false,
"stride" : 24,
"offset" : 0
}
,
"NORMAL" : {
"name" : "NORMAL",
"type" : "float",
"numElements" : 3,
"normalized" : false,
"stride" : 24,
"offset" : 12
}
},
"bounds" : [-0.475529, -0.500000, -0.500000, 0.475529, 0.500000, 0.500000],
"indices" : [
2, 1, 0,
5, 4, 3,
8, 7, 6,
11, 10, 9,
14, 13, 12,
17, 16, 15,
20, 19, 18,
23, 22, 21,
26, 25, 24,
29, 28, 27,
32, 31, 30,
35, 34, 33,
38, 37, 36,
41, 40, 39,
44, 43, 42,
47, 46, 45,
50, 49, 48,
53, 52, 51,
56, 55, 54,
59, 58, 57,
62, 61, 60,
65, 64, 63,
68, 67, 66,
71, 70, 69,
74, 73, 72,
77, 76, 75,
80, 79, 78,
83, 82, 81,
86, 85, 84,
89, 88, 87,
92, 91, 90,
95, 94, 93,
98, 97, 96,
101, 100, 99,
104, 103, 102,
107, 106, 105,
110, 109, 108,
113, 112, 111,
116, 115, 114,
119, 118, 117,
122, 121, 120,
125, 124, 123,
128, 127, 126,
131, 130, 129,
134, 133, 132,
137, 136, 135,
140, 139, 138,
143, 142, 141,
146, 145, 144,
149, 148, 147,
152, 151, 150,
155, 154, 153,
158, 157, 156,
161, 160, 159,
164, 163, 162,
167, 166, 165,
170, 169, 168,
173, 172, 171,
176, 175, 174,
179, 178, 177,
182, 181, 180,
185, 184, 183,
188, 187, 186,
191, 190, 189,
194, 193, 192,
197, 196, 195,
200, 199, 198,
203, 202, 201,
206, 205, 204,
209, 208, 207,
212, 211, 210,
215, 214, 213,
218, 217, 216,
221, 220, 219,
224, 223, 222,
227, 226, 225,
230, 229, 228,
233, 232, 231,
236, 235, 234,
239, 238, 237
],
"vertices" : [
0.000000, -0.500000, -0.000000, -0.000000, -1.000000, -0.000000,
0.212661, -0.425327, -0.154506, 0.425323, -0.850653, -0.309013,
-0.081228, -0.425327, -0.249998, -0.162458, -0.850654, -0.499996,
0.361804, -0.223610, -0.262863, 0.723607, -0.447217, -0.525727,
0.212661, -0.425327, -0.154506, 0.425323, -0.850653, -0.309013,
0.425324, -0.262868, -0.000000, 0.850649, -0.525734, -0.000000,
0.000000, -0.500000, -0.000000, -0.000000, -1.000000, -0.000000,
-0.081228, -0.425327, -0.249998, -0.162458, -0.850654, -0.499996,
-0.262865, -0.425326, -0.000000, -0.525729, -0.850652, -0.000000,
0.000000, -0.500000, -0.000000, -0.000000, -1.000000, -0.000000,
-0.262865, -0.425326, -0.000000, -0.525729, -0.850652, -0.000000,
-0.081228, -0.425327, 0.249998, -0.162458, -0.850654, 0.499996,
0.000000, -0.500000, -0.000000, -0.000000, -1.000000, -0.000000,
-0.081228, -0.425327, 0.249998, -0.162458, -0.850654, 0.499996,
0.212661, -0.425327, 0.154506, 0.425323, -0.850653, 0.309013,
0.361804, -0.223610, -0.262863, 0.723607, -0.447217, -0.525727,
0.425324, -0.262868, -0.000000, 0.850649, -0.525734, -0.000000,
0.475529, 0.000000, -0.154506, 0.951057, 0.000000, -0.309015,
-0.138194, -0.223610, -0.425325, -0.276391, -0.447218, -0.850649,
0.131434, -0.262869, -0.404506, 0.262868, -0.525735, -0.809014,
0.000000, 0.000000, -0.500000, -0.000000, -0.000000, -1.000000,
-0.447213, -0.223608, -0.000000, -0.894426, -0.447215, -0.000000,
-0.344095, -0.262868, -0.249998, -0.688190, -0.525734, -0.499998,
-0.475529, 0.000000, -0.154506, -0.951057, -0.000000, -0.309015,
-0.138194, -0.223610, 0.425325, -0.276391, -0.447218, 0.850649,
-0.344095, -0.262868, 0.249998, -0.688190, -0.525734, 0.499998,
-0.293893, 0.000000, 0.404508, -0.587787, -0.000000, 0.809016,
0.361804, -0.223610, 0.262863, 0.723607, -0.447217, 0.525727,
0.131434, -0.262869, 0.404506, 0.262868, -0.525735, 0.809014,
0.293893, 0.000000, 0.404508, 0.587787, 0.000000, 0.809016,
0.361804, -0.223610, -0.262863, 0.723607, -0.447217, -0.525727,
0.475529, 0.000000, -0.154506, 0.951057, 0.000000, -0.309015,
0.293893, 0.000000, -0.404508, 0.587787, 0.000000, -0.809016,
-0.138194, -0.223610, -0.425325, -0.276391, -0.447218, -0.850649,
0.000000, 0.000000, -0.500000, -0.000000, -0.000000, -1.000000,
-0.293893, 0.000000, -0.404508, -0.587787, -0.000000, -0.809016,
-0.447213, -0.223608, -0.000000, -0.894426, -0.447215, -0.000000,
-0.475529, 0.000000, -0.154506, -0.951057, -0.000000, -0.309015,
-0.475529, 0.000000, 0.154506, -0.951057, -0.000000, 0.309015,
-0.138194, -0.223610, 0.425325, -0.276391, -0.447218, 0.850649,
-0.293893, 0.000000, 0.404508, -0.587787, -0.000000, 0.809016,
0.000000, 0.000000, 0.500000, -0.000000, -0.000000, 1.000000,
0.361804, -0.223610, 0.262863, 0.723607, -0.447217, 0.525727,
0.293893, 0.000000, 0.404508, 0.587787, 0.000000, 0.809016,
0.475529, 0.000000, 0.154506, 0.951057, 0.000000, 0.309015,
0.138194, 0.223610, -0.425325, 0.276391, 0.447218, -0.850649,
0.344095, 0.262868, -0.249998, 0.688190, 0.525734, -0.499998,
0.081228, 0.425327, -0.249998, 0.162458, 0.850654, -0.499996,
-0.361804, 0.223610, -0.262863, -0.723607, 0.447217, -0.525727,
-0.131434, 0.262869, -0.404506, -0.262868, 0.525735, -0.809014,
-0.212661, 0.425327, -0.154506, -0.425323, 0.850653, -0.309013,
-0.361804, 0.223610, 0.262863, -0.723607, 0.447217, 0.525727,
-0.425324, 0.262868, -0.000000, -0.850649, 0.525734, -0.000000,
-0.212661, 0.425327, 0.154506, -0.425323, 0.850653, 0.309013,
0.138194, 0.223610, 0.425325, 0.276391, 0.447218, 0.850649,
-0.131434, 0.262869, 0.404506, -0.262868, 0.525735, 0.809014,
0.081228, 0.425327, 0.249998, 0.162458, 0.850654, 0.499996,
0.447213, 0.223608, -0.000000, 0.894426, 0.447215, -0.000000,
0.344095, 0.262868, 0.249998, 0.688190, 0.525734, 0.499998,
0.262865, 0.425326, -0.000000, 0.525729, 0.850652, -0.000000,
-0.081228, -0.425327, -0.249998, -0.162458, -0.850654, -0.499996,
0.131434, -0.262869, -0.404506, 0.262868, -0.525735, -0.809014,
-0.138194, -0.223610, -0.425325, -0.276391, -0.447218, -0.850649,
-0.081228, -0.425327, -0.249998, -0.162458, -0.850654, -0.499996,
0.212661, -0.425327, -0.154506, 0.425323, -0.850653, -0.309013,
0.131434, -0.262869, -0.404506, 0.262868, -0.525735, -0.809014,
0.212661, -0.425327, -0.154506, 0.425323, -0.850653, -0.309013,
0.361804, -0.223610, -0.262863, 0.723607, -0.447217, -0.525727,
0.131434, -0.262869, -0.404506, 0.262868, -0.525735, -0.809014,
0.425324, -0.262868, -0.000000, 0.850649, -0.525734, -0.000000,
0.212661, -0.425327, 0.154506, 0.425323, -0.850653, 0.309013,
0.361804, -0.223610, 0.262863, 0.723607, -0.447217, 0.525727,
0.425324, -0.262868, -0.000000, 0.850649, -0.525734, -0.000000,
0.212661, -0.425327, -0.154506, 0.425323, -0.850653, -0.309013,
0.212661, -0.425327, 0.154506, 0.425323, -0.850653, 0.309013,
0.212661, -0.425327, -0.154506, 0.425323, -0.850653, -0.309013,
0.000000, -0.500000, -0.000000, -0.000000, -1.000000, -0.000000,
0.212661, -0.425327, 0.154506, 0.425323, -0.850653, 0.309013,
-0.262865, -0.425326, -0.000000, -0.525729, -0.850652, -0.000000,
-0.344095, -0.262868, -0.249998, -0.688190, -0.525734, -0.499998,
-0.447213, -0.223608, -0.000000, -0.894426, -0.447215, -0.000000,
-0.262865, -0.425326, -0.000000, -0.525729, -0.850652, -0.000000,
-0.081228, -0.425327, -0.249998, -0.162458, -0.850654, -0.499996,
-0.344095, -0.262868, -0.249998, -0.688190, -0.525734, -0.499998,
-0.081228, -0.425327, -0.249998, -0.162458, -0.850654, -0.499996,
-0.138194, -0.223610, -0.425325, -0.276391, -0.447218, -0.850649,
-0.344095, -0.262868, -0.249998, -0.688190, -0.525734, -0.499998,
-0.081228, -0.425327, 0.249998, -0.162458, -0.850654, 0.499996,
-0.344095, -0.262868, 0.249998, -0.688190, -0.525734, 0.499998,
-0.138194, -0.223610, 0.425325, -0.276391, -0.447218, 0.850649,
-0.081228, -0.425327, 0.249998, -0.162458, -0.850654, 0.499996,
-0.262865, -0.425326, -0.000000, -0.525729, -0.850652, -0.000000,
-0.344095, -0.262868, 0.249998, -0.688190, -0.525734, 0.499998,
-0.262865, -0.425326, -0.000000, -0.525729, -0.850652, -0.000000,
-0.447213, -0.223608, -0.000000, -0.894426, -0.447215, -0.000000,
-0.344095, -0.262868, 0.249998, -0.688190, -0.525734, 0.499998,
0.212661, -0.425327, 0.154506, 0.425323, -0.850653, 0.309013,
0.131434, -0.262869, 0.404506, 0.262868, -0.525735, 0.809014,
0.361804, -0.223610, 0.262863, 0.723607, -0.447217, 0.525727,
0.212661, -0.425327, 0.154506, 0.425323, -0.850653, 0.309013,
-0.081228, -0.425327, 0.249998, -0.162458, -0.850654, 0.499996,
0.131434, -0.262869, 0.404506, 0.262868, -0.525735, 0.809014,
-0.081228, -0.425327, 0.249998, -0.162458, -0.850654, 0.499996,
-0.138194, -0.223610, 0.425325, -0.276391, -0.447218, 0.850649,
0.131434, -0.262869, 0.404506, 0.262868, -0.525735, 0.809014,
0.475529, 0.000000, -0.154506, 0.951057, 0.000000, -0.309015,
0.475529, 0.000000, 0.154506, 0.951057, 0.000000, 0.309015,
0.447213, 0.223608, -0.000000, 0.894426, 0.447215, -0.000000,
0.475529, 0.000000, -0.154506, 0.951057, 0.000000, -0.309015,
0.425324, -0.262868, -0.000000, 0.850649, -0.525734, -0.000000,
0.475529, 0.000000, 0.154506, 0.951057, 0.000000, 0.309015,
0.425324, -0.262868, -0.000000, 0.850649, -0.525734, -0.000000,
0.361804, -0.223610, 0.262863, 0.723607, -0.447217, 0.525727,
0.475529, 0.000000, 0.154506, 0.951057, 0.000000, 0.309015,
0.000000, 0.000000, -0.500000, -0.000000, -0.000000, -1.000000,
0.293893, 0.000000, -0.404508, 0.587787, 0.000000, -0.809016,
0.138194, 0.223610, -0.425325, 0.276391, 0.447218, -0.850649,
0.000000, 0.000000, -0.500000, -0.000000, -0.000000, -1.000000,
0.131434, -0.262869, -0.404506, 0.262868, -0.525735, -0.809014,
0.293893, 0.000000, -0.404508, 0.587787, 0.000000, -0.809016,
0.131434, -0.262869, -0.404506, 0.262868, -0.525735, -0.809014,
0.361804, -0.223610, -0.262863, 0.723607, -0.447217, -0.525727,
0.293893, 0.000000, -0.404508, 0.587787, 0.000000, -0.809016,
-0.475529, 0.000000, -0.154506, -0.951057, -0.000000, -0.309015,
-0.293893, 0.000000, -0.404508, -0.587787, -0.000000, -0.809016,
-0.361804, 0.223610, -0.262863, -0.723607, 0.447217, -0.525727,
-0.475529, 0.000000, -0.154506, -0.951057, -0.000000, -0.309015,
-0.344095, -0.262868, -0.249998, -0.688190, -0.525734, -0.499998,
-0.293893, 0.000000, -0.404508, -0.587787, -0.000000, -0.809016,
-0.344095, -0.262868, -0.249998, -0.688190, -0.525734, -0.499998,
-0.138194, -0.223610, -0.425325, -0.276391, -0.447218, -0.850649,
-0.293893, 0.000000, -0.404508, -0.587787, -0.000000, -0.809016,
-0.293893, 0.000000, 0.404508, -0.587787, -0.000000, 0.809016,
-0.475529, 0.000000, 0.154506, -0.951057, -0.000000, 0.309015,
-0.361804, 0.223610, 0.262863, -0.723607, 0.447217, 0.525727,
-0.293893, 0.000000, 0.404508, -0.587787, -0.000000, 0.809016,
-0.344095, -0.262868, 0.249998, -0.688190, -0.525734, 0.499998,
-0.475529, 0.000000, 0.154506, -0.951057, -0.000000, 0.309015,
-0.344095, -0.262868, 0.249998, -0.688190, -0.525734, 0.499998,
-0.447213, -0.223608, -0.000000, -0.894426, -0.447215, -0.000000,
-0.475529, 0.000000, 0.154506, -0.951057, -0.000000, 0.309015,
0.293893, 0.000000, 0.404508, 0.587787, 0.000000, 0.809016,
0.000000, 0.000000, 0.500000, -0.000000, -0.000000, 1.000000,
0.138194, 0.223610, 0.425325, 0.276391, 0.447218, 0.850649,
0.293893, 0.000000, 0.404508, 0.587787, 0.000000, 0.809016,
0.131434, -0.262869, 0.404506, 0.262868, -0.525735, 0.809014,
0.000000, 0.000000, 0.500000, -0.000000, -0.000000, 1.000000,
0.131434, -0.262869, 0.404506, 0.262868, -0.525735, 0.809014,
-0.138194, -0.223610, 0.425325, -0.276391, -0.447218, 0.850649,
0.000000, 0.000000, 0.500000, -0.000000, -0.000000, 1.000000,
0.293893, 0.000000, -0.404508, 0.587787, 0.000000, -0.809016,
0.344095, 0.262868, -0.249998, 0.688190, 0.525734, -0.499998,
0.138194, 0.223610, -0.425325, 0.276391, 0.447218, -0.850649,
0.293893, 0.000000, -0.404508, 0.587787, 0.000000, -0.809016,
0.475529, 0.000000, -0.154506, 0.951057, 0.000000, -0.309015,
0.344095, 0.262868, -0.249998, 0.688190, 0.525734, -0.499998,
0.475529, 0.000000, -0.154506, 0.951057, 0.000000, -0.309015,
0.447213, 0.223608, -0.000000, 0.894426, 0.447215, -0.000000,
0.344095, 0.262868, -0.249998, 0.688190, 0.525734, -0.499998,
-0.293893, 0.000000, -0.404508, -0.587787, -0.000000, -0.809016,
-0.131434, 0.262869, -0.404506, -0.262868, 0.525735, -0.809014,
-0.361804, 0.223610, -0.262863, -0.723607, 0.447217, -0.525727,
-0.293893, 0.000000, -0.404508, -0.587787, -0.000000, -0.809016,
0.000000, 0.000000, -0.500000, -0.000000, -0.000000, -1.000000,
-0.131434, 0.262869, -0.404506, -0.262868, 0.525735, -0.809014,
0.000000, 0.000000, -0.500000, -0.000000, -0.000000, -1.000000,
0.138194, 0.223610, -0.425325, 0.276391, 0.447218, -0.850649,
-0.131434, 0.262869, -0.404506, -0.262868, 0.525735, -0.809014,
-0.475529, 0.000000, 0.154506, -0.951057, -0.000000, 0.309015,
-0.425324, 0.262868, -0.000000, -0.850649, 0.525734, -0.000000,
-0.361804, 0.223610, 0.262863, -0.723607, 0.447217, 0.525727,
-0.475529, 0.000000, 0.154506, -0.951057, -0.000000, 0.309015,
-0.475529, 0.000000, -0.154506, -0.951057, -0.000000, -0.309015,
-0.425324, 0.262868, -0.000000, -0.850649, 0.525734, -0.000000,
-0.475529, 0.000000, -0.154506, -0.951057, -0.000000, -0.309015,
-0.361804, 0.223610, -0.262863, -0.723607, 0.447217, -0.525727,
-0.425324, 0.262868, -0.000000, -0.850649, 0.525734, -0.000000,
0.000000, 0.000000, 0.500000, -0.000000, -0.000000, 1.000000,
-0.131434, 0.262869, 0.404506, -0.262868, 0.525735, 0.809014,
0.138194, 0.223610, 0.425325, 0.276391, 0.447218, 0.850649,
0.000000, 0.000000, 0.500000, -0.000000, -0.000000, 1.000000,
-0.293893, 0.000000, 0.404508, -0.587787, -0.000000, 0.809016,
-0.131434, 0.262869, 0.404506, -0.262868, 0.525735, 0.809014,
-0.293893, 0.000000, 0.404508, -0.587787, -0.000000, 0.809016,
-0.361804, 0.223610, 0.262863, -0.723607, 0.447217, 0.525727,
-0.131434, 0.262869, 0.404506, -0.262868, 0.525735, 0.809014,
0.475529, 0.000000, 0.154506, 0.951057, 0.000000, 0.309015,
0.344095, 0.262868, 0.249998, 0.688190, 0.525734, 0.499998,
0.447213, 0.223608, -0.000000, 0.894426, 0.447215, -0.000000,
0.475529, 0.000000, 0.154506, 0.951057, 0.000000, 0.309015,
0.293893, 0.000000, 0.404508, 0.587787, 0.000000, 0.809016,
0.344095, 0.262868, 0.249998, 0.688190, 0.525734, 0.499998,
0.293893, 0.000000, 0.404508, 0.587787, 0.000000, 0.809016,
0.138194, 0.223610, 0.425325, 0.276391, 0.447218, 0.850649,
0.344095, 0.262868, 0.249998, 0.688190, 0.525734, 0.499998,
0.081228, 0.425327, -0.249998, 0.162458, 0.850654, -0.499996,
0.262865, 0.425326, -0.000000, 0.525729, 0.850652, -0.000000,
0.000000, 0.500000, -0.000000, 0.000000, 1.000000, -0.000000,
0.081228, 0.425327, -0.249998, 0.162458, 0.850654, -0.499996,
0.344095, 0.262868, -0.249998, 0.688190, 0.525734, -0.499998,
0.262865, 0.425326, -0.000000, 0.525729, 0.850652, -0.000000,
0.344095, 0.262868, -0.249998, 0.688190, 0.525734, -0.499998,
0.447213, 0.223608, -0.000000, 0.894426, 0.447215, -0.000000,
0.262865, 0.425326, -0.000000, 0.525729, 0.850652, -0.000000,
-0.212661, 0.425327, -0.154506, -0.425323, 0.850653, -0.309013,
0.081228, 0.425327, -0.249998, 0.162458, 0.850654, -0.499996,
0.000000, 0.500000, -0.000000, 0.000000, 1.000000, -0.000000,
-0.212661, 0.425327, -0.154506, -0.425323, 0.850653, -0.309013,
-0.131434, 0.262869, -0.404506, -0.262868, 0.525735, -0.809014,
0.081228, 0.425327, -0.249998, 0.162458, 0.850654, -0.499996,
-0.131434, 0.262869, -0.404506, -0.262868, 0.525735, -0.809014,
0.138194, 0.223610, -0.425325, 0.276391, 0.447218, -0.850649,
0.081228, 0.425327, -0.249998, 0.162458, 0.850654, -0.499996,
-0.212661, 0.425327, 0.154506, -0.425323, 0.850653, 0.309013,
-0.212661, 0.425327, -0.154506, -0.425323, 0.850653, -0.309013,
0.000000, 0.500000, -0.000000, 0.000000, 1.000000, -0.000000,
-0.212661, 0.425327, 0.154506, -0.425323, 0.850653, 0.309013,
-0.425324, 0.262868, -0.000000, -0.850649, 0.525734, -0.000000,
-0.212661, 0.425327, -0.154506, -0.425323, 0.850653, -0.309013,
-0.425324, 0.262868, -0.000000, -0.850649, 0.525734, -0.000000,
-0.361804, 0.223610, -0.262863, -0.723607, 0.447217, -0.525727,
-0.212661, 0.425327, -0.154506, -0.425323, 0.850653, -0.309013,
0.081228, 0.425327, 0.249998, 0.162458, 0.850654, 0.499996,
-0.212661, 0.425327, 0.154506, -0.425323, 0.850653, 0.309013,
0.000000, 0.500000, -0.000000, 0.000000, 1.000000, -0.000000,
0.081228, 0.425327, 0.249998, 0.162458, 0.850654, 0.499996,
-0.131434, 0.262869, 0.404506, -0.262868, 0.525735, 0.809014,
-0.212661, 0.425327, 0.154506, -0.425323, 0.850653, 0.309013,
-0.131434, 0.262869, 0.404506, -0.262868, 0.525735, 0.809014,
-0.361804, 0.223610, 0.262863, -0.723607, 0.447217, 0.525727,
-0.212661, 0.425327, 0.154506, -0.425323, 0.850653, 0.309013,
0.262865, 0.425326, -0.000000, 0.525729, 0.850652, -0.000000,
0.081228, 0.425327, 0.249998, 0.162458, 0.850654, 0.499996,
0.000000, 0.500000, -0.000000, 0.000000, 1.000000, -0.000000,
0.262865, 0.425326, -0.000000, 0.525729, 0.850652, -0.000000,
0.344095, 0.262868, 0.249998, 0.688190, 0.525734, 0.499998,
0.081228, 0.425327, 0.249998, 0.162458, 0.850654, 0.499996,
0.344095, 0.262868, 0.249998, 0.688190, 0.525734, 0.499998,
0.138194, 0.223610, 0.425325, 0.276391, 0.447218, 0.850649,
0.081228, 0.425327, 0.249998, 0.162458, 0.850654, 0.499996
]
}
]
};
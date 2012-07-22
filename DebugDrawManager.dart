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

class _DebugLine {
  vec3 positionStart;
  vec3 positionEnd;
  vec4 colorStart;
  vec4 colorEnd;
  num duration;
}

class _DebugDrawLineManager {
  static final int DebugDrawVertexSize = 7; // 3 (position) + 4 (color)
  List<_DebugLine> _lines;

  int _maxVertices;
  Float32Array _vboStorage;

  int _vboUsed;
  int _vbo;
  int _vboLayout;

  _DebugDrawLineManager(Device device, String name, int vboSize, int lineShaderHandle) {
    _maxVertices = vboSize;
    _lines = new List<_DebugLine>();
    _vboUsed = 0;
    _vboStorage = new Float32Array(vboSize*DebugDrawVertexSize);
    _vbo = device.createVertexBuffer(name, {'usage': 'dynamic', 'size': vboSize*DebugDrawVertexSize});
    List inputElements = [new InputElementDescription('vPosition', Device.DeviceFormatFloat3, 7*4, 0, 0),
                          new InputElementDescription('vColor', Device.DeviceFormatFloat4, 7*4, 0, 3*4)];
    _vboLayout = device.createInputLayout('$name Layout', inputElements, lineShaderHandle);
  }

  bool hasRoomFor(int lineCount) {
    int current = _lines.length;
    return current+(lineCount*2) < _maxVertices;
  }

  void add(_DebugLine line) {
    _lines.add(line);
  }

  void _prepareForRender(ImmediateContext context) {
    _vboUsed = 0;
    for (int i = 0; i < _lines.length; i++) {
      _DebugLine line = _lines[i];

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
    for (int i = 0; i < _lines.length;) {
      _DebugLine line = _lines[i];
      line.duration -= dt;
      if (line.duration < 0.0) {
        _lines.removeRange(i, 1);
        continue;
      }
      i++;
    }
  }
}

class _DebugDrawSphere {
  // Probably want to pool these Float32Arrays
  Float32Array centerUniform;
  Float32Array colorUniform;
  num radiusUniform;
  num duration;
  _DebugDrawSphere(vec3 center, vec4 color, num radius) {
    centerUniform = new Float32Array(3);
    centerUniform[0] = center.x;
    centerUniform[1] = center.y;
    centerUniform[2] = center.z;
    colorUniform = new Float32Array(4);
    colorUniform[0] = color.x;
    colorUniform[1] = color.y;
    colorUniform[2] = color.z;
    colorUniform[3] = color.w;
    radiusUniform = radius;
  }

  void destroy() {
    centerUniform = null;
    colorUniform = null;
    radiusUniform = null;
  }
}

class _DebugDrawSphereManager {
  int _maxSpheres;
  List<_DebugDrawSphere> _spheres;
  int _unitSphere;
  int _vboLayout;
  int _sphereShader;
  Float32Array _sphereColor;

  _DebugDrawSphereManager(int unitSphere, int maxSpheres) {
    _unitSphere = unitSphere;
    _maxSpheres = maxSpheres;
    _spheres = new List<_DebugDrawSphere>();
  }

  bool hasRoomFor(int sphereCount) {
    int current = _spheres.length;
    return current+sphereCount < _maxSpheres;
  }

  void _prepareForRender(ImmediateContext context) {
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

  List<int> _handles;

  List _startupCommands;
  List _drawCommands;

  _DebugDrawLineManager _depthEnabledLines;
  _DebugDrawLineManager _depthDisabledLines;
  _DebugDrawSphereManager _depthEnabledSpheres;
  _DebugDrawSphereManager _depthDisabledSpheres;
  Float32Array _cameraMatrix;

  Device _device;
  ImmediateContext _context;

  DebugDrawManager() {
    _handles = new List<int>();
    _cameraMatrix = new Float32Array(16);

    ProgramBuilder pb = new ProgramBuilder();
    pb.createDepthState(_depthStateEnabledName, {'depthTestEnabled': true, 'depthWriteEnabled': true, 'depthComparisonOp': DepthState.DepthComparisonOpLess}, _handles);
    pb.createDepthState(_depthStateDisabledName, {'depthTestEnabled': false, 'depthWriteEnabled': false}, _handles);
    pb.createBlendState(_blendStateName, {}, _handles);
    pb.createRasterizerState(_rasterizerStateName, {'cullEnabled': false, 'lineWidth': 1.0}, _handles);
    pb.createVertexShader(_lineVertexShaderName, {}, _handles);
    pb.createFragmentShader(_lineFragmentShaderName, {}, _handles);
    pb.createShaderProgram(_lineShaderProgramName, {}, _handles);
    pb.setRegisterFromList(0, _handles, _lineVertexShaderHandleIndex);
    pb.setRegisterFromList(1, _handles, _lineFragmentShaderHandleIndex);
    pb.setRegisterFromList(2, _handles, _lineShaderProgramHandleIndex);
    // register 3 must have resource handle for the vertex shader
    // register 4 must have resource handle for the fragment shader
    pb.compileShaderFromResource(Handle.makeRegisterHandle(0), Handle.makeRegisterHandle(3));
    pb.compileShaderFromResource(Handle.makeRegisterHandle(1), Handle.makeRegisterHandle(4));
    pb.linkShaderProgram(Handle.makeRegisterHandle(2), Handle.makeRegisterHandle(0), Handle.makeRegisterHandle(1));
    _startupCommands = pb.ops;
  }

  void init(Device device, ResourceManager rm, int lineVSResourceHandle, int lineFSResourceHandle, int sphereVSResource, int sphereFSResource, int unitSphere, [int vboSize=4096, int maxSpheres=1024]) {
    _device = device;
    _context = device.immediateContext;

    Interpreter interpreter = new Interpreter();
    interpreter.setRegister(3, lineVSResourceHandle);
    interpreter.setRegister(4, lineFSResourceHandle);
    interpreter.run(_startupCommands, _device, rm, _context);

    _depthEnabledLines = new _DebugDrawLineManager(device, _depthEnabledLineVBOName, vboSize, _handles[_lineShaderProgramHandleIndex]);
    _depthDisabledLines = new _DebugDrawLineManager(device, _depthDisabledLineVBOName, vboSize, _handles[_lineShaderProgramHandleIndex]);
    _depthEnabledSpheres = new _DebugDrawSphereManager(unitSphere, maxSpheres);
    _depthDisabledSpheres = new _DebugDrawSphereManager(unitSphere, maxSpheres);

    // Build the program
    ProgramBuilder pb = new ProgramBuilder();
    // General
    pb.setBlendState(_handles[_blendStateHandleIndex]);
    pb.setRasterizerState(_handles[_rasterizerStateHandleIndex]);
    pb.setShaderProgram(_handles[_lineShaderProgramHandleIndex]);
    pb.setUniformMatrix4('cameraTransform', _cameraMatrix);
    pb.setPrimitiveTopology(ImmediateContext.PrimitiveTopologyLines);
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
    } else if (_depthDisabledLines.hasRoomFor(1)){
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
    _depthEnabledLines._prepareForRender(_context);
    _depthDisabledLines._prepareForRender(_context);
    _depthEnabledSpheres._prepareForRender(_context);
    _depthDisabledSpheres._prepareForRender(_context);
  }

  /// Render debug primitives for [Camera] [cam]
  void render(Camera cam) {
    {
      mat4x4 pm = cam.projectionMatrix;
      mat4x4 la = cam.lookAtMatrix;
      pm.selfMultiply(la);
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
  }

  /// Update time [seconds], removing any dead debug primitives
  void update(num seconds) {
    _depthEnabledLines.update(seconds);
    _depthDisabledLines.update(seconds);
    _depthEnabledSpheres.update(seconds);
    _depthDisabledSpheres.update(seconds);
  }
}

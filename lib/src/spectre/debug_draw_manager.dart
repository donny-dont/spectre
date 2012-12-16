part of spectre;

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

class _DebugLineVertex {
  double x;
  double y;
  double z;
  _DebugLineVertex next = null;
}

class _DebugLineObject {
  double r;
  double g;
  double b;
  double a;
  double duration;
  _DebugLineVertex vertexStream;
}

class _DebugLineCollection {
  List<_DebugLineVertex> _freeLineVertices;
  List<_DebugLineObject> _freeLineObjects;
  List<_DebugLineObject> _lineObjects;

  _DebugLineObject _lineObject;

  _DebugLineCollection() {
    _freeLineVertices = new List<_DebugLineVertex>();
    _freeLineObjects = new List<_DebugLineObject>();
    _lineObjects = new List<_DebugLineObject>();
  }

  void startLineObject(double r, double g, double b, double a, double duration){
    if (_lineObject != null) {
      _lineObjects.add(_lineObject);
    }
    if (_freeLineObjects.length > 0) {
      _lineObject = _freeLineObjects.removeLast();
    } else {
      _lineObject = new _DebugLineObject();
    }
    _lineObject.r = r;
    _lineObject.g = g;
    _lineObject.b = b;
    _lineObject.a = a;
    _lineObject.duration = duration;
  }

  _DebugLineVertex getVertex() {
    if (_freeLineVertices.length > 0) {
      return _freeLineVertices.removeLast();
    }
    return new _DebugLineVertex();
  }

  void addVertex(double x, double y, double z) {
    _DebugLineVertex v = getVertex();
    v.x = x;
    v.y = y;
    v.z = z;
    v.next = _lineObject.vertexStream;
    _lineObject.vertexStream = v;
  }

  void freeLineObject(_DebugLineObject lineObject) {
    _DebugLineVertex v = lineObject.vertexStream;
    while (v != null) {
      _freeLineVertices.add(v);
      v = v.next;
    }
    lineObject.vertexStream = null;
    _freeLineObjects.add(lineObject);
  }

  void update(num dt) {
    for (int i = _lineObjects.length-1; i >= 0; i--) {
      _DebugLineObject lineObject = _lineObjects[i];
      lineObject.duration -= dt;
      if (lineObject.duration < 0.0) {
        freeLineObject(lineObject);
        int last = _lineObjects.length-1;
        // Copy last over
        _lineObjects[i] = _lineObjects[last];
        _lineObjects.removeLast();
      }
    }
  }
}

class _DebugDrawLineManager {
  static final int DebugDrawVertexSize = 7; // 3 (position) + 4 (color)
  final GraphicsDevice device;
  final _DebugLineCollection lines = new _DebugLineCollection();
  SingleArrayMesh _lineMesh;
  InputLayout _lineMeshInputLayout;

  int _maxVertices;
  Float32Array _vboStorage;
  int _vboUsed;

  _DebugDrawLineManager(this.device, String name, int vboSize,
                        ShaderProgram lineShaderHandle) {
    _maxVertices = vboSize;
    _vboUsed = 0;
    _vboStorage = new Float32Array(vboSize*DebugDrawVertexSize);
    _lineMesh = device.createSingleArrayMesh(name);
    _lineMesh.vertexArray.allocate(vboSize*DebugDrawVertexSize*4,
                                   SpectreBuffer.UsageDynamic);
    _lineMesh.attributes['vPosition'] = new SpectreMeshAttribute('vPosition',
                                                                 'float', 3,
                                                                 0, 28, false);
    _lineMesh.attributes['vColor'] = new SpectreMeshAttribute('vColor',
                                                              'float', 4,
                                                              12, 28, false);
    _lineMeshInputLayout = device.createInputLayout('$name Layout');
    _lineMeshInputLayout.shaderProgram = lineShaderHandle;
    _lineMeshInputLayout.mesh = _lineMesh;
  }

  void _prepareForRender(GraphicsContext context) {
    _vboUsed = 0;
    for (_DebugLineObject line in lines._lineObjects) {
      _DebugLineVertex v = line.vertexStream;
      while (v != null) {
        _vboStorage[_vboUsed++] = v.x;
        _vboStorage[_vboUsed++] = v.y;
        _vboStorage[_vboUsed++] = v.z;
        _vboStorage[_vboUsed++] = line.r;
        _vboStorage[_vboUsed++] = line.g;
        _vboStorage[_vboUsed++] = line.b;
        _vboStorage[_vboUsed++] = line.a;
        v = v.next;
      }
    }
    _lineMesh.vertexArray.uploadSubData(0, _vboStorage);
  }

  int get vertexCount => _vboUsed ~/ DebugDrawVertexSize;

  void update(num dt) {
    lines.update(dt);
  }
}

/** The debug draw manager manages a collection of debug primitives that are
 * drawn each frame. Each debug primitive has a lifetime and the manager
 * continues to draw each primitive until its lifetime has expired.
 *
 * The following primitives are supported:
 *
 * - Lines
 * - Crosses
 * - Spheres
 * - Circles
 * - Arcs
 * - Transformations (coordinate axes)
 * - Triangles
 * - AABB (Axis Aligned Bounding Boxes)
 *
 *
 * The following controls are supported for each primitive:
 *
 * - Depth testing on or off.
 * - Size.
 * - Color.
 * - Lifetime.
 *
 */
class DebugDrawManager {
  static final _depthStateEnabledName = 'Debug Depth Enabled State';
  static final _depthStateDisabledName = 'Debug Depth Disabled State';
  static final _blendStateName = 'Debug Blend State';
  static final _rasterizerStateName = 'Debug Rasterizer State';
  static final _lineVertexShaderName = 'Debug Line Vertex Shader';
  static final _lineFragmentShaderName = 'Debug Line Fragment Shader';
  static final _lineShaderProgramName = 'Debug Line Program';
  static final _depthEnabledLineVBOName = 'Debug Draw Depth Enabled VBO';
  static final _depthDisabledLineVBOName = 'Debug Draw Depth Disabled VBO';
  static final _cameraTransformUniformName = 'cameraTransform';

  DepthState _depthEnabled;
  DepthState _depthDisabled;
  BlendState _blend;
  RasterizerState _rasterizer;
  VertexShader _lineVertexShader;
  FragmentShader _lineFragmentShader;
  ShaderProgram _lineShaderProgram;
  _DebugDrawLineManager _depthEnabledLines;
  _DebugDrawLineManager _depthDisabledLines;

  Float32Array _cameraMatrix = new Float32Array(16);

  final GraphicsDevice device;

  /** Construct and initialize a DebugDrawManager. */
  DebugDrawManager(this.device, [int vboSize=16384]) {
    _depthEnabled = device.createDepthState(_depthStateEnabledName, {});
    _depthEnabled.depthTestEnabled = true;
    _depthEnabled.depthWriteEnabled = true;
    _depthEnabled.depthComparisonOp = DepthState.DepthComparisonOpLess;
    _depthDisabled = device.createDepthState(_depthStateDisabledName, {});
    _depthDisabled.depthTestEnabled = false;
    _depthDisabled.depthWriteEnabled = false;
    _blend = device.createBlendState(_blendStateName, {});
    _rasterizer = device.createRasterizerState(_rasterizerStateName, {});
    _rasterizer.cullEnabled = true;
    _rasterizer.lineWidth = 1.0;
    _lineVertexShader = device.createVertexShader(_lineVertexShaderName, {});
    _lineFragmentShader = device.createFragmentShader(_lineFragmentShaderName,
                                                      {});
    _lineShaderProgram = device.createShaderProgram(_lineShaderProgramName,
                                                     {});
    _lineVertexShader.source = _debugLineVertexShader;
    _lineFragmentShader.source = _debugLineFragmentShader;
    _lineShaderProgram.vertexShader = _lineVertexShader;
    _lineShaderProgram.fragmentShader = _lineFragmentShader;
    _lineShaderProgram.link();
    _depthEnabledLines = new _DebugDrawLineManager(device,
                                                   _depthEnabledLineVBOName,
                                                   vboSize,
                                                   _lineShaderProgram);
    _depthDisabledLines = new _DebugDrawLineManager(device,
                                                    _depthDisabledLineVBOName,
                                                    vboSize,
                                                    _lineShaderProgram);
  }

  void _addLine(vec3 start, vec3 finish, bool depthEnabled) {
    if (depthEnabled) {
      _depthEnabledLines.lines.addVertex(finish.x, finish.y, finish.z);
      _depthEnabledLines.lines.addVertex(start.x, start.y, start.z);
    } else {
      _depthDisabledLines.lines.addVertex(finish.x, finish.y, finish.z);
      _depthDisabledLines.lines.addVertex(start.x, start.y, start.z);
    }
  }

  void _addLineRaw(double sx, double sy, double sz,
                   double fx, double fy, double fz, bool depthEnabled) {
    if (depthEnabled) {
      _depthEnabledLines.lines.addVertex(fx, fy, fz);
      _depthEnabledLines.lines.addVertex(sx, sy, sz);
    } else {
      _depthDisabledLines.lines.addVertex(fx, fy, fz);
      _depthDisabledLines.lines.addVertex(sx, sy, sz);
    }
  }

  /** Add a line primitive. The line extends from [start] to [finish].
   * The line is drawn in [color] for [duration] seconds.
   */
  void addLine(vec3 start, vec3 finish, vec4 color,
               [num duration = 0.0, bool depthEnabled=true]) {
    if (depthEnabled) {
      _depthEnabledLines.lines.startLineObject(color.r, color.g, color.b,
                                               color.a, duration);
    } else {
      _depthDisabledLines.lines.startLineObject(color.r, color.g, color.b,
                                                color.a, duration);
    }
    _addLine(start, finish, depthEnabled);
  }

  /** Add a cross primitive. The cross primitive is drawn at [point].
   * The cross is drawn in [color] for [duration] seconds.
   * The cross is drawn [size] units wide.
   */
  void addCross(vec3 point, vec4 color,
                [num size = 1.0, num duration = 0.0, bool depthEnabled=true]) {
    if (depthEnabled) {
      _depthEnabledLines.lines.startLineObject(color.r, color.g, color.b,
                                               color.a, duration);
    } else {
      _depthDisabledLines.lines.startLineObject(color.r, color.g, color.b,
                                                color.a, duration);
    }
    num half_size = size * 0.5;
    _addLine(point, point + new vec3(half_size, 0.0, 0.0), depthEnabled);
    _addLine(point, point + new vec3(-half_size, 0.0, 0.0), depthEnabled);
    _addLine(point, point + new vec3(0.0, half_size, 0.0), depthEnabled);
    _addLine(point, point + new vec3(0.0, -half_size, 0.0), depthEnabled);
    _addLine(point, point + new vec3(0.0, 0.0, half_size), depthEnabled);
    _addLine(point, point + new vec3(0.0, 0.0, -half_size), depthEnabled);
  }

  /** Add a sphere primitive. The sphere primitive is drawn at [center]
   * with [radius].
   * The sphere is drawn in [color] for [duration] seconds.
   */
  void addSphere(vec3 center, num radius, vec4 color,
                 [num duration = 0.0, bool depthEnabled = true]) {
    if (depthEnabled) {
      _depthEnabledLines.lines.startLineObject(color.r, color.g, color.b,
                                               color.a, duration);
    } else {
      _depthDisabledLines.lines.startLineObject(color.r, color.g, color.b,
                                                color.a, duration);
    }
    _circle_u.x = 1.0;
    _circle_u.y = 0.0;
    _circle_u.z = 0.0;
    _circle_v.x = 0.0;
    _circle_v.y = 1.0;
    _circle_v.z = 0.0;
  }

  final vec3 _circle_u = new vec3.zero();
  final vec3 _circle_v = new vec3.zero();

  /** Add an arc primitive. The arc is drawn at [center] with [radius].
   * The arc is drawn from [startAngle] to [stopAngle].
   * The arc is drawn in [color] for [duration] seconds.
   */
  void addArc(vec3 center, vec3 planeNormal, num radius, num startAngle,
              num stopAngle, vec4 color, [num duration = 0.0,
              bool depthEnabled = true, int numSegments = 16]) {
    buildPlaneVectors(planeNormal, _circle_u, _circle_v);
    num alpha = 0.0;
    num twoPi = (2.0 * 3.141592653589793238462643);
    num _step = twoPi/numSegments;

    alpha = startAngle;
    double cosScale = cos(alpha) * radius;
    double sinScale = sin(alpha) * radius;
    double lastX = center.x + cosScale * _circle_u.x + sinScale * _circle_v.x;
    double lastY = center.y + cosScale * _circle_u.y + sinScale * _circle_v.y;
    double lastZ = center.z + cosScale * _circle_u.z + sinScale * _circle_v.z;

    if (depthEnabled) {
      _depthEnabledLines.lines.startLineObject(color.r, color.g, color.b,
                                                color.a, duration);
    } else {
      _depthDisabledLines.lines.startLineObject(color.r, color.g, color.b,
                                                 color.a, duration);
    }


    for (alpha = startAngle; alpha <= stopAngle+_step; alpha += _step) {
      cosScale = cos(alpha) * radius;
      sinScale = sin(alpha) * radius;
      double pX = center.x + cosScale * _circle_u.x + sinScale * _circle_v.x;
      double pY = center.y + cosScale * _circle_u.y + sinScale * _circle_v.y;
      double pZ = center.z + cosScale * _circle_u.z + sinScale * _circle_v.z;
      _addLineRaw(lastX, lastY, lastZ, pX, pY, pZ, depthEnabled);
      lastX = pX;
      lastY = pY;
      lastZ = pZ;
    }
  }

  /** Add a circle primitive. The circle is located at [center] and
   * is drawn in the plane defined by [planeNormal].
   * The circle has [radius] and [color] and is drawn for [duration] seconds.
   */
  void addCircle(vec3 center, vec3 planeNormal, num radius, vec4 color,
                 [num duration = 0.0, bool depthEnabled = true,
                 int numSegments = 16]) {
    buildPlaneVectors(planeNormal, _circle_u, _circle_v);
    num alpha = 0.0;
    num twoPi = (2.0 * 3.141592653589793238462643);
    num _step = twoPi/numSegments;

    double lastX = center.x + _circle_u.x * radius;
    double lastY = center.y + _circle_u.y * radius;
    double lastZ = center.z + _circle_u.z * radius;

    if (depthEnabled) {
      _depthEnabledLines.lines.startLineObject(color.r, color.g, color.b,
                                                color.a, duration);
    } else {
      _depthDisabledLines.lines.startLineObject(color.r, color.g, color.b,
                                                 color.a, duration);
    }

    for (alpha = 0.0; alpha <= twoPi; alpha += _step) {
      double cosScale = cos(alpha) * radius;
      double sinScale = sin(alpha) * radius;
      double pX = center.x + cosScale * _circle_u.x + sinScale * _circle_v.x;
      double pY = center.y + cosScale * _circle_u.y + sinScale * _circle_v.y;
      double pZ = center.z + cosScale * _circle_u.z + sinScale * _circle_v.z;
      _addLineRaw(lastX, lastY, lastZ, pX, pY, pZ, depthEnabled);
      lastX = pX;
      lastY = pY;
      lastZ = pZ;
    }
    _addLineRaw(lastX, lastY, lastZ,
                center.x + _circle_u.x * radius,
                center.y + _circle_u.y * radius,
                center.z + _circle_u.z * radius, depthEnabled);
  }

  /// Add a transformation (rotation & translation) from [xform].
  /// Size is controlled with [size]
  ///
  /// X,Y, and Z axes are colored Red,Green, and Blue
  ///
  /// Options: [duration] and [depthEnabled]
  void addAxes(mat4 xform, num size,
               [num duration = 0.0, bool depthEnabled = true]) {
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
    if (depthEnabled) {
      _depthEnabledLines.lines.startLineObject(color.r, color.g, color.b,
                                                color.a, duration);
    } else {
      _depthDisabledLines.lines.startLineObject(color.r, color.g, color.b,
                                                 color.a, duration);
    }
    _addLine(origin.xyz, X.xyz, depthEnabled);
    _addLine(X.xyz, X_head_0.xyz, depthEnabled);
    _addLine(X.xyz, X_head_1.xyz, depthEnabled);
    _addLine(X.xyz, X_head_2.xyz, depthEnabled);
    _addLine(X.xyz, X_head_3.xyz, depthEnabled);

    Y = xform * Y;
    Y_head_0 = xform * Y_head_0;
    Y_head_1 = xform * Y_head_1;
    Y_head_2 = xform * Y_head_2;
    Y_head_3 = xform * Y_head_3;

    color = new vec4.raw(0.0, 1.0, 0.0, 1.0);
    if (depthEnabled) {
      _depthEnabledLines.lines.startLineObject(color.r, color.g, color.b,
                                                color.a, duration);
    } else {
      _depthDisabledLines.lines.startLineObject(color.r, color.g, color.b,
                                                 color.a, duration);
    }
    _addLine(origin.xyz, Y.xyz, depthEnabled);
    _addLine(Y.xyz, Y_head_0.xyz, depthEnabled);
    _addLine(Y.xyz, Y_head_1.xyz, depthEnabled);
    _addLine(Y.xyz, Y_head_2.xyz, depthEnabled);
    _addLine(Y.xyz, Y_head_3.xyz, depthEnabled);

    Z = xform * Z;
    Z_head_0 = xform * Z_head_0;
    Z_head_1 = xform * Z_head_1;
    Z_head_2 = xform * Z_head_2;
    Z_head_3 = xform * Z_head_3;

    color = new vec4.raw(0.0, 0.0, 1.0, 1.0);
    if (depthEnabled) {
      _depthEnabledLines.lines.startLineObject(color.r, color.g, color.b,
                                                color.a, duration);
    } else {
      _depthDisabledLines.lines.startLineObject(color.r, color.g, color.b,
                                                 color.a, duration);
    }
    _addLine(origin.xyz, Z.xyz, depthEnabled);
    _addLine(Z.xyz, Z_head_0.xyz, depthEnabled);
    _addLine(Z.xyz, Z_head_1.xyz, depthEnabled);
    _addLine(Z.xyz, Z_head_2.xyz, depthEnabled);
    _addLine(Z.xyz, Z_head_3.xyz, depthEnabled);
  }

  /// Add a triangle with vertices [vertex0], [vertex1], and [vertex2].
  /// Color [color]
  ///
  /// Options: [duration] and [depthEnabled]
  void addTriangle(vec3 vertex0, vec3 vertex1, vec3 vertex2, vec4 color,
                   [num duration = 0.0, bool depthEnabled = true]) {
    if (depthEnabled) {
      _depthEnabledLines.lines.startLineObject(color.r, color.g, color.b,
                                                color.a, duration);
    } else {
      _depthDisabledLines.lines.startLineObject(color.r, color.g, color.b,
                                                 color.a, duration);
    }
    _addLine(vertex0, vertex1, depthEnabled);
    _addLine(vertex1, vertex2, depthEnabled);
    _addLine(vertex2, vertex0, depthEnabled);
  }

  /// Add an AABB from [boxMin] to [boxMax] with [color].
  ///
  /// Options: [duration] and [depthEnabled]
  void addAABB(vec3 boxMin, vec3 boxMax, vec4 color,
               [num duration = 0.0, bool depthEnabled = true]) {
    vec3 vertex_a;
    vec3 vertex_b;

    if (depthEnabled) {
      _depthEnabledLines.lines.startLineObject(color.r, color.g, color.b,
                                                color.a, duration);
    } else {
      _depthDisabledLines.lines.startLineObject(color.r, color.g, color.b,
                                                 color.a, duration);
    }
    vertex_a = new vec3.copy(boxMin);
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[0] = boxMax[0];
    _addLine(vertex_a, vertex_b, depthEnabled);
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[1] = boxMax[1];
    _addLine(vertex_a, vertex_b, depthEnabled);
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[2] = boxMax[2];
    _addLine(vertex_a, vertex_b, depthEnabled);
    vertex_a[1] = boxMax[1];
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[0] = boxMax[0];
    _addLine(vertex_a, vertex_b, depthEnabled);
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[2] = boxMax[2];
    _addLine(vertex_a, vertex_b, depthEnabled);
    vertex_a = new vec3.copy(boxMin);
    vertex_a[0] = boxMax[0];
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[1] = boxMax[1];
    _addLine(vertex_a, vertex_b, depthEnabled);
    vertex_a = new vec3.copy(boxMax);
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[0] = boxMin[0];
    _addLine(vertex_a, vertex_b, depthEnabled);
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[1] = boxMin[1];
    _addLine(vertex_a, vertex_b, depthEnabled);
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[2] = boxMin[2];
    _addLine(vertex_a, vertex_b, depthEnabled);
    vertex_a[1] = boxMin[1];
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[0] = boxMin[0];
    _addLine(vertex_a, vertex_b, depthEnabled);
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[2] = boxMin[2];
    _addLine(vertex_a, vertex_b, depthEnabled);
    vertex_a = new vec3.copy(boxMin);
    vertex_a[2] = boxMax[2];
    vertex_b = new vec3.copy(vertex_a);
    vertex_b[1] = boxMax[1];
    _addLine(vertex_a, vertex_b, depthEnabled);
  }

  /// Prepare to render debug primitives
  void prepareForRender() {
    _depthEnabledLines._prepareForRender(device.context);
    _depthDisabledLines._prepareForRender(device.context);
  }

  /// Render debug primitives for [Camera] [cam]
  void render(Camera cam) {
    mat4 pm = cam.projectionMatrix;
    mat4 la = cam.lookAtMatrix;
    pm.multiply(la);
    pm.copyIntoArray(_cameraMatrix);
    device.context.setBlendState(_blend);
    device.context.setRasterizerState(_rasterizer);
    device.context.setShaderProgram(_lineShaderProgram);
    device.context.setConstant('cameraTransform', _cameraMatrix);
    device.context.setPrimitiveTopology(GraphicsContext.PrimitiveTopologyLines);
    device.context.setIndexBuffer(null);
    device.context.setDepthState(_depthEnabled);
    device.context.setVertexBuffers(
        0,
        [_depthEnabledLines._lineMesh.vertexArray]);
    device.context.setInputLayout(_depthEnabledLines._lineMeshInputLayout);
    device.context.draw(_depthEnabledLines.vertexCount, 0);
    device.context.setDepthState(_depthDisabled);
    device.context.setVertexBuffers(
        0,
        [_depthDisabledLines._lineMesh.vertexArray]);
    device.context.draw(_depthDisabledLines.vertexCount, 0);
  }

  /// Update time [seconds], removing any dead debug primitives
  void update(num seconds) {
    _depthEnabledLines.update(seconds);
    _depthDisabledLines.update(seconds);
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
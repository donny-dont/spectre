import 'dart:html';
import 'dart:math' as Math;
import 'package:spectre/spectre.dart';
import 'package:vector_math/vector_math_browser.dart';

final String _canvasId = '#backbuffer';

GraphicsDevice _graphicsDevice;
GraphicsContext _graphicsContext;
ResourceManager _resourceManager;
DebugDrawManager _debugDrawManager;

int _viewport;
Camera _camera;
double _lastTime;
bool _circleDrawn = false;

vec2 ballPosition = new vec2(0.1, 0.1);
vec2 ballDirection = new vec2(-1.0, -1.0).normalize();
final double ballVelocity = 0.01;
final double ballRadius = 0.02;

final List<vec2> lineStart = [
                        new vec2(-2.0, -1.0), // Top
                        new vec2(-2.0, 1.0), // Bottom
                        new vec2(-2.0, -1.0), // End
                        new vec2(2.0, -1.0),
                        new vec2(-1.0, -0.5)
                        ];
final List<vec2> lineEnd = [
                      new vec2(2.0, -1.0), // Top
                      new vec2(2.0, 1.0), // Bottom
                      new vec2(-2.0, 1.0), // End
                      new vec2(2.0, 1.0), //
                      new vec2(1.0, 0.5)
                      ];
List<vec2> lineNormals;

void _makeNormals() {
  assert(lineStart.length == lineEnd.length);
  lineNormals = new List<vec2>(lineStart.length);
  for (int i = 0; i < lineStart.length; i++) {
    vec2 n = lineEnd[i]-lineStart[i];
    n.normalize();
    lineNormals[i] = n;
  }
}

// http://mathworld.wolfram.com/Circle-LineIntersection.html
bool _ballIntersectsRay(vec2 _a, vec2 _b) {
  // Move line origin to be relative to the ball's position.
  vec2 a = new vec2.copy(_a).sub(ballPosition);
  vec2 b = new vec2.copy(_b).sub(ballPosition);
  vec2 delta = b-a;
  double deltaLen = delta.length;
  double D = (a.x * b.y) - (b.x * a.y);
  return (ballRadius*ballRadius*deltaLen*deltaLen) - (D*D) >= 0;
}

bool _ballIntersectsLineSegment(vec2 _a, vec2 _b) {
  if (_ballIntersectsRay(_a, _b) == false) {
    return false;
  }
  // We intersect with the ray, now check if we are within the line segment.
  // Make ballPosition relative to the line segment
  vec2 p = ballPosition - _a;
  vec2 delta = _b-_a;
  double t = dot(p, delta) / delta.length2;
  if (t < 0.0 || t > 1.0) {
    return false;
  }
  return true;
}

void _updateBall(double dt) {
  assert(lineStart.length == lineEnd.length);
  ballPosition.add(ballDirection.scaled(ballVelocity));
  for (int i = 0; i < lineStart.length; i++) {
    if (_ballIntersectsLineSegment(lineStart[i], lineEnd[i])) {
      vec2 n = lineNormals[i];
      // 2D reflection.
      double scalarProjection = 2.0 * n.dot(ballDirection);
      vec2 vectorProjection = n.scaled(scalarProjection);
      ballDirection = vectorProjection - ballDirection;
      // Make sure ballDirection is always unit length.
      ballDirection.normalize();
      break;
    }
  }
}

void frame(double time) {
  Stopwatch sw = new Stopwatch();
  if (_lastTime == null) {
    _lastTime = time;
    window.requestAnimationFrame(frame);
    return;
  }
  double dt = time - _lastTime;
  _lastTime = time;
  double seconds = dt * 0.001;
  // Update the debug draw manager state
  _debugDrawManager.update(seconds);
  // Clear the color buffer
  _graphicsContext.clearColorBuffer(0.0, 0.0, 0.0, 1.0);
  // Clear the depth buffer
  _graphicsContext.clearDepthBuffer(1.0);
  // Reset the context
  _graphicsContext.reset();
  // Set the viewport
  _graphicsContext.setViewport(_viewport);
  // Add three lines, one for each axis.

  /* Draw playing area */
  // Top & Bottom
  for (int i = 0; i < 2; i++) {
    vec3 s = new vec3.raw(lineStart[i].x, lineStart[i].y, 0.0);
    vec3 e = new vec3.raw(lineEnd[i].x, lineEnd[i].y, 0.0);
    _debugDrawManager.addLine(s, e, new vec4.raw(1.0, 0.0, 0.0, 1.0));
  }

  // Ends
  for (int i = 2; i < 4; i++) {
    vec3 s = new vec3.raw(lineStart[i].x, lineStart[i].y, 0.0);
    vec3 e = new vec3.raw(lineEnd[i].x, lineEnd[i].y, 0.0);
    _debugDrawManager.addLine(s, e, new vec4.raw(1.0, 1.0, 1.0, 1.0));
  }

  // Other
  for (int i = 4; i < lineStart.length; i++) {
    vec3 s = new vec3.raw(lineStart[i].x, lineStart[i].y, 0.0);
    vec3 e = new vec3.raw(lineEnd[i].x, lineEnd[i].y, 0.0);
    _debugDrawManager.addLine(s, e, new vec4.raw(0.0, 0.0, 1.0, 1.0));
  }

  _updateBall(seconds);

  // Draw ball
  _debugDrawManager.addCircle(new vec3(ballPosition.x, ballPosition.y, 0.0),
                              new vec3(0.0, 0.0, 1.0),
                              ballRadius, new vec4(0.0, 0.0, 1.0, 1.0));
  // Prepare the debug draw manager for rendering
  _debugDrawManager.prepareForRender();
  // Render it
  _debugDrawManager.render(_camera);
  // Schedule our next frame callback
  window.requestAnimationFrame(frame);
}

// Handle resizes
void resizeFrame(Event event) {
  CanvasElement canvas = query(_canvasId);
  // Set the canvas width and height to match the dom elements
  canvas.width = canvas.clientWidth;
  canvas.height = canvas.clientHeight;
  // Adjust the viewport dimensions
  Viewport vp = _graphicsDevice.getDeviceChild(_viewport);
  vp.width = canvas.width;
  vp.height = canvas.height;
  // Fix the camera's aspect ratio
  _camera.aspectRatio = canvas.width.toDouble()/canvas.height.toDouble();
}

main() {
  final String baseUrl = "${window.location.href.substring(0, window.location.href.length - "engine.html".length)}web/resources";
  CanvasElement canvas = query(_canvasId);
  assert(canvas != null);
  WebGLRenderingContext gl = canvas.getContext('experimental-webgl');

  assert(gl != null);

  // Initialize Spectre
  initSpectre();
  // Create a GraphicsDevice
  _graphicsDevice = new GraphicsDevice(gl);
  // Get a reference to the GraphicsContext
  _graphicsContext = _graphicsDevice.context;
  // Create a resource manager and set it's base URL
  _resourceManager = new ResourceManager();
  _resourceManager.setBaseURL(baseUrl);
  // Create a debug draw manager and initialize it
  _debugDrawManager = new DebugDrawManager();
  _debugDrawManager.init(_graphicsDevice);

  // Set the canvas width and height to match the dom elements
  canvas.width = canvas.clientWidth;
  canvas.height = canvas.clientHeight;

  // Create a viewport
  var viewportProperties = {
    'x': 0,
    'y': 0,
    'width': canvas.width,
    'height': canvas.height
  };

  _makeNormals();

  // Create the viewport
  _viewport = _graphicsDevice.createViewport('view', viewportProperties);

  // Create the camera
  _camera = new Camera();
  _camera.aspectRatio = canvas.width.toDouble()/canvas.height.toDouble();
  _camera.position = new vec3.raw(0.0, 0.0, -2.5);
  _camera.focusPosition = new vec3.raw(0.0, 0.0, 0.0);
  window.requestAnimationFrame(frame);
  window.on.resize.add(resizeFrame);
}
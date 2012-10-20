import 'dart:html';
import 'dart:math';
import 'package:spectre/spectre.dart';
import 'package:vector_math/vector_math_browser.dart';

final String _canvasId = '#backbuffer';

GraphicsDevice _graphicsDevice;
ImmediateContext _graphicsContext;
ResourceManager _resourceManager;
DebugDrawManager _debugDrawManager;

int _viewport;
Camera _camera;
int _lastTime;
bool _circleDrawn = false;

void frame(int time) {
  if (_lastTime == null) {
    _lastTime = time;
    window.requestAnimationFrame(frame);
    return;
  }
  int dt = time - _lastTime;
  _lastTime = time;
  double seconds = dt.toDouble() * 0.001;
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
  _debugDrawManager.addLine(new vec3.raw(0.0, 0.0, 0.0),
                            new vec3.raw(10.0, 0.0, 0.0),
                            new vec4.raw(1.0, 0.0, 0.0, 1.0));
  _debugDrawManager.addLine(new vec3.raw(0.0, 0.0, 0.0),
                            new vec3.raw(0.0, 10.0, 0.0),
                            new vec4.raw(0.0, 1.0, 0.0, 1.0));
  _debugDrawManager.addLine(new vec3.raw(0.0, 0.0, 0.0),
                            new vec3.raw(0.0, 0.0, 10.0),
                            new vec4.raw(0.0, 0.0, 1.0, 1.0));
  if (_circleDrawn == false) {
    _circleDrawn = true;
    // Draw a circle that lasts for 5 seconds.
    _debugDrawManager.addCircle(new vec3.raw(0.0, 0.0, 0.0), new vec3.raw(0.0, 1.0, 0.0), 2.0, new vec4.raw(1.0, 1.0, 1.0, 1.0), 5.0);
  }
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
  _graphicsContext = _graphicsDevice.immediateContext;
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

  // Create the viewport
  _viewport = _graphicsDevice.createViewport('view', viewportProperties);

  // Create the camera
  _camera = new Camera();
  _camera.aspectRatio = canvas.width.toDouble()/canvas.height.toDouble();
  _camera.position = new vec3.raw(2.0, 2.0, 2.0);
  _camera.focusPosition = new vec3.raw(1.0, 1.0, 1.0);
  window.requestAnimationFrame(frame);
  window.on.resize.add(resizeFrame);
}
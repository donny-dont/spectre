import 'dart:html';
import 'dart:math';
import 'package:vector_math/vector_math.dart';
import 'package:game_loop/game_loop.dart';
import 'package:asset_pack/asset_pack.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_asset_pack.dart';
import 'package:spectre/spectre_renderer.dart';

final String _canvasId = '#frontBuffer';

GraphicsDevice graphicsDevice;
GraphicsContext graphicsContext;
DebugDrawManager debugDrawManager;
GameLoop gameLoop;
AssetManager assetManager;
Renderer renderer;
final List<Layer> layers = new List<Layer>();

final Camera camera = new Camera();
final cameraController = new FpsFlyCameraController();
double _lastTime;
bool _circleDrawn = false;

Map renderer_config = {
 'buffers': [
 {
 'name': 'depthBuffer',
 'type': 'depth',
 'width': 640,
 'height': 480
 },
 {
'name': 'colorBuffer',
 'type': 'color',
 'width': 640,
 'height': 480
 }
 ],
 'targets': [
 {
 'name': 'frontBuffer',
 'width': 640,
 'height': 480,
 },
 {
 'name': 'backBuffer',
 'depthBuffer': 'depthBuffer',
 'colorBuffer': 'colorBuffer',
 }
 ]
};

void gameFrame(GameLoop gameLoop) {
  double dt = gameLoop.dt;
  cameraController.forwardVelocity = 25.0;
  cameraController.strafeVelocity = 25.0;
  cameraController.forward =
      gameLoop.keyboard.buttons[Keyboard.W].down;
  cameraController.backward =
      gameLoop.keyboard.buttons[Keyboard.S].down;
  cameraController.strafeLeft =
      gameLoop.keyboard.buttons[Keyboard.A].down;
  cameraController.strafeRight =
      gameLoop.keyboard.buttons[Keyboard.D].down;
  if (gameLoop.pointerLock.locked) {
    cameraController.accumDX = gameLoop.mouse.dx;
    cameraController.accumDY = gameLoop.mouse.dy;
  }
  cameraController.updateCamera(gameLoop.dt, camera);
  // Update the debug draw manager state
  debugDrawManager.update(dt);
}

void renderFrame(GameLoop gameLoop) {
  renderer.time = gameLoop.gameTime;
  renderer.render(layers, null, camera);

  // Add three lines, one for each axis.
  debugDrawManager.addLine(new vec3.raw(0.0, 0.0, 0.0),
                           new vec3.raw(10.0, 0.0, 0.0),
                           new vec4.raw(1.0, 0.0, 0.0, 1.0));
  debugDrawManager.addLine(new vec3.raw(0.0, 0.0, 0.0),
                           new vec3.raw(0.0, 10.0, 0.0),
                           new vec4.raw(0.0, 1.0, 0.0, 1.0));
  debugDrawManager.addLine(new vec3.raw(0.0, 0.0, 0.0),
                           new vec3.raw(0.0, 0.0, 10.0),
                           new vec4.raw(0.0, 0.0, 1.0, 1.0));
  debugDrawManager.addSphere(new vec3(20.0, 20.0, 20.0), 20.0,
                             new vec4(0.0, 1.0, 0.0, 1.0));
  if (_circleDrawn == false) {
    _circleDrawn = true;
    // Draw a circle that lasts for 5 seconds.
    debugDrawManager.addCircle(new vec3.raw(0.0, 0.0, 0.0),
                               new vec3.raw(0.0, 1.0, 0.0),
                               2.0,
                               new vec4.raw(1.0, 1.0, 1.0, 1.0),
                               duration:5.0);
  }
  // Prepare the debug draw manager for rendering
  debugDrawManager.prepareForRender();
  // Render it
  debugDrawManager.render(camera);
}

// Handle resizes
void resizeFrame(GameLoop gameLoop) {
  CanvasElement canvas = gameLoop.element;
  // Set the canvas width and height to match the dom elements
  canvas.width = canvas.client.width;
  canvas.height = canvas.client.height;
  // Fix the camera's aspect ratio
  camera.aspectRatio = canvas.width.toDouble()/canvas.height.toDouble();
}

SingleArrayIndexedMesh _skyboxMesh;
ShaderProgram _skyboxShaderProgram;
InputLayout _skyboxInputLayout;
SamplerState _skyboxSampler;
DepthState _skyboxDepthState;
BlendState _skyboxBlendState;
RasterizerState _skyboxRasterizerState;

void _setupSkybox() {
  _skyboxShaderProgram = assetManager['demoAssets.skyBoxShader'];
  assert(_skyboxShaderProgram.linked == true);
  _skyboxMesh = assetManager['demoAssets.skyBox'];
  _skyboxInputLayout = new InputLayout('Skybox', graphicsDevice);
  _skyboxInputLayout.mesh = _skyboxMesh;
  _skyboxInputLayout.shaderProgram = _skyboxShaderProgram;
  assert(_skyboxInputLayout.ready == true);
  _skyboxSampler = new SamplerState('Skybox', graphicsDevice);
  _skyboxDepthState = new DepthState('Skybox', graphicsDevice);
  _skyboxBlendState = new BlendState('Skybox', graphicsDevice);
  _skyboxBlendState.enabled = false;
  _skyboxRasterizerState = new RasterizerState('skybox.rs', graphicsDevice);
  _skyboxRasterizerState.cullMode = CullMode.None;
}

Float32Array _cameraTransform = new Float32Array(16);

void _drawSkybox() {
  var context = graphicsDevice.context;
  context.setInputLayout(_skyboxInputLayout);
  context.setPrimitiveTopology(GraphicsContext.PrimitiveTopologyTriangles);
  context.setShaderProgram(_skyboxShaderProgram);
  context.setTextures(0, [assetManager['demoAssets.space']]);
  context.setSamplers(0, [_skyboxSampler]);
  {
    mat4 P = camera.projectionMatrix;
    mat4 LA = makeViewMatrix(new vec3.zero(),
        camera.frontDirection,
        new vec3(0.0, 1.0, 0.0));
    P.multiply(LA);
    P.copyIntoArray(_cameraTransform, 0);
  }
  context.setConstant('cameraTransform', _cameraTransform);
  context.setBlendState(_skyboxBlendState);
  context.setRasterizerState(_skyboxRasterizerState);
  context.setDepthState(_skyboxDepthState);
  context.setIndexedMesh(_skyboxMesh);
  context.drawIndexedMesh(_skyboxMesh);
}


main() {
  CanvasElement canvas = query(_canvasId);
  assert(canvas != null);

  // Create a GraphicsDevice
  graphicsDevice = new GraphicsDevice(canvas);
  // Get a reference to the GraphicsContext
  graphicsContext = graphicsDevice.context;
  // Create a debug draw manager and initialize it
  debugDrawManager = new DebugDrawManager(graphicsDevice);

  // Set the canvas width and height to match the dom elements
  canvas.width = canvas.client.width;
  canvas.height = canvas.client.height;

  assetManager = new AssetManager();
  registerSpectreWithAssetManager(graphicsDevice, assetManager);
  renderer = new Renderer(canvas, graphicsDevice, assetManager);
  renderer.fromJson(renderer_config);
  gameLoop = new GameLoop(canvas);
  gameLoop.onUpdate = gameFrame;
  gameLoop.onRender = renderFrame;
  gameLoop.onResize = resizeFrame;
  assetManager.loadPack('demoAssets', 'assets.pack').then((assetPack) {
    // All assets are loaded.
    _setupSkybox();
    // Setup camera.
    camera.aspectRatio = canvas.width.toDouble()/canvas.height.toDouble();
    camera.position = new vec3.raw(2.0, 2.0, 2.0);
    camera.focusPosition = new vec3.raw(1.0, 1.0, 1.0);

    // Setup layers.
    var clearBackBuffer = new Layer('clear', 'fullscreen');
    clearBackBuffer.clearColorTarget = true;
    clearBackBuffer.clearDepthTarget = true;
    clearBackBuffer.renderTarget = 'backBuffer';
    layers.add(clearBackBuffer);
    var colorBackBuffer = new Layer('color', 'fullscreen');
    colorBackBuffer.clearColorTarget = true;
    colorBackBuffer.clearColorG = 1.0;
    colorBackBuffer.clearDepthTarget = true;
    colorBackBuffer.renderTarget = 'backBuffer';
    layers.add(colorBackBuffer);
    var blitBackBuffer = new Layer('blit', 'fullscreen');
    blitBackBuffer.renderTarget = 'frontBuffer';
    blitBackBuffer.clearColorTarget = true;
    blitBackBuffer.material = assetManager['fullscreenEffects.blit'];
    blitBackBuffer.material.textures['source'].texturePath =
        'renderer.colorBuffer';
    blitBackBuffer.material.textures['source'].sampler = renderer.NPOTSampler;
    layers.add(blitBackBuffer);
    gameLoop.start();
  });
}

import 'dart:html';
import 'dart:math';
import 'package:vector_math/vector_math.dart';
import 'package:game_loop/game_loop.dart';
import 'package:asset_pack/asset_pack.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_asset_pack.dart';

final String _canvasId = '#backbuffer';

GraphicsDevice _graphicsDevice;
GraphicsContext _graphicsContext;
DebugDrawManager _debugDrawManager;

GameLoop _gameLoop;
AssetManager _assetManager;

Viewport _viewport;
final Camera camera = new Camera();
final cameraController = new MouseKeyboardCameraController();
double _lastTime;
bool _circleDrawn = false;

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
  _debugDrawManager.update(dt);
}

void renderFrame(GameLoop gameLoop) {
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
    _debugDrawManager.addCircle(new vec3.raw(0.0, 0.0, 0.0),
                                new vec3.raw(0.0, 1.0, 0.0),
                                2.0,
                                new vec4.raw(1.0, 1.0, 1.0, 1.0),
                                5.0);
  }

  _drawSkybox();
  _drawSkinnedCharacter();
  // Prepare the debug draw manager for rendering
  _debugDrawManager.prepareForRender();
  // Render it
  _debugDrawManager.render(camera);
}

// Handle resizes
void resizeFrame(GameLoop gameLoop) {
  CanvasElement canvas = gameLoop.element;
  // Set the canvas width and height to match the dom elements
  canvas.width = canvas.clientWidth;
  canvas.height = canvas.clientHeight;
  // Adjust the viewport dimensions
  _viewport.width = canvas.width;
  _viewport.height = canvas.height;
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
  _skyboxShaderProgram = _assetManager.root.demoAssets.skyBoxShader;
  assert(_skyboxShaderProgram.linked == true);
  _skyboxMesh = _assetManager.root.demoAssets.skyBox;
  _skyboxInputLayout = new InputLayout('Skybox', _graphicsDevice);
  _skyboxInputLayout.mesh = _skyboxMesh;
  _skyboxInputLayout.shaderProgram = _skyboxShaderProgram;

  assert(_skyboxInputLayout.ready == true);
  _skyboxSampler = new SamplerState('Skybox', _graphicsDevice);
  _skyboxDepthState = new DepthState('Skybox', _graphicsDevice);
  _skyboxBlendState = new BlendState('Skybox', _graphicsDevice);
  _skyboxBlendState.enabled = false;
  _skyboxRasterizerState = new RasterizerState('skybox.rs', _graphicsDevice);
  _skyboxRasterizerState.cullMode = CullMode.None;
}

Float32Array _cameraTransform = new Float32Array(16);

void _drawSkybox() {
  var context = _graphicsDevice.context;
  context.setInputLayout(_skyboxInputLayout);
  context.setPrimitiveTopology(GraphicsContext.PrimitiveTopologyTriangles);
  context.setShaderProgram(_skyboxShaderProgram);
  context.setTextures(0, [_assetManager.root.demoAssets.space]);
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

ShaderProgram _skinnedShaderProgram;
InputLayout _skinnedInputLayout;
SkinnedMesh _skinnedMesh;
RasterizerState _skinnedRasterizerState;
DepthState _skinnedDepthState;
int _depthGuard = 100;
double _skeletonScale = 1.0;
void _drawSkinnedBones(SkinnedMesh mesh, int id, int depth) {
  List<double> origin = [0.0, 0.0, 0.0];
  final matrices = mesh.globalBoneTransforms;
  origin[0] = matrices[id][12] * _skeletonScale;
  origin[1] = matrices[id][13] * _skeletonScale;
  origin[2] = matrices[id][14] * _skeletonScale;
  int childOffset = mesh.boneChildrenOffsets[id];
  if (id == 0) {
    _debugDrawManager.addCross(new vec3.raw(origin[0], origin[1], origin[2]),
        new vec4.raw(1.0, 0.0, 1.0, 1.0));
  } else {
  _debugDrawManager.addCross(new vec3.raw(origin[0], origin[1], origin[2]),
                             new vec4.raw(0.0, 1.0, 1.0, 1.0));
  }
  if (depth >= _depthGuard) {
    return;
  }
  while (mesh.boneChildrenIds[childOffset] != -1) {
    List<double> end = [0.0, 0.0, 0.0];
    int childId = mesh.boneChildrenIds[childOffset];
    end[0] = matrices[childId][12] * _skeletonScale;
    end[1] = matrices[childId][13] * _skeletonScale;
    end[2] = matrices[childId][14] * _skeletonScale;
    _debugDrawManager.addLine(new vec3.raw(origin[0],
                                           origin[1],
                                           origin[2]),
                              new vec3.raw(end[0], end[1], end[2]),
                              new vec4.raw(1.0, 1.0, 1.0, 1.0));
    _drawSkinnedBones(mesh, childId, depth+1);
    childOffset++;
  }
}

void _setupSkinnedCharacter() {
  _skinnedShaderProgram = _assetManager.root.demoAssets.litdiffuse;
  assert(_skinnedShaderProgram.linked == true);
  _skinnedMesh = importSkinnedMesh('skinned', _graphicsDevice,
                                   _assetManager.root.demoAssets.hellknight);
  _skinnedInputLayout = new InputLayout('skinned.il', _graphicsDevice);
  _skinnedInputLayout.mesh = _skinnedMesh;
  _skinnedInputLayout.shaderProgram = _skinnedShaderProgram;
  _skinnedRasterizerState = new RasterizerState('skinned.rs', _graphicsDevice);
  _skinnedRasterizerState.cullMode = CullMode.Back;
  _skinnedDepthState = new DepthState('skinned.ds', _graphicsDevice);
  _skinnedDepthState.depthBufferEnabled = true;
  _skinnedDepthState.depthBufferWriteEnabled = true;
  _skinnedDepthState.depthBufferFunction = CompareFunction.LessEqual;
}

void _drawSkinnedCharacter() {
  _skinnedMesh.update(1.0/60.0);
  _drawSkinnedBones(_skinnedMesh, 0, 0);
  var context = _graphicsDevice.context;
  context.setPrimitiveTopology(GraphicsContext.PrimitiveTopologyTriangles);
  context.setShaderProgram(_skinnedShaderProgram);
  context.setSamplers(0, [_skyboxSampler]);
  {
    mat4 P = camera.projectionMatrix;
    mat4 LA = camera.viewMatrix;
    P.multiply(LA);
    P.copyIntoArray(_cameraTransform, 0);
  }
  context.setConstant('cameraTransform', _cameraTransform);
  context.setBlendState(_skyboxBlendState);
  context.setRasterizerState(_skinnedRasterizerState);
  context.setDepthState(_skinnedDepthState);
  context.setIndexBuffer(_skinnedMesh.indexArray);
  context.setVertexBuffers(0, [_skinnedMesh.vertexArray]);
  context.setInputLayout(_skinnedInputLayout);

  context.setTextures(0, [_assetManager.root.demoAssets.hellknight_body]);
  if (true) {
    for (int i = 0; i < _skinnedMesh.meshes.length; i++) {
      context.drawIndexed(_skinnedMesh.meshes[i]['count'], _skinnedMesh.meshes[i]['offset']);
    }
    return;
  }

  context.drawIndexed(_skinnedMesh.meshes[0]['count'], _skinnedMesh.meshes[0]['offset']);
  context.drawIndexed(_skinnedMesh.meshes[5]['count'], _skinnedMesh.meshes[5]['offset']);

  // Draw with face texture
  context.setTextures(0, [_assetManager.root.demoAssets.guard_face]);
  context.drawIndexed(_skinnedMesh.meshes[1]['count'], _skinnedMesh.meshes[1]['offset']);

  // Draw with helmet texture
  context.setTextures(0, [_assetManager.root.demoAssets.guard_helmet]);
  context.drawIndexed(_skinnedMesh.meshes[2]['count'], _skinnedMesh.meshes[2]['offset']);

  // Draw with iron grill texture
  context.setTextures(0, [_assetManager.root.demoAssets.iron_grill]);
  context.drawIndexed(_skinnedMesh.meshes[3]['count'], _skinnedMesh.meshes[3]['offset']);

  // Draw with round grill texture
  context.setTextures(0, [_assetManager.root.demoAssets.round_grill]);
  context.drawIndexed(_skinnedMesh.meshes[4]['count'], _skinnedMesh.meshes[4]['offset']);

}

main() {
  final String baseUrl = "${window.location.href.substring(0, window.location.href.length - "asset_pack.html".length)}";
  print(baseUrl);
  CanvasElement canvas = query(_canvasId);
  assert(canvas != null);

  // Create a GraphicsDevice
  _graphicsDevice = new GraphicsDevice(canvas);
  // Print out GraphicsDeviceCapabilities
  print(_graphicsDevice.capabilities);
  // Get a reference to the GraphicsContext
  _graphicsContext = _graphicsDevice.context;
  // Create a debug draw manager and initialize it
  _debugDrawManager = new DebugDrawManager(_graphicsDevice);

  // Set the canvas width and height to match the dom elements
  canvas.width = canvas.clientWidth;
  canvas.height = canvas.clientHeight;

  // Create the viewport
  _viewport = new Viewport('view', _graphicsDevice);
  _viewport.x = 0;
  _viewport.y = 0;
  _viewport.width = canvas.width;
  _viewport.height = canvas.height;

  // Create the camera
  camera.aspectRatio = canvas.width.toDouble()/canvas.height.toDouble();
  camera.position = new vec3.raw(2.0, 2.0, 2.0);
  camera.focusPosition = new vec3.raw(1.0, 1.0, 1.0);

  _assetManager = new AssetManager();
  registerSpectreWithAssetManager(_graphicsDevice, _assetManager);
  _gameLoop = new GameLoop(canvas);
  _gameLoop.onUpdate = gameFrame;
  _gameLoop.onRender = renderFrame;
  _gameLoop.onResize = resizeFrame;
  _assetManager.loadPack('demoAssets', '$baseUrl/assets.pack').then((assetPack) {
    // All assets are loaded.
    _setupSkybox();
    _setupSkinnedCharacter();
    _gameLoop.start();
  });
}

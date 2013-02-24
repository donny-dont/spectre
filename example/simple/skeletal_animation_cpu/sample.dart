/*
  Copyright (C) 2013 Spectre Authors

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

library skeletal_animation_cpu;

//---------------------------------------------------------------------
// Imports
//---------------------------------------------------------------------

import 'dart:html';
import 'dart:math' as Math;
import 'dart:async';
import 'package:property_map/property_map.dart';
import 'package:vector_math/vector_math.dart';
import 'package:game_loop/game_loop.dart';
import 'package:asset_pack/asset_pack.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_asset_pack.dart';

//---------------------------------------------------------------------
// Library sources
//---------------------------------------------------------------------

part 'ui.dart';

//---------------------------------------------------------------------
// Application
//---------------------------------------------------------------------

/// The sample application.
class Application {
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// The red value to clear the color buffer to.
  static const double _redClearColor = 248.0 / 255.0;
  /// The green value to clear the color buffer to.
  static const double _greenClearColor = 248.0 / 255.0;
  /// The blue value to clear the color buffer to.
  static const double _blueClearColor = 248.0 / 255.0;
  /// The alpha value to clear the color buffer to.
  static const double _alphaClearColor = 1.0;

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The [GraphicsDevice] used by the application.
  ///
  /// All [GraphicsResource]s are created through the [GraphicsDevice].
  GraphicsDevice _graphicsDevice;
  /// The [GraphicsContext] used by the application.
  ///
  /// The [GraphicsContext] is used to render the scene. All the rendering
  /// commands pass through the context.
  GraphicsContext _graphicsContext;
  /// The [AssetManager] used by the application.
  ///
  /// The [AssetManager] is used to import [GraphicsResource]s into the
  /// the application. Typically assets are imported by loading in a .pack
  /// file which contains references to the locations of the assets. Once
  /// loaded they can be used by the application.
  AssetManager _assetManager;

  //---------------------------------------------------------------------
  // Debug drawing member variables
  //---------------------------------------------------------------------

  /// Retained mode debug draw manager.
  ///
  /// Used to draw debugging information to the screen. In this sample the
  /// skeleton of the mesh is drawn by the [DebugDrawManager].
  DebugDrawManager _debugDrawManager;
  /// Whether debugging information should be drawn.
  ///
  /// If the debugging information is turned on in this sample the
  /// mesh's skeleton will be displayed.
  bool _drawDebugInformation = false;

  //---------------------------------------------------------------------
  // Rendering state member variables
  //---------------------------------------------------------------------

  /// The [Viewport] to draw to.
  Viewport _viewport;

  //---------------------------------------------------------------------
  // Camera member variables
  //---------------------------------------------------------------------

  /// The [Camera] being used to view the scene.
  Camera _camera;
  /// The [MouseKeyboardCameraController] which allows the movement of the [Camera].
  ///
  /// A [MouseKeyboardCameraController] provides a way to move the camera in the
  /// same way that a free-look FPS operates.
  MouseKeyboardCameraController _cameraController;
  /// The velocity with which the [CameraController] moves the camera forward/backward.
  double _forwardVelocity = 25.0;
  /// The velocity with which the [CameraController] moves the camera left/right.
  double _strafeVelocity = 25.0;

  //---------------------------------------------------------------------
  // Mesh drawing variables
  //---------------------------------------------------------------------

  /// The [SkinnedMesh] to animate and draw to the screen.
  SkinnedMesh _mesh;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [Application] class.
  ///
  /// The application is hosted within the [CanvasElement] specified in [canvas].
  Application(CanvasElement canvas) {
    // Create the GraphicsDevice using the CanvasElement
    _graphicsDevice = new GraphicsDevice(canvas);

    // Get the GraphicsContext from the GraphicsDevice
    _graphicsContext = _graphicsDevice.context;

    // Create the AssetManager and register Spectre specific resource loading
    _assetManager = new AssetManager();
    registerSpectreWithAssetManager(_graphicsDevice, _assetManager);

    // Create the Camera and the CameraController
    _camera = new Camera();
    _cameraController = new MouseKeyboardCameraController();
    _cameraController.forwardVelocity = _forwardVelocity;
    _cameraController.strafeVelocity = _strafeVelocity;

    // Create the viewport
    _viewport = new Viewport('Viewport', _graphicsDevice);

    // Resize the canvas using the offsetWidth/offsetHeight.
    //
    // The canvas width/height is not being explictly specified in the markup,
    // but the canvas needs to take up the entire contents of the window. The
    // stylesheet accomplishes this but the underlying canvas will default to
    // 300x150 which will produce a really low resolution image.
    int width = canvas.offsetWidth;
    int height = canvas.offsetHeight;

    canvas.width = width;
    canvas.height = height;

    // Call the onResize method which will update the viewport and camera
    onResize(width, height);
  }

  //---------------------------------------------------------------------
  // Public methods
  //---------------------------------------------------------------------

  /// Updates the application.
  ///
  /// Uses the current change in time, [dt].
  void onUpdate(double dt) {
    // Update the state of the CameraController
    Keyboard keyboard = _gameLoop.keyboard;

    _cameraController.forward     = keyboard.buttons[Keyboard.W].down;
    _cameraController.backward    = keyboard.buttons[Keyboard.S].down;
    _cameraController.strafeLeft  = keyboard.buttons[Keyboard.A].down;
    _cameraController.strafeRight = keyboard.buttons[Keyboard.D].down;

    if (_gameLoop.pointerLock.locked) {
      Mouse mouse = _gameLoop.mouse;

      _cameraController.accumDX = mouse.dx;
      _cameraController.accumDY = mouse.dy;
    }

    // Update the mesh
    //_mesh.update(dt);
  }

  /// Renders the scene.
  void onRender() {
    // Clear the color and depth buffer
    _graphicsContext.clearColorBuffer(
      _redClearColor,
      _greenClearColor,
      _blueClearColor,
      _alphaClearColor
    );
    _graphicsContext.clearDepthBuffer(1.0);

    // Reset the graphics context
    _graphicsContext.reset();

    // Set the renderer state
    _graphicsContext.setViewport(_viewport);

    // Render debugging information if requested
    if (_drawDebugInformation) {

    }
  }

  /// Resizes the application viewport.
  ///
  /// Changes the [Viewport]'s dimensions to the values contained in [width]
  /// and [height]. Additionally the [Camera]'s aspect ratio needs to be adjusted
  /// accordingly.
  ///
  /// This needs to occur whenever the underlying [CanvasElement] is resized,
  /// otherwise the rendered scene will be incorrect.
  void onResize(int width, int height) {
    // Resize the viewport
    _viewport.width = width;
    _viewport.height = height;

    // Change the aspect ratio of the camera
    _camera.aspectRatio = _viewport.aspectRation;
  }
}

//---------------------------------------------------------------------
// Global variables
//---------------------------------------------------------------------

/// Instance of the [Application].
Application _instance;
/// Instance of the [ApplicationControls].
ApplicationControls _applicationControls;
/// Instance of the [GameLoop] controlling the application flow.
GameLoop _gameLoop;
/// Identifier of the [CanvasElement] the application is rendering to.
final String _canvasId = '#backBuffer';

//---------------------------------------------------------------------
// GameLoop hooks
//---------------------------------------------------------------------

/// Callback for when the application should be updated.
void onFrame(GameLoop gameLoop) {
  _instance.onUpdate(gameLoop.dt);
}

/// Callback for when the application should render.
void onRender(GameLoop gameLoop) {
  _instance.onRender();
}

/// Callback for when the canvas is resized.
void onResize(GameLoop gameLoop) {
  _instance.onResize(gameLoop.width, gameLoop.height);
}

/// Callback for when the pointer lock changes.
///
/// Used to show/hide the options UI.
void onPointerLockChange(GameLoop gameLoop) {
  if (gameLoop.pointerLock.locked) {
    _applicationControls.hide();
  } else {
    _applicationControls.show();
  }
}

/// Entrypoint for the application.
void main() {
  // Get the canvas
  CanvasElement canvas = query(_canvasId);

  // Create the application
  _instance = new Application(canvas);

  // Create the application controls
  _applicationControls = new ApplicationControls();
  _applicationControls.show();

  // Hook up the game loop
  // The loop isn't started until the start method is called.
  _gameLoop = new GameLoop(canvas);
  _gameLoop.onResize = onResize;
  _gameLoop.onUpdate = onFrame;
  _gameLoop.onRender = onRender;
  _gameLoop.onPointerLockChange = onPointerLockChange;

  _gameLoop.start();
}

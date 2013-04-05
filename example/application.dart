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

library spectre_example;

//---------------------------------------------------------------------
// Imports
//---------------------------------------------------------------------

import 'dart:html';
import 'dart:math' as Math;
import 'dart:async';
import 'dart:typeddata';

import 'package:asset_pack/asset_pack.dart';
import 'package:game_loop/game_loop.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_asset_pack.dart';
import 'package:spectre/spectre_mesh.dart';
import 'package:vector_math/vector_math.dart';

//---------------------------------------------------------------------
// Shared sources
//---------------------------------------------------------------------

part 'shared/demo_screen.dart';

//---------------------------------------------------------------------
// SimpleGeometry sources
//---------------------------------------------------------------------

part 'simple/simple_geometry/simple_geometry_screen.dart';

//---------------------------------------------------------------------
// MeshLoading sources
//---------------------------------------------------------------------

part 'simple/mesh_loading/mesh_loading_screen.dart';

/// The sample application.
class Application {
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

  DemoScreen _currentScreen;

  int _width;
  int _height;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [Application] class.
  ///
  /// The application is hosted within the [CanvasElement] specified in [canvas].
  Application(CanvasElement canvas) {
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

    // Create the GraphicsDevice and attaches the AssetManager
    _createGraphicsDevice(canvas);

    // Create the rendering state
    _createRendererState();

    // Call the onResize method which will update the viewport and camera
    onResize(width, height);

    // Start loading the resources
    _onLoad();
  }

  /// Creates the [GraphicsDevice] and attaches the [AssetManager].
  void _createGraphicsDevice(CanvasElement canvas) {
    // Create the GraphicsDevice using the CanvasElement
    _graphicsDevice = new GraphicsDevice(canvas);

    // Get the GraphicsContext from the GraphicsDevice
    _graphicsContext = _graphicsDevice.context;

    // Create the AssetManager and register Spectre specific resource loading
    _assetManager = new AssetManager();
    registerSpectreWithAssetManager(_graphicsDevice, _assetManager);

    // Attach additional importer/loaders to the AssetManager
    //
    // The application uses config files to define behavior. These files
    // are just json data. So associate a TextLoader and a JsonImporter
    // to a 'config'
    _assetManager.loaders['config'] = new TextLoader();
    _assetManager.importers['config'] = new JsonImporter();
  }

  /// Creates the rendering state.
  void _createRendererState() {
  }

  /// Load the resources held in the .pack files.
  void _onLoad() {
    // Load the base pack
    _assetManager.loadPack('base', 'assets/base.pack').then((assetPack) {
      //_currentScreen = new MeshLoadingScreen(_graphicsDevice, _assetManager);
      _currentScreen = new SimpleGeometryScreen(_graphicsDevice, _assetManager);

      _currentScreen.onLoad().then((value) {
        _currentScreen.onResize(_width, _height);
        _gameLoop.start();
      });
    });
  }

  //---------------------------------------------------------------------
  // Public methods
  //---------------------------------------------------------------------

  /// Updates the application.
  ///
  /// Uses the current change in time, [dt].
  void onUpdate(double dt) {
    _currentScreen.onUpdate(dt);
  }

  /// Renders the scene.
  void onRender() {
    _currentScreen.onRender();
  }

  /// Resizes the application viewport.
  ///
  /// Changes the [Viewport]'s dimensions to the values contained in [width]
  /// and [height].
  ///
  /// This needs to occur whenever the underlying [CanvasElement] is resized,
  /// otherwise the rendered scene will be incorrect.
  void onResize(int width, int height) {
    // Resize the viewport
    _width = width;
    _height = height;
    //_viewport.width = width;
    //_viewport.height = height;
  }
}

//---------------------------------------------------------------------
// Global variables
//---------------------------------------------------------------------

/// Instance of the [Application].
Application _application;
/// Instance of the [GameLoop] controlling the application flow.
GameLoop _gameLoop;
/// Identifier of the [CanvasElement] the application is rendering to.
final String _canvasId = '#backBuffer';

//---------------------------------------------------------------------
// GameLoop hooks
//---------------------------------------------------------------------

/// Callback for when the application should be updated.
void onFrame(GameLoop gameLoop) {
  _application.onUpdate(gameLoop.dt);
}

/// Callback for when the application should render.
void onRender(GameLoop gameLoop) {
  _application.onRender();
}

/// Callback for when the canvas is resized.
void onResize(GameLoop gameLoop) {
  _application.onResize(gameLoop.width, gameLoop.height);
}

/// Callback for when the pointer lock changes.
///
/// Used to show/hide the options UI.
void onPointerLockChange(GameLoop gameLoop) {
/*
  if (gameLoop.pointerLock.locked) {
    _applicationControls.hide();
  } else {
    _applicationControls.show();
  }
*/
}

/// Entrypoint for the application.
void main() {
  // Get the canvas
  CanvasElement canvas = query(_canvasId);

  // Create the application
  _application = new Application(canvas);

  // Hook up the game loop
  // The loop isn't started until the start method is called.
  _gameLoop = new GameLoop(canvas);
  _gameLoop.onResize = onResize;
  _gameLoop.onUpdate = onFrame;
  _gameLoop.onRender = onRender;
  _gameLoop.onPointerLockChange = onPointerLockChange;
}

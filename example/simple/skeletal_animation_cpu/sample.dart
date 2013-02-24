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
// Application source
//---------------------------------------------------------------------

part 'ui.dart';

//---------------------------------------------------------------------
// Global variables
//---------------------------------------------------------------------

/// Instance of the [Application].
//Application _instance;
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
  //_instance.onUpdate(gameLoop.dt);
}

/// Callback for when the application should render.
void onRender(GameLoop gameLoop) {
  //_instance.onRender();
}

/// Callback for when the canvas is resized.
void onResize(GameLoop gameLoop) {

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
  // Create the application controls
  _applicationControls = new ApplicationControls();
  _applicationControls.show();

  // Get the canvas
  CanvasElement canvas = query(_canvasId);

  // Hook up the game loop
  // The loop isn't started until the start method is called.
  _gameLoop = new GameLoop(canvas);
  _gameLoop.onResize = onResize;
  _gameLoop.onUpdate = onFrame;
  _gameLoop.onRender = onRender;
  _gameLoop.onPointerLockChange = onPointerLockChange;
}

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

part of spectre_example;

abstract class DemoScreen {
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// The red value to clear the color buffer to.
  static const double _defaultRedClearColor = 248.0 / 255.0;
  /// The green value to clear the color buffer to.
  static const double _defaultGreenClearColor = 248.0 / 255.0;
  /// The blue value to clear the color buffer to.
  static const double _defaultBlueClearColor = 248.0 / 255.0;
  /// The alpha value to clear the color buffer to.
  static const double _defaultAlphaClearColor = 1.0;

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


  DemoScreen(GraphicsDevice graphicsDevice, AssetManager assetManager) {
    if (graphicsDevice == null) {
      throw new ArgumentError('The GraphicsDevice cannot be null');
    }
    if (assetManager == null) {
      throw new ArgumentError('The AssetManager cannot be null');
    }

    _graphicsDevice  = graphicsDevice;
    _graphicsContext = graphicsDevice.context;
    _assetManager    = assetManager;
  }

  /// Whether the screen is currently loaded.
  bool _isLoaded = false;

  /// Creates an instance of the [Screen] class.
  Screen();

  /// Sets up the [Screen] for the display.
  Future<bool> onLoad() {
    // Only load once
    if (_isLoaded) {
      return new Future.immediate(true);
    }

    // Attempt to load the screen
    Completer completer = new Completer();

    _onLoad().then((value) {
      _isLoaded = value;

      completer.complete(value);
    });

    return completer.future;
  }

  /// Unloads the [Screen] prior to deletion.
  void onUnload() {
    if (_isLoaded) {
      _onUnload();

      _isLoaded = false;
    }
  }

  void onUpdate(double dt);

  void onRender();

  Future<bool> _onLoad();
  void _onUnload();
}

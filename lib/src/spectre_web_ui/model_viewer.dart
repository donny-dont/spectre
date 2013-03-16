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

import 'dart:html';
import 'dart:async';
import 'package:web_ui/web_ui.dart';
import 'package:asset_pack/asset_pack.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_asset_pack.dart';
import 'package:vector_math/vector_math.dart';

class ModelViewerComponent extends WebComponent {
  //---------------------------------------------------------------------
  // Key codes
  //---------------------------------------------------------------------

  /// Move camera to the left.
  static const int _keyCodeA = 65;
  /// Move camera to the right.
  static const int _keyCodeD = 68;
  /// Move camera backwards.
  static const int _keyCodeS = 83;
  /// Move camera forward.
  static const int _keyCodeW = 87;
  /// Rotate camera to the right.
  static const int _keyCodeQ = 81;
  /// Rotate camera to the left.
  static const int _keyCodeE = 69;

  //---------------------------------------------------------------------
  // Default shader source
  //---------------------------------------------------------------------

  /// Default vertex shader source.
  ///
  /// Shader simply draws a textured mesh.
  static const String _defaultVertexShaderSource =
'''
precision highp float;

// Vertex attributes
attribute vec3 POSITION;
attribute vec3 NORMAL;

// Uniform variables
uniform float uTime;
uniform mat4 uModelMatrix;
uniform mat4 uModelViewMatrix;
uniform mat4 uModelViewProjectionMatrix;
uniform mat4 uProjectionMatrix;
uniform mat4 uNormalMatrix;

// Varying variables
// Allows communication between vertex and fragment stages
varying vec3 position;
varying vec3 normal;

void main() {
  vec4 vPosition4 = vec4(POSITION, 1.0);
  position = vec3(uModelViewMatrix * vPosition4);
  normal = normalize(mat3(uNormalMatrix) * NORMAL);
  gl_Position = uModelViewProjectionMatrix * vPosition4;
}
''';
  /// Default fragment shader source.
  ///
  /// Shader simply draws a textured mesh.
  static const String _defaultFragmentShaderSource =
'''
precision mediump float;

// Varying variables
// Allows communication between vertex and fragment stages
varying vec3 position;
varying vec3 normal;

// Constants
vec3 lightPosition = vec3(1.0, 1.0, 0.0);
vec3 lightIntensity = vec3(0.5, 0.5, 0.5);
vec3 kd = vec3(0.5, 0.5, 0.5);
vec3 ka = vec3(0.2, 0.2, 0.2);
vec3 ks = vec3(0.6, 0.6, 0.6);
float shininess = 64.0;

vec3 ads() {
  vec3 n = normalize(normal);
  vec3 s = normalize(lightPosition);
  vec3 v = normalize(-position);
  vec3 r = reflect(-s, n);

  return lightIntensity * 
    (ka +
     kd * max(dot(s, n), 0.0) +
     ks * pow(max(dot(r, v), 0.0), shininess));
}

void main() {
    gl_FragColor = vec4(ads(), 1.0);
}
''';

  //---------------------------------------------------------------------
  // Canvas related member variables
  //---------------------------------------------------------------------

  /// The width of the [ModelViewerComponent].
  ///
  /// Specifies the underlying [CanvasElement.width] for the 3D surface.
  ///
  /// Due to the flow of web-ui this has to be kept around rather
  /// than just using the [CanvasElement.width] property directly.
  int _width = 320;
  /// The last width of the [ModelViewerComponent].
  ///
  /// Used when toggling between fullscreen modes.
  int _lastWidth = 320;
  /// The height of the [ModelViewerComponent].
  ///
  /// Specifies the underlying [CanvasElement.width] for the 3D surface.
  ///
  /// Due to the flow of web-ui this has to be kept around rather
  /// than just using the [CanvasElement.width] property directly.
  int _height = 240;
  /// The last height of the [ModelViewerComponent].
  ///
  /// Used wen toggling between fullscreen mode.
  int _lastHeight = 240;
  /// The [CanvasElement] containing the [WebGLRenderingContext].
  CanvasElement _canvas;
  /// The time of the last frame
  double _lastFrameTime = 0.0;

  //---------------------------------------------------------------------
  // Spectre related member variables
  //---------------------------------------------------------------------

  /// Spectre graphics device.
  GraphicsDevice _graphicsDevice;
  /// Immediate rendering context.
  GraphicsContext _graphicsContext;
  /// [Viewport] for the window.
  Viewport _viewport;
  /// The [BlendState] to use when rendering the model.
  BlendState _blendState;
  /// The [DepthState] to use when rendering the model.
  DepthState _depthState;
  /// The [RasterizerState] to use when rendering the model.
  RasterizerState _rasterizerState;
  /// The [ShaderProgram] to use when rendering the model.
  ShaderProgram _shaderProgram;
  /// The [VertexShader] attached to the [ShaderProgram].
  VertexShader _vertexShader;
  /// The [FragmentShader] attached to the [ShaderProgram].
  FragmentShader _fragmentShader;
  /// The [InputLayout] of the model.
  InputLayout _inputLayout;
  /// The model to draw.
  SpectreMesh _model;
  /// Whether the model is a skinned mesh or indexed mesh.
  bool _isSkinnedMesh;

  /// Resource handler for the game.
  ///
  /// All resources, texture, mesh, shader, etc, that require loading should
  /// go through the resource handler. This ensures that resources are not
  /// loaded redundantly.
  AssetManager _assetManager;

  String _modelAssetName = 'model';

  //---------------------------------------------------------------------
  // Transform variables
  //---------------------------------------------------------------------

  /// Camera
  Camera _camera;
  /// Camera controller
  FpsFlyCameraController _cameraController;

  /// Transformation for the mesh.
  mat4 _modelMatrix;
  /// A typed array containing the transformation.
  Float32Array _modelMatrixArray;

  //---------------------------------------------------------------------
  // Builtin shader uniform variables
  //---------------------------------------------------------------------

  /// A [Float32Array] containing the model/view matrix.
  Float32Array _modelViewMatrixArray;
  /// A [Float32Array] containing the model/view/projection matrix.
  Float32Array _modelViewProjectionMatrixArray;
  /// A [Float32Array] containing the projection matrix.
  Float32Array _projectionMatrixArray;
  /// A [Float32Array] containing the normal matrix.
  Float32Array _normalMatrixArray;

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The width of the [ModelViewerComponent].
  ///
  /// Specifies the underlying [CanvasElement.width] for the 3D surface.
  int get width => _width;
  set width(int value) {
    _width = value;

    _resize();
  }

  /// The height of the [ModelViewerComponent].
  ///
  /// Specifies the underlying [CanvasElement.height] for the 3D surface.
  int get height => _height;
  set height(int value) {
    _height = value;

    _resize();
  }

  /// Whether the [ModelViewer] is in fullscreen mode.
  bool get fullscreen => _canvas == document.webkitFullscreenElement;
  set fullscreen(bool value) {
    if (fullscreen != value) {
      if (value) {
        _canvas.requestFullscreen();
      } else {
        document.webkitExitFullscreen();
      }
    }
  }

  /// Whether the [ModelViewer] has control of the mouse pointer.
  bool get pointerLocked => _canvas == document.webkitPointerLockElement;
  set pointerLocked(bool value) {
    if (pointerLocked != value) {
      if (value) {
        _canvas.requestPointerLock();
      } else {
        document.webkitExitPointerLock();
      }
    }
  }

  /// The [BlendState] to use when rendering the model.
  BlendState get blendState => _blendState;
  set blendState(BlendState value) { _blendState = value; }

  /// The [DepthState] to use when rendering the model.
  DepthState get depthState => _depthState;
  set depthState(DepthState value) { _depthState = value; }

  /// The [RasterizerState] to use when rendering the model.
  RasterizerState get rasterizerState => _rasterizerState;
  set rasterizerState(RasterizerState value) { _rasterizerState = value; }

  //---------------------------------------------------------------------
  // WebComponent methods
  //---------------------------------------------------------------------

  /// Invoked when this component gets inserted in the DOM tree.
  ///
  /// At this point the [CanvasElement] can be queried and the [GraphicsDevice]
  /// can be initialized. From here a model can be displayed.
  void inserted() {
    super.inserted();

    // Get the canvas
    _canvas = query('canvas');

    // Create the Spectre device
    _graphicsDevice = new GraphicsDevice(_canvas);
    _graphicsContext = _graphicsDevice.context;

    // Create the asset manager
    _assetManager = new AssetManager();
    registerSpectreWithAssetManager(_graphicsDevice, _assetManager);

    // Create the Spectre state information
    // Use the defaults in the pipeline
    _viewport = new Viewport('Viewport', _graphicsDevice);

    _blendState = new BlendState.opaque('BlendState', _graphicsDevice);
    _depthState = new DepthState.depthWrite('DepthState', _graphicsDevice);
    _rasterizerState = new RasterizerState.cullClockwise('RasterizerState', _graphicsDevice);

    // Create the default vertex shader
    _vertexShader = new VertexShader('VertexShader', _graphicsDevice);
    _vertexShader.source = _defaultVertexShaderSource;
    _vertexShader.compile();

    _fragmentShader = new FragmentShader('FragmentShader', _graphicsDevice);
    _fragmentShader.source = _defaultFragmentShaderSource;
    _fragmentShader.compile();

    _shaderProgram = new ShaderProgram('ShaderProgram', _graphicsDevice);
    _shaderProgram.vertexShader = _vertexShader;
    _shaderProgram.fragmentShader = _fragmentShader;
    _shaderProgram.link();

    // Create the model
    _model = new SingleArrayIndexedMesh('Mesh', _graphicsDevice);
    _isSkinnedMesh = false;

    // Create the input layout
    _inputLayout = new InputLayout('InputLayout', _graphicsDevice);
    _inputLayout.mesh = _model;
    _inputLayout.shaderProgram = _shaderProgram;

    // Create the camera
    _camera = new Camera();
    _cameraController = new FpsFlyCameraController();

    // The camera is located -2.5 units along the Z axis.
    _camera.position = new vec3.raw(0.0, 0.0, -2.5);
    // The camera is pointed at the origin.
    _camera.focusPosition = new vec3.raw(0.0, 0.0, 0.0);

    // Create the model matrix
    // Center it at 0.0, 0.0, 0.0
    _modelMatrix = new mat4.identity();
    _modelMatrixArray = new Float32Array(16);

    // Create the camera's matrices
    _modelViewMatrixArray = new Float32Array(16);
    _modelViewProjectionMatrixArray = new Float32Array(16);
    _projectionMatrixArray = new Float32Array(16);
    _normalMatrixArray = new Float32Array(16);

    // Create event hooks
    _canvas.onClick.listen(_onClick);
    _canvas.onKeyDown.listen(_onKeyboardDown);
    _canvas.onKeyUp.listen(_onKeyboardUp);
    _canvas.onMouseMove.listen(_onMouseMove);
    _canvas.onFullscreenChange.listen(_onFullscreenChange);

    // Resize the window
    // This will setup the viewport and canvas size
    _resize();
  }

  //---------------------------------------------------------------------
  // Public methods
  //---------------------------------------------------------------------

  /// Animates the [ModelViewer]'s scene, using the current [time].
  void update(double time) {
    // Get the change in time
    double dt = (time - _lastFrameTime) * 0.001;
    _lastFrameTime = time;

    if (_isSkinnedMesh) {
      SkinnedMesh model = _model as SkinnedMesh;

      model.update(dt);
    }

    // Update the camera
    _cameraController.updateCamera(dt, _camera);

    // Rotate the model
    double angle = 0.0;//dt * Math.PI;

    mat4 rotation = new mat4.rotationX(angle);
    _modelMatrix.multiply(rotation);
    _modelMatrix.copyIntoArray(_modelMatrixArray);

    // Compute the builtin uniforms
    mat4 modelView = _camera.viewMatrix * _modelMatrix;
    modelView.copyIntoArray(_modelViewMatrixArray);

    mat4 projection = _camera.projectionMatrix;
    projection.copyIntoArray(_projectionMatrixArray);

    mat4 modelViewProjection = projection * modelView;
    modelViewProjection.copyIntoArray(_modelViewProjectionMatrixArray);

    _camera.copyProjectionMatrixIntoArray(_projectionMatrixArray);
    _camera.copyNormalMatrixIntoArray(_normalMatrixArray);
  }

  /// Renders the [ModelViewer]'s scene.
  ///
  /// Should be called after the [update] method.
  void draw() {
    // Clear the buffers
    _graphicsContext.clearColorBuffer(0.0, 0.0, 0.0, 1.0);
    _graphicsContext.clearDepthBuffer(1.0);
    _graphicsContext.reset();

    // Set the viewport
    _graphicsContext.setViewport(_viewport);

    // Set associated state
    _graphicsContext.setBlendState(_blendState);
    _graphicsContext.setRasterizerState(_rasterizerState);
    _graphicsContext.setDepthState(_depthState);

    // Set the shader program
    _graphicsContext.setShaderProgram(_shaderProgram);

    // Set the uniforms
    _graphicsContext.setConstant('uTime', _lastFrameTime);
    _graphicsContext.setConstant('uModelMatrix', _modelMatrixArray);
    _graphicsContext.setConstant('uModelViewMatrix', _modelViewMatrixArray);
    _graphicsContext.setConstant('uModelViewProjectionMatrix', _modelViewProjectionMatrixArray);
    _graphicsContext.setConstant('uProjectionMatrix', _projectionMatrixArray);
    _graphicsContext.setConstant('uNormalMatrix', _normalMatrixArray);

    // Set the input layout
    _graphicsContext.setInputLayout(_inputLayout);

    // Draw the mesh
    if (_isSkinnedMesh) {
      SkinnedMesh model = _model as SkinnedMesh;

      _graphicsContext.setVertexBuffers(0, [model.vertexArray]);
      _graphicsContext.setIndexBuffer(model.indexArray);
      _graphicsContext.setPrimitiveTopology(GraphicsContext.PrimitiveTopologyTriangles);

      // Draw each part of the mesh
      int meshCount = model.meshes.length;

      for (int i = 0; i < meshCount; ++i) {
        Map meshData = model.meshes[i];

        _graphicsContext.drawIndexed(meshData['count'], meshData['offset']);
      }
    } else {
      SingleArrayIndexedMesh model = _model as SingleArrayIndexedMesh;

      _graphicsContext.setIndexedMesh(model);
      _graphicsContext.drawIndexedMesh(model);
    }
  }

  /// Loads the model at the specified [url].
  void loadModelFromUrl(String url, bool skinned) {
    if (_assetManager.root[_modelAssetName] != null) {
      _assetManager.root.deregisterAsset(_modelAssetName);
    }

    String type = skinned ? 'json' : 'mesh';
    Future<Asset> assetRequest = _assetManager.loadAndRegisterAsset(_modelAssetName, url, type, {}, {});

    assetRequest.then((asset) {
      if (asset == null) {
        print('No model');
        return;
      }

      if (skinned) {
        // Import the model
        _model = importSkinnedMesh('SkinnedMesh', _graphicsDevice, asset.imported);
      } else {
        // Update the model
        _model = asset.imported;
     }
      _isSkinnedMesh = skinned;

      // Reset the layout
      _inputLayout.mesh = _model;
    });
  }

  //---------------------------------------------------------------------
  // Private methods
  //---------------------------------------------------------------------

  /// Resizes the [ModelViewer].
  ///
  /// Resizes the underlying [CanvasElement]. Also resizes the associated
  /// [Viewport] used for rendering.
  void _resize() {
    if (_canvas != null) {
      _canvas.width = _width;
      _canvas.height = _height;

      _viewport.width = _width;
      _viewport.height = _height;

      _camera.aspectRatio = _width / _height;
    }
  }

  //---------------------------------------------------------------------
  // Event handlers
  //---------------------------------------------------------------------

  /// Callback for when the [CanvasElement] is clicked.
  ///
  /// Used to request a pointer lock.
  void _onClick(_) {
    pointerLocked = true;
  }

  /// Responds to key down events.
  void _onKeyboardDown(KeyboardEvent event) {
    if (!pointerLocked) {
      return;
    }

    switch (event.keyCode) {
      case _keyCodeA: _cameraController.strafeLeft  = true; break;
      case _keyCodeD: _cameraController.strafeRight = true; break;
      case _keyCodeS: _cameraController.backward    = true; break;
      case _keyCodeW: _cameraController.forward     = true; break;
    }
  }

  /// Responds to key up events.
  void _onKeyboardUp(KeyboardEvent event)
  {
    switch (event.keyCode) {
      case _keyCodeA: _cameraController.strafeLeft  = false; break;
      case _keyCodeD: _cameraController.strafeRight = false; break;
      case _keyCodeS: _cameraController.backward    = false; break;
      case _keyCodeW: _cameraController.forward     = false; break;
    }
  }

  /**
   * Responds to mouse move events
   */
  void _onMouseMove(MouseEvent event)
  {
    if (pointerLocked) {
      _cameraController.accumDX += event.movementX;
      _cameraController.accumDY += event.movementY;
    }
  }

  /// Callback for when a request to change the fullscreen state occurs.
  void _onFullscreenChange(_) {
    if (document.webkitIsFullScreen) {
      // Save off the old values
      _lastWidth = _canvas.width;
      _lastHeight = _canvas.height;

      // Expand to screen size
      Screen screen = window.screen;
      _width = screen.width;
      _height = screen.height;
    } else {
      // Restore old values
      _width = _lastWidth;
      _height = _lastHeight;
    }

    _resize();
  }
}

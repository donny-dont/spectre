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
attribute vec3 vPosition;
attribute vec3 vNormal;

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
  vec4 vPosition4 = vec4(vPosition, 1.0);
  position = vec3(uModelViewMatrix * vPosition4);
  normal = normalize(mat3(uNormalMatrix) * vNormal);
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
  GraphicsContext _context;
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

  /// Resource handler for the game.
  ///
  /// All resources, texture, mesh, shader, etc, that require loading should
  /// go through the resource handler. This ensures that resources are not
  /// loaded redundantly.
  AssetManager _assetManager;
  int _meshCount = 0;

  //---------------------------------------------------------------------
  // Transform variables
  //---------------------------------------------------------------------

  /// Camera
  Camera _camera;
  /// Camera controller
  MouseKeyboardCameraController _cameraController;

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

    // Create the asset manager
    _assetManager = new AssetManager();
    registerSpectreWithAssetManager(_graphicsDevice, _assetManager);

    // Create the Spectre device
    _graphicsDevice = new GraphicsDevice(_canvas);
    _context = _graphicsDevice.context;

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

    // Create the input layout
    _inputLayout = new InputLayout('InputLayout', _graphicsDevice);
    _inputLayout.mesh = _model;
    _inputLayout.shaderProgram = _shaderProgram;

    // Create the camera
    _camera = new Camera();
    _cameraController = new MouseKeyboardCameraController();

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
    _context.clearColorBuffer(0.0, 0.0, 0.0, 1.0);
    _context.clearDepthBuffer(1.0);
    _context.reset();

    // Set the viewport
    _context.setViewport(_viewport);

    // Set associated state
    _context.setBlendState(_blendState);
    _context.setRasterizerState(_rasterizerState);
    _context.setDepthState(_depthState);

    // Set the shader program
    _context.setShaderProgram(_shaderProgram);

    // Set the uniforms
    _context.setConstant('uTime', _lastFrameTime);
    _context.setConstant('uModelMatrix', _modelMatrixArray);
    _context.setConstant('uModelViewMatrix', _modelViewMatrixArray);
    _context.setConstant('uModelViewProjectionMatrix', _modelViewProjectionMatrixArray);
    _context.setConstant('uProjectionMatrix', _projectionMatrixArray);
    _context.setConstant('uNormalMatrix', _normalMatrixArray);

    // Draw the mesh
    _context.setInputLayout(_inputLayout);
    _context.setIndexedMesh(_model);
    _context.drawIndexedMesh(_model);
  }

  /// Loads the model at the specified [url].
  void loadModelFromUrl(String url) {
    /*
    _assetManager.register
    ResourceBase meshResource = _resourceManager.registerResource(url);
    //Asset asset = _assetManager.registerAssetAtPath();


    _resourceManager.addEventCallback(meshResource, ResourceEvents.TypeUpdate, (type, resource) {
      MeshResource mesh = resource;

      // Update the layout
      Map layout = mesh.meshData['meshes'][0]['attributes'];

      layout.forEach((key, value) {
        String attributeName;

        // Convert to the proper attribute names
        switch (key) {
          case 'POSITION' : attributeName = 'vPosition' ; break;
          case 'NORMAL'   : attributeName = 'vNormal'   ; break;
          case 'BITANGENT': attributeName = 'vBitangent'; break;
          case 'TANGENT'  : attributeName = 'vTangent'  ; break;
          case 'TEXCOORD0': attributeName = 'vTexCoord0'; break;
          default: throw new FallThroughError();
        }

        // Create the associated MeshAttribute
        SpectreMeshAttribute attribute =
          new SpectreMeshAttribute(
            attributeName,
            value['type'],
            value['numElements'],
            value['offset'],
            value['stride'],
            value['normalized']
          );

        _model.attributes[attributeName] = attribute;
      });

      // Update the model
      _model.vertexArray.uploadData(mesh.vertexArray, SpectreBuffer.UsageStatic);
      _model.indexArray.uploadData(mesh.indexArray, SpectreBuffer.UsageStatic);
      _model.count = mesh.numIndices;

      // Reset the layout
      _inputLayout.mesh = _model;
    });

    _resourceManager.loadResource(meshResource);
    */
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

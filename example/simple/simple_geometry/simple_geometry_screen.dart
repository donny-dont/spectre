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

/// Displays a simple geometry using the mesh library.
///
/// Shows how standard mesh types can be created and displayed within
/// an application.
class SimpleGeometryScreen extends DemoScreen {
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
  /// The [FpsFlyCameraController] which allows the movement of the [Camera].
  ///
  /// A [FpsFlyCameraController] provides a way to move the camera in the
  /// same way that a free-look FPS operates.
  FpsFlyCameraController _cameraController;
  /// The Model-View-Projection matrix.
  mat4 _modelViewProjectionMatrix;
  /// [Float32Array] storage for the Model-View matrix.
  Float32Array _modelViewMatrixArray;
  /// [Float32Array] storage for the Model-View-Projection matrix.
  Float32Array _modelViewProjectionMatrixArray;
  /// [Float32Array] storage for the normal matrix.
  Float32Array _normalMatrixArray;

  //---------------------------------------------------------------------
  // Mesh drawing variables
  //---------------------------------------------------------------------

  /// The [ShaderProgram] to use to draw the mesh.
  ///
  /// The models all contain a normal and specular map. The [ShaderProgram] uses the
  /// normal map to add additional detail to the surface, and the specular map to
  /// provide a variable shininess, which is used in Phong lighting, across the mesh.
  ShaderProgram _shaderProgram;
  /// The [Mesh] to draw to the screen.
  Mesh _boxMesh;
  Mesh _sphereMesh;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [SimpleGeometryScreen] class.
  SimpleGeometryScreen(GraphicsDevice graphicsDevice, AssetManager assetManager)
    : super(graphicsDevice, assetManager);

  //---------------------------------------------------------------------
  // Loading methods
  //---------------------------------------------------------------------

  Future<bool> _onLoad() {
    // Create the rendering state
    _createRendererState();

    // Create the Camera and the CameraController
    _createCamera();

    // Create the Mesh and retrieve the ShaderProgram
    _createMesh();

    // Ready to display
    return new Future.immediate(true);
  }

  /// Creates the rendering state.
  void _createRendererState() {
    // Create the Viewport
    _viewport = new Viewport('Viewport', _graphicsDevice);

    // By default the rendering pipeline has alpha blending turned off.
    // Because there is no alpha blending required there is no reason to
    // create and explictly apply a BlendState while rendering.

    // By default the rendering pipeline has the depth buffer enabled and
    // set to writeable. Because of this there is no reason to create and
    // explcitly apply a DepthState while rendering.

    // By default the rendering pipeline has back facing polygons being
    // culled. Because of this there is no reason to create and explicitly
    // apply a RasterizerState while rendering.
  }

  /// Create the [Camera] and the [CameraController] to position it.
  void _createCamera() {
    // Create the Camera
    _camera = new Camera();
    _camera.position = new vec3.raw(0.0, 0.0, 5.0);
    _camera.focusPosition = new vec3.raw(0.0, 0.0, 0.0);

    // Create the CameraController and set the velocity of the movement
    _cameraController = new FpsFlyCameraController();
    _cameraController.forwardVelocity = 5.0;
    _cameraController.strafeVelocity = 5.0;

    // Create the mat4 holding the Model-View-Projection matrix
    _modelViewProjectionMatrix = new mat4();

    // Create the Float32Arrays that store the constant values for the matrices
    _modelViewMatrixArray = new Float32Array(16);
    _modelViewProjectionMatrixArray = new Float32Array(16);
    _normalMatrixArray = new Float32Array(16);
  }

  /// Create the mesh to display.
  void _createMesh() {
    // Create a box mesh
    _boxMesh = _createBoxMesh();
    
    // Create a sphere mesh
    _sphereMesh = _createSphereMesh();

    // Get the ShaderProgram to render with.
    //
    // The shader to use is shared between multiple examples, and is loaded by
    // the Application at startup into the 'base' pack. The shader can be accessed
    // through the [] operator using the format 'packName.resourceName'.
    _shaderProgram = _assetManager.root['base.solidLightingShader'];
  }

  /// Creates a box mesh for display.
  Mesh _createBoxMesh() {
    // A box mesh can be created through a BoxGenerator.
    //
    // There are helper methods that can be used when creating a single mesh.
    // When creating a large number of boxes a BoxGenerator should be created and
    // used to create all the boxes.
    //
    // Create a unit cube centered at the origin.
    vec3 extents = new vec3.raw(1.0, 1.0, 1.0);
    vec3 center  = new vec3.raw(0.0, 0.0, 0.0);

    InputLayoutElement positionElement = new InputLayoutElement(0, 1,  0, 12, GraphicsDevice.DeviceFormatFloat3);
    InputLayoutElement normalElement   = new InputLayoutElement(0, 0, 12, 24, GraphicsDevice.DeviceFormatFloat3);

    List<InputLayoutElement> elements = [positionElement, normalElement];

    return BoxGenerator.createBox('BoxGeometry', _graphicsDevice, elements, extents, center);
  }
  
  /// Creates a box mesh for display.
  Mesh _createSphereMesh() {
    // A sphere mesh can be created through a SphereGenerator.
    //
    // There are helper methods that can be used when creating a single mesh.
    // When creating a large number of spheres a SphereGenerator should be created and
    // used to create all the spheres.
    //
    // Create a unit sphere
    num radius = 1.0;
    vec3 center  = new vec3.raw(2.0, 0.0, 0.0);

    InputLayoutElement positionElement = new InputLayoutElement(0, 1,  0, 12, GraphicsDevice.DeviceFormatFloat3);
    InputLayoutElement normalElement   = new InputLayoutElement(0, 0, 12, 24, GraphicsDevice.DeviceFormatFloat3);

    List<InputLayoutElement> elements = [positionElement, normalElement];

    return SphereGenerator.createSphere('SphereGeometry', _graphicsDevice, elements, radius, center);
  }

  //---------------------------------------------------------------------
  // Unloading methods
  //---------------------------------------------------------------------

  void _onUnload() {
    // Destroy the rendering state
    _destroyRendererState();

    // Destroy the Camera and the CameraController
    _destroyCamera();

    // Destroy the mesh
    _destroyMesh();
  }

  void _destroyRendererState() {
    // Dispose of the Viewport
    _viewport.dispose();
    _viewport = null;
  }

  void _destroyCamera() {
    // Mark the Camera for deletion
    _camera = null;

    // Mark the CameraController for deletion
    _cameraController = null;

    // Mark the Model-View-Projection matrix for deletion
    _modelViewProjectionMatrix = null;

    // Mark the Float32Arrays for deletion
    _modelViewMatrixArray = null;
    _modelViewProjectionMatrixArray = null;
    _normalMatrixArray = null;
  }

  void _destroyMesh() {
    // Dispose of the Box Mesh
    _boxMesh.dispose();
    _boxMesh = null;
    
    // Dispose of the Sphere Mesh
    _sphereMesh.dispose();
    _sphereMesh = null;

    // The ShaderProgram is contained within the base AssetPack which is
    // potentially shared. Just set this to null to remove the reference.
    _shaderProgram = null;
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

    _cameraController.updateCamera(dt, _camera);

    // Get the current model-view-projection matrix
    //
    // Start off by copying the projection matrix into the matrix.
    _camera.copyProjectionMatrix(_modelViewProjectionMatrix);

    // Multiply the projection matrix by the view matrix to combine them.
    //
    // The mathematical operators in Dart Vector Math will end up creating
    // a new object. Rather than using * a self multiply is used. This is to
    // avoid creating additional objects. As a general rule with a garbage
    // collected language objects should be reused whenever possible.
    _modelViewProjectionMatrix.multiply(_camera.viewMatrix);

    // At this point we actually have the Model-View-Projection matrix. This
    // is because the model matrix is currently the identity matrix. The model
    // has no rotation, no scaling, and is sitting at (0, 0, 0).

    // Copy the Model-View-Projection matrix into a Float32Array so it can be
    // passed in as a constant to the ShaderProgram.
    _modelViewProjectionMatrix.copyIntoArray(_modelViewProjectionMatrixArray);

    // Copy the View matrix from the camera into the Float32Array.
    _camera.copyViewMatrixIntoArray(_modelViewMatrixArray);

    // Copy the Normal matrix from the camera into the Float32Array.
    _camera.copyNormalMatrixIntoArray(_normalMatrixArray);
  }

  /// Renders the scene.
  void onRender() {
    // Clear the color and depth buffer
    _graphicsContext.clearColorBuffer(
      DemoScreen._defaultRedClearColor,
      DemoScreen._defaultGreenClearColor,
      DemoScreen._defaultBlueClearColor,
      DemoScreen._defaultAlphaClearColor
    );
    _graphicsContext.clearDepthBuffer(1.0);

    // Reset the graphics context
    _graphicsContext.reset();

    // Set the renderer state
    _graphicsContext.setViewport(_viewport);

    // Set the shader program
    _graphicsContext.setShaderProgram(_shaderProgram);

    // The matrices are the same for the drawing of each part of the mesh so
    // they only need to be set once.
    _graphicsContext.setConstant('uModelViewMatrix', _modelViewMatrixArray);
    _graphicsContext.setConstant('uModelViewProjectionMatrix', _modelViewProjectionMatrixArray);
    _graphicsContext.setConstant('uNormalMatrix', _normalMatrixArray);

    // Set and draw the box mesh
    _graphicsContext.setMeshNew(_boxMesh);
    _graphicsContext.drawMeshNew(_boxMesh);
    
    // Set and draw the sphere mesh
    _graphicsContext.setMeshNew(_sphereMesh);
    _graphicsContext.drawMeshNew(_sphereMesh);
  }

  void onResize(int width, int height) {
    // Resize the viewport
    _viewport.width = width;
    _viewport.height = height;

    // Change the aspect ratio of the camera
    _camera.aspectRatio = _viewport.aspectRatio;
  }
}

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

part of spectre;

/// Format describing a vertex buffer element
class DeviceFormat {
  final int type;
  final int count;
  final bool normalized;
  const DeviceFormat(this.type, this.count, this.normalized);
  String toString() {
    return '($type, $count, $normalized)';
  }
}

/// Spectre GPU Device

/// All GPU resources are created and destroyed through a Device.

/// Each resource requires a unique name.

/// An existing resource can be looked up using its name.
class GraphicsDevice {
  static const DeviceFormat DeviceFormatFloat1 =
                    const DeviceFormat(WebGL.FLOAT, 1, false);
  static const DeviceFormat DeviceFormatFloat2 =
                    const DeviceFormat(WebGL.FLOAT, 2, false);
  static const DeviceFormat DeviceFormatFloat3 =
                    const DeviceFormat(WebGL.FLOAT, 3, false);
  static const DeviceFormat DeviceFormatFloat4 =
                    const DeviceFormat(WebGL.FLOAT, 4, false);

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The [CanvasElement] containing the surface to draw to.
  CanvasElement _surface;
  /// The [WebGL.RenderingContext] to use.
  WebGL.RenderingContext _gl;
  /// The [WebGL.OesVertexArrayObject] extension.
  ///
  /// Used to interact with vertex array objects.
  WebGL.OesVertexArrayObject _vao;
  /// The [GraphicsContext] associated with the device.
  ///
  /// This functions as an immediate context meaning all calls are sent directly
  /// to the GPU rather than creating a command list that is then processed.
  GraphicsContext _context;
  /// The [GraphicsDeviceCapabilites] describing what GPU features are
  /// available.
  GraphicsDeviceCapabilities _capabilities;
  /// The currently bound resources.
  ///
  /// Used to keep track of the resources created through the [GraphicsDevice].
  /// Each resource is referred to by its name.
  final Set<DeviceChild> children = new Set<DeviceChild>();

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Initializes an instance of the [GraphicsDevice] class.
  ///
  /// A [WebGLRenderingContext] is created from the given [surface]. Additionally an
  /// optional instance of [GraphicsDeviceConfig] can be passed in to control the creation
  /// of the underlying frame buffer.
  GraphicsDevice(CanvasElement surface, [GraphicsDeviceConfig config = null]) {
    assert(surface != null);
    _surface = surface;

    // Get the WebGL context
    if (config == null) {
      config = new GraphicsDeviceConfig();
    }

    _gl = surface.getContext3d(stencil: config.stencilBuffer);

    if (_gl == null) {
      throw new UnsupportedError('WebGL not available');
    }

    // Query the device capabilities
    _capabilities = new GraphicsDeviceCapabilities._fromContext(_gl);
    // \todo REMOVE This should go away once extensions are fully supported
    print(_capabilities);

    // Create the VAO extension if present
    if (_capabilities.hasVertexArrayObjects) {
      _vao = GraphicsDeviceCapabilities._getExtension(_gl, 'OES_vertex_array_object');
    }

    // Create the associated GraphicsContext
    _context = new GraphicsContext(this);

    RenderTarget._systemRenderTarget = new RenderTarget.systemTarget(
        'WebGLFrontBuffer',
        this);
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  // \TODO: REMOVE
  WebGL.RenderingContext get gl => _gl;

  /// The [GraphicsContext] associated with the device.
  ///
  /// This functions as an immediate context meaning all calls are sent directly
  /// to the GPU rather than creating a command list that is then processed.
  GraphicsContext get context => _context;

  /// The [GraphicsDeviceCapabilites] describing what GPU features are
  /// available.
  GraphicsDeviceCapabilities get capabilities => _capabilities;

  /// The width of the drawing surface.
  int get surfaceWidth => _surface.width;

  /// The height of the drawing surface.
  int get surfaceHeight => _surface.height;

  /// The actual width of the drawing buffer.
  ///
  /// This may differ from the [surfaceWidth] if the implementation is unable
  /// to satisfy the requested width.
  int get frontBufferWidth => _gl.drawingBufferWidth;

  /// The actual height of the drawing buffer.
  ///
  /// This may differ from the [surfaceHeight] if the implementation is unable
  /// to satisfy the requested height.
  int get frontBufferHeight => _gl.drawingBufferHeight;

  //---------------------------------------------------------------------
  // GraphicsResource methods
  //---------------------------------------------------------------------

  void _addChild(DeviceChild child) {
    if (children.contains(child)) {
      throw new StateError('$child is already registered.');
    }
    children.add(child);
  }

  void _removeChild(DeviceChild child) {
    if (children.contains(child) == false) {
      throw new StateError('$child is not registered');
    }
    children.remove(child);
  }

  //---------------------------------------------------------------------
  // Creation methods
  //---------------------------------------------------------------------

  void _createMesh(Mesh mesh) {
    if (_vao != null) {
      print('Can create VAO!');
    }
  }

  void _destroyMesh(Mesh mesh) {
    if (_vao != null) {

    }
  }
}

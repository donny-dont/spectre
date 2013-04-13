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


  CanvasElement _surface;
  GraphicsContext _context;
  GraphicsContext get context => _context;

  GraphicsDeviceCapabilities _capabilities;
  GraphicsDeviceCapabilities get capabilities => _capabilities;

  WebGL.RenderingContext _gl;
  WebGL.RenderingContext get gl => _gl;

  int get canvasWidth => _surface.width;
  int get canvasHeight => _surface.height;
  int get frontBufferWidth => _gl.drawingBufferWidth;
  int get frontBufferHeight => _gl.drawingBufferHeight;

  final Set<DeviceChild> children = new Set<DeviceChild>();
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

  void _drawSquare(CanvasRenderingContext2D context2d, int x, int y, int w, int h) {
    context2d.save();
    context2d.beginPath();
    context2d.translate(x, y);
    context2d.fillStyle = "#656565";
    context2d.fillRect(0, 0, w, h);
    context2d.restore();
  }

  void _drawGrid(CanvasRenderingContext2D context2d, int width, int height, int horizSlices, int vertSlices) {
    int sliceWidth = width ~/ horizSlices;
    int sliceHeight = height ~/ vertSlices;
    int sliceHalfWidth = sliceWidth ~/ 2;
    for (int i = 0; i < horizSlices; i++) {
      for (int j = 0; j < vertSlices; j++) {
        if (j % 2 == 0) {
          _drawSquare(context2d, i * sliceWidth, j * sliceHeight, sliceHalfWidth, sliceHeight);
        } else {
          _drawSquare(context2d, i * sliceWidth + sliceHalfWidth, j * sliceHeight, sliceHalfWidth, sliceHeight);
        }
      }
    }
  }

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
    _capabilities = new GraphicsDeviceCapabilities._fromContext(gl);
    // \todo REMOVE This should go away once extensions are fully supported
    print(_capabilities);

    // Create the associated GraphicsContext
    _context = new GraphicsContext(this);
    RenderTarget._systemRenderTarget = new RenderTarget.systemTarget(
        'WebGLFrontBuffer',
        this);
  }

  void _createMesh(Mesh mesh) {

  }

  void _deleteMesh(Mesh mesh) {

  }
}

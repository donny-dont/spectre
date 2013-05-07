/*
  Copyright (C) 2013 John McCutchan

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

/// The window dimensions of a render-target surface onto which a 3D volume projects.
/// Create using [Device.createViewport]
/// Set using [ImmediateContext.setViewport]
class Viewport extends DeviceChild {
  //---------------------------------------------------------------------
  // Serialization names
  //---------------------------------------------------------------------

  /// Serialization name for [x].
  static const String _xName = 'x';
  /// Serialization name for [y].
  static const String _yName = 'y';
  /// Serialization name for [width].
  static const String _widthName = 'width';
  /// Serialization name for [height].
  static const String _heightName = 'height';
  /// Serialization name for [minDepth].
  static const String _minDepthName = 'minDepth';
  /// Serialization name for [maxDepth].
  static const String _maxDepthName = 'maxDepth';

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The x-coordinate of the upper left corner of the viewport on the render-target surface.
  int _x = 0;
  /// The y-coordinate of the upper left corner of the viewport on the render-target surface.
  int _y = 0;
  /// The width of the viewport on the render-target surface, in pixels.
  int _width = 640;
  /// The height of the viewport on the render-target surface, in pixels.
  int _height = 480;
  /// The minimum depth of the viewport.
  double _minDepth = 0.0;
  /// The maximum depth of the viewport.
  double _maxDepth = 1.0;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [Viewport] class.
  Viewport(String name, GraphicsDevice device)
    : super._internal(name, device);

  /// Creates an instance of the [Viewport] class.
  /// The rectangular bounding box is specified.
  Viewport.bounds(String name, GraphicsDevice device, int this._x, int this._y, int this._width, int this._height)
    : super._internal(name, device);

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// The x-coordinate of the upper left corner of the viewport on the render-target surface.
  int get x => _x;
  set x(int value) { _x = value; }

  /// The y-coordinate of the upper left corner of the viewport on the render-target surface.
  int get y => _y ;
  set y(int value) { _y = value; }

  /// The width of the viewport on the render-target surface, in pixels.
  /// Throws [ArgumentError] if [value] is not a positive number.
  int get width => _width;
  set width(int value) {
    if (value < 0) {
      throw new ArgumentError('width must be a positive number');
    }

    _width = value;
  }

  /// The height of the viewport on the render-target surface, in pixels.
  /// Throws [ArgumentError] if [value] is not a positive number.
  int get height => _height;
  set height(int value) {
    if (value < 0) {
      throw new ArgumentError('height must be a positive number');
    }

    _height = value;
  }

  /// The minimum depth of the viewport.
  /// Throws [ArgumentError] if [value] is not in the range [0, 1].
  double get minDepth => _minDepth;
  set minDepth(double value) {
    if ((value >= 0.0) && (value <= 1.0)) {
      _minDepth = value;
      return;
    }

    throw new ArgumentError('minDepth must be in the range [0, 1]');
  }

  /// The aspect ratio used by the viewport.
  double get aspectRatio => width / height;

  /// The maximum depth of the viewport.
  /// Throws [ArgumentError] if [value] is not in the range [0, 1].
  double get maxDepth => _maxDepth;
  set maxDepth(double value) {
    if ((value >= 0.0) && (value <= 1.0)) {
      _maxDepth = value;
      return;
    }

    throw new ArgumentError('maxDepth must be in the range [0, 1]');
  }

  //---------------------------------------------------------------------
  // Serialization
  //---------------------------------------------------------------------

  /// Serializes the [RasterizerState] to a JSON.
  dynamic toJson() {
    Map json = new Map();

    json[_xName] = _x;
    json[_yName] = _y;

    json[_widthName]  = _width;
    json[_heightName] = _height;

    json[_minDepthName] = _minDepth;
    json[_maxDepthName] = _maxDepth;

    return json;
  }

  /// Deserializes the [RasterizerState] from a JSON.
  void fromJson(dynamic values) {
    assert(values != null);

    dynamic value;

    value = values[_xName];
    _x = (value != null) ? value : _x;
    value = values[_yName];
    _y = (value != null) ? value : _y;

    value = values[_widthName];
    _width = (value != null) ? value : _width;
    value = values[_heightName];
    _height = (value != null) ? value : _height;

    value = values[_minDepthName];
    _minDepth = (value != null) ? value : _minDepth;
    value = values[_maxDepthName];
    _maxDepth = (value != null) ? value : _maxDepth;
  }
}

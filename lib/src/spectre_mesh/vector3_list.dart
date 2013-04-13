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

part of spectre_mesh;

/// Helper for accessing interleaved scalar elements.
///
/// The [Vector3List] class provides easy random access to 3D vector values
/// interleaved within vertex data.
class Vector3List extends StridedList<vec3> {
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// The number of bytes per element in the [List]
  static const int BYTES_PER_ELEMENT = 12;
  /// The number of items within the [Vector3List].
  static const int _itemCount = 3;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [Vector3List] class with the given [length] (in elements).
  ///
  /// Initially all elements are set to zero.
  Vector3List(int length)
      : super._create(length, _itemCount);

  /// Creates a [Vector3List] view of the specified region in the specified byte buffer.
  Vector3List.view(ArrayBuffer buffer, [int offsetInBytes = 0, int strideInBytes = BYTES_PER_ELEMENT])
      : super._view(buffer, offsetInBytes, strideInBytes, BYTES_PER_ELEMENT);

  //---------------------------------------------------------------------
  // Operators
  //---------------------------------------------------------------------

  /// Returns the element at the given index in the list.
  ///
  /// Throws a RangeError if index is out of bounds.
  vec3 operator[](int index) {
    int actualIndex = _getActualIndex(index);

    double x = _list[actualIndex++];
    double y = _list[actualIndex++];
    double z = _list[actualIndex];

    return new vec3.raw(x, y, z);
  }

  /// Sets the entry at the given index in the list to value.
  ///
  /// Throws a RangeError if index is out of bounds.
  void operator[]=(int index, vec3 value) {
    int actualIndex = _getActualIndex(index);

    _list[actualIndex++] = value.x;
    _list[actualIndex++] = value.y;
    _list[actualIndex]   = value.z;
  }

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// Returns the number of elements.
  int get length => _length;

  //---------------------------------------------------------------------
  // Public methods
  //---------------------------------------------------------------------

  /// Gets the [value] at the specified [index].
  ///
  /// Copies the value at [index] into [value]. This method will not create
  /// a new object like the \[\] operator will. Prefer this method whenever
  /// possible.
  void getAt(int index, vec3 value) {
    int actualIndex = _getActualIndex(index);

    value.x = _list[actualIndex++];
    value.y = _list[actualIndex++];
    value.z = _list[actualIndex];
  }

  /// Sets the [value] at the specified [index].
  void setAt(int index, vec3 value) {
    int actualIndex = _getActualIndex(index);

    _list[actualIndex++] = value.x;
    _list[actualIndex++] = value.y;
    _list[actualIndex]   = value.z;
  }

  //---------------------------------------------------------------------
  // Private methods
  //---------------------------------------------------------------------

  /// Retrieves the actual index of the data.
  int _getActualIndex(int index) => _offset + (index * _stride);
}


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
/// The [ScalarList] class provides easy random access to scalar values
/// interleaved within vertex data. If the vertex data is not interleaved
/// then a [ScalarList] should not be used as it has additional overhead,
/// in comparison to [Float32List] and will perform worse.
class ScalarList extends StridedList<double> {
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// The number of bytes per element in the [List]
  static const int BYTES_PER_ELEMENT = 4;
  /// The number of items within the [ScalarList].
  static const int _itemCount = 1;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [ScalarList] class with the given [length] (in elements).
  ///
  /// Initially all elements are set to zero.
  ScalarList(int length)
      : super._create(length, _itemCount);

  /// Creates a [ScalarList] view of the specified region in the specified byte buffer.
  ScalarList.view(ArrayBuffer buffer, [int offsetInBytes = 0, int strideInBytes = BYTES_PER_ELEMENT])
      : super._view(buffer, offsetInBytes, strideInBytes, BYTES_PER_ELEMENT);

  //---------------------------------------------------------------------
  // Operators
  //---------------------------------------------------------------------

  /// Returns the element at the given index in the list.
  ///
  /// Throws a RangeError if index is out of bounds.
  double operator[](int index) {
    return _list[_getActualIndex(index)];
  }

  /// Sets the entry at the given index in the list to value.
  ///
  /// Throws a RangeError if index is out of bounds.
  void operator[]=(int index, double value) {
    _list[_getActualIndex(index)] = value;
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
  /// Copies the value at [index] into [value]. This is not available for
  /// [ScalarList].
  void getAt(int index, double value) {
    throw new UnsupportedError('The getAt method is not valid for scalars');
  }

  /// Sets the [value] at the specified [index].
  void setAt(int index, double value) {
    _list[_getActualIndex(index)] = value;
  }

  //---------------------------------------------------------------------
  // Private methods
  //---------------------------------------------------------------------

  /// Retrieves the actual index of the data.
  int _getActualIndex(int index) => _offset + (index * _stride);
}

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
class ScalarList implements StridedList<double> {
  //---------------------------------------------------------------------
  // Class variables
  //---------------------------------------------------------------------

  /// The number of bytes per element in the [List]
  static const int BYTES_PER_ELEMENT = 4;

  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The offset to the element.
  int _offset;
  /// The length of the list.
  int _length;
  /// The stride between elements.
  int _stride;
  /// The [Float32List] used to access elements.
  Float32List _list;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [ScalarList] class with the given [length] (in elements).
  ///
  /// Initially all elements are set to zero.
  ScalarList(int length)
    : _offset = 0
    , _stride = 1
    , _length = length
    , _list = new Float32List(length);

  ScalarList.view(ByteBuffer buffer, [int offsetInBytes = 0, int strideInBytes = BYTES_PER_ELEMENT])
    : _offset = offsetInBytes >> 2
    , _stride = strideInBytes >> 2
  {
    if (offsetInBytes % 4 != 0) {
      throw new ArgumentError('The byte offset must be on a 4-byte boundary');
    }

    if (strideInBytes % 4 != 0) {
      throw new ArgumentError('The stride offset must be on a 4-byte boundary');
    }

    if (strideInBytes < BYTES_PER_ELEMENT) {
      throw new ArgumentError('The stride is less than the element size');
    }

    _list = new Float32List.view(buffer);
    _length = _list.length ~/ _stride;
  }

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
  // Private methods
  //---------------------------------------------------------------------

  /// Retrieves the actual index of the data.
  int _getActualIndex(int index) => _offset + (index * _stride);
}

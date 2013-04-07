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

abstract class StridedList<E> {//implements List<E> {
  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  /// The underlying [Float32List] containing the elements.
  Float32Array _list;
  /// The offset to the element.
  int _offset;
  /// The length of the list.
  int _length;
  /// The stride between elements.
  int _stride;

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [StridedList] class with the given [length].
  StridedList._create(int length, int itemCount)
      : _offset = 0
      , _stride = itemCount
      , _length = length
      , _list = new Float32Array(length * itemCount);

  /// Creates a [StridedList] view of the specified region in the specified byte buffer.
  StridedList._view(ArrayBuffer buffer, int offsetInBytes, int strideInBytes, int bytesPerElement)
      : _offset = offsetInBytes >> 2
      , _stride = strideInBytes >> 2
  {
    if (offsetInBytes % 4 != 0) {
      throw new ArgumentError('The byte offset must be on a 4-byte boundary');
    }

    if (strideInBytes % 4 != 0) {
      throw new ArgumentError('The stride offset must be on a 4-byte boundary');
    }

    if (strideInBytes < bytesPerElement) {
      throw new ArgumentError('The stride is less than the element size');
    }

    // \TODO Change to Float32List when available
    _list = new Float32Array.fromBuffer(buffer);
    _length = _list.length ~/ _stride;
  }



  //---------------------------------------------------------------------
  // Operators
  //---------------------------------------------------------------------

  E operator[](int index);

  void operator[]=(int index, E value);

  //---------------------------------------------------------------------
  // Properties
  //---------------------------------------------------------------------

  /// Returns the number of elements.
  int get length;

  /// Returns the underlying [Float32List].
  Float32Array get list => _list;

  //---------------------------------------------------------------------
  // Methods
  //---------------------------------------------------------------------

  /// Gets the [value] at the specified [index].
  ///
  /// Copies the value at [index] into [value]. Dependent on the type of [E] the
  /// \[\] operator can create a new object. Prefer this method when [E] is
  /// an object.
  void getAt(int index, E value);

  /// Sets the [value] at the specified [index].
  void setAt(int index, E value);

  //---------------------------------------------------------------------
  // Unsupported methods
  //
  // Define all the List<E> methods that are unsupported by the
  // implementation.
  //---------------------------------------------------------------------

}

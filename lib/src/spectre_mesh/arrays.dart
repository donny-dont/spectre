/*

  Copyright (C) 2012 The Spectre Project authors.

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

/**
 * Interface that supports a simple iteration over vertex data.
 *
 * Modelled after C#'s IEnumerator interface rather than the
 * Dart iterator.
 */
abstract class VertexEnumerator<T> {

  /**
   * Moves the iterator to the next location.
   *
   * Returns true if the iterator's state is valid;
   * false otherwise.
   */
  bool moveNext();

  /**
   * The value the iterator is pointing to.
   *
   * Prefer [getCurrentValue] over the value getter to
   * avoid creating additional garbage.
   */
  T get current();
  set current(T value);

  /**
   * Retrives the value contained in the iterator.
   *
   * This method should be used over [current] when [T]
   * is an object. This will avoid the creation of additional
   * garbage.
   */
  void getCurrentValue(T value);

  /**
   * Sets the value contained in the iterator.
   */
  void setCurrentValue(T value);
}

abstract class VertexArray<T> {

  T operator[] (int index);
  void operator[]= (int index, T value);
  void getAt(int index, T value);
  void setAt(int index, T value);
  VertexEnumerator<T> getEnumerator([int index = 0]);
}

/**
 * Iterates over a scalar values interleaved within a [Float32Array].
 *
 * Prefer a [ScalarIterator] over a [ScalarArray] if the data
 * access will be sequential. This is because a [ScalarArray] will
 * recalculate the position within the backing [Float32Array] at
 * each call, while the [ScalarIterator] retains the state.
 *
 *     int length = array.length;
 *     for (int i = 0; i < length; ++i) {
 *       array[i] = someNum;    // currentIndex = (index * stride) + offset
 *     }
 *
 *     while (itr.moveNext()) {
 *       itr.current = someNum; // currentIndex += stride
 *     }
 */
class ScalarIterator implements VertexEnumerator<double> {

  Float32Array _array;

  ScalarIterator() {

  }

  /**
   * Moves to the next location within the array.
   *
   * Returns true if there is a next element; false otherwise.
   */
  bool moveNext() {

    return false;
  }

  /**
   * The value the iterator is pointing to.
   *
   * Prefer [getCurrentValue] over the value getter to
   * avoid creating additional garbage.
   */
  double get current() {

  }
  set current(double value) {

  }

  /**
   * Retrives the value contained in the iterator.
   *
   * This method should not be used with a [ScalarIterator]
   * as a double is a builtin type.
   */
  void getCurrentValue(double value) {
    throw new ArgumentError('getCurrentValue is not valid for ScalarIterator. Use the current property instead');
  }

  /**
   * Sets the value contained in the iterator.
   */
  void setCurrentValue(double value) {

  }
}

/**
 * Helper for accessing interleaved scalar elements from within a [Float32Array].
 *
 * The [ScalarArray] class provides easy random access to scalar values
 * interleaved within vertex data. If the vertex data is not interleaved
 * then a [ScalarArray] should not be used as it has additional overhead,
 * in comparison to [Float32Array] and will perform worse.
 *
 * Prefer the [ScalarArray] over a [ScalarIterator] if the data
 * access will be random. A [ScalarIterator] can be generated for times
 * when sequential access is needed by calling the [getIterator] method.
 */
class ScalarArray { //implements VertexArray<double> {
  static const int _itemCount = 1;

  ScalarArray.fromArray(Float32Array array, [int byteOffset=0, int byteStride=_itemCount]);

  ScalarIterator getEnumerator([int index = 0]) {

  }
}

/**
 * Iterates over a 2D elements, [vec2], interleaved within a [Float32Array].
 */
class Vector2Enumerator implements VertexEnumerator<vec2> {
  static const int _itemCount = 2;

  Float32Array _array;
  int _index;
  int _stride;
  int _end;

  Vector2Enumerator(Float32Array array, [int byteOffset=0, int byteStride=_itemCount])
    : _index = byteOffset >> 2
    , _stride = byteStride >> 2
    , _array = array
  {
    assert(byteOffset % 4 == 0);
    assert(byteStride % 4 == 0);

    _end = _array.length + _index;
  }

  Vector2Enumerator._fromVector2Array(Vector2Array array, int index)
    : _array = array.array
    , _index = index
    , _stride = array._stride
  {
    _end = _array.length + (_index % _stride);
  }

  /**
   * Moves to the next location within the array.
   *
   * Returns true if there is a next element; false otherwise.
   */
  bool moveNext() {
    _index += _stride;

    return _end != _index;
  }

  /**
   * The value the iterator is pointing to.
   *
   * Prefer [getCurrentValue] over the value getter to
   * avoid creating additional garbage.
   */
  vec2 get current() {
    double x = _array[_index];
    double y = _array[_index + 1];

    return new vec2.raw(x, y);
  }
  set current(vec2 value) {
    _array[_index]     = value.x;
    _array[_index + 1] = value.y;
  }

  /**
   * Retrives the value contained in the iterator.
   *
   * This method should not be used with a [ScalarIterator]
   * as a double is a builtin type.
   */
  void getCurrentValue(vec2 value) {
    double x = _array[_index];
    double y = _array[_index + 1];

    value.setComponents(x, y);
  }

  /**
   * Sets the value contained in the iterator.
   */
  void setCurrentValue(vec2 value) {
    _array[_index]     = value.x;
    _array[_index + 1] = value.y;
  }
}

/**
 * Helper for accessing interleaved 2D elements, [vec2], from within a [Float32Array].
 */
class Vector2Array implements VertexArray<vec2> {
  static const int BYTES_PER_ELEMENT = 8;

  static const int _itemCount = 2;

  int _offset;
  int _stride;
  Float32Array _array;

  Vector2Array(int length)
    : _offset = 0
    , _stride = _itemCount
    , _array = new Float32Array(length * _itemCount);

  Vector2Array.fromArray(Float32Array array, [int byteOffset=0, int byteStride=_itemCount])
    : _offset = byteOffset >> 2
    , _stride = byteStride >> 2
    , _array = array
  {
    assert(byteOffset % 4 == 0);
    assert(byteStride % 4 == 0);
  }

  Float32Array get array() => _array;

  vec2 operator[] (int index)
  {
    int arrayIndex = _getArrayIndex(index);

    double x = _array[arrayIndex++];
    double y = _array[arrayIndex];

    return new vec2.raw(x, y);
  }

  void operator[]= (int index, vec2 value)
  {
    int arrayIndex = _getArrayIndex(index);

    _array[arrayIndex++] = value.x;
    _array[arrayIndex]   = value.y;
  }

  void getAt(int index, vec2 value) {
    int arrayIndex = _getArrayIndex(index);

    value.x = _array[arrayIndex++];
    value.y = _array[arrayIndex];
  }

  void setAt(int index, vec2 value) {
    int arrayIndex = _getArrayIndex(index);

    _array[arrayIndex++] = value.x;
    _array[arrayIndex]   = value.y;
  }

  int _getArrayIndex(int index) => _offset + (index * _stride);

  VertexEnumerator<vec2> getEnumerator([int index = 0]) {
    int arrayIndex = _getArrayIndex(index);

    return new Vector2Enumerator._fromVector2Array(this, arrayIndex);
  }
}

/**
 * Iterates over a 3D elements, [vec3], interleaved within a [Float32Array].
 */
class Vector3Enumerator implements VertexEnumerator<vec3> {
  static const int _itemCount = 2;

  Float32Array _array;
  int _index;
  int _stride;
  int _end;

  Vector3Enumerator(Float32Array array, [int byteOffset=0, int byteStride=_itemCount])
    : _index = byteOffset >> 2
    , _stride = byteStride >> 2
    , _array = array
  {
    assert(byteOffset % 4 == 0);
    assert(byteStride % 4 == 0);

    _end = _array.length + _index;
  }

  Vector3Enumerator._fromVector3Array(Vector3Array array, int index)
    : _array = array.array
    , _index = index
    , _stride = array._stride
  {
    _end = _array.length + (_index % _stride);
  }

  /**
   * Moves to the next location within the array.
   *
   * Returns true if there is a next element; false otherwise.
   */
  bool moveNext() {
    _index += _stride;

    return _end != _index;
  }

  /**
   * The value the iterator is pointing to.
   *
   * Prefer [getCurrentValue] over the value getter to
   * avoid creating additional garbage.
   */
  vec3 get current() {
    double x = _array[_index];
    double y = _array[_index + 1];
    double z = _array[_index + 2];

    return new vec3.raw(x, y, z);
  }
  set current(vec3 value) {
    _array[_index]     = value.x;
    _array[_index + 1] = value.y;
    _array[_index + 2] = value.z;
  }

  /**
   * Retrives the value contained in the iterator.
   *
   * This method should not be used with a [ScalarIterator]
   * as a double is a builtin type.
   */
  void getCurrentValue(vec3 value) {
    double x = _array[_index];
    double y = _array[_index + 1];
    double z = _array[_index + 2];

    value.setComponents(x, y, z);
  }

  /**
   * Sets the value contained in the iterator.
   */
  void setCurrentValue(vec3 value) {
    _array[_index]     = value.x;
    _array[_index + 1] = value.y;
    _array[_index + 2] = value.z;
  }
}

/**
 * Helper for accessing interleaved 3D elements, [vec3], from within a [Float32Array].
 */
class Vector3Array implements VertexArray<vec3> {
  static const int BYTES_PER_ELEMENT = 8;

  static const int _itemCount = 3;

  int _offset;
  int _stride;
  Float32Array _array;

  Vector3Array(int length)
    : _offset = 0
    , _stride = _itemCount
    , _array = new Float32Array(length * _itemCount);

  Vector3Array.fromArray(Float32Array array, [int byteOffset=0, int byteStride=_itemCount])
    : _offset = byteOffset >> 2
    , _stride = byteStride >> 2
    , _array = array
  {
    assert(byteOffset % 4 == 0);
    assert(byteStride % 4 == 0);
  }

  Float32Array get array() => _array;

  vec3 operator[] (int index)
  {
    int arrayIndex = _getArrayIndex(index);

    double x = _array[arrayIndex++];
    double y = _array[arrayIndex++];
    double z = _array[arrayIndex];

    return new vec3.raw(x, y, z);
  }

  void operator[]= (int index, vec3 value)
  {
    int arrayIndex = _getArrayIndex(index);

    _array[arrayIndex++] = value.x;
    _array[arrayIndex++] = value.y;
    _array[arrayIndex]   = value.z;
  }

  void getAt(int index, vec3 value) {
    int arrayIndex = _getArrayIndex(index);

    value.x = _array[arrayIndex++];
    value.y = _array[arrayIndex++];
    value.z = _array[arrayIndex];
  }

  void setAt(int index, vec3 value) {
    int arrayIndex = _getArrayIndex(index);

    _array[arrayIndex++] = value.x;
    _array[arrayIndex++] = value.y;
    _array[arrayIndex]   = value.z;
  }

  int _getArrayIndex(int index) => _offset + (index * _stride);

  VertexEnumerator<vec3> getEnumerator([int index = 0]) {
    int arrayIndex = _getArrayIndex(index);

    return new Vector3Enumerator._fromVector3Array(this, arrayIndex);
  }
}

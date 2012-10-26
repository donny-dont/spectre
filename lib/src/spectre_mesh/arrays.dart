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

abstract class VertexArray<T> {
  T operator[] (int index);
  void operator[]= (int index, T value);
  void getAt(int index, T value);
  void setAt(int index, T value);
  int getDataIndex(int index);
  int get length;
  Float32Array get array;
}

/**
 * Helper for accessing interleaved scalar elements from within a [Float32Array].
 *
 * The [ScalarArray] class provides easy random access to scalar values
 * interleaved within vertex data. If the vertex data is not interleaved
 * then a [ScalarArray] should not be used as it has additional overhead,
 * in comparison to [Float32Array] and will perform worse.
 */
class ScalarArray implements VertexArray<double> {
  static const int BYTES_PER_ELEMENT = 4;
  static const int _itemCount = 1;

  int _offset;
  int _stride;
  int _length;
  Float32Array _array;

  ScalarArray(int length)
    : _offset = 0
    , _stride = _itemCount
    , _length = length
    , _array = new Float32Array(length * _itemCount);

  ScalarArray.fromArray(Float32Array array, [int byteOffset=0, int byteStride=_itemCount])
    : _offset = byteOffset >> 2
    , _stride = byteStride >> 2
    , _array = array
  {
    assert(byteOffset % 4 == 0);
    assert(byteStride % 4 == 0);

    _length = _array.length ~/ _stride;

    assert(_array.length % _stride == 0);
  }

  int get length => _length;
  Float32Array get array => _array;

  double operator[] (int index)
  {
    int arrayIndex = getDataIndex(index);

    return _array[arrayIndex];
  }

  void operator[]= (int index, double value) {
    int arrayIndex = getDataIndex(index);

    _array[arrayIndex] = value;
  }

  void getAt(int index, double value) {
    throw new ArgumentError('getAt is not valid for ScalarArray');
  }

  void setAt(int index, double value) {
    int arrayIndex = getDataIndex(index);

    _array[arrayIndex] = value;
  }

  int getDataIndex(int index) => _offset + (index * _stride);
}

/**
 * Helper for accessing interleaved 2D elements, [vec2], from within a [Float32Array].
 *
 * The [Vector2Array] class provides easy random access to 2D vector values
 * inteleaved within vertex data.
 */
class Vector2Array implements VertexArray<vec2> {
  static const int BYTES_PER_ELEMENT = 8;
  static const int _itemCount = 2;

  int _offset;
  int _stride;
  int _length;
  Float32Array _array;

  Vector2Array(int length)
    : _offset = 0
    , _stride = _itemCount
    , _length = length
    , _array = new Float32Array(length * _itemCount);

  Vector2Array.fromArray(Float32Array array, [int byteOffset=0, int byteStride=_itemCount])
    : _offset = byteOffset >> 2
    , _stride = byteStride >> 2
    , _array = array
  {
    assert(byteOffset % 4 == 0);
    assert(byteStride % 4 == 0);

    _length = _array.length ~/ _stride;

    assert(_array.length % _stride == 0);
  }

  int get length => _length;
  Float32Array get array => _array;

  vec2 operator[] (int index) {
    int arrayIndex = getDataIndex(index);

    double x = _array[arrayIndex++];
    double y = _array[arrayIndex];

    return new vec2.raw(x, y);
  }

  void operator[]= (int index, vec2 value) {
    int arrayIndex = getDataIndex(index);

    _array[arrayIndex++] = value.x;
    _array[arrayIndex]   = value.y;
  }

  void getAt(int index, vec2 value) {
    int arrayIndex = getDataIndex(index);

    value.x = _array[arrayIndex++];
    value.y = _array[arrayIndex];
  }

  void setAt(int index, vec2 value) {
    int arrayIndex = getDataIndex(index);

    _array[arrayIndex++] = value.x;
    _array[arrayIndex]   = value.y;
  }

  int getDataIndex(int index) => _offset + (index * _stride);
}

/**
 * Helper for accessing interleaved 3D elements, [vec3], from within a [Float32Array].
 *
 * The [Vector3Array] class provides easy random access to 3D vector values
 * inteleaved within vertex data.
 */
class Vector3Array implements VertexArray<vec3> {
  static const int BYTES_PER_ELEMENT = 12;
  static const int _itemCount = 3;

  int _offset;
  int _stride;
  int _length;
  Float32Array _array;

  Vector3Array(int length)
    : _offset = 0
    , _stride = _itemCount
    , _length = length
    , _array = new Float32Array(length * _itemCount);

  Vector3Array.fromArray(Float32Array array, [int byteOffset=0, int byteStride=_itemCount])
    : _offset = byteOffset >> 2
    , _stride = byteStride >> 2
    , _array = array
  {
    assert(byteOffset % 4 == 0);
    assert(byteStride % 4 == 0);

    _length = _array.length ~/ _stride;

    assert(_array.length % _stride == 0);
  }

  int get length => _length;
  Float32Array get array => _array;

  vec3 operator[] (int index) {
    int arrayIndex = getDataIndex(index);

    double x = _array[arrayIndex++];
    double y = _array[arrayIndex++];
    double z = _array[arrayIndex];

    return new vec3.raw(x, y, z);
  }

  void operator[]= (int index, vec3 value) {
    int arrayIndex = getDataIndex(index);

    _array[arrayIndex++] = value.x;
    _array[arrayIndex++] = value.y;
    _array[arrayIndex]   = value.z;
  }

  void getAt(int index, vec3 value) {
    int arrayIndex = getDataIndex(index);

    value.x = _array[arrayIndex++];
    value.y = _array[arrayIndex++];
    value.z = _array[arrayIndex];
  }

  void setAt(int index, vec3 value) {
    int arrayIndex = getDataIndex(index);

    _array[arrayIndex++] = value.x;
    _array[arrayIndex++] = value.y;
    _array[arrayIndex]   = value.z;
  }

  int getDataIndex(int index) => _offset + (index * _stride);
}

/**
 * Helper for accessing interleaved 3D elements, [vec3], from within a [Float32Array].
 *
 * The [Vector3Array] class provides easy random access to 3D vector values
 * inteleaved within vertex data.
 */
class Vector4Array implements VertexArray<vec4> {
  static const int BYTES_PER_ELEMENT = 16;
  static const int _itemCount = 4;

  int _offset;
  int _stride;
  int _length;
  Float32Array _array;

  Vector4Array(int length)
    : _offset = 0
    , _stride = _itemCount
    , _length = length
    , _array = new Float32Array(length * _itemCount);

  Vector4Array.fromArray(Float32Array array, [int byteOffset=0, int byteStride=_itemCount])
    : _offset = byteOffset >> 2
    , _stride = byteStride >> 2
    , _array = array
  {
    assert(byteOffset % 4 == 0);
    assert(byteStride % 4 == 0);

    _length = _array.length ~/ _stride;

    assert(_array.length % _stride == 0);
  }

  int get length => _length;
  Float32Array get array => _array;

  vec4 operator[] (int index) {
    int arrayIndex = getDataIndex(index);

    double x = _array[arrayIndex++];
    double y = _array[arrayIndex++];
    double z = _array[arrayIndex++];
    double w = _array[arrayIndex];

    return new vec4.raw(x, y, z, w);
  }

  void operator[]= (int index, vec4 value) {
    int arrayIndex = getDataIndex(index);

    _array[arrayIndex++] = value.x;
    _array[arrayIndex++] = value.y;
    _array[arrayIndex++] = value.z;
    _array[arrayIndex]   = value.w;
  }

  void getAt(int index, vec4 value) {
    int arrayIndex = getDataIndex(index);

    value.x = _array[arrayIndex++];
    value.y = _array[arrayIndex++];
    value.z = _array[arrayIndex++];
    value.w = _array[arrayIndex];
  }

  void setAt(int index, vec4 value) {
    int arrayIndex = getDataIndex(index);

    _array[arrayIndex++] = value.x;
    _array[arrayIndex++] = value.y;
    _array[arrayIndex++] = value.z;
    _array[arrayIndex]   = value.w;
  }

  int getDataIndex(int index) => _offset + (index * _stride);
}

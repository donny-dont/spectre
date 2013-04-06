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

library vector2_list_test;

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre_mesh.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:typeddata';

Float32List createSequentialList(int count) {
  Float32List list = new Float32List(count);

  for (int i = 0; i < count; ++i) {
    list[i] = i.toDouble();
  }

  return list;
}

void main() {
  const int elementCount = 2;
  const int bytesPerElement = Vector2List.BYTES_PER_ELEMENT;

  test('no stride', () {
    const int size = 2048;
    const int listSize = size ~/ elementCount;

    Float32List test = createSequentialList(size);
    Vector2List list = new Vector2List.view(test.buffer);

    expect(list.length, listSize);

    int testIndex = 0;
    for (int i = 0; i < listSize; ++i) {
      vec2 element = list[i];

      expect(element.x, test[testIndex++]);
      expect(element.y, test[testIndex++]);
    }
  });

  test('stride and offset', () {
    const int size = 2048;
    const int listSize = size ~/ elementCount;

    Float32List test = createSequentialList(size);
    ByteBuffer array = test.buffer;

    for (int k = 1; k < listSize; ++k) {
      int length = size ~/ (k * elementCount);

      for (int j = 0; j < k; ++j) {
        Vector2List list = new Vector2List.view(array, j * bytesPerElement, k * bytesPerElement);

        expect(list.length, length);

        for (int i = 0; i < length; ++i) {
          vec2 value = list[i];
          int testIndex = elementCount * ((k * i) + j);
          expect(value.x, test[testIndex++]);
          expect(value.y, test[testIndex]);
        }
      }
    }
  });
}

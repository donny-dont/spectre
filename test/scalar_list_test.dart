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

library scalar_list_test;

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre_mesh.dart';
import 'dart:scalarlist';

Float32List createSequentialList(int count) {
  Float32List list = new Float32List(count);

  for (int i = 0; i < count; ++i) {
    list[i] = i.toDouble();
  }

  return list;
}

void main() {
  test('no stride', () {
    const int size = 1024;

    Float32List test = createSequentialList(size);
    ScalarList list = new ScalarList.view(test.asByteArray());

    expect(list.length, test.length);

    for (int i = 0; i < size; ++i) {
      expect(list[i], test[i]);
    }
  });

  test('stride and offset', () {
    const int size = 1024;

    Float32List test = createSequentialList(size);
    ByteArray array = test.asByteArray();

    for (int k = 1; k < size; ++k) {
      int length = size ~/ k;

      for (int j = 0; j < k; ++j) {
        ScalarList list = new ScalarList.view(array, j * 4, k * 4);

        expect(list.length, length);

        for (int i = 0; i < length; ++i) {
          expect(list[i], test[(k * i) + j]);
        }
      }
    }
  });
}

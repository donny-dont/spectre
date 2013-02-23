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

library dds_file_test;

import 'dart:async';
import 'dart:html';
import 'package:unittest/unittest.dart';
import 'package:spectre/spectre_asset_pack.dart';

Future<ArrayBuffer> getFile(String url) {
  Completer completer = new Completer();

  // Make HTTP request
  HttpRequest request = new HttpRequest();
  request.responseType = 'arraybuffer';
  request.onLoad.listen((event) {
    if (request.status == 200) {
      completer.complete(request.response);
    } else {
      completer.complete(null);
    }
  });
  request.open('GET', url);
  request.send();

  return completer.future;
}

void testStandardTexture(String url, int width, int height, int mipMapCount) {
  getFile(url).then(expectAsync1((buffer) {
    expect(buffer != null, true);

    DdsFile ddsFile = new DdsFile(buffer);

    expect(ddsFile.width, width);
    expect(ddsFile.height, height);
    expect(ddsFile.depth, 0);
    expect(ddsFile.mipMapCount, mipMapCount);
    expect(ddsFile.isCubeMap, false);
    expect(ddsFile.hasAllCubeMapFaces, false);
    expect(ddsFile.isVolumeTexture, false);
  }));
}

void testCubeMap(String url, int width, int height, int mipMapCount) {

}

void main() {
  test('invalid file', () {
    testStandardTexture('dds/lena.dds', 512, 512, 0);
  });
/*
  // Format tests
  test('32-bit unsigned int', () {
    testStandardTexture('dds/lena_a8r8g8b8_dx9.dds', 512, 512, 0);
  });
  test('128-bit floating point A32B32G32R32', () {
    testStandardTexture('dds/lena_float_a32b32g32r32_dx9.dds', 512, 512, 0);
  });
  test('DXT1', () {
    testStandardTexture('dds/lena_dxt1_dx9.dds', 512, 512, 0);
  });

  test('64-bit half-floating point A16B16G16R16', () {
    testStandardTexture('dds/lena_float_a16b16g16r16_dx9.dds', 512, 512, 0);
  });

  // Non power of two tests
  test('non-power of two texture', () {
    testStandardTexture('dds/lenna_npot.dds', 400, 200, 9);
  });

  test('non-power of two texture', () {
    testStandardTexture('dds/lenna_npot_no_mipmaps.dds', 400, 200, 0);
  });

  getFile('dds/lenna_npot.dds').then(expectAsync1((buffer) {
      expect(buffer != null, true);
      testStandardTexture(buffer, 400, 200, 9);
    }));
  });

  test('non-power of two texture no mipmap', () {
    getFile('dds/lenna_npot_no_mipmaps.dds').then(expectAsync1((buffer) {
      expect(buffer != null, true);
      testStandardTexture(buffer, 400, 200, 0);
    }));
  });

  test('cube map', () {
    getFile('dds/cube.dds').then(expectAsync1((buffer) {
      expect(buffer != null, true);

      DdsFile ddsFile = new DdsFile(buffer);

      expect(ddsFile.width, 512);
      expect(ddsFile.height, 512);
      expect(ddsFile.depth, 0);
      expect(ddsFile.mipMapCount, 10);
      expect(ddsFile.isCubeMap, true);
      expect(ddsFile.hasAllCubeMapFaces, true);
      expect(ddsFile.isVolumeTexture, false);
    }));
  });
  */
}

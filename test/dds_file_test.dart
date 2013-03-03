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

    print(url);
    print('Has extended header: ${ddsFile.hasExtendedHeader}');
    print('Pitch/Linear size  : ${ddsFile.header.pitchOrLinearSize}');
    print('');

    expect(ddsFile.width, width);
    expect(ddsFile.height, height);
    expect(ddsFile.depth, 1);
    expect(ddsFile.mipMapCount, mipMapCount);
    expect(ddsFile.isCubeMap, false);
    expect(ddsFile.hasAllCubeMapFaces, false);
    expect(ddsFile.isVolumeTexture, false);
  }));
}

void testCubeMap(String url, int width, int height, int mipMapCount) {

}

void testFormats(bool dx10) {
  List formats = [
                  'R32G32B32A32_FLOAT',
                  'R32G32B32A32_UINT',
                  'R32G32B32A32_SINT',
                  'R32G32B32_FLOAT',
                  'R32G32B32_UINT',
                  'R32G32B32_SINT',
                  'R16G16B16A16_FLOAT',
                  'R16G16B16A16_UNORM',
                  'R16G16B16A16_UINT',
                  'R16G16B16A16_SNORM',
                  'R16G16B16A16_SINT',
                  'R32G32_FLOAT',
                  'R32G32_UINT',
                  'R32G32_SINT',
                  'R10G10B10A2_UNORM',
                  'R10G10B10A2_UINT',
                  'R11G11B10_FLOAT',

                  'R8G8B8A8_UNORM',
                  'R8G8B8A8_UNORM_SRGB',
                  'R8G8B8A8_UINT',
                  'R8G8B8A8_SNORM',
                  'R8G8B8A8_SINT',
                  'R16G16_FLOAT',
                  'R16G16_UNORM',
                  'R16G16_UINT',
                  'R16G16_SNORM',
                  'R16G16_SINT',

                  'R32_FLOAT',
                  'R32_UINT',
                  'R32_SINT',
                  'R8G8_UNORM',
                  'R8G8_UINT',
                  'R8G8_SNORM',
                  'R8G8_SINT',
                  'R16_FLOAT',
                  'R16_UNORM',
                  'R16_UINT',
                  'R16_SNORM',
                  'R16_SINT',
                  'R8_UNORM',
                  'R8_UINT',
                  'R8_SNORM',
                  'R8_SINT',
                  'A8_UNORM',
                  'R9G9B9E5_SHAREDEXP',
                  'R8G8_B8G8_UNORM',
                  'G8R8_G8B8_UNORM',
                  'BC1_UNORM',
                  'BC1_UNORM_SRGB',
                  'BC2_UNORM',
                  'BC2_UNORM_SRGB',
                  'BC3_UNORM',
                  'BC3_UNORM_SRGB',
                  'BC4_UNORM',
                  'BC4_SNORM',
                  'BC5_UNORM',
                  'BC5_SNORM',
                  'B5G6R5_UNORM',
                  'B5G5R5A1_UNORM',
                  'B8G8R8A8_UNORM',
                  'B8G8R8X8_UNORM',
                  'R10G10B10_XR_BIAS_A2_UNORM',
                  'B8G8R8A8_UNORM_SRGB',
                  'B8G8R8X8_UNORM_SRGB',
                  'BC6H_UF16',
                  'BC6H_SF16',
                  'BC7_UNORM',
                  'BC7_UNORM_SRGB'
                  ];


  String testPrefix;
  String directory;

  if (dx10) {
    testPrefix = 'DX 10';
    directory = 'dds/formats/dx10/';
  } else {
    testPrefix = 'DX 9';
    directory = 'dds/formats/dx9/';
  }

  for (int i = 0; i < formats.length; ++i) {
    String format = formats[i];

    test('Format ${testPrefix} ${format}', () {
      String url = '${directory}lena_${format}.dds';

      testStandardTexture(url, 32, 32, 1);
    });
  }
}

void main() {
  testFormats(false);
/*
  test('invalid file', () {
    testStandardTexture('dds/lena.dds', 512, 512, 0);
  });

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

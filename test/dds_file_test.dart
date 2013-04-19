/*
  Copyright (C) 2013 John McCutchan

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
import 'dart:math' as Math;
import 'package:unittest/unittest.dart';
import 'package:spectre/spectre_asset_pack.dart';

//---------------------------------------------------------------------
// DDS Resource Formats
//---------------------------------------------------------------------

List dx9Formats = [
  'FloatR32G32B32A32',
  'FloatR16G16B16A16',
  'UnormR16G16B16A16',
  'NormR16G16B16A16',
  'FloatR32G32',
  'UnormR8G8B8A8',
  'FloatR16G16',
  'UnormR16G16',
  'FloatR32',
  'UnormR8G8',
  'FloatR16',
  'UnormR16',
  'UnormR8',
  'UnormA8',
  'UnormR8G8B8G8',
  'UnormG8R8G8B8',
  'UnormBc1',
  'UnormBc2',
  'UnormBc3',
  'UnormBc4',
  'NormBc4',
  'UnormBc5',
  'NormBc5',
  'UnormB5G6R5',
  'UnormB5G5R5A1',
  'UnormB8G8R8A8',
  'UnormB8G8R8X8',
];

List dx10Formats = [
  'FloatR32G32B32A32',
  'UintR32G32B32A32',
  'IntR32G32B32A32',
  'FloatR32G32B32',
  'UintR32G32B32',
  'IntR32G32B32',
  'FloatR16G16B16A16',
  'UnormR16G16B16A16',
  'UintR16G16B16A16',
  'NormR16G16B16A16',
  'IntR16G16B16A16',
  'FloatR32G32',
  'UintR32G32',
  'IntR32G32',
  'UnormR10G10B10A2',
  'UintR10G10B10A2',
  'FloatR11G11B10',
  'UnormR8G8B8A8',
  'SrgbUnormR8G8B8A8',
  'UintR8G8B8A8',
  'NormR8G8B8A8',
  'IntR8G8B8A8',
  'FloatR16G16',
  'UnormR16G16',
  'UintR16G16',
  'NormR16G16',
  'IntR16G16',
  'FloatR32',
  'UintR32',
  'IntR32',
  'UnormR8G8',
  'UintR8G8',
  'NormR8G8',
  'IntR8G8',
  'FloatR16',
  'UnormR16',
  'UintR16',
  'NormR16',
  'IntR16',
  'UnormR8',
  'UintR8',
  'NormR8',
  'IntR8',
  'UnormA8',
  'SharedExpR9G9B9E5',
  'UnormR8G8B8G8',
  'UnormG8R8G8B8',
  'UnormBc1',
  'SrgbUnormBc1',
  'UnormBc2',
  'SrgbUnormBc2',
  'UnormBc3',
  'SrgbUnormBc3',
  'UnormBc4',
  'NormBc4',
  'UnormBc5',
  'NormBc5',
  'UnormB5G6R5',
  'UnormB5G5R5A1',
  'UnormB8G8R8A8',
  'UnormB8G8R8X8',
  'XrBiasA2UnormR10G10B10',
  'SrgbUnormB8G8R8A8',
  'SrgbUnormB8G8R8X8',
  'Uf16Bc6h',
  'Sf16Bc6h',
  'UnormBc7',
  'SrgbUnormBc7'
];

//---------------------------------------------------------------------
// DdsFile testing utility functions
//---------------------------------------------------------------------

int getDdsResourceFormat(String name) {
  switch (name) {
    case 'FloatR32G32B32A32'     : return DdsResourceFormat.FloatR32G32B32A32;
    case 'UintR32G32B32A32'      : return DdsResourceFormat.UintR32G32B32A32;
    case 'IntR32G32B32A32'       : return DdsResourceFormat.IntR32G32B32A32;
    case 'FloatR32G32B32'        : return DdsResourceFormat.FloatR32G32B32;
    case 'UintR32G32B32'         : return DdsResourceFormat.UintR32G32B32;
    case 'IntR32G32B32'          : return DdsResourceFormat.IntR32G32B32;
    case 'FloatR16G16B16A16'     : return DdsResourceFormat.FloatR16G16B16A16;
    case 'UnormR16G16B16A16'     : return DdsResourceFormat.UnormR16G16B16A16;
    case 'UintR16G16B16A16'      : return DdsResourceFormat.UintR16G16B16A16;
    case 'NormR16G16B16A16'      : return DdsResourceFormat.NormR16G16B16A16;
    case 'IntR16G16B16A16'       : return DdsResourceFormat.IntR16G16B16A16;
    case 'FloatR32G32'           : return DdsResourceFormat.FloatR32G32;
    case 'UintR32G32'            : return DdsResourceFormat.UintR32G32;
    case 'IntR32G32'             : return DdsResourceFormat.IntR32G32;
    case 'UnormR10G10B10A2'      : return DdsResourceFormat.UnormR10G10B10A2;
    case 'UintR10G10B10A2'       : return DdsResourceFormat.UintR10G10B10A2;
    case 'FloatR11G11B10'        : return DdsResourceFormat.FloatR11G11B10;
    case 'UnormR8G8B8A8'         : return DdsResourceFormat.UnormR8G8B8A8;
    case 'SrgbUnormR8G8B8A8'     : return DdsResourceFormat.SrgbUnormR8G8B8A8;
    case 'UintR8G8B8A8'          : return DdsResourceFormat.UintR8G8B8A8;
    case 'NormR8G8B8A8'          : return DdsResourceFormat.NormR8G8B8A8;
    case 'IntR8G8B8A8'           : return DdsResourceFormat.IntR8G8B8A8;
    case 'FloatR16G16'           : return DdsResourceFormat.FloatR16G16;
    case 'UnormR16G16'           : return DdsResourceFormat.UnormR16G16;
    case 'UintR16G16'            : return DdsResourceFormat.UintR16G16;
    case 'NormR16G16'            : return DdsResourceFormat.NormR16G16;
    case 'IntR16G16'             : return DdsResourceFormat.IntR16G16;
    case 'FloatR32'              : return DdsResourceFormat.FloatR32;
    case 'UintR32'               : return DdsResourceFormat.UintR32;
    case 'IntR32'                : return DdsResourceFormat.IntR32;
    case 'UnormR8G8'             : return DdsResourceFormat.UnormR8G8;
    case 'UintR8G8'              : return DdsResourceFormat.UintR8G8;
    case 'NormR8G8'              : return DdsResourceFormat.NormR8G8;
    case 'IntR8G8'               : return DdsResourceFormat.IntR8G8;
    case 'FloatR16'              : return DdsResourceFormat.FloatR16;
    case 'UnormR16'              : return DdsResourceFormat.UnormR16;
    case 'UintR16'               : return DdsResourceFormat.UintR16;
    case 'NormR16'               : return DdsResourceFormat.NormR16;
    case 'IntR16'                : return DdsResourceFormat.IntR16;
    case 'UnormR8'               : return DdsResourceFormat.UnormR8;
    case 'UintR8'                : return DdsResourceFormat.UintR8;
    case 'NormR8'                : return DdsResourceFormat.NormR8;
    case 'IntR8'                 : return DdsResourceFormat.IntR8;
    case 'UnormA8'               : return DdsResourceFormat.UnormA8;
    case 'SharedExpR9G9B9E5'     : return DdsResourceFormat.SharedExpR9G9B9E5;
    case 'UnormR8G8B8G8'         : return DdsResourceFormat.UnormR8G8B8G8;
    case 'UnormG8R8G8B8'         : return DdsResourceFormat.UnormG8R8G8B8;
    case 'UnormBc1'              : return DdsResourceFormat.UnormBc1;
    case 'SrgbUnormBc1'          : return DdsResourceFormat.SrgbUnormBc1;
    case 'UnormBc2'              : return DdsResourceFormat.UnormBc2;
    case 'SrgbUnormBc2'          : return DdsResourceFormat.SrgbUnormBc2;
    case 'UnormBc3'              : return DdsResourceFormat.UnormBc3;
    case 'SrgbUnormBc3'          : return DdsResourceFormat.SrgbUnormBc3;
    case 'UnormBc4'              : return DdsResourceFormat.UnormBc4;
    case 'NormBc4'               : return DdsResourceFormat.NormBc4;
    case 'UnormBc5'              : return DdsResourceFormat.UnormBc5;
    case 'NormBc5'               : return DdsResourceFormat.NormBc5;
    case 'UnormB5G6R5'           : return DdsResourceFormat.UnormB5G6R5;
    case 'UnormB5G5R5A1'         : return DdsResourceFormat.UnormB5G5R5A1;
    case 'UnormB8G8R8A8'         : return DdsResourceFormat.UnormB8G8R8A8;
    case 'UnormB8G8R8X8'         : return DdsResourceFormat.UnormB8G8R8X8;
    case 'XrBiasA2UnormR10G10B10': return DdsResourceFormat.XrBiasA2UnormR10G10B10;
    case 'SrgbUnormB8G8R8A8'     : return DdsResourceFormat.SrgbUnormB8G8R8A8;
    case 'SrgbUnormB8G8R8X8'     : return DdsResourceFormat.SrgbUnormB8G8R8X8;
    case 'Uf16Bc6h'              : return DdsResourceFormat.Uf16Bc6h;
    case 'Sf16Bc6h'              : return DdsResourceFormat.Sf16Bc6h;
    case 'UnormBc7'              : return DdsResourceFormat.UnormBc7;
    case 'SrgbUnormBc7'          : return DdsResourceFormat.SrgbUnormBc7;
  }

  return DdsResourceFormat.Unknown;
}

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

void testStandardTexture(String url, int width, int height, int mipMapCount, int resourceFormat, bool hasExtendedHeader) {
  getFile(url).then(expectAsync1((buffer) {
    expect(buffer != null, true);

    DdsFile ddsFile = new DdsFile(buffer);

    expect(ddsFile.width, width);
    expect(ddsFile.height, height);
    expect(ddsFile.depth, 1);
    expect(ddsFile.arraySize, 1);
    expect(ddsFile.mipMapCount, mipMapCount);
    expect(ddsFile.isCubeMap, false);
    expect(ddsFile.hasAllCubeMapFaces, false);
    //expect(ddsFile.isVolumeTexture, false);
    expect(ddsFile.resourceFormat, resourceFormat);
    expect(ddsFile.hasExtendedHeader, hasExtendedHeader);

    ddsFile.getPixelData(0, 0);
  }));
}

void testCubeMapTexture(String url, int width, int height, int mipMapCount, int resourceFormat, bool hasExtendedHeader) {
  getFile(url).then(expectAsync1((buffer) {
    expect(buffer != null, true);

    DdsFile ddsFile = new DdsFile(buffer);

    expect(ddsFile.width, width);
    expect(ddsFile.height, height);
    expect(ddsFile.depth, 1);
    expect(ddsFile.arraySize, 6);
    expect(ddsFile.mipMapCount, mipMapCount);
    expect(ddsFile.isCubeMap, true);
    expect(ddsFile.hasAllCubeMapFaces, true);
    expect(ddsFile.isVolumeTexture, false);
    expect(ddsFile.resourceFormat, resourceFormat);
    expect(ddsFile.hasExtendedHeader, hasExtendedHeader);
  }));
}

void testVolumeTexture(String url, int width, int height, int depth, int mipMapCount, int resourceFormat, bool hasExtendedHeader) {
  getFile(url).then(expectAsync1((buffer) {
    expect(buffer != null, true);

    DdsFile ddsFile = new DdsFile(buffer);

    expect(ddsFile.width, width);
    expect(ddsFile.height, height);
    expect(ddsFile.depth, depth);
    expect(ddsFile.arraySize, 1);
    expect(ddsFile.mipMapCount, mipMapCount);
    expect(ddsFile.isCubeMap, false);
    expect(ddsFile.hasAllCubeMapFaces, false);
    expect(ddsFile.isVolumeTexture, true);
    expect(ddsFile.resourceFormat, resourceFormat);
    expect(ddsFile.hasExtendedHeader, hasExtendedHeader);
  }));
}

void testFormats(bool dx10) {
  List formats;
  String testPrefix;
  String directory;

  if (dx10) {
    formats = dx10Formats;
    testPrefix = 'DX 10';
    directory = 'dds/formats/dx10/';
  } else {
    formats = dx9Formats;
    testPrefix = 'DX 9';
    directory = 'dds/formats/dx9/';
  }

  for (int i = 0; i < formats.length; ++i) {
    String format = formats[i];

    test('Format ${testPrefix} ${format}', () {
      String url = '${directory}lena_${format}.dds';

      testStandardTexture(url, 32, 32, 1, getDdsResourceFormat(format), dx10);
    });
  }
}

void testMipMaps(int levels, bool dx10) {
  String testPrefix;
  String directory;

  if (dx10) {
    testPrefix = 'DX 10';
    directory = 'dds/mipmaps/dx10/';
  } else {
    testPrefix = 'DX 9';
    directory = 'dds/mipmaps/dx9/';
  }

  for (int i = 1; i <= levels; ++i) {
    test('MipMap levels ${testPrefix} ${i}', () {
      String url = '${directory}lena_MipMapLevels${i}.dds';

      testStandardTexture(url, 32, 32, i, DdsResourceFormat.UnormBc1, dx10);
    });
  }
}

void main() {
  // Test that DX9 and DX10 formats can be identified
  testFormats(false);
  testFormats(true);

  // Test that mipmap levels can be identified
  testMipMaps(6, false);
  testMipMaps(6, true);

  // Test that cubemaps can be identified
  test('CubeMap DX 9', () {
    testCubeMapTexture('dds/cubemaps/dx9/mountain_path.dds', 128, 128, 8, DdsResourceFormat.UnormBc1, false);
  });

  test('CubeMap DX 10', () {
    testCubeMapTexture('dds/cubemaps/dx10/mountain_path.dds', 128, 128, 8, DdsResourceFormat.UnormBc1, true);
  });

  // Test that volume textures can be identified
  test('Volume DX 9', () {
    testVolumeTexture('dds/texture3d/dx9/lena_32x32x2.dds', 32, 32, 2, 1, DdsResourceFormat.UnormB8G8R8X8, false);
  });

  // Test reading uncompressed 2D textures
  test('Read 2D R8G8B8A data', () {
    getFile('dds/texture2d/dx9/red_256x256_UnormR8G8B8A8.dds').then(expectAsync1((buffer) {
      expect(buffer != null, true);

      DdsFile ddsFile = new DdsFile(buffer);

      expect(ddsFile.width, 256);
      expect(ddsFile.height, 256);
      expect(ddsFile.depth, 1);
      expect(ddsFile.arraySize, 1);
      expect(ddsFile.mipMapCount, 9);
      expect(ddsFile.isCubeMap, false);
      expect(ddsFile.hasAllCubeMapFaces, false);
      expect(ddsFile.isVolumeTexture, false);
      expect(ddsFile.resourceFormat, DdsResourceFormat.UnormR8G8B8A8);
      expect(ddsFile.hasExtendedHeader, false);

      List textureSize = [ 262144, 65536, 16384, 4096, 1024, 256, 64, 16, 4 ];
      int read = 128;
      int color = 0xff0000ff;
      int levels = textureSize.length;

      for (int i = 0; i < levels; ++i) {
        ArrayBuffer texture = ddsFile.getPixelData(0, i);

        expect(texture.byteLength, textureSize[i]);

        Uint32Array values = new Uint32Array.fromBuffer(texture);
        int length = values.length;

        for (int x = 0; x < length; ++x) {
          expect(values[x], color);
        }

        read += texture.byteLength;
      }

      // Verify that all bytes were read
      expect(read, buffer.byteLength);
    }));
  });

  test('Read 2D B5G6R5 NPOT data', () {
    getFile('dds/texture2d/dx9/red_31x31_UnormB5G6R5.dds').then(expectAsync1((buffer) {
      expect(buffer != null, true);

      DdsFile ddsFile = new DdsFile(buffer);

      expect(ddsFile.width, 31);
      expect(ddsFile.height, 31);
      expect(ddsFile.depth, 1);
      expect(ddsFile.arraySize, 1);
      expect(ddsFile.mipMapCount, 5);
      expect(ddsFile.isCubeMap, false);
      expect(ddsFile.hasAllCubeMapFaces, false);
      expect(ddsFile.isVolumeTexture, false);
      expect(ddsFile.resourceFormat, DdsResourceFormat.UnormB5G6R5);
      expect(ddsFile.hasExtendedHeader, false);

      List textureSize = [ 1922, 450, 98, 18, 2 ];
      int color = 0xf800;
      int levels = textureSize.length;

      for (int i = 0; i < levels; ++i) {
        ArrayBuffer texture = ddsFile.getPixelData(0, i);

        expect(texture.byteLength, textureSize[i]);

        Uint16Array values = new Uint16Array.fromBuffer(texture);
        int length = values.length;

        for (int x = 0; x < length; ++x) {
          expect(values[x], color);
        }
      }
    }));
  });

  // Test reading compressed 2D textures
  test('Read 2D UnormBc1 data', () {
    getFile('dds/texture2d/dx9/red_256x64_UnormBc1.dds').then(expectAsync1((buffer) {
      expect(buffer != null, true);

      DdsFile ddsFile = new DdsFile(buffer);

      expect(ddsFile.width, 256);
      expect(ddsFile.height, 64);
      expect(ddsFile.depth, 1);
      expect(ddsFile.arraySize, 1);
      expect(ddsFile.mipMapCount, 9);
      expect(ddsFile.isCubeMap, false);
      expect(ddsFile.hasAllCubeMapFaces, false);
      expect(ddsFile.isVolumeTexture, false);
      expect(ddsFile.resourceFormat, DdsResourceFormat.UnormBc1);
      expect(ddsFile.hasExtendedHeader, false);

      List textureSize = [ 8192, 2048, 512, 128, 32, 16, 8, 8, 8 ];
      int read = 128;
      int levels = textureSize.length;

      for (int i = 0; i < levels; ++i) {
        ArrayBuffer texture = ddsFile.getPixelData(0, i);

        expect(texture.byteLength, textureSize[i]);

        read += texture.byteLength;
      }

      // Verify that all bytes were read
      expect(read, buffer.byteLength);
    }));
  });

  test('Read 2D UnormBc3 data', () {
    getFile('dds/texture2d/dx10/red_256x64_UnormBc3.dds').then(expectAsync1((buffer) {
      expect(buffer != null, true);

      DdsFile ddsFile = new DdsFile(buffer);

      expect(ddsFile.width, 256);
      expect(ddsFile.height, 64);
      expect(ddsFile.depth, 1);
      expect(ddsFile.arraySize, 1);
      expect(ddsFile.mipMapCount, 9);
      expect(ddsFile.isCubeMap, false);
      expect(ddsFile.hasAllCubeMapFaces, false);
      expect(ddsFile.isVolumeTexture, false);
      expect(ddsFile.resourceFormat, DdsResourceFormat.UnormBc3);
      expect(ddsFile.hasExtendedHeader, true);

      List textureSize = [ 16384, 4096, 1024, 256, 64, 32, 16, 16, 16 ];
      int read = 148;
      int levels = textureSize.length;

      for (int i = 0; i < levels; ++i) {
        ArrayBuffer texture = ddsFile.getPixelData(0, i);

        expect(texture.byteLength, textureSize[i]);

        read += texture.byteLength;
      }

      // Verify that all bytes were read
      expect(read, buffer.byteLength);
    }));
  });

  // Test reading an uncompressed cubemap texture
  test('Read CubeMap UnormR8G8B8A8 data', () {
    getFile('dds/cubemaps/dx9/solid_cube_256x256_UnormR8G8B8A8.dds').then(expectAsync1((buffer) {
      expect(buffer != null, true);

      DdsFile ddsFile = new DdsFile(buffer);

      expect(ddsFile.width, 256);
      expect(ddsFile.height, 256);
      expect(ddsFile.depth, 1);
      expect(ddsFile.arraySize, 6);
      expect(ddsFile.mipMapCount, 9);
      expect(ddsFile.isCubeMap, true);
      expect(ddsFile.hasAllCubeMapFaces, true);
      expect(ddsFile.isVolumeTexture, false);
      expect(ddsFile.resourceFormat, DdsResourceFormat.UnormR8G8B8A8);
      expect(ddsFile.hasExtendedHeader, false);

      List textureSize = [ 262144, 65536, 16384, 4096, 1024, 256, 64, 16, 4 ];
      List colors = [ 0xff0000ff, 0xff00ff00, 0xffff0000, 0xffff00ff, 0xffffff00, 0xffffffff ];
      int read = 128;
      int levels = textureSize.length;

      for (int j = 0; j < 6; ++j) {
        for (int i = 0; i < levels; ++i) {
          ArrayBuffer texture = ddsFile.getPixelData(j, i);

          expect(texture.byteLength, textureSize[i]);

          Uint32Array values = new Uint32Array.fromBuffer(texture);
          int length = values.length;

          for (int x = 0; x < length; ++x) {
            expect(values[x], colors[j]);
          }

          read += texture.byteLength;
        }
      }

      // Verify that all bytes were read
      expect(read, buffer.byteLength);
    }));
  });

  // Test reading compressed cubemap textures
  test('Read CubeMap UnormBc1 data', () {
    getFile('dds/cubemaps/dx9/solid_cube_256x256_UnormBc1.dds').then(expectAsync1((buffer) {
      expect(buffer != null, true);

      DdsFile ddsFile = new DdsFile(buffer);

      expect(ddsFile.width, 256);
      expect(ddsFile.height, 256);
      expect(ddsFile.depth, 1);
      expect(ddsFile.arraySize, 6);
      expect(ddsFile.mipMapCount, 9);
      expect(ddsFile.isCubeMap, true);
      expect(ddsFile.hasAllCubeMapFaces, true);
      expect(ddsFile.isVolumeTexture, false);
      expect(ddsFile.resourceFormat, DdsResourceFormat.UnormBc1);
      expect(ddsFile.hasExtendedHeader, false);

      List textureSize = [ 32768, 8192, 2048, 512, 128, 32, 8, 8, 8 ];
      int read = 128;
      int levels = textureSize.length;

      for (int j = 0; j < 6; ++j) {
        for (int i = 0; i < levels; ++i) {
          ArrayBuffer texture = ddsFile.getPixelData(j, i);

          expect(texture.byteLength, textureSize[i]);

          read += texture.byteLength;
        }
      }

      // Verify that all bytes were read
      expect(read, buffer.byteLength);
    }));
  });

  // Test reading uncompressed volume textures
  test('Read Volume R8G8B8A8 data', () {
    getFile('dds/texture3d/dx9/solid_volume_64x64x4_UnormR8G8B8A8.dds').then(expectAsync1((buffer) {
      expect(buffer != null, true);

      DdsFile ddsFile = new DdsFile(buffer);

      expect(ddsFile.width, 64);
      expect(ddsFile.height, 64);
      expect(ddsFile.depth, 4);
      expect(ddsFile.arraySize, 1);
      expect(ddsFile.mipMapCount, 7);
      expect(ddsFile.isCubeMap, false);
      expect(ddsFile.hasAllCubeMapFaces, false);
      expect(ddsFile.isVolumeTexture, true);
      expect(ddsFile.resourceFormat, DdsResourceFormat.UnormR8G8B8A8);
      expect(ddsFile.hasExtendedHeader, false);

      List textureSize = [ 65536, 8192, 1024, 256, 64, 16, 4 ];
      List colors = [
        [ 0xff0000ff, 0xff00ff00, 0xffff0000, 0xffff00ff ],
        [ 0xff008080, 0xffff0080 ],
        [ 0xff804080 ],
        [ 0xff804080 ],
        [ 0xff804080 ],
        [ 0xff804080 ],
        [ 0xff804080 ]
      ];

      int read = 128;
      int levels = textureSize.length;
      int width  = ddsFile.width;
      int height = ddsFile.height;
      int depth  = ddsFile.depth;

      for (int i = 0; i < levels; ++i) {
        ArrayBuffer texture = ddsFile.getPixelData(0, i);

        expect(texture.byteLength, textureSize[i]);

        Uint32Array values = new Uint32Array.fromBuffer(texture);

        int index = 0;

        for (int y = 0; y < depth; ++y) {
          int length = width * height;
          for (int x = 0; x < length; ++x) {
            expect(values[index++], colors[i][y]);
          }
        }

        width  = Math.max(1, width  ~/ 2);
        height = Math.max(1, height ~/ 2);
        depth  = Math.max(1, depth  ~/ 2);

        read += texture.byteLength;
      }

      // Verify that all bytes were read
      expect(read, buffer.byteLength);
    }));
  });
}

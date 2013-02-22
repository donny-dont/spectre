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

void main() {
  test('invalid file', () {

  });

  test('cube map', () {
    getFile('dds/cube.dds').then(expectAsync1((buffer) {
      expect(buffer != null, true);

      DdsFile ddsFile = new DdsFile(buffer);

      expect(ddsFile.width, 512);
      expect(ddsFile.height, 512);
    }));
  });
}

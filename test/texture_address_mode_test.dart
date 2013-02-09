library texture_address_mode_test;

/*

  Copyright (C) 2012 John McCutchan <john@johnmccutchan.com>

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

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre.dart';
import 'dart:html';

void main() {
  test('values', () {
    expect(TextureAddressMode.Clamp , WebGLRenderingContext.CLAMP_TO_EDGE);
    expect(TextureAddressMode.Mirror, WebGLRenderingContext.MIRRORED_REPEAT);
    expect(TextureAddressMode.Wrap  , WebGLRenderingContext.REPEAT);
  });

  test('stringify', () {
    expect(TextureAddressMode.stringify(TextureAddressMode.Clamp) , 'TextureAddressMode.Clamp');
    expect(TextureAddressMode.stringify(TextureAddressMode.Mirror), 'TextureAddressMode.Mirror');
    expect(TextureAddressMode.stringify(TextureAddressMode.Wrap)  , 'TextureAddressMode.Wrap');

    expect(() { TextureAddressMode.stringify(-1); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('parse', () {
    expect(TextureAddressMode.parse('TextureAddressMode.Clamp') , TextureAddressMode.Clamp);
    expect(TextureAddressMode.parse('TextureAddressMode.Mirror'), TextureAddressMode.Mirror);
    expect(TextureAddressMode.parse('TextureAddressMode.Wrap')  , TextureAddressMode.Wrap);

    expect(() { CullMode.parse('NotValid'); }, throwsA(new isInstanceOf<AssertionError>()));
  });

  test('isValid', () {
    expect(TextureAddressMode.isValid(TextureAddressMode.Clamp) , true);
    expect(TextureAddressMode.isValid(TextureAddressMode.Mirror), true);
    expect(TextureAddressMode.isValid(TextureAddressMode.Wrap)  , true);

    expect(TextureAddressMode.isValid(-1), false);
  });
}

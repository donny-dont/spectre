/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>
  Copyright (C) 2013 Don Olmstead <don.j.olmstead@gmail.com>

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

library input_element_usage_test;

import 'package:unittest/unittest.dart';
import 'package:spectre/spectre.dart';

void main() {
  test('values', () {
    expect(InputElementUsage.Position         , 0);
    expect(InputElementUsage.Normal           , 1);
    expect(InputElementUsage.Tangent          , 2);
    expect(InputElementUsage.Binormal         , 3);
    expect(InputElementUsage.TextureCoordinate, 4);
    expect(InputElementUsage.Color            , 5);
    expect(InputElementUsage.PointSize        , 6);
  });

  test('stringify', () {
    expect(InputElementUsage.stringify(InputElementUsage.Position),
                                      'InputElementUsage.Position');
    expect(InputElementUsage.stringify(InputElementUsage.Normal),
                                      'InputElementUsage.Normal');
    expect(InputElementUsage.stringify(InputElementUsage.Tangent),
                                      'InputElementUsage.Tangent');
    expect(InputElementUsage.stringify(InputElementUsage.Binormal),
                                      'InputElementUsage.Binormal');
    expect(InputElementUsage.stringify(InputElementUsage.TextureCoordinate),
                                      'InputElementUsage.TextureCoordinate');
    expect(InputElementUsage.stringify(InputElementUsage.Color),
                                      'InputElementUsage.Color');
    expect(InputElementUsage.stringify(InputElementUsage.PointSize),
                                      'InputElementUsage.PointSize');

    expect(
        () { InputElementUsage.stringify(-1); },
        throwsA(new isInstanceOf<AssertionError>())
    );
  });

  test('parse', () {
    expect(InputElementUsage.parse('InputElementUsage.Position'),
                                    InputElementUsage.Position);
    expect(InputElementUsage.parse('InputElementUsage.Normal'),
                                    InputElementUsage.Normal);
    expect(InputElementUsage.parse('InputElementUsage.Tangent'),
                                    InputElementUsage.Tangent);
    expect(InputElementUsage.parse('InputElementUsage.Binormal'),
                                    InputElementUsage.Binormal);
    expect(InputElementUsage.parse('InputElementUsage.TextureCoordinate'),
                                    InputElementUsage.TextureCoordinate);
    expect(InputElementUsage.parse('InputElementUsage.Color'),
                                    InputElementUsage.Color);
    expect(InputElementUsage.parse('InputElementUsage.PointSize'),
                                    InputElementUsage.PointSize);

    expect(
        () { InputElementUsage.parse('NotValid'); },
        throwsA(new isInstanceOf<AssertionError>())
    );
  });

  test('isValid', () {
    expect(InputElementUsage.isValid(InputElementUsage.Position)         , true);
    expect(InputElementUsage.isValid(InputElementUsage.Normal)           , true);
    expect(InputElementUsage.isValid(InputElementUsage.Tangent)          , true);
    expect(InputElementUsage.isValid(InputElementUsage.Binormal)         , true);
    expect(InputElementUsage.isValid(InputElementUsage.TextureCoordinate), true);
    expect(InputElementUsage.isValid(InputElementUsage.Color)            , true);
    expect(InputElementUsage.isValid(InputElementUsage.PointSize)        , true);

    expect(InputElementUsage.isValid(-1), false);
  });
}

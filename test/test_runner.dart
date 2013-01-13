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
import 'package:unittest/html_config.dart';
import 'blend_test.dart' as blend_test;
import 'blend_operation_test.dart' as blend_operation_test;
import 'blend_state_test.dart' as blend_state_test;
import 'graphics_context_test.dart' as graphics_context_test;

void main() {
  useHtmlConfiguration();

  group('Blend tests', blend_test.main);
  group('BlendOperation tests', blend_operation_test.main);
  group('BlendState tests', blend_state_test.main);
  group('GraphicsContext tests', graphics_context_test.main);
}

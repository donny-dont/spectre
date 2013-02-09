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
import 'package:unittest/html_enhanced_config.dart';
import 'blend_test.dart' as blend_test;
import 'blend_operation_test.dart' as blend_operation_test;
import 'blend_state_test.dart' as blend_state_test;
import 'compare_function_test.dart' as compare_function_test;
import 'cull_mode_test.dart' as cull_mode_test;
import 'depth_state_test.dart' as depth_state_test;
import 'front_face_test.dart' as front_face_test;
import 'graphics_context_test.dart' as graphics_context_test;
import 'rasterizer_state_test.dart' as rasterizer_state_test;
import 'surface_format_test.dart' as surface_format_test;
import 'texture_address_mode_test.dart' as texture_address_mode_test;
import 'texture_mag_filter_test.dart' as texture_mag_filter_test;
import 'texture_min_filter_test.dart' as texture_min_filter_test;
import 'viewport_test.dart' as viewport_test;

void main() {
  useHtmlEnhancedConfiguration();

  group('Blend tests', blend_test.main);
  group('BlendOperation tests', blend_operation_test.main);
  group('BlendState tests', blend_state_test.main);
  group('CompareFunction tests', compare_function_test.main);
  group('CullMode tests', cull_mode_test.main);
  group('DepthState tests', depth_state_test.main);
  group('FrontFace tests', front_face_test.main);
  group('GraphicsContext tests', graphics_context_test.main);
  group('RasterizerState tests', rasterizer_state_test.main);
  group('SurfaceFormat tests', surface_format_test.main);
  group('TextureAddressMode tests', texture_address_mode_test.main);
  group('TextureMagFilter tests', texture_mag_filter_test.main);
  group('TextureMinFilter tests', texture_min_filter_test.main);
  group('Viewport tests', viewport_test.main);
}

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

/** Spectre Library */

library spectre;

import 'dart:html';
import 'dart:json';
import 'package:vector_math/vector_math_browser.dart';
import 'package:handle_system/handle_system.dart';
import 'package:marker_prof/profiler.dart';

part 'src/spectre/blend.dart';
part 'src/spectre/blend_function.dart';
part 'src/spectre/camera.dart';
part 'src/spectre/camera_controller.dart';
part 'src/spectre/command_list_builder.dart';
part 'src/spectre/command_list_operations.dart';
part 'src/spectre/compare_function.dart';
part 'src/spectre/cull_mode.dart';
part 'src/spectre/debug_draw_manager.dart';
part 'src/spectre/device_children.dart';
part 'src/spectre/graphics_context.dart';
part 'src/spectre/graphics_device.dart';
part 'src/spectre/graphics_device_capabilities.dart';
part 'src/spectre/input_layout_helper.dart';
part 'src/spectre/interpreter.dart';
part 'src/spectre/logger.dart';
part 'src/spectre/mouse_keyboard_camera_controller.dart';
part 'src/spectre/resource.dart';
part 'src/spectre/resource_loader.dart';
part 'src/spectre/resource_manager.dart';
part 'src/spectre/texture_address_mode.dart';

// We have a single logger
Logger spectreLog;

Future<bool> initSpectre() {
  if (spectreLog == null) {
    spectreLog = new PrintLogger();
  }
  return new Future.immediate(true);
}

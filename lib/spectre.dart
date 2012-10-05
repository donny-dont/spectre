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

#library('Spectre');
#import('dart:html');
#import('dart:json');
#import('package:dartvectormath/vector_math_html.dart');
#import('package:handlesystem/handlesystem.dart');
#import('package:markerprof/profiler.dart');
#source('src/spectre/logger.dart');
#source('src/spectre/device_children.dart');
#source('src/spectre/device.dart');
#source('src/spectre/immediate_context.dart');
#source('src/spectre/resource_loader.dart');
#source('src/spectre/resource.dart');
#source('src/spectre/resource_manager.dart');
#source('src/spectre/program.dart');
#source('src/spectre/program_builder.dart');
#source('src/spectre/interpreter.dart');
#source('src/spectre/input_layout_helper.dart');
#source('src/spectre/debug_draw_manager.dart');

#source('src/spectre/camera.dart');
#source('src/spectre/camera_controller.dart');
#source('src/spectre/mouse_keyboard_camera_controller.dart');

// We have a single logger
Logger spectreLog;

Future<bool> initSpectre() {
  if (spectreLog == null) {
    spectreLog = new PrintLogger();
  }
  return new Future.immediate(true);
}

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
#import('package:DartVectorMath/vector_math_html.dart');
#import('handle.dart');
#import('package:markerprof/profiler.dart');
#source('spectre/logger.dart');
#source('spectre/device_children.dart');
#source('spectre/device.dart');
#source('spectre/immediate_context.dart');
#source('spectre/resource_loader.dart');
#source('spectre/resource.dart');
#source('spectre/resource_manager.dart');
#source('spectre/program.dart');
#source('spectre/program_builder.dart');
#source('spectre/interpreter.dart');
#source('spectre/input_layout_helper.dart');
#source('spectre/debug_draw_manager.dart');

#source('spectre/camera.dart');
#source('spectre/camera_controller.dart');
#source('spectre/mouse_keyboard_camera_controller.dart');

// We have a single logger
Logger spectreLog;

Future<bool> initSpectre() {
  if (spectreLog == null) {
    spectreLog = new PrintLogger();
  }
  return new Future.immediate(true);
}
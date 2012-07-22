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
#import('VectorMath/VectorMath.dart');
#source('Logger.dart');
#source('Handle.dart');
#source('HandleSystem.dart');
#source('DeviceChildren.dart');
#source('Device.dart');
#source('ImmediateContext.dart');
#source('ResourceLoader.dart');
#source('Resource.dart');
#source('ResourceManager.dart');
#source('Program.dart');
#source('ProgramBuilder.dart');
#source('Interpreter.dart');

#source('Camera.dart');
#source('CameraController.dart');
#source('MouseKeyboardCameraController.dart');
#source('InputLayoutHelper.dart');
#source('DebugDrawManager.dart');

// We have a single logger
Logger spectreLog;

Future<bool> initSpectre() {
  if (spectreLog == null) {
    spectreLog = new PrintLogger();
  }
  return new Future.immediate(true);
}
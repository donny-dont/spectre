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
#source('Device.dart');
#source('ImmediateContext.dart');
#source('Resource.dart');
#source('ResourceManager.dart');
#source('StaticResources.dart');
#source('Camera.dart');
#source('CameraController.dart');
#source('MouseKeyboardCameraController.dart');
#source('InputLayoutHelper.dart');
#source('DebugDrawManager.dart');

// We have a single WebGL context
WebGLRenderingContext webGL;
/// [spectreDevice] is the global Spectre GPU device instance
Device spectreDevice;
/// [spectreImmediateContext] is the global Spectre GPU Immediate context instance
ImmediateContext spectreImmediateContext;
/// [spectreDDM] is the global Spectre debug draw manager instance
DebugDrawManager spectreDDM;
// We have a single logger
Logger spectreLog;
/// [spectreRM] is the global Sprectre resource manager instance
ResourceManager spectreRM;

/// Initializes the Spectre graphis engine. [canvasName] is the CSS id of the canvas to render to
/// Returns a Future that will complete when all required resources are loaded and the engine is running
Future<bool> initSpectre(String canvasName) {
  if (spectreLog == null) {
    spectreLog = new PrintLogger();
  }
  spectreLog.Info('Started Spectre');
  CanvasElement canvas = document.query(canvasName);
  webGL = canvas.getContext("experimental-webgl");
  spectreDevice = new Device();
  spectreImmediateContext = new ImmediateContext();
  spectreDDM = new DebugDrawManager();
  spectreRM = new ResourceManager();
  var baseUrl = "${window.location.href.substring(0, window.location.href.length - "index.html".length)}data/";
  spectreRM.setBaseURL(baseUrl);
  print('Started Spectre');
  List loadedResources = [];
  loadedResources.add(spectreRM.load('/shaders/debug_line.vs'));
  loadedResources.add(spectreRM.load('/shaders/debug_line.fs'));
  Future allLoaded = Futures.wait(loadedResources);
  Completer<bool> inited = new Completer<bool>();
  allLoaded.then((resourceList) {
    VertexShaderResource lineVShader = resourceList[0];
    FragmentShaderResource linePShader = resourceList[1];
    spectreDDM.Init(lineVShader, linePShader, null, null, null);
    inited.complete(true);
  });
  return inited.future;
}

void checkWebGL() {
  if (webGL == null) {
    return;
  }
  
  int error = webGL.getError();
  if (error != WebGLRenderingContext.NO_ERROR) {
    spectreLog.Error('WebGL Error: $error');
  }
}
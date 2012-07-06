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

#import('dart:html');
#import('Spectre.dart');
#import('VectorMath/VectorMath.dart');
#import('Javeline.dart');

class JavelineDemoDescription {
  String name;
  Function constructDemo;
}

class JavelineDemoLaunch {
  JavelineDemoInterface _demo;
  List<JavelineDemoDescription> demos;
  
  void registerDemo(String name, Function constructDemo) {
    JavelineDemoDescription jdd = new JavelineDemoDescription();
    jdd.name = name;
    jdd.constructDemo = constructDemo;
    demos.add(jdd);
  }
  
  JavelineDemoLaunch() { 
    _demo = null;
    demos = new List<JavelineDemoDescription>();
  }
  
  void updateStatus(String message) {
    // the HTML library defines a global "document" variable
    document.query('#DartStatus').innerHTML = message;
  }
  
  void run() {
    // Start spectre
    updateStatus("(Dart Is Running)");
    spectreLog = new HtmlLogger('#SpectreLog');
    Future<bool> spectreStarted = initSpectre("#webGLFrontBuffer");
    
    spectreStarted.then((value) {
      print('Launching demo');
      webGL.clearColor(0.0, 0.0, 0.0, 1.0);
      webGL.clearDepth(1.0);
      webGL.clear(WebGLRenderingContext.COLOR_BUFFER_BIT|WebGLRenderingContext.DEPTH_BUFFER_BIT);
      
      registerDemo('Debug Draw Test', () { return new JavelineDebugDrawTest(); });
      registerDemo('Spinning Cube', () { return new JavelineSpinningCube(); });

      // Select demo
      //_demo = new JavelineImmediateTest();
      //_demo = new JavelineDebugDrawTest();
      _demo = new JavelineSpinningCube();
      
      // Start demo
      Future<JavelineDemoStatus> started = _demo.startup();
      started.then((statusValue) {
        _demo.run();
        print('Running demo');
      });
    });
  }
  
  void switchToDemo(String name) {
    Future shut;
    if (_demo != null) {
      shut = _demo.shutdown();
    } else {
      shut = new Future.immediate(new JavelineDemoStatus(JavelineDemoStatus.DemoStatusOKAY, ''));
    }
    shut.then((statusValue) {
      _demo = null;
      for (final JavelineDemoDescription jdd in demos) {
        if (jdd.name == name) {
          _demo = jdd.constructDemo();
          break;
        }
      }
    });
  }
}

void main() {
  JavelineConfigStorage.init();
  JavelineConfigStorage.load();
  new JavelineDemoLaunch().run();
}
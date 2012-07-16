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
    refreshDemoList('#DemoPicker');
  }
  
  JavelineDemoLaunch() { 
    _demo = null;
    demos = new List<JavelineDemoDescription>();
  }
  
  void updateStatus(String message) {
    // the HTML library defines a global "document" variable
    document.query('#DartStatus').innerHTML = message;
  }
  
  void refreshDemoList(String listDiv) {
    DivElement d = document.query(listDiv);
    if (d == null) {
      return;
    }
    d.nodes.clear();
    for (final JavelineDemoDescription jdd in demos) {
      DivElement demod = new DivElement();
      demod.on.click.add((Event event) {
        switchToDemo(jdd.name);
      });
      demod.innerHTML = '${jdd.name}';
      demod.classes.add('DemoButton');
      d.nodes.add(demod);
    }
  }
  
  void refreshResourceManagerTable() {
    final String divName = '#ResourceManagerTable';
    DivElement d = document.query(divName);
    if (d == null) {
      return;
    }
    d.nodes.clear();
    ParagraphElement pe = new ParagraphElement();
    pe.innerHTML = 'Loaded Resources:';
    d.nodes.add(pe);
    spectreRM.children.forEach((name, resource) {
      DivElement resourceDiv = new DivElement();
      resourceDiv.innerHTML = '${name}';
      d.nodes.add(resourceDiv);
    });
  }
  
  void refreshDeviceManagerTable() {
    final String divName = '#DeviceChildTable';
    DivElement d = document.query(divName);
    d.nodes.clear();
    ParagraphElement pe = new ParagraphElement();
    pe.innerHTML = 'Device Objects:';
    d.nodes.add(pe);
    if (d == null) {
      return;
    }
    spectreDevice.children.forEach((name, handle) {
      DivElement resourceDiv = new DivElement();
      String type = spectreDevice.getHandleType(handle);
      resourceDiv.innerHTML = '${name} ($type)';
      d.nodes.add(resourceDiv);
    });
  }
  
  void run() {
    updateStatus("Pick a demo: ");
    // Start spectre
    Future<bool> spectreStarted = initSpectre("#webGLFrontBuffer");
    spectreStarted.then((value) {
      print('Spectre Launched');
      webGL.clearColor(0.0, 0.0, 0.0, 1.0);
      webGL.clearDepth(1.0);
      webGL.clear(WebGLRenderingContext.COLOR_BUFFER_BIT|WebGLRenderingContext.DEPTH_BUFFER_BIT);
      registerDemo('Empty Demo', () { return new JavelineEmptyDemo(); });
      registerDemo('Debug Draw Test', () { return new JavelineDebugDrawTest(); });
      registerDemo('Spinning Cube', () { return new JavelineSpinningCube(); });
      window.setInterval(refreshResourceManagerTable, 1000);
      window.setInterval(refreshDeviceManagerTable, 1000);
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
      if (_demo != null) {
        print('Starting demo $name');
        Future<JavelineDemoStatus> started = _demo.startup();
        started.then((sv) {
          print('Running demo $name');
          _demo.run();
        });
      }
    });
  }
}

void main() {
  JavelineConfigStorage.init();
  JavelineConfigStorage.load();
  spectreLog = new HtmlLogger('#SpectreLog');
  new JavelineDemoLaunch().run();
}
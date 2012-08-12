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
#import('../../external/DartVectorMath/lib/vector_math_html.dart');
#import('../../lib/spectre.dart');
#import('../../lib/javeline.dart');
#import('../../lib/profiler.dart');
#import('../../lib/profiler_gui.dart');
#import('../../lib/profiler_client.dart');
#import('hfluid.dart');

// Demos
#source('demo_empty.dart');
#source('demo_debug_draw.dart');
#source('demo_spinning_cube.dart');
#source('demo_hfluid.dart');

class JavelineDemoDescription {
  String name;
  Function constructDemo;
}

class JavelineDemoLaunch {
  JavelineBaseDemo _demo;
  List<JavelineDemoDescription> demos;
  ProfilerClient profilerClient;

  Device device;
  ResourceManager resourceManager;
  DebugDrawManager debugDrawManager;
  ProfilerTree tree;

  bool isLocked;

  void captured(List data) {
  }

  void captureControl(int command, String requester) {
    if (command == ProfilerClient.StartCapture) {
      spectreLog.Info('$requester started capture');
      Profiler.clear();
    }
    if (command == ProfilerClient.StopCapture) {
      spectreLog.Info('$requester stopped capture');
      List capture = Profiler.makeCapture();
      //spectreLog.Info('$capture');
      profilerClient.deliverCapture(requester, capture);
    }
  }

  void registerDemo(String name, Function constructDemo) {
    JavelineDemoDescription jdd = new JavelineDemoDescription();
    jdd.name = name;
    jdd.constructDemo = constructDemo;
    demos.add(jdd);
    refreshDemoList('#DemoPicker');
  }

  void webglClicked(Event ev) {
    document.query('#webGLFrontBuffer').webkitRequestPointerLock();
  }

  void pointerLockChanged(Event ev) {
    isLocked = document.query('#webGLFrontBuffer') == document.webkitPointerLockElement;
    if (_demo != null) {
      _demo.mouse.locked = isLocked;
    }
  }

  JavelineDemoLaunch() {
    _demo = null;
    demos = new List<JavelineDemoDescription>();
    tree = new ProfilerTree();
    isLocked = false;
    profilerClient = new ProfilerClient('Javeline', captured, captureControl, ProfilerClient.TypeUserApplication);
    profilerClient.connect('ws://127.0.0.1:8087/');
    document.on.pointerLockChange.add(pointerLockChanged);
    document.query('#webGLFrontBuffer').on.click.add(webglClicked);
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
    resourceManager.children.forEach((name, resource) {
      DivElement resourceDiv = new DivElement();
      DivElement resourceNameDiv = new DivElement();
      DivElement resourceUnloadDiv = new DivElement();
      DivElement resourceLoadDiv = new DivElement();
      resourceNameDiv.innerHTML = '${name}';
      resourceLoadDiv.innerHTML = 'Load';
      resourceLoadDiv.on.click.add((Event event) {
        resourceManager.loadResource(resource);
      });
      resourceUnloadDiv.innerHTML = 'Unload';
      resourceUnloadDiv.on.click.add((Event event) {
        resourceManager.unloadResource(resource);
      });
      resourceLoadDiv.classes.add('DemoButton');
      resourceUnloadDiv.classes.add('DemoButton');
      resourceDiv.nodes.add(resourceNameDiv);
      resourceDiv.nodes.add(resourceLoadDiv);
      resourceDiv.nodes.add(resourceUnloadDiv);
      resourceDiv.classes.add('ResourceRow');
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
    if (_demo == null) {
      return;
    }
    _demo.device.children.forEach((name, handle) {
      DivElement resourceDiv = new DivElement();
      String type = _demo.device.getHandleType(handle);
      resourceDiv.innerHTML = '${name} ($type)';
      d.nodes.add(resourceDiv);
    });
  }

  void resizeHandler(Event event) {
    updateSize();
  }

  void updateSize() {
    String webGLCanvasParentName = '#MainView';
    String webGLCanvasName = '#webGLFrontBuffer';
    {
      DivElement canvasParent = document.query(webGLCanvasParentName);
      final num width = canvasParent.$dom_clientWidth;
      final num height = canvasParent.$dom_clientHeight;
      CanvasElement canvas = document.query(webGLCanvasName);
      canvas.width = width;
      canvas.height = height;
      if (_demo != null) {
        _demo.resize(width, height);
      }
    }
  }

  Future<bool> startup() {
    final String webGLCanvasParentName = '#MainView';
    final String webGLCanvasName = '#webGLFrontBuffer';
    spectreLog.Info('Started Javeline');
    CanvasElement canvas = document.query(webGLCanvasName);
    WebGLRenderingContext webGL = canvas.getContext("experimental-webgl");
    device = new Device(webGL);
    debugDrawManager = new DebugDrawManager();
    resourceManager = new ResourceManager();
    var baseUrl = "${window.location.href.substring(0, window.location.href.length - "index.html".length)}data/";
    resourceManager.setBaseURL(baseUrl);

    Future<int> debugPackLoaded = null;
    {
      int debugPackResourceHandle = resourceManager.registerResource('/packs/debug.pack');
      debugPackLoaded = resourceManager.loadResource(debugPackResourceHandle);
    }
    Completer<bool> inited = new Completer<bool>();
    debugPackLoaded.then((resourceList) {
      debugDrawManager.init(device,
        resourceManager,
        resourceManager.getResourceHandle('/shaders/debug_line.vs'),
        resourceManager.getResourceHandle('/shaders/debug_line.fs'),
        resourceManager.getResourceHandle('/shaders/debug_sphere.vs'),
        resourceManager.getResourceHandle('/shaders/debug_sphere.fs'),
        resourceManager.getResourceHandle('/meshes/unitSphere.mesh'));
      inited.complete(true);
    });
    return inited.future;
  }
  void run() {
    updateStatus("Pick a demo: ");
    window.on.resize.add(resizeHandler);
    updateSize();
    // Start spectre
    Future<bool> started = startup();
    started.then((value) {
      spectreLog.Info('Javeline Running');
      device.immediateContext.clearColorBuffer(0.0, 0.0, 0.0, 1.0);
      device.immediateContext.clearDepthBuffer(1.0);
      registerDemo('Empty', () { return new JavelineEmptyDemo(device, resourceManager, debugDrawManager); });
      registerDemo('Debug Draw Test', () { return new JavelineDebugDrawTest(device, resourceManager, debugDrawManager); });
      registerDemo('Spinning Cube', () { return new JavelineSpinningCube(device, resourceManager, debugDrawManager); });
      registerDemo('Height Field Fluid', () { return new JavelineHFluidDemo(device, resourceManager, debugDrawManager); });
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
          updateSize();
          _demo.mouse.locked = isLocked;
          _demo.run();
        });
      }
    });
  }
}

void main() {
  Profiler.init();
  JavelineConfigStorage.init();
  // Comment out the following line to keep defaults
  JavelineConfigStorage.load();
  spectreLog = new HtmlLogger('#SpectreLog');
  new JavelineDemoLaunch().run();
}
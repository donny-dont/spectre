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

typedef void ResourceEventCallback(int type, ResourceBase resource);

class ResourceEvents {
  static final int TypeUpdate = 0x1;
  static final int TypeUnloaded = 0x2;
  Map<int, ResourceEventCallback> update;
  Map<int, ResourceEventCallback> unloaded;
  int _idCounter;
  ResourceEvents() {
    update = new HashMap();
    unloaded = new HashMap();
    _idCounter = 0;
  }

  int addUpdate(ResourceEventCallback cb) {
    _idCounter++;
    if (_idCounter == 0) {
      _idCounter++;
    }
    update[_idCounter] = cb;
    return _idCounter;
  }
  
  void removeUpdate(int id) {
    update.remove(id);
  }
  
  int addUnloaded(ResourceEventCallback cb) {
    _idCounter++;
    if (_idCounter == 0) {
      _idCounter++;
    }
    unloaded[_idCounter] = cb;
    return _idCounter;
  }
  
  void removeUnloaded(int id) {
    unloaded.remove(id);
  }
}

class ResourceBase {
  bool _isLoaded;
  bool get isLoaded() => _isLoaded;

  String _url;
  String get url() => _url;

  ResourceEvents on;
  ResourceManager _rm;

  ResourceBase(this._url, this._rm) {
    _isLoaded = false;
    on = new ResourceEvents();
  }

  void load(ResourceLoaderResult result) {
    _fireUpdated();
  }
  
  void update(Map state) {
    _fireUpdated();
  }
  
  void unload() {
    _fireUnloaded();
  }
  void deregister() {
  }
  
  void notifyUpdate() {
    _fireUpdated();
  }

  // Call after the data is updated
  void _fireUpdated() {
    on.update.forEach((key, value) {
      value(ResourceEvents.TypeUpdate, this);
    });
  }

  // Call before the data is gone
  void _fireUnloaded() {
    on.unloaded.forEach((key, value) {
      value(ResourceEvents.TypeUpdate, this);
    });
  }
}

class Float32ArrayResource extends ResourceBase {
  Float32Array _array;

  Float32ArrayResource(String url, ResourceManager rm) : super(url, rm) {
  }

  Float32Array get array() => _array;
  set array(Float32Array array) {
    _array = array;
    _fireUpdated();
  }
  
  void load(ResourceLoaderResult result) {
    _fireUpdated();
    result.completer.complete(result.handle);
  }
  
  void update(Map state) {
    Dynamic o;
    o = state['array'];
    if (o != null && o is Float32Array) {
      _array = o;
      _fireUpdated();
    }
    o = state['list'];
    if (o != null && o is List<num>) {
      _array = new Float32Array.fromList(o);
      _fireUpdated();
    }
  }

  void unload() {
    _fireUnloaded();
    _array = null;
  }
}

class Uint16ArrayResource extends ResourceBase {
  Uint16Array _array;

  Uint16ArrayResource(String url, ResourceManager rm) : super(url, rm) {
  }

  Uint16Array get array() => _array;
  set array(Uint16Array array) {
    _array = array;
    _fireUpdated();
  }
  
  void load(ResourceLoaderResult result) {
    _fireUpdated();
    result.completer.complete(result.handle);
  }

  void unload() {
    _fireUnloaded();
  }
}

class MeshResource extends ResourceBase {
  Map meshData;
  Float32Array vertexArray;
  Uint16Array indexArray;

  MeshResource(String url, ResourceManager rm) : super(url, rm) {

  }

  int get numIndices() {
    return meshData['meshes'][0]['indices'].length;
  }

  void load(ResourceLoaderResult result) {
    if (result.success == false) {
      return;
    }
    meshData = JSON.parse(result.data);
    indexArray = new Uint16Array.fromList(meshData['meshes'][0]['indices']);
    vertexArray = new Float32Array.fromList(meshData['meshes'][0]['vertices']);
    _fireUpdated();
    result.completer.complete(result.handle);
  }

  void unload() {
    _fireUnloaded();
    vertexArray = null;
    indexArray = null;
    meshData = null;
  }
}

class ShaderResource extends ResourceBase {
  String source;

  ShaderResource(String url, ResourceManager rm) : super(url, rm) {
    source = '';
  }

  void load(ResourceLoaderResult result) {
    if (result.success == false) {
      return;
    }
    source = result.data;
    _fireUpdated();
    result.completer.complete(result.handle);
  }
  
  void update(Map state) {
    Dynamic o = state['source'];
    if (o != null && o is String) {
      source = o;
      _fireUpdated();
    }
  }

  void unload() {
    _fireUnloaded();
    source = null;
  }
}

class ShaderProgramResource extends ResourceBase {
  String vertexShaderSource;
  String fragmentShaderSource;
  
  ShaderProgramResource(String url, ResourceManager rm) : super(url, rm) {
    vertexShaderSource = '';
    fragmentShaderSource = '';
  }

  void load(ResourceLoaderResult result) {
    if (result.success == false) {
      return;
    }
    List<Future> futures = new List();
    bool fetchedVertex = false;
    bool fetchedFragment = false;
    if (result.data is String) {
      Map spdata = JSON.parse(result.data);
      String inlineVertexShader = spdata['inlineVertexShader'];
      String inlineFragmentShader = spdata['inlineFragmentShader'];
      String fetchVertexShader = spdata['fetchVertexShader'];
      String fetchFragmentShader = spdata['fetchFragmentShader'];
      if (inlineVertexShader != null) {
        vertexShaderSource = inlineVertexShader;
      }
      if (fetchVertexShader != null) {
        fetchedVertex = true;
        futures.add(new ShaderResourceLoader().load('${_rm._baseURL}${fetchVertexShader}'));
      }
      if (inlineFragmentShader != null) {
        fragmentShaderSource = inlineFragmentShader;
      }
      if (fetchFragmentShader != null) {
        fetchedFragment = true;
        futures.add(new ShaderResourceLoader().load('${_rm._baseURL}${fetchFragmentShader}'));        
      }
    }
    if (futures.length > 0) {
      Future all = Futures.wait(futures);
      all.then((results) {
        int index = 0;
        if (fetchedVertex) {
          ResourceLoaderResult vsResult = results[index];
          index++;
          if (vsResult.success) {
            vertexShaderSource = vsResult.data;
          }
        }
        if (fetchedFragment) {
          ResourceLoaderResult fsResult = results[index];
          if (fsResult.success) {
            fragmentShaderSource = fsResult.data;
          }
        }
        _fireUpdated();
        result.completer.complete(result.handle);
      });  
    } else {
      _fireUpdated();
      result.completer.complete(result.handle);
    }
  }
  
  void update(Map state) {
    Dynamic o = state['vertexShaderSource'];
    if (o != null && o is String) {
      vertexShaderSource = o;
    }
    o = state['fragmentShaderSource'];
    if (o != null && o is String) {
      fragmentShaderSource = o;
    }
    _fireUpdated();
  }

  void unload() {
    _fireUnloaded();
    vertexShaderSource = null;
    fragmentShaderSource = null;
  }
}

class ImageResource extends ResourceBase {
  ImageElement _image;

  ImageResource(String url, ResourceManager rm) : super(url, rm) {

  }
  
  ImageElement get image() => _image;

  void load(ResourceLoaderResult result) {
    if (result.success == false) {
      return;
    }
    _image = result.data;
    _fireUpdated();
    result.completer.complete(result.handle);
  }
  
  void update(Map state) {
    Dynamic o = state['image'];
    if (o != null && o is ImageElement) {
      _image = o;
      _fireUpdated();
    }
  }

  void unload() {
    _fireUnloaded();
    _image = null;
  }
}

class PackResource extends ResourceBase {
  List<int> childResources;
  PackResource(String url, ResourceManager rm) : super(url, rm) {
    childResources = new List<int>();
  }
  
  void load(ResourceLoaderResult result) {
    if (childResources.length > 0) {
      _rm.batchUnload(childResources);
      childResources.clear();
    }
    if (result.success) {
      List<Future<int>> futures = new List<Future<int>>();
      if (result.data is String) {
        Map pack = JSON.parse(result.data);
        if (pack != null) {
          for (String url in pack['packContents']) {
            int handle = _rm.registerResource(url);
            childResources.add(handle);
            if (handle != Handle.BadHandle) {
              futures.add(_rm.loadResource(handle));
            }
          }
        }
      }
      _fireUpdated();
      Future allLoaded = Futures.wait(futures);
      allLoaded.then((_unused) {
        result.completer.complete(result.handle);  
      });
    }
  }
  
  void unload() {
    _rm.batchUnload(childResources);
  }
  
  void deregister() {
    _rm.batchDeregister(childResources);
  }
}

class ProgramResource extends ResourceBase {
  List _program;
  ProgramResource(String url, ResourceManager rm) : super(url, rm) {
    _program = null;
  }
  
  set program(List program) {
    _program = program;
    _fireUpdated();
  }
  
  void update(Map state) {
    Dynamic o = state['program'];
    if (o != null && o is List) {
      _program = o;
      _fireUpdated();  
    }
  }
  
  void unload() {
    _fireUnloaded();
    _program = null;
  }
  
  void deregister() {
  }
}
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

class ResourceManager {
  static final int MaxResources = 2048;
  static final int MaxStaticResources = 512;
  static final int ResourceType = 0x1;
  
  ResourceLoaders _loaders;
  
  HandleSystem _handleSystem;
  List<ResourceBase> _resources;
  
  String _baseURL;
  
  Map<String, int> _urlToHandle;
  
  ResourceManager() {
    _handleSystem = new HandleSystem(MaxResources, MaxStaticResources);
    _resources = new List(MaxResources);
    _urlToHandle = new Map<String, int>();
    _loaders = new ResourceLoaders();
  }

  void setBaseURL(String baseURL) {
    _baseURL = baseURL;
  }
  
  Map<String, int> get children() => _urlToHandle; 
  
  ResourceBase getResource(int handle) {
    if (handle == 0) {
      return null;
    }
    if (_handleSystem.validHandle(handle) == false) {
      spectreLog.Warning('getResource - $handle is not a valid handle');
      return null;
    }
    int index = Handle.getIndex(handle);
    return _resources[index];
  }

  String getResourceURL(int handle) {
    ResourceBase rb = getResource(handle);
    if (rb != null) {
      return rb.url;
    }
    return null;
  }
  
  int getResourceHandle(String url) {
    int handle = _urlToHandle[url];
    if (handle == null) {
      return Handle.BadHandle;
    }
    return handle;
  }
  
  int registerResource(String url, [int handle = Handle.BadHandle]) {
    {
      // Resource already exists
      int existingHandle = getResourceHandle(url);
      if (existingHandle != Handle.BadHandle) {
        return existingHandle;
      }
    }
    
    ResourceLoader rl = _loaders.findResourceLoader(url);
    if (rl == null) {
      spectreLog.Error('Resource Manager cannot load $url.');
      return Handle.BadHandle;
    }
    
    ResourceBase rb = rl.createResource(url);
    
    if (handle != Handle.BadHandle) {
      // Static handle
      int r = _handleSystem.setStaticHandle(handle);
      if (r != handle) {
        spectreLog.Error('Registering a static handle $handle failed.');
        return Handle.BadHandle;
      }
    } else {
      // Dynamic handle
      handle = _handleSystem.allocateHandle(ResourceType);
      if (handle == Handle.BadHandle) {
        spectreLog.Error('Registering dynamic handle failed.');
        return Handle.BadHandle;
      }
    }
    assert(_handleSystem.validHandle(handle));
     
    int index = Handle.getIndex(handle);
    if (_resources[index] != null) {
      spectreLog.Warning('Registering a resource t at $index but there is already something there.');
      _resources[index].unload();
      _resources[index] = null;
    }
    
    _resources[index] = rb;
    _urlToHandle[url] = handle;
    return handle;
  }
  
  bool deregisterResource(int handle) {
    if (handle == 0) {
      return true;
    }
    if (_handleSystem.validHandle(handle) == false) {
      spectreLog.Warning('deregisterHandle - $handle is not a valid handle');
      return false;
    }
    int index = Handle.getIndex(handle);
    ResourceBase rb = _resources[index];
    if (rb != null) {
      rb.unload();
      _urlToHandle.remove(rb.url);
    }
    _resources[index] = null;
    _handleSystem.freeHandle(handle);
  }
  
  /// Load the resource [handle]. Can be called again to reload.
  Future<int> loadResource(int handle) {
    ResourceBase rb = getResource(handle);
    if (rb == null) {
      return null;
    }
    ResourceLoader rl = _loaders.findResourceLoader(rb.url);
    if (rl == null) {
      return null;
    }
    // Start the load...    
    Future<ResourceLoaderResult> futureResult = rl.load('$_baseURL${rb.url}');
    Completer<int> completer = new Completer<int>();
    if (futureResult != null) {
      futureResult.then((result) {
        rb.load(result);
        completer.complete(handle);
      });
    }
    return completer.future;
  }
  
  /// Unload the resource [handle]. [handle] remains registered and can be reloaded.
  void unloadResource(int handle) {
    if (handle == 0) {
      return;
    }
    if (_handleSystem.validHandle(handle) == false) {
      spectreLog.Warning('deregisterHandle - $handle is not a valid handle');
      return;
    }
    int index = Handle.getIndex(handle);
    if (_resources[index] != null) {
      _resources[index].unload();
    }
  }
  
  void batchUnload(List<int> handles, [bool deregister=false]) {
    if (deregister) {
      for (int h in handles) {
        deregisterResource(h);
      }  
    } else {
      for (int h in handles) {
        unloadResource(h);
      }
    }
    
  }
}
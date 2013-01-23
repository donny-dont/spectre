part of spectre;

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
  ResourceLoaders _loaders;

  Set<ResourceBase> _resources;
  Map<String, ResourceBase> _urlToHandle;

  String _baseURL;

  ResourceManager()
    : _loaders = new ResourceLoaders()
    , _resources = new Set<ResourceBase>()
    , _baseURL = ''
    , _urlToHandle = new Map<String, ResourceBase>();

  void setBaseURL(String baseURL) {
    _baseURL = baseURL;
  }

  Map<String, ResourceBase> get children => _urlToHandle;

  ResourceBase getResource(String url) {
    return _urlToHandle[url];
  }

  bool registerDynamicResource(ResourceBase resource) {
    _resources.add(resource);
    _urlToHandle[resource.url] = resource;
    return true;
  }

  ResourceBase registerResource(String url) {
    {
      // Resource already exists
      ResourceBase existingHandle = getResource(url);
      if (existingHandle != null) {
        print('RR: $url $existingHandle');
        return existingHandle;
      }
    }

    _ResourceLoader rl = _loaders.findResourceLoader(url);
    if (rl == null) {
      spectreLog.Error('Resource Manager cannot load $url.');
      return null;
    }

    ResourceBase rb = rl.createResource(url, this);

    _resources.add(rb);
    _urlToHandle[url] = rb;
    //print('RR: $url $handle');
    return rb;
  }

  bool deregisterResource(ResourceBase rb) {
    if (rb != null) {
      _urlToHandle.remove(rb.url);
      print('Removing ${rb.url}');
      rb.unload();
      rb.deregister();
      _resources.remove(rb);
      return true;
    }
    return false;
  }

  void updateResource(ResourceBase rb, dynamic state) {
    if (state is String) {
      state = JSON.parse(state);
    }
    if (state is Map == false) {
      spectreLog.Warning('updateResource - state is not a Map or a JSON string.');
      return;
    }
    if (rb != null) {
      rb.update(state);
    }
  }

  /// Load the resource [rb]. Can be called again to reload.
  Future<ResourceBase> loadResource(ResourceBase rb, [bool force=true]) {
    if (rb == null) {
      return null;
    }
    _ResourceLoader rl = _loaders.findResourceLoader(rb.url);
    if (rl == null) {
      return null;
    }
    Completer<ResourceBase> completer = new Completer<ResourceBase>();
    if (rb.isLoaded && force == false) {
      // Skip load
      completer.complete(rb);
    } else {
      // Start the load...
      rl.load('$_baseURL${rb.url}').then((result) {
        // The raw resource data has been loaded.
        // Set the resource handle
        // The resource class is responsible for completing the load
        //
        result.handle = rb;
        result.completer = completer;
        rb.load(result);
      });
    }
    return completer.future;
  }

  Future<bool> loadResources(Collection<ResourceBase> handles, [bool force=true]) {
    List<Future<ResourceBase>> futures = new List<Future<ResourceBase>>();
    handles.forEach((handle) {
      var r = loadResource(handle, force);
      futures.add(r);
    });
    Future<List> allFutures = Future.wait(futures);
    Completer<bool> completer = new Completer<bool>();
    allFutures.then((result) {
      completer.complete(true);
    });
    return completer.future;
  }

  /// Unload the resource [handle]. [handle] remains registered and can be reloaded.
  void unloadResource(ResourceBase rb) {
    rb.unload();
  }

  void batchUnload(List<ResourceBase> handles) {
    for (ResourceBase h in handles) {
      unloadResource(h);
    }
  }

  void batchDeregister(List<ResourceBase> handles) {
    for (ResourceBase h in handles) {
      deregisterResource(h);
    }
  }

  void addEventCallback(ResourceBase rb, int eventType, ResourceEventCallback callback) {
    if (rb == null) {
      return;
    }
    if (eventType == ResourceEvents.TypeUpdate) {
      rb.on.addUpdate(callback);
    } else if (eventType == ResourceEvents.TypeUnloaded) {
      rb.on.addUnloaded(callback);
    }
    return;
  }

  void removeEventCallback(ResourceBase rb, int eventType, ResourceEventCallback callback) {
    if (rb == null) {
      return;
    }
    if (eventType == ResourceEvents.TypeUpdate) {
      rb.on.removeUpdate(callback);
    } else if (eventType == ResourceEvents.TypeUnloaded) {
      rb.on.removeUnloaded(callback);
    }
  }
}
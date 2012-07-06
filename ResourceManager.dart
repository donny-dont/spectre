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

typedef void OnResourceLoad(Object resource, String name, String type, Completer<Resource> completer);
typedef void OnResourceLoadFailure(String name, String type, Completer<Resource> completer);

class _ResourceLoader {
  static String contentTypeForType(String type) {
    if (type == 'jpeg' || type == 'jpeg') {
      return 'image/jpeg';
    } else if (type == 'png') {
      return 'image/png';
    }
    return 'text/plain';
  }
  
  static String responseTypeForType(String type) {
    if (type == 'jpg' || type == 'jpeg' || type == 'png') {
      return 'arraybuffer';
    }
    return '';
  }
  static void load(String url, String name, String type, OnResourceLoad onLoad, OnResourceLoadFailure onFailure, Completer<Resource> completer) {
    var req = new XMLHttpRequest();
    req.open("GET", url, true);
    req.responseType = responseTypeForType(type);
    print('Requesting $url ${req.responseType}');
    req.on.load.add((event) {
      if (req.response != null) {
        spectreLog.Info('Request for $url was successful. Fetched ${req.responseType}');
        onLoad(req.response, name, type, completer);
      } else {
        spectreLog.Info('Request for $url was unsuccessful. ${req.statusText}');
        onFailure(name, type, completer);
      }
    });
    req.send();
  }
}

/// Resource Manager
///
/// Loads resources from URLs
typedef void ResourceManagerForEach(String name, Resource res);

class ResourceManager {
  Map<String, Resource> _resources;

  String _baseURL;

  /// Constructs a [ResourceManager]
  ResourceManager() {
    _baseURL = null;
    _resources = new Map();
  }

  /// Sets the base URL to load resources from
  void setBaseURL(String baseURL) {
    _baseURL = baseURL;
    spectreLog.Info('Resource manager serving from $baseURL');
  }

  void _add(Resource r) {
    print('Adding resource ${r.name}');
    _resources[r.name] = r;
  }

  void _remove(Resource r) {
    r.deleteDeviceObjects();
    r.releaseData();
    _resources.remove(r.name);
  }

  void _onLoad(Object resource, String name, String type, Completer<Resource> completer) {
    switch (type) {
      case 'mesh':
        MeshResource mr = new MeshResource(name, resource);
        mr.createDeviceObjects();
        _add(mr);
        completer.complete(mr);
      break;
      case 'vs':
        VertexShaderResource vsr = new VertexShaderResource(name, resource);
        vsr.createDeviceObjects();
        _add(vsr);
        completer.complete(vsr);
      break;
      case 'fs':
        FragmentShaderResource fsr = new FragmentShaderResource(name, resource);
        fsr.createDeviceObjects();
        _add(fsr);
        completer.complete(fsr);
      break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        _add(resource);
        completer.complete(resource);
      break;
      default:
        spectreLog.Error('Resource manager does not understand $type');
      break;
    }
  }

  void _onLoadFailure(String name, String type, Completer<Resource> completer) {
    spectreLog.Info('Failed to load $name ($type)');
  }

  void _load(String url, String name, String type, Completer<Resource> completer) {
    if (type == 'jpeg' || type == 'jpg' || type == 'png') {
      ImageResource ir = new ImageResource(name, url);
      ir.image.on.load.add((event) {
        _onLoad(ir, name, type, completer);
      });
      ir.image.src = ir.url;
    } else {
      _ResourceLoader.load(url, name, type, _onLoad, _onLoadFailure, completer);  
    }
  }

  /// Loads the resource in [name]
  ///
  /// Returns a future that will complete when the resource has been fetched and loaded
  Future<Resource> load(String name) {
    if (_resources.containsKey(name)) {
      spectreLog.Warning('Requested load of $name but it is already loaded.');
      return new Future.immediate(_resources[name]);
    }
    String url = '$_baseURL$name';
    String type = name.split('.').last();
    spectreLog.Info('Loading $name ($type) from $url');
    Completer<Resource> completer = new Completer();
    _load(url, name, type, completer);
    spectreLog.Info('Returning future for $name');
    return completer.future;
  }

  /// Unloads a resource [name]
  void unload(String name) {
    if (_resources.containsKey(name) == false) {
      spectreLog.Warning('Unload of $name but not loaded.');
      return;
    }
    Resource r = _resources[name];
    spectreLog.Info('Unloading $name');
    _remove(r);
  }
  
  void unloadAll() {
    _resources.forEach((k, v) {
      spectreLog.Info('Unloading $k');
      _remove(v);
    });
  }
  
  void unloadBatch(List<String> resources) {
    resources.forEach((name) {
      unload(name);
    });
  }

  /// Refreshes a resource [name]
  void refresh(String name) {
    if (_resources.containsKey(name)) {
      Resource r = _resources[name];
    } else {
      spectreLog.Warning('Requested refresh of $name but no resource exists. Loading instead.');
      load(name);
    }
  }
  
  void forEach(ResourceManagerForEach f) {
    _resources.forEach(f);
  }
}

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
  Set<ResourceEventCallback> update;
  Set<ResourceEventCallback> unloaded;
  ResourceEvents() {
    update = new HashSet();
    unloaded = new HashSet();
  }

  Set<ResourceEventCallback> getSetForType(int type) {
    if (type == TypeUpdate) {
      return update;
    }
    if (type == TypeUnloaded) {
      return unloaded;
    }
    return null;
  }
}

class ResourceBase {
  bool _isLoaded;
  bool get isLoaded() => _isLoaded;

  String _url;
  String get url() => _url;

  ResourceEvents on;

  ResourceBase(this._url) {
    _isLoaded = false;
    on = new ResourceEvents();
  }

  abstract void load(ResourceLoaderResult result);

  abstract void unload();

  // Call after the data is updated
  void _fireUpdated() {
    for (ResourceEventCallback reu in on.update) {
      reu(ResourceEvents.TypeUpdate, this);
    }
  }

  // Call before the data is gone
  void _fireUnloaded() {
    for (ResourceEventCallback reu in on.unloaded) {
      reu(ResourceEvents.TypeUnloaded, this);
    }
  }
}

class Float32ArrayResource extends ResourceBase {
  Float32Array array;

  Float32ArrayResource(String url) : super(url) {
  }

  void load(ResourceLoaderResult result) {
    _fireUpdated();
  }

  void unload() {
    _fireUnloaded();
  }
}

class Uint16ArrayResource extends ResourceBase {
  Uint16Array array;

  Uint16ArrayResource(String url) : super(url) {
  }

  void load(ResourceLoaderResult result) {
    _fireUpdated();
  }

  void unload() {
    _fireUnloaded();
  }
}

class MeshResource extends ResourceBase {
  Map meshData;
  Float32Array vertexArray;
  Uint16Array indexArray;

  MeshResource(String url) : super(url) {

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

  ShaderResource(String url) : super(url) {
  }

  void load(ResourceLoaderResult result) {
    if (result.success == false) {
      return;
    }
    source = result.data;
    _fireUpdated();
  }

  void unload() {
    _fireUnloaded();
    source = null;
  }
}

class ImageResource extends ResourceBase {
  ImageElement image;

  ImageResource(String url) : super(url) {

  }

  void load(ResourceLoaderResult result) {
    if (result.success == false) {
      return;
    }
    image = result.data;
    _fireUpdated();
  }

  void unload() {
    _fireUnloaded();
    image = null;
  }
}

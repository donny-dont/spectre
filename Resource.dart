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

typedef void ResourceEvent(int type, ResourceBase resource);

class ResourceEvents {
  static final int TypeUpdate = 0x1;
  static final int TypeUnloaded = 0x2;
  List<ResourceEvent> update;
  List<ResourceEvent> unloaded;
  ResourceEvents() {
    update = new List();
    unloaded = new List();
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
    for (ResourceEvent reu in on.update) {
      reu(ResourceEvents.TypeUpdate, this);
    }
  }

  // Call before the data is gone
  void _fireUnloaded() {
    for (ResourceEvent reu in on.unloaded) {
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


/// ----

/*
  void createDeviceObjects() {
    String ibName = '${name}.IndexBuffer';
    String vbName = '${name}.VertexBuffer';
    int numIndices = meshData['meshes'][0]['indices'].length;
    int indexWidth = meshData['meshes'][0]['indexWidth'];
    int ibSize = numIndices*indexWidth;
    indexBuffer = spectreDevice.createIndexBuffer(ibName,{'usage':'dynamic','size':ibSize});
    spectreImmediateContext.updateBuffer(indexBuffer, new Uint16Array.fromList(meshData['meshes'][0]['indices']));
    int numAttributeValues = meshData['meshes'][0]['vertices'].length;
    int attributeValueWidth = 4;
    int vbSize = numAttributeValues*attributeValueWidth;
    vertexBuffer = spectreDevice.createVertexBuffer(vbName, {'usage':'dynamic','size':vbSize});
    spectreImmediateContext.updateBuffer(vertexBuffer, new Float32Array.fromList(meshData['meshes'][0]['vertices']));
    spectreLog.Info('Created ($ibName,$vbName) device objects for $name');
  }

  void deleteDeviceObjects() {
    spectreLog.Info('Deleted (${spectreDevice.getDeviceChildName(indexBuffer)},${spectreDevice.getDeviceChildName(vertexBuffer)}) for $name');
    spectreDevice.deleteDeviceChild(indexBuffer);
    spectreDevice.deleteDeviceChild(vertexBuffer);
    indexBuffer = null;
    vertexBuffer = null;
  }

*/
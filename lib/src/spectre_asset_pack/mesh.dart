/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

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

part of spectre_asset_pack;

class MeshImporter extends AssetImporter {
  final GraphicsDevice device;
  dynamic get fallback => null;

  MeshImporter(this.device);

  SpectreMesh _processMeshes(AssetRequest request, List meshes) {
    final String name = request.name;
    SingleArrayIndexedMesh mesh = device.createSingleArrayIndexedMesh(name);
    var vertexArray = new Float32Array.fromList(meshes[0]['vertices']);
    var indexArray = new Uint16Array.fromList(meshes[0]['indices']);
    mesh.vertexArray.uploadData(vertexArray, SpectreBuffer.UsageStatic);
    mesh.indexArray.uploadData(indexArray, SpectreBuffer.UsageStatic);
    mesh.count = indexArray.length;
    meshes[0]['attributes'].forEach((k, v) {
      var attribute = new SpectreMeshAttribute(v['name'],
                                               v['type'],
                                               v['numElements'],
                                               v['offset'],
                                               v['stride'],
                                               v['normalized']);
      mesh.attributes[k] = attribute;
    });
    return mesh;
  }

  SpectreMesh _processIndexedMesh(AssetRequest request, Map indexedMesh) {
    // TODO(johnmccutchan): Implement support for new mesh format.
    assert(false);
  }
  SpectreMesh _processArrayMesh(AssetRequest request, Map arrayMesh) {
    // TODO(johnmccutchan): Implement support for new mesh format.
    assert(false);
  }
  Future<dynamic> import(dynamic payload, AssetRequest request) {
    if (payload is String) {
      try {
        Map parsed = JSON.parse(payload);
        SpectreMesh mesh;
        if (parsed.containsKey('meshes')) {
          mesh = _processMeshes(request, parsed['meshes']);
        } else if (parsed.containsKey('indexedMesh')) {
          mesh = _processIndexedMesh(request, parsed['indexedMesh']);
        } else if (parsed.containsKey('arrayMesh')) {
          mesh =  _processArrayMesh(request, parsed['arrayMesh']);
        } else {
          return new Future.immediate(fallback);
        }
        if (mesh != null) {
          return new Future.immediate(mesh);
        } else {
          return new Future.immediate(fallback);
        }
      } catch (_) {
        return new Future.immediate(fallback);
      }
    } else {
      assert(!(payload is String));
      return new Future.immediate(fallback);
    }
  }
  void delete(SpectreMesh imported) {
    print('Deleting ${imported.name}');
    device.deleteDeviceChild(imported);
  }
}
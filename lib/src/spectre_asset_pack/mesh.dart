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
  MeshImporter(this.device);



  void initialize(Asset asset) {
  }

  SpectreMesh _processMesh(Asset asset, Map json) {
    final String name = asset.name;
    SingleArrayIndexedMesh mesh = new SingleArrayIndexedMesh(name, device);
    var vertexArray = new Float32List.fromList(json['vertices']);
    var indexArray = new Uint16List.fromList(json['indices']);
    mesh.vertexArray.uploadData(vertexArray, SpectreBuffer.UsageStatic);
    mesh.indexArray.uploadData(indexArray, SpectreBuffer.UsageStatic);
    mesh.count = indexArray.length;
    List attributes = json['attributes'];

    attributes.forEach((v) {
      String name = v['name'];
      int offset = v['offset'];
      int stride = v['stride'];
      int count = 1;

      switch (v['format']) {
        case 'float2': count = 2; break;
        case 'float3': count = 3; break;
        case 'float4': count = 4; break;
      }

      SpectreMeshAttribute attribute = new SpectreMeshAttribute(
          name,
          'float',
          count,
          offset,
          stride,
          false);

      mesh.attributes[name] = attribute;
    });
    return mesh;
  }

  SpectreMesh _processMeshes(Asset asset, List meshes, AssetPackTrace tracer) {
    final String name = asset.name;
    SingleArrayIndexedMesh mesh = new SingleArrayIndexedMesh(name, device);
    var vertexArray = new Float32List.fromList(meshes[0]['vertices']);
    var indexArray = new Uint16List.fromList(meshes[0]['indices']);
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

  SpectreMesh _processIndexedMesh(Asset asset, Map indexedMesh) {
    // TODO(johnmccutchan): Implement support for new mesh format.
    assert(false);
  }
  SpectreMesh _processArrayMesh(Asset asset, Map arrayMesh) {
    // TODO(johnmccutchan): Implement support for new mesh format.
    assert(false);
  }

  Future<Asset> import(dynamic payload, Asset asset, AssetPackTrace tracer) {
    if (payload is String) {
      try {
        Map parsed = JSON.parse(payload);
        SpectreMesh mesh;

        mesh = _processMesh(asset, parsed);

        /*
        if (parsed.containsKey('meshes')) {
          mesh = _processMeshes(asset, parsed['meshes']);
        } else if (parsed.containsKey('indexedMesh')) {
          mesh = _processIndexedMesh(asset, parsed['indexedMesh']);
        } else if (parsed.containsKey('arrayMesh')) {
          mesh =  _processArrayMesh(asset, parsed['arrayMesh']);
        }
        */
        if (mesh != null) {
          asset.imported = mesh;
        }
      } on FormatException catch (e) {
        tracer.assetImportError(asset, e.message);
      }
    }
    return new Future.value(asset);
  }

  void delete(SpectreMesh imported) {
    if (imported != null) {
      print('Deleting ${imported.name}');
      imported.dispose();
    }
  }
}

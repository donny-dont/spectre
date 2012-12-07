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

class IndexedMesh extends DeviceChild {
  VertexBuffer vertexArray;
  IndexBuffer indexArray;
  int numIndices;
  int indexOffset;

  IndexedMesh(String name, GraphicsDevice device) : super._internal(name, device) {
    numIndices = 0;
    indexOffset = 0;
  }

  void _createDeviceState() {
    super._createDeviceState();
    vertexArray = device.createVertexBuffer('${name}.array', {});
    indexArray = device.createIndexBuffer('${name}.index', {});
  }

  void _configDeviceState(Map props) {
    super._configDeviceState(props);
    if (props != null) {
      dynamic o;

      o = props['UpdateFromMeshResource'];
      if (o != null && o is Map) {
        ResourceManager rm = o['resourceManager'];
        MeshResource mesh = o['meshResourceHandle'];
        if (mesh != null) {
          device.context.updateBuffer(vertexArray, mesh.vertexArray, WebGLRenderingContext.STATIC_DRAW);
          device.context.updateBuffer(indexArray, mesh.indexArray, WebGLRenderingContext.STATIC_DRAW);
          indexOffset = 0;
          numIndices = mesh.numIndices;
        }
      }

      o = props['UpdateFromMeshMap'];
      if (o != null && o is Map) {
        Map mesh = o['meshes'][0];
        if (o != null && o is Map) {
          var indices = new Uint16Array.fromList(mesh['indices']);
          device.context.updateBuffer(vertexArray, new Float32Array.fromList(mesh['vertices']), WebGLRenderingContext.STATIC_DRAW);
          device.context.updateBuffer(indexArray, indices, WebGLRenderingContext.STATIC_DRAW);
          indexOffset = 0;
          numIndices = indices.length;
        }
      }

      /* TODO
      o = props['UpdateFromArray'];
      if (o != null && o is int) {

      }
      */

      o = props['indexOffset'];
      if (o != null && o is int) {
        indexOffset = o;
      }

      o = props['numIndices'];
      if (o != null && o is int) {
        numIndices = o;
      }
    }
  }

  void _destroyDeviceState() {
    device.deleteDeviceChild(indexArray);
    device.deleteDeviceChild(vertexArray);
    super._destroyDeviceState();
  }
}

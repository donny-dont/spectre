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

class ArrayMesh extends DeviceChild {
  VertexBuffer vertexArray;
  int numVertices;
  int vertexOffset;

  ArrayMesh(String name, GraphicsDevice device) : super._internal(name, device) {
    numVertices = 0;
    vertexOffset = 0;
  }

  void _createDeviceState() {
    super._createDeviceState();
    vertexArray = device.createVertexBuffer('${name}.array', {});
  }

  void _configDeviceState(Map props) {
    super._configDeviceState(props);
    if (props != null) {
      dynamic o;

      /* TODO
      o = props['UpdateFromArray'];
      if (o != null && o is int) {

      }

      o = props['vertexOffset'];
      if (o != null && o is int) {
        vertexOffset = o;
      }

      o = props['numVertices'];
      if (o != null && o is int) {
        numVertices = o;
      }*/
    }
  }

  void _destroyDeviceState() {
    device.deleteDeviceChild(vertexArray);
    super._destroyDeviceState();
  }
}

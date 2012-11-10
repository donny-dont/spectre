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

class InputLayoutDescription {
  String meshAttributeName;
  int vertexBufferIndex;
  String shaderAttributeName;

  InputLayoutDescription(this.shaderAttributeName, this.vertexBufferIndex, this.meshAttributeName);
}

class InputLayoutHelper {
  static InputElementDescription inputElementDescriptionFromMeshMap(InputLayoutDescription description, Map mesh, [num meshIndex=0]) {
    Map innerMesh = mesh['meshes'][meshIndex];
    Map attributes = innerMesh['attributes'];
    Map attribute = attributes[description.meshAttributeName];
    if (attribute == null) {
      spectreLog.Info('mesh is does not have ${description.meshAttributeName}');
      // mesh doesn't have this attribute
      return null;
    }

    String type = attribute['type'];
    num numElements = attribute['numElements'];
    bool normalized = attribute['normalized'];
    num stride = attribute['stride'];
    num offset = attribute['offset'];
    DeviceFormat format = null;
    if (type == 'float') {
      if (numElements == 1) {
        format = GraphicsDevice.DeviceFormatFloat1;
      }
      if (numElements == 2) {
        format = GraphicsDevice.DeviceFormatFloat2;
      }
      if (numElements == 3) {
        format = GraphicsDevice.DeviceFormatFloat3;
      }
      if (numElements == 4) {
        format = GraphicsDevice.DeviceFormatFloat4;
      }
    }
    if (format == null) {
      spectreLog.Info('cant find format for $type $numElements');
      return null;
    }
    return new InputElementDescription(description.shaderAttributeName, format, stride, description.vertexBufferIndex, offset);
  }

  static InputElementDescription inputElementDescriptionFromMesh(InputLayoutDescription description, MeshResource mesh, [num meshIndex=0]) {
    if (mesh == null) {
      spectreLog.Info('mesh is null');
      return null;
    }
    if (mesh is MeshResource == false) {
      spectreLog.Info('mesh is not a MeshResource');
      return null;
    }
    return inputElementDescriptionFromMeshMap(description, mesh.meshData, meshIndex);
  }

  static InputElementDescription inputElementDescriptionFromAttributes(InputLayoutDescription description, Map attributes) {
    Map attribute = attributes[description.meshAttributeName];
    if (attribute == null) {
      spectreLog.Info('mesh is does not have ${description.meshAttributeName}');
      // mesh doesn't have this attribute
      return null;
    }

    String type = attribute['type'];
    num numElements = attribute['numElements'];
    bool normalized = attribute['normalized'];
    num stride = attribute['stride'];
    num offset = attribute['offset'];
    DeviceFormat format = null;
    if (type == 'float') {
      if (numElements == 1) {
        format = GraphicsDevice.DeviceFormatFloat1;
      }
      if (numElements == 2) {
        format = GraphicsDevice.DeviceFormatFloat2;
      }
      if (numElements == 3) {
        format = GraphicsDevice.DeviceFormatFloat3;
      }
      if (numElements == 4) {
        format = GraphicsDevice.DeviceFormatFloat4;
      }
    }
    if (format == null) {
      spectreLog.Info('cant find format for $type $numElements');
      return null;
    }
    return new InputElementDescription(description.shaderAttributeName, format, stride, description.vertexBufferIndex, offset);
  }
}
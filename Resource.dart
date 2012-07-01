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

class Resource implements Hashable {
  String name;
  
  int hashCode() {
    return name.hashCode();
  }
  
  void createDeviceObjects() {
    spectreLog.Error('createDeviceObjects called on base resource');
  }
  bool hasDeviceObjects() {
    spectreLog.Error('hasDeviceObjects called on base resource');
  }
  void deleteDeviceObjects() {
    spectreLog.Error('deleteDeviceObjects called on base resource');
  }
  void refreshDeviceObjects() {
    deleteDeviceObjects();
    createDeviceObjects();
  }
  bool hasData() {
    spectreLog.Error('hasData called on base resource');
  }
  void releaseData() {
    spectreLog.Error('releaseData called on base resource');
  }
}

class MeshResource extends Resource {
  Map meshData;
  IndexBuffer indexBuffer;
  VertexBuffer vertexBuffer;
  
  MeshResource(String name, Dynamic mesh) {
    this.name = name;
    
    meshData = null;
    indexBuffer = null;
    vertexBuffer = null;
    
    if (mesh is String) {
      mesh = JSON.parse(mesh);
    }
    
    if (mesh is Map) {
      meshData = mesh;
    }
  }
  
  int get numIndices() {
    return meshData['meshes'][0]['indices'].length;
  }
  
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
  
  bool hasDeviceObjects() {
    return indexBuffer != null && vertexBuffer != null;
  }
  
  void deleteDeviceObjects() {
    spectreDevice.deleteIndexBuffer(indexBuffer);
    spectreDevice.deleteVertexBuffer(vertexBuffer);
    spectreLog.Info('Deleted (${indexBuffer.name},${vertexBuffer.name}) for $name');
    indexBuffer = null;
    vertexBuffer = null;
  }
  
  bool hasData() {
    return meshData != null;
  }
  
  void releaseData() {
    meshData = null;
  }
}

class VertexShaderResource extends Resource {
  String shaderSource;
  VertexShader shader;
  
  VertexShaderResource(String name, String source) {
    this.name = name;
    shaderSource = source;
  }
  
  void createDeviceObjects() {
    shader = spectreDevice.createVertexShader(name, {});
    shader.source = shaderSource;
    shader.compile();
  }
  
  bool hasDeviceObjects() {
    return shader != null;
  }
  
  void deleteDeviceObjects() {
    spectreDevice.deleteVertexShader(shader);
    shader = null;
  }
  
  bool hasData() {
    return shaderSource != null;
  }
  
  void releaseData() {
    shaderSource = null;
  }
}

class FragmentShaderResource extends Resource {
  String shaderSource;
  FragmentShader shader;
  
  FragmentShaderResource(String name, String source) {
    this.name = name;
    shaderSource = source;
  }
  
  void createDeviceObjects() {
    shader = spectreDevice.createFragmentShader(name, {});
    shader.source = shaderSource;
    shader.compile();
  }
  
  bool hasDeviceObjects() {
    return shader != null;
  }
  
  void deleteDeviceObjects() {
    spectreDevice.deleteFragmentShader(shader);
    shader = null;
  }

  bool hasData() {
    return shaderSource != null;
  }
  
  void releaseData() {
    shaderSource = null;
  }
}

class ImageResource extends Resource {
  String url;
  ImageElement image;
  ImageResource(String name, this.url) {
    this.name = name;
    image = new ImageElement();
  }
  
  void createDeviceObjects() {
    
  }
  
  bool hasDeviceObjects() {
    return false;
  }
  
  void deleteDeviceObjects() {
  }
  
  bool hasData() {
    image != null;
  }
  
  void releaseData() {
    image = null;
  }
}
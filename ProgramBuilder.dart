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

class ProgramBuilder {
  List ops;

  ProgramBuilder() {
    ops = new List();
  }
  ProgramBuilder.append(this.ops);

  void setRegister(int register, Dynamic value) {
    ops.add(Ops.SetRegister);
    ops.add(register);
    ops.add(value);
  }

  void setRegisterFromList(int register, List table, int index) {
    ops.add(Ops.SetRegisterFromList);
    ops.add(register);
    ops.add(table);
    ops.add(index);
  }

  void createBlendState(String name, Map options, List output) {
    ops.add(Ops.CreateBlendState);
    ops.add(name);
    ops.add(options);
    ops.add(output);
  }

  void createDepthState(String name, Map options, List output) {
    ops.add(Ops.CreateDepthState);
    ops.add(name);
    ops.add(options);
    ops.add(output);
  }

  void createRasterizerState(String name, Map options, List output) {
    ops.add(Ops.CreateRasterizerState);
    ops.add(name);
    ops.add(options);
    ops.add(output);
  }

  void createVertexShader(String name, Map options, List output) {
    ops.add(Ops.CreateVertexShader);
    ops.add(name);
    ops.add(options);
    ops.add(output);
  }

  void createFragmentShader(String name, Map options, List output) {
    ops.add(Ops.CreateFragmentShader);
    ops.add(name);
    ops.add(options);
    ops.add(output);
  }

  void createShaderProgram(String name, Map options, List output) {
    ops.add(Ops.CreateShaderProgram);
    ops.add(name);
    ops.add(options);
    ops.add(output);
  }

  void createIndexedMesh(String name, Map options, List output) {
    ops.add(Ops.CreateIndexedMesh);
    ops.add(name);
    ops.add(options);
    ops.add(output);
  }

  void compileShaderFromResource(int shaderHandle, int resourceHandle) {
    ops.add(Ops.CompileShaderFromResource);
    ops.add(shaderHandle);
    ops.add(resourceHandle);
  }

  void linkShaderProgram(int shaderProgramHandle, int vertexShaderHandle, int fragmentShaderHandle) {
    ops.add(Ops.LinkShaderProgram);
    ops.add(shaderProgramHandle);
    ops.add(vertexShaderHandle);
    ops.add(fragmentShaderHandle);
  }

  void setPrimitiveTopology(int topology) {
    ops.add(Ops.SetPrimitiveTopology);
    ops.add(topology);
  }

  void setIndexBuffer(int handle) {
    ops.add(Ops.SetIndexBuffer);
    ops.add(handle);
  }

  void setBlendState(int handle) {
    ops.add(Ops.SetBlendState);
    ops.add(handle);
  }

  void setRasterizerState(int handle) {
    ops.add(Ops.SetRasterizerState);
    ops.add(handle);
  }

  void setDepthState(int handle) {
    ops.add(Ops.SetDepthState);
    ops.add(handle);
  }

  void setShaderProgram(int handle) {
    ops.add(Ops.SetShaderProgram);
    ops.add(handle);
  }

  void setVertexBuffers(int offset, List handles) {
    ops.add(Ops.SetVertexBuffers);
    ops.add(offset);
    ops.add(handles);
  }

  void setInputLayout(int handle) {
    ops.add(Ops.SetInputLayout);
    ops.add(handle);
  }

  void setTextures(int textureUnitOffset, List<int> handles) {
    ops.add(Ops.SetTextures);
    ops.add(textureUnitOffset);
    ops.add(handles);
  }

  void setSamplers(int textureUnitOffset, List<int> handles) {
    ops.add(Ops.SetSamplers);
    ops.add(textureUnitOffset);
    ops.add(handles);
  }

  void setUniformMatrix4(String name, Float32Array buf) {
    ops.add(Ops.SetUniformMatrix4);
    ops.add(name);
    ops.add(buf);
  }

  void draw(int vertexCount, int vertexOffset) {
    ops.add(Ops.Draw);
    ops.add(vertexCount);
    ops.add(vertexOffset);
  }

  void drawIndirect(int vertexCountHandle, int vertexOffsetHandle) {
    ops.add(Ops.DrawIndirect);
    ops.add(vertexCountHandle);
    ops.add(vertexOffsetHandle);
  }

  void drawIndexed(int numIndices, int indexOffset) {
    ops.add(Ops.DrawIndexed);
    ops.add(numIndices);
    ops.add(indexOffset);
  }

  void deregisterAndUnloadResources(List<int> handles) {
    ops.add(Ops.DeregisterAndUnloadResources);
    ops.add(handles);
  }

  void deleteDeviceChildren(List<int> handles) {
    ops.add(Ops.DeleteDeviceChildren);
    ops.add(handles);
  }
}
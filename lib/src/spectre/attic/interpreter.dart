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

class Interpreter {
  static final int NumRegisters = 32;
  List registers;

  Interpreter() {
    registers = new List.fixedLength(NumRegisters);
  }

  void clearRegisters() {
    for (int i = 0; i < NumRegisters; i++) {
      registers[i] = null;
    }
  }

  void setRegister(int register, dynamic value) {
    registers[register] = value;
  }

  void run(List program, GraphicsDevice device, ResourceManager rm, GraphicsContext im) {
    if (program == null) {
      return;
    }
    final int last = program.length;
    int i = 0;
    int skip = 0;
    while (i < last) {
      final int code = program[i];
      if (code == null) {
        break;
      }
      switch (code) {
        case Ops.Null:
          skip = 1;
          break;
        case Ops.SetRegister:
          skip = 3;
          {
            final int regId = program[i+1];
            final dynamic val = program[i+2];
            registers[regId] = val;
          }
          break;
        case Ops.SetRegisterFromList:
          skip = 4;
          {
            final int regId = program[i+1];
            final List table = program[i+2];
            final int tableIndex = program[i+3];
            registers[regId] = table[tableIndex];
          }
          break;
        case Ops.CreateBlendState:
          skip = 4;
        {
          final String name = program[i+1];
          final Map options = program[i+2];
          final List output = program[i+3];
          DeviceChild handle = device.createBlendState(name, options);
          if (output != null) {
            output.add(handle);
          }
        }
        break;
        case Ops.CreateRasterizerState:
          skip = 4;
        {
          final String name = program[i+1];
          final Map options = program[i+2];
          final List output = program[i+3];
          DeviceChild handle = device.createRasterizerState(name, options);
          if (output != null) {
            output.add(handle);
          }
        }
        break;
        case Ops.CreateDepthState:
          skip = 4;
        {
          final String name = program[i+1];
          final Map options = program[i+2];
          final List output = program[i+3];
          DeviceChild handle = device.createDepthState(name, options);
          if (output != null) {
            output.add(handle);
          }
        }
        break;
        case Ops.CreateVertexShader:
          skip = 4;
        {
          final String name = program[i+1];
          final Map options = program[i+2];
          final List output = program[i+3];
          DeviceChild handle = device.createVertexShader(name, options);
          if (output != null) {
            output.add(handle);
          }
        }
        break;
        case Ops.CreateFragmentShader:
          skip = 4;
        {
          final String name = program[i+1];
          final Map options = program[i+2];
          final List output = program[i+3];
          DeviceChild handle = device.createFragmentShader(name, options);
          if (output != null) {
            output.add(handle);
          }
        }
        break;
        case Ops.CreateShaderProgram:
          skip = 4;
        {
          final String name = program[i+1];
          final Map options = program[i+2];
          final List output = program[i+3];
          DeviceChild handle = device.createShaderProgram(name, options);
          if (output != null) {
            output.add(handle);
          }
        }
        break;
        case Ops.CreateIndexedMesh:
          skip = 4;
        {
          final String name = program[i+1];
          final Map options = program[i+2];
          final List output = program[i+3];
          DeviceChild handle = device.createIndexedMesh(name, options);
          if (output != null) {
            output.add(handle);
          }
        }
        break;
        case Ops.CompileShaderFromResource:
          skip = 3;
        {
          final Shader shaderHandle = program[i+1];
          final ShaderResource resourceHandle = program[i+2];
          im.compileShaderFromResource(shaderHandle, resourceHandle, rm);
        }
        break;
        case Ops.CreateInputLayoutForMeshResource:
          skip = 5;
        {
          final String name = program[i+1];
          final MeshResource mr = program[i+2];
          final ShaderProgram shaderProgramHandle = program[i+3];
          final List<InputLayoutDescription> inputs = program[i+4];
          final List output = program[i+5];
          List<InputElementDescription> elements = new List<InputElementDescription>.fixedLength(inputs.length);
          for (int j = 0; j < inputs.length; j++) {
            elements[j] = InputLayoutHelper.inputElementDescriptionFromMesh(inputs[j], mr);
          }
          DeviceChild handle = device.createInputLayout(name, {'elements':elements, 'shaderProgram':shaderProgramHandle});
          if (output != null) {
            output.add(handle);
          }
        }
        break;
        case Ops.LinkShaderProgram:
          skip = 4;
        {
          final ShaderProgram shaderProgramHandle = program[i+1];
          final VertexShader vertexShaderHandle = program[i+2];
          final FragmentShader fragmentShaderHandle = program[i+3];
          im.linkShaderProgram(shaderProgramHandle, vertexShaderHandle, fragmentShaderHandle);
        }
        break;
        case Ops.SetBlendState:
          skip = 2;
          {
            final BlendState handle = program[i+1];
            im.setBlendState(handle);
          }
          break;
        case Ops.SetRasterizerState:
          skip = 2;
          {
            final RasterizerState handle = program[i+1];
            im.setRasterizerState(handle);
          }
          break;
        case Ops.SetDepthState:
          skip = 2;
          {
            final DepthState handle = program[i+1];
            im.setDepthState(handle);
          }
          break;
        case Ops.SetShaderProgram:
          skip = 2;
          {
            final ShaderProgram handle = program[i+1];
            im.setShaderProgram(handle);
          }
          break;
        case Ops.SetPrimitiveTopology:
          skip = 2;
          {
            final int primTop = program[i+1];
            im.setPrimitiveTopology(primTop);
          }
          break;
        case Ops.SetVertexBuffers:
          skip = 3;
          {
            final int vertexBufferOffset = program[i+1];
            final List vertexBuffers = program[i+2];
            im.setVertexBuffers(vertexBufferOffset, vertexBuffers);
          }
          break;
        case Ops.SetIndexBuffer:
          skip = 2;
          {
            final IndexBuffer handle = program[i+1];
            im.setIndexBuffer(handle);
          }
          break;
        case Ops.SetInputLayout:
          skip = 2;
          {
            final InputLayout handle = program[i+1];
            im.setInputLayout(handle);
          }
          break;
        case Ops.SetTextures:
          skip = 3;
        {
          final int textureUnitOffset = program[i+1];
          final List<Texture> handles = program[i+2];
          im.setTextures(textureUnitOffset, handles);
        }
        break;
        case Ops.SetSamplers:
          skip = 3;
        {
          final int textureUnitOffset = program[i+1];
          final List<SamplerState> handles = program[i+2];
          im.setSamplers(textureUnitOffset, handles);
        }
        break;
        case Ops.SetIndexedMesh:
          skip = 2;
        {
          final SingleArrayIndexedMesh indexedMesh = program[i+1];
          im.setIndexedMesh(indexedMesh);
        }
        break;
        case Ops.SetUniformMatrix4:
          skip = 3;
          {
            final String name = program[i+1];
            final Float32Array buf = program[i+2];
            im.setConstant(name, buf);
          }
          break;
        case Ops.SetUniformVector4:
          skip = 3;
          {
            final String name = program[i+1];
            final Float32Array buf = program[i+2];
            im.setConstant(name, buf);
          }
          break;
        case Ops.SetUniformVector3:
          skip = 3;
          {
            final String name = program[i+1];
            final Float32Array buf = program[i+2];
            im.setConstant(name, buf);
          }
          break;
        case Ops.SetUniformVector2:
          skip = 3;
          {
            final String name = program[i+1];
            final Float32Array buf = program[i+2];
            im.setConstant(name, buf);
          }
          break;
        case Ops.SetUniformInt:
          skip = 3;
          {
            final String name = program[i+1];
            final int buf = program[i+2];
            im.setConstant(name, buf);
          }
          break;
        case Ops.Draw:
          skip = 3;
          {
            final int vertexCount = program[i+1];
            final int vertexOffset = program[i+2];
            im.draw(vertexCount, vertexOffset);
          }
          break;
        case Ops.DrawIndirect:
          skip = 3;
          {
            final int vertexCount = registers[program[i+1]];
            final int vertexOffset = registers[program[i+2]];
            im.draw(vertexCount, vertexOffset);
          }
          break;
        case Ops.DrawIndexed:
          skip = 3;
          {
            final int indexCount = program[i+1];
            final int indexOffset = program[i+2];
            im.drawIndexed(indexCount, indexOffset);
          }
          break;
        case Ops.DrawIndexedMesh:
          skip = 2;
          {
            final SingleArrayIndexedMesh indexedMesh = program[i+1];
            im.drawIndexedMesh(indexedMesh);
          }
          break;
        case Ops.DeregisterResources:
          skip = 2;
        {
          final List<ResourceBase> handles = program[i+1];
          rm.batchDeregister(handles);
        }
        break;
        case Ops.DeleteDeviceChildren:
          skip = 2;
        {
          final List<DeviceChild> handles = program[i+1];
          device.batchDeleteDeviceChildren(handles);
        }
        break;
        case Ops.Call:
          skip = 2;
        {
          List subProgram = program[i+1];
          run(subProgram, device, rm, im);
        }
          break;
        case Ops.Return:
        default:
          return;
      }
      i += skip;
    }
  }
}
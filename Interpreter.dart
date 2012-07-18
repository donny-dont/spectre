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

class Ops {
  /// NO-OP
  /// No arguments
  static final int Null = 0;
  /// Set the value of a register
  /// Arg0 - Register index (0...NumRegisters)
  /// Arg1 - Value to set
  static final int SetRegister = 1;

  /*
  /// Create an index buffer
  /// Arg0 - Handle
  /// Arg1 - Name of index buffer
  static final int CreateIndexBuffer = 6;
  /// Delete an index buffer
  /// Arg0 - Handle
  static final int DeleteIndexBuffer = 7;
  /// Update a buffer with the contents of an array
  /// Arg0 - Buffer handle
  /// Arg1 - Array handle
  static final int UpdateBuffer = 8;
  /// Create a resource
  /// Arg0 - Handle
  /// Arg1 - Name
  static final int CreateResource = 9;
  /// Load a URL into a resource
  /// Arg0 - Handle
  /// Arg1 - URL
  static final int LoadResource = 10;
  static final int DeleteResource = 11;
  /// Update texture on resource change
  /// Arg0 - Texture Handle
  /// Arg1 - Resource Handle
  static final int UpdateTextureOnResourceChange = 20;
  /// Update a buffer on resource change
  /// Arg0 - Buffer Handle
  /// Arg1 - Resource Handle
  static final int UpdateBufferOnResourceChange = 21;
  */

  static final int Call = 30;
  static final int Return = 31;

  /// Set the blend state
  /// Arg0 - Blend State handle
  static final int SetBlendState = 0xA0;
  /// Set the rasterizer state
  /// Arg0 - Rasterizer State handle
  static final int SetRasterizerState = 0xA1;
  /// Set the depth state
  /// Arg0 - Depth State Handle
  static final int SetDepthState = 0xA2;
  /// Set the shader program
  /// ARg0 - Shader Program handle
  static final int SetShaderProgram = 0xA3;
  /// Set the primitive topology
  /// Arg0 - Primitive topology
  static final int SetPrimitiveTopology = 0xA4;
  /// Set the vertex buffer
  /// Arg0 - Offset
  /// Arg1 - List of vertex buffer handles
  static final int SetVertexBuffers = 0xA5;
  /// Set the active index buffer
  /// Arg0 - Index buffer Handle
  static final int SetIndexBuffer = 0xA6;
  /// Set the input layout
  /// Arg0 - Input Layout handle
  static final int SetInputLayout = 0xA7;

  /// Set a uniform variable
  /// Arg0 - Uniform name
  /// Arg1 - Float32Array
  static final int SetUniformMatrix4 = 0xB0;

  /// Draw vertices
  /// Arg0 - Vertex Count
  /// Arg1 - Vertex Buffer Offset
  static final int Draw = 0xC0;

  /// Draw vertices with values from registers
  /// Arg0 - Vertex Count register
  /// Arg1 - Vertex Buffer Offset register
  static final int DrawIndirect = 0xC1;
}

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
}

class Interpreter {
  static final int NumRegisters = 32;
  List registers;

  Interpreter() {
    registers = new List(NumRegisters);
  }

  void clearRegisters() {
    for (int i = 0; i < NumRegisters; i++) {
      registers[i] = null;
    }
  }

  void setRegister(int register, Dynamic value) {
    registers[register] = value;
  }

  int getHandle(int handle) {
    if (Handle.isRegisterHandle(handle) == false ) {
      // Not a register handle, return it
      return handle;
    }
    // handle is a register handle
    // dereference and return contents of register
    return registers[Handle.getIndex(handle)];
  }

  int getRegisterIndex(int handle) {
    if (Handle.isRegisterHandle(handle) == false ) {
      // Not a register handle
      return -1;
    }
    return Handle.getIndex(handle);
  }

  void run(List program, Device device, ResourceManager rm, ImmediateContext im) {
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
            final Dynamic val = program[i+2];
            registers[regId] = val;
          }
          break;
        case Ops.SetBlendState:
          skip = 2;
          {
            final int handle = getHandle(program[i+1]);
            im.setBlendState(handle);
          }
          break;
        case Ops.SetRasterizerState:
          skip = 2;
          {
            final int handle = getHandle(program[i+1]);
            im.setRasterizerState(handle);
          }
          break;
        case Ops.SetDepthState:
          skip = 2;
          {
            final int handle = getHandle(program[i+1]);
            im.setDepthState(handle);
          }
          break;
        case Ops.SetShaderProgram:
          skip = 2;
          {
            final int handle = getHandle(program[i+1]);
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
            final int handle = getHandle(program[i+1]);
            im.setIndexBuffer(handle);
          }
          break;
        case Ops.SetInputLayout:
          skip = 2;
          {
            final int handle = getHandle(program[i+1]);
            im.setInputLayout(handle);
          }
          break;
        case Ops.SetUniformMatrix4:
          skip = 3;
          {
            final String name = program[i+1];
            final Float32Array buf = program[i+2];
            im.setUniformMatrix4(name, buf);
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
            final int vertexCount = registers[getRegisterIndex(program[i+1])];
            final int vertexOffset = registers[getRegisterIndex(program[i+2])];
            im.draw(vertexCount, vertexOffset);
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
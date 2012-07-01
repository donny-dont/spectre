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

class Command {
  static final int None = 0;
  static final int SetPrimitiveTopology = 1;
  static final int SetIndexBuffer = 2;
  static final int SetVertexBuffers = 3;
  static final int SetInputLayout = 4;
  static final int SetShaderProgram = 5;
  static final int SetRasterizerState = 6;
  static final int SetViewport = 7;
  static final int SetBlendState = 8;
  static final int SetDepthState = 9;
  static final int SetRenderTarget = 10;
  static final int SetUniformVector3 = 11;
  static final int SetUniformVector4 = 12;
  static final int SetUniformMatrix3 = 13;
  static final int SetUniformMatrix4 = 14;
  static final int DrawIndexed = 15;
  static final int Draw = 16;
  int _command;
  int get command() => _command;
  abstract void apply(ResourceManager resourceManager, Device device, ImmediateContext context);
  abstract BoundCommand bind(ResourceManager resourceManager, Device device);
}

class CommandSetPrimitiveTopology extends Command {
  int topology;
  CommandSetPrimitiveTopology(this.topology) {
    _command = Command.SetPrimitiveTopology;
  }
  
  void apply(ResourceManager resourceManager, Device device, ImmediateContext context) {
    context.setPrimitiveTopology(topology);
  }
  
  BoundCommand bind(ResourceManager resourceManager, Device device) {
    BoundCommandSetPrimitiveTopology cmd = new BoundCommandSetPrimitiveTopology(topology);
    return cmd;
  }
}

class CommandSetIndexBuffer extends Command {
  String indexBufferName;
  
  CommandSetIndexBuffer(this.indexBufferName) {
    _command = Command.SetIndexBuffer;
  }
  
  void apply(ResourceManager resourceManager, Device device, ImmediateContext context) {
    if (indexBufferName != null) {
      IndexBuffer ib = device.findIndexBuffer(indexBufferName);
      context.setIndexBuffer(ib);  
    } else {
      context.setIndexBuffer(null);
    }
  }
  
  BoundCommand bind(ResourceManager resourceManager, Device device) {
    IndexBuffer ib = null;
    if (indexBufferName != null) {
      ib = device.findIndexBuffer(indexBufferName);
    }
    return new BoundCommandSetIndexBuffer(ib);
  }
}

class CommandSetVertexBuffers extends Command {
  int vboIndex;
  List<String> vboNames;
  
  CommandSetVertexBuffers(this.vboIndex, this.vboNames) {
    _command = Command.SetVertexBuffers;
  }
  
  void apply(ResourceManager resourceManager, Device device, ImmediateContext context) {
    List<VertexBuffer> _vertexBuffers = new List<VertexBuffer>();
    for (final String name in vboNames) {
      _vertexBuffers.add(device.findVertexBuffer(name));
    }
    context.setVertexBuffers(vboIndex, _vertexBuffers);
  }
  
  BoundCommand bind(ResourceManager resourceManager, Device device) {
    List<VertexBuffer> _vertexBuffers = new List<VertexBuffer>();
    for (final String name in vboNames) {
      _vertexBuffers.add(device.findVertexBuffer(name));
    }
    return new BoundCommandSetVertexBuffers(vboIndex, _vertexBuffers);
  }
}

class CommandSetInputLayout extends Command {
  String inputLayoutName;
  
  CommandSetInputLayout(this.inputLayoutName) {
    _command = Command.SetInputLayout;
  }
  
  void apply(ResourceManager resourceManager, Device device, ImmediateContext context) {
    InputLayout il = device.findInputLayout(inputLayoutName);
    context.setInputLayout(il);
  }
  
  BoundCommand bind(ResourceManager resourceManager, Device device) {
    InputLayout il = device.findInputLayout(inputLayoutName);
    return new BoundCommandSetInputLayout(il);
  }
}

class CommandSetShaderProgram extends Command {
  String programName;
  CommandSetShaderProgram(this.programName) {
    _command = Command.SetShaderProgram;
  }
  
  void apply(ResourceManager resourceManager, Device device, ImmediateContext context) {
    ShaderProgram program = device.findShaderProgram(programName);
    context.setShaderProgram(program);
  }
  
  BoundCommand bind(ResourceManager resourceManager, Device device) {
    ShaderProgram program = device.findShaderProgram(programName);
    return new BoundCommandSetShaderProgram(program);
  }
}

class CommandSetRasterizerState extends Command {
  String rasterizerStateName;
  
  CommandSetRasterizerState(this.rasterizerStateName) {
    _command = Command.SetRasterizerState;
  }
  
  void apply(ResourceManager resourceManager, Device device, ImmediateContext context) {
    RasterizerState rs = device.findRasterizerState(rasterizerStateName);
    context.setRasterizerState(rs);
  }
  
  BoundCommand bind(ResourceManager resourceManager, Device device) {
    RasterizerState rs = device.findRasterizerState(rasterizerStateName);
    return new BoundCommandSetRasterizerState(rs);
  }
}

class CommandSetViewport extends Command {
  String viewportName;
  
  CommandSetViewport(this.viewportName) {
    _command = Command.SetViewport;
  }
  
  void apply(ResourceManager resourceManager, Device device, ImmediateContext context) {
    Viewport vp = device.findViewport(viewportName);
    context.setViewport(vp);
  }
  
  BoundCommand bind(ResourceManager resourceManager, Device device) {
    Viewport vp = device.findViewport(viewportName);
    return new BoundCommandSetViewport(vp);
  }
}

class CommandSetBlendState extends Command {
  String blendStateName;
  
  CommandSetBlendState(this.blendStateName) {
    _command = Command.SetBlendState;
  }
  
  void apply(ResourceManager resourceManager, Device device, ImmediateContext context) {
    BlendState bs = device.findBlendState(blendStateName);
    context.setBlendState(bs);
  }
  
  BoundCommand bind(ResourceManager resourceManager, Device device) {
    BlendState bs = device.findBlendState(blendStateName);
    return new BoundCommandSetBlendState(bs);
  }
}

class CommandSetDepthState extends Command {
  String depthStateName;
  
  CommandSetDepthState(this.depthStateName) {
    _command = Command.SetBlendState;
  }
  
  void apply(ResourceManager resourceManager, Device device, ImmediateContext context) {
    DepthState ds = device.findDepthState(depthStateName);
    context.setDepthState(ds);
  }
  
  BoundCommand bind(ResourceManager resourceManager, Device device) {
    DepthState ds = device.findDepthState(depthStateName);
    return new BoundCommandSetDepthState(ds);
  }
}

class CommandSetUniformVector3 extends Command {
  String uniformName;
  num x;
  num y;
  num z;
  
  CommandSetUniformVector3(this.uniformName, this.x, this.y, this.z) {
    _command = Command.SetUniformVector3;
  }
  
  void apply(ResourceManager resourceManager, Device device, ImmediateContext context) {
    context.setUniform3f(uniformName, x, y, z);
  }
  
  BoundCommand bind(ResourceManager resourceManager, Device device) {
    return new BoundCommandSetUniformVector3(uniformName, x, y, z);
  }
}


class CommandSetUniformVector4 extends Command {
  String uniformName;
  num x;
  num y;
  num z;
  num w;  
  CommandSetUniformVector4(this.uniformName, this.x, this.y, this.z, this.w) {
    _command = Command.SetUniformVector4;
  }
  
  void apply(ResourceManager resourceManager, Device device, ImmediateContext context) {
    context.setUniform4f(uniformName, x, y, z, w);
  }
  
  BoundCommand bind(ResourceManager resourceManager, Device device) {
    return new BoundCommandSetUniformVector4(uniformName, x, y, z, w);
  }
}


class CommandSetUniformMatrix3 extends Command {
  String uniformName;
  Float32Array uniformArray;
  bool transposed;
  
  CommandSetUniformMatrix3(this.uniformName, this.uniformArray, [bool transposed_ = false]) {
    this.transposed = transposed_;
    _command = Command.SetUniformMatrix3;
  }
  
  void apply(ResourceManager resourceManager, Device device, ImmediateContext context) {
    context.setUniformMatrix3(uniformName, uniformArray, transposed);
  }
  
  BoundCommand bind(ResourceManager resourceManager, Device device) {
    return new BoundCommandSetUniformMatrix3(uniformName, uniformArray, transposed);
  }
}

class CommandSetUniformMatrix4 extends Command {
  String uniformName;
  Float32Array uniformArray;
  bool transposed;
  
  CommandSetUniformMatrix4(this.uniformName, this.uniformArray, [bool transposed_ = false]) {
    this.transposed = transposed_;
    _command = Command.SetUniformMatrix4;
  }
  
  void apply(ResourceManager resourceManager, Device device, ImmediateContext context) {
    context.setUniformMatrix4(uniformName, uniformArray, transposed);
  }
  
  BoundCommand bind(ResourceManager resourceManager, Device device) {
    return new BoundCommandSetUniformMatrix4(uniformName, uniformArray, transposed);
  }
}

class CommandDraw extends Command {
  int numVertices;
  int vertexOffset;
  
  CommandDraw(this.numVertices, this.vertexOffset) {
    _command = Command.Draw;
  }
  
  void apply(ResourceManager resourceManager, Device device, ImmediateContext context) {
    context.draw(numVertices, vertexOffset);
  }
  
  BoundCommand bind(ResourceManager resourceManager, Device device) {
    return null;
  }
}

class CommandDrawIndexed extends Command {
  int numIndices;
  int indexOffset;
  
  CommandDrawIndexed(this.numIndices, this.indexOffset) {
    _command = Command.DrawIndexed;
  }
  
  void apply(ResourceManager resourceManager, Device device, ImmediateContext context) {
    context.drawIndexed(numIndices, indexOffset);
  }
  
  BoundCommand bind(ResourceManager resourceManager, Device device) {
    return null;
  }
}


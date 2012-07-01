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

class BoundCommand {
  int _command;
  int get command() => _command;
  abstract void apply(ImmediateContext context);
}

class BoundCommandSetPrimitiveTopology extends BoundCommand {
  int primitiveTopology;
  BoundCommandSetPrimitiveTopology(this.primitiveTopology);
  void apply(ImmediateContext context) {
    context.setPrimitiveTopology(primitiveTopology);
  }
}

class BoundCommandSetIndexBuffer extends BoundCommand {
  IndexBuffer ib;
  BoundCommandSetIndexBuffer(this.ib);
  void apply(ImmediateContext context) {
    context.setIndexBuffer(ib);
  }
}

class BoundCommandSetVertexBuffers extends BoundCommand {
  int vboStartIndex;
  List<VertexBuffer> vbs;
  BoundCommandSetVertexBuffers(this.vboStartIndex, this.vbs);
  void apply(ImmediateContext context) {
    context.setVertexBuffers(vboStartIndex, vbs);
  }
}

class BoundCommandSetInputLayout extends BoundCommand {
  InputLayout il;
  BoundCommandSetInputLayout(this.il);
  void apply(ImmediateContext context) {
    context.setInputLayout(il);
  }
}

class BoundCommandSetShaderProgram extends BoundCommand {
  ShaderProgram shaderProgram;
  BoundCommandSetShaderProgram(this.shaderProgram);
  void apply(ImmediateContext context) {
    context.setShaderProgram(shaderProgram);
  }
}

class BoundCommandSetRasterizerState extends BoundCommand {
  RasterizerState rs;
  BoundCommandSetRasterizerState(this.rs);
  void apply(ImmediateContext context) {
    context.setRasterizerState(rs);
  }
}

class BoundCommandSetViewport extends BoundCommand {
  Viewport vp;
  BoundCommandSetViewport(this.vp);
  void apply(ImmediateContext context) {
    context.setViewport(vp);
  }
}

class BoundCommandSetBlendState extends BoundCommand {
  BlendState bs;
  BoundCommandSetBlendState(this.bs);
  void apply(ImmediateContext context) {
    context.setBlendState(bs);
  }
}

class BoundCommandSetDepthState extends BoundCommand {
  DepthState ds;
  BoundCommandSetDepthState(this.ds);
  void apply(ImmediateContext context) {
    context.setDepthState(ds);
  }
}

class BoundCommandSetUniformVector3 extends BoundCommand {
  String uniformName;
  num x;
  num y;
  num z;
  BoundCommandSetUniformVector3(this.uniformName, this.x, this.y, this.z);
  
  void apply(ImmediateContext context) {
    context.setUniform3f(uniformName, x, y, z);
  }
}

class BoundCommandSetUniformVector4 extends BoundCommand {
  String uniformName;
  num x;
  num y;
  num z;
  num w;
  BoundCommandSetUniformVector4(this.uniformName, this.x, this.y, this.z, this.w);
  
  void apply(ImmediateContext context) {
    context.setUniform4f(uniformName, x, y, z, w);
  }
}

class BoundCommandSetUniformMatrix3 extends BoundCommand {
  String uniformName;
  Float32Array uniformArray;
  bool transposed;
  BoundCommandSetUniformMatrix3(this.uniformName, this.uniformArray, this.transposed);
  
  void apply(ImmediateContext context) {
    context.setUniformMatrix3(uniformName, uniformArray, transposed);
  }
}

class BoundCommandSetUniformMatrix4 extends BoundCommand {
  String uniformName;
  Float32Array uniformArray;
  bool transposed;
  BoundCommandSetUniformMatrix4(this.uniformName, this.uniformArray, this.transposed);
  
  void apply(ImmediateContext context) {
    context.setUniformMatrix4(uniformName, uniformArray, transposed);
  }
}

class BoundCommandDraw extends BoundCommand {
  int numVertices;
  int vertexOffset;
  BoundCommandDraw(this.numVertices, this.vertexOffset);
  void apply(ImmediateContext context) {
    context.draw(numVertices, vertexOffset);
  }
}

class BoundCommandDrawIndexed extends BoundCommand {
  int numIndices;
  int indexOffset;
  BoundCommandDrawIndexed(this.numIndices, this.indexOffset);
  void apply(ImmediateContext context) {
    context.drawIndexed(numIndices, indexOffset);
  }
}

class BoundCommandExecuter {
  static executeCommands(List<BoundCommand> commands, ImmediateContext context) {
    for (final BoundCommand cmd in commands) {
      cmd.apply(context);
    }
  }
}
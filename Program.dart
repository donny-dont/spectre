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
  static final int Null = 0x00;
  /// Set the value of a register
  /// Arg0 - Register index (0...NumRegisters)
  /// Arg1 - Value to set
  static final int SetRegister = 0x01;

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

  static final int Call = 0x10;
  static final int Return = 0x11;

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
  /// Set the texture units
  /// Arg0 - texture unit offset
  /// Arg1 - List of texture handles
  static final int SetTextures = 0xA8;
  /// Set the sampler state on texture units
  /// Arg0 - texture unit offset
  /// Arg1 - List of sampler handles
  static final int SetSamplers = 0xA9;

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

  /// Draw an indexed primitive stream
  /// Arg0 - Index count
  /// Arg1 - Index buffer offset
  static final int DrawIndexed = 0xC2;

  /// Dergister and unload resources
  /// Arg0 - List of resource handles
  static final int DeregisterAndUnloadResources = 0xD0;

  /// Delete device children
  /// Arg0 - List of device handles
  static final int DeleteDeviceChildren = 0xD1;
}
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
  static const int Null = 0x00;
  /// Set the value of a register
  /// Arg0 - Register index (0...NumRegisters)
  /// Arg1 - Value to set
  static const int SetRegister = 0x01;
  /// Set the value of a register
  /// Arg0 - Register index (0...NumRegisters)
  /// Arg1 - List
  /// Arg2 - List index
  static const int SetRegisterFromList = 0x02;


  static const int Call = 0x10;
  static const int Return = 0x11;


  /// Create a new blend state
  /// Arg0 - Name of blend state
  /// Arg1 - Map of options
  /// Arg2 - List to store handle in (can be null)
  static const int CreateBlendState = 0x20;
  /// Create a new depth state
  /// Arg0 - Name of depth state
  /// Arg1 - Map of options
  /// Arg2 - List to store handle in (can be null)
  static const int CreateDepthState = 0x21;
  /// Create a new rasterizer state
  /// Arg0 - Name of rasterizer state
  /// Arg1 - Map of options
  /// Arg2 - List to store handle in (can be null)
  static const int CreateRasterizerState = 0x22;
  /// Create a new vertex shader
  /// Arg0 - Name of vertex shader
  /// Arg1 - Map of options
  /// Arg2 - List to store handle in (can be null)
  static const int CreateVertexShader = 0x23;
  /// Create a new fragment shader
  /// Arg0 - Name of fragment shader
  /// Arg1 - Map of options
  /// Arg2 - List to store handle in (can be null)
  static const int CreateFragmentShader = 0x24;
  /// Create a new shader program
  /// Arg0 - Name of shader program state
  /// Arg1 - Map of options
  /// Arg2 - List to store handle in (can be null)
  static const int CreateShaderProgram = 0x25;
  /// Create a new indexed mesh
  /// Arg0 - Name of indexed mesh
  /// Arg1 - Map of options
  /// Arg2 - List to store handle in (can be null)
  static const int CreateIndexedMesh = 0x26;
  /// Create a new input layout for a given indexed mesh resource and shader
  /// Arg0 - Name of input layout
  /// Arg1 - Handle of mesh resource
  /// Arg2 - Handle of shader program resource
  /// Arg3 - List of inputs descriptions (InputLayoutDescription)
  /// Arg4 - List to store handle in (can be null)
  static const int CreateInputLayoutForMeshResource = 0x27;

  /// Compile a shader from a shader resource
  /// Arg0 - Handle to shader
  /// Arg1 - Handle to resource
  static const int CompileShaderFromResource = 0x30;
  /// Link a shader program
  /// Arg0 - Handle to shader program
  /// Arg1 - Handle to vertex shader
  /// Arg2 - Handle to fragment shader
  static const int LinkShaderProgram = 0x31;

  /// Set the blend state
  /// Arg0 - Blend State handle
  static const int SetBlendState = 0xA0;
  /// Set the rasterizer state
  /// Arg0 - Rasterizer State handle
  static const int SetRasterizerState = 0xA1;
  /// Set the depth state
  /// Arg0 - Depth State Handle
  static const int SetDepthState = 0xA2;
  /// Set the shader program
  /// ARg0 - Shader Program handle
  static const int SetShaderProgram = 0xA3;
  /// Set the primitive topology
  /// Arg0 - Primitive topology
  static const int SetPrimitiveTopology = 0xA4;
  /// Set the vertex buffer
  /// Arg0 - Offset
  /// Arg1 - List of vertex buffer handles
  static const int SetVertexBuffers = 0xA5;
  /// Set the active index buffer
  /// Arg0 - Index buffer Handle
  static const int SetIndexBuffer = 0xA6;
  /// Set the input layout
  /// Arg0 - Input Layout handle
  static const int SetInputLayout = 0xA7;
  /// Set the texture units
  /// Arg0 - texture unit offset
  /// Arg1 - List of texture handles
  static const int SetTextures = 0xA8;
  /// Set the sampler state on texture units
  /// Arg0 - texture unit offset
  /// Arg1 - List of sampler handles
  static const int SetSamplers = 0xA9;

  /// Set the index buffer and vertex buffer units
  /// Arg0 - Handle to indexed mesh
  static const int SetIndexedMesh = 0xA10;

  /// Set a uniform variable
  /// Arg0 - Uniform name
  /// Arg1 - Float32Array
  static const int SetUniformMatrix4 = 0xB0;

  /// Set a uniform variable
  /// Arg0 - Uniform name
  /// Arg1 - Float32Array
  static const int SetUniformVector4 = 0xB1;

  /// Set a uniform variable
  /// Arg0 - Uniform name
  /// Arg1 - Float32Array
  static const int SetUniformVector3 = 0xB2;

  /// Set a uniform variable
  /// Arg0 - Uniform name
  /// Arg1 - Float32Array
  static const int SetUniformVector2 = 0xB3;

  /// Set a uniform variable
  /// Arg0 - Uniform name
  /// Arg1 - Int
  static const int SetUniformInt = 0xB4;

  /// Draw vertices
  /// Arg0 - Vertex Count
  /// Arg1 - Vertex Buffer Offset
  static const int Draw = 0xC0;

  /// Draw vertices with values from registers
  /// Arg0 - Vertex Count register
  /// Arg1 - Vertex Buffer Offset register
  static const int DrawIndirect = 0xC1;

  /// Draw an indexed primitive stream
  /// Arg0 - Index count
  /// Arg1 - Index buffer offset
  static const int DrawIndexed = 0xC2;

  /// Draw an IndexedMesh
  /// Arg0 - handle to IndexedMesh
  static const int DrawIndexedMesh = 0xC3;

  /// Dergister and unload resources
  /// Arg0 - List of resource handles
  static const int DeregisterResources = 0xD0;

  /// Delete device children
  /// Arg0 - List of device handles
  static const int DeleteDeviceChildren = 0xD1;
}
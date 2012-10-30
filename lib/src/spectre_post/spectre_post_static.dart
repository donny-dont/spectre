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

class SpectrePost {
  static GraphicsDevice _device = null;
  static Map<String, SpectrePostPass> _passes = null;
  static int _rasterizerState = null;
  static int _depthState = null;
  static int _blendState = null;
  static int vertexBuffer = null;
  static int vertexShader = null;
  static List<InputElementDescription> elements  = null;

  static void init(GraphicsDevice device) {
    if (_device == null) {
      _device = device;
      _rasterizerState = _device.createRasterizerState('SpectrePost.RS', {'cullEnabled': false});
      _depthState = _device.createDepthState('SpectrePost.DS', {});
      _blendState = _device.createBlendState('SpectrePost.PS', {'blendEnable':true, 'blendSourceColorFunc': BlendState.BlendSourceShaderAlpha, 'blendDestColorFunc': BlendState.BlendSourceShaderInverseAlpha, 'blendSourceAlphaFunc': BlendState.BlendSourceShaderAlpha, 'blendDestAlphaFunc': BlendState.BlendSourceShaderInverseAlpha});
      _passes = new Map<String, SpectrePostPass>();
      int numFloats = 6 * (3+2);
      Float32Array verts = new Float32Array(6*(3+2));
      elements = [new InputElementDescription('vPosition', GraphicsDevice.DeviceFormatFloat3, 20, 0, 0),
                  new InputElementDescription('vTexCoord', GraphicsDevice.DeviceFormatFloat2, 20, 0, 12)
                  ];
      int index = 0;
      num depth = -1.0;
      // Triangle 1
      {
        // Vertex 1
        verts[index++] = -1.0;
        verts[index++] = -1.0;
        verts[index++] = depth;
        verts[index++] = 0.0;
        verts[index++] = 0.0;

        // Vertex 2
        verts[index++] = 1.0;
        verts[index++] = -1.0;
        verts[index++] = depth;
        verts[index++] = 1.0;
        verts[index++] = 0.0;

        // Vertex 3
        verts[index++] = 1.0;
        verts[index++] = 1.0;
        verts[index++] = depth;
        verts[index++] = 1.0;
        verts[index++] = 1.0;
      }
      // Triangle 2
      {
        // Vertex 1
        verts[index++] = -1.0;
        verts[index++] = -1.0;
        verts[index++] = depth;
        verts[index++] = 0.0;
        verts[index++] = 0.0;

        // Vertex 2
        verts[index++] = 1.0;
        verts[index++] = 1.0;
        verts[index++] = depth;
        verts[index++] = 1.0;
        verts[index++] = 1.0;

        // Vertex 3
        verts[index++] = -1.0;
        verts[index++] = 1.0;
        verts[index++] = depth;
        verts[index++] = 0.0;
        verts[index++] = 1.0;
      }
      assert(index == numFloats);
      vertexBuffer = _device.createVertexBuffer('SpectrePost.VBO', {
        'usage': 'static'
      });
      _device.context.updateBuffer(vertexBuffer, verts);
      vertexShader = _device.createVertexShader('SpectrePost.VS', {});
      VertexShader vs = _device.getDeviceChild(vertexShader);
      _device.context.compileShader(vertexShader, '''
precision highp float;

attribute vec3 vPosition;
attribute vec2 vTexCoord;

varying vec2 samplePoint;

uniform vec2 texScale;

void main() {
    vec4 vPosition4 = vec4(vPosition.x, vPosition.y, vPosition.z, 1.0);
    gl_Position = vPosition4;
    samplePoint = vTexCoord * texScale;
}
''');
      addFragmentPass('blit', '''
precision mediump float;

varying vec2 samplePoint;
uniform sampler2D blitSource;

void main() {
    gl_FragColor = texture2D(blitSource, samplePoint);
}''');

      addFragmentPass('testblit', '''
precision mediump float;

varying vec2 samplePoint;
uniform sampler2D blitSource;

void main() {
    gl_FragColor = vec4(1.0, 0.5, 0.5, 1.0);
}''');

      addFragmentPass('blur', '''
          precision mediump float;

          const float blurSize = 1.0/512.0;

          varying vec2 samplePoint;
          uniform sampler2D RTScene;

          void main() {
            vec2 vTexCoord = samplePoint;
   vec4 sum = texture2D(RTScene, vec2(vTexCoord.x - 4.0*blurSize, vTexCoord.y)) * 0.05;
   sum += texture2D(RTScene, vec2(vTexCoord.x - 3.0*blurSize, vTexCoord.y)) * 0.09;
   sum += texture2D(RTScene, vec2(vTexCoord.x - 2.0*blurSize, vTexCoord.y)) * 0.12;
   sum += texture2D(RTScene, vec2(vTexCoord.x - blurSize, vTexCoord.y)) * 0.15;
   sum += texture2D(RTScene, vec2(vTexCoord.x, vTexCoord.y)) * 0.16;
   sum += texture2D(RTScene, vec2(vTexCoord.x + blurSize, vTexCoord.y)) * 0.15;
   sum += texture2D(RTScene, vec2(vTexCoord.x + 2.0*blurSize, vTexCoord.y)) * 0.12;
   sum += texture2D(RTScene, vec2(vTexCoord.x + 3.0*blurSize, vTexCoord.y)) * 0.09;
   sum += texture2D(RTScene, vec2(vTexCoord.x + 4.0*blurSize, vTexCoord.y)) * 0.05;

   gl_FragColor = sum;

      }''');
    } else {
      // already initialized...
      spectreLog.Error('Cannot initialize SpectrePost more than once.');
    }
  }

  static void cleanup() {
    _passes.forEach((k,v) {
      spectreLog.Info('Cleaning up spectre post process $k');
      v.cleanup(_device);
    });
    _passes.clear();
    _device.deleteDeviceChild(vertexBuffer);
    _device.deleteDeviceChild(vertexShader);
    _device.deleteDeviceChild(_rasterizerState);
    _device.deleteDeviceChild(_blendState);
    _device.deleteDeviceChild(_depthState);
  }

  static void addPass(String name, SpectrePostPass pass) {
    if (_passes[name] != null) {
      spectreLog.Error('Attempt to add pass that already exists- $name');
      return;
    }
    _passes[name] = pass;
  }

  static void addFragmentPass(String name, String fragmentSource) {
    if (_passes[name] != null) {
      spectreLog.Error('Attempt to add pass that already eists- $name');
      return;
    }
    int fragmentShader = _device.createFragmentShader('SpectrePost.FS[$name]', {});
    _device.context.compileShader(fragmentShader, fragmentSource);
    int passProgram = _device.createShaderProgram('SpectrePost.Program[$name]', {
      'VertexProgram': vertexShader,
      'FragmentProgram': fragmentShader
    });
    SpectrePostFragment spf = new SpectrePostFragment(_device, name, passProgram, elements);
    _passes[name] = spf;
  }

  static void removePass(String name) {
    SpectrePostPass pass = _passes[name];
    if (pass != null) {
      _passes.remove(name);
      pass.cleanup(_device);
    }
  }

  static void pass(String name, int renderTargetHandle, Map<String, dynamic> arguments) {
    SpectrePostPass pass = _passes[name];
    if (pass == null) {
      spectreLog.Error('Post process $name does not exist. Cannot do pass.');
      return;
    }
    pass.setup(_device, arguments);
    _device.context.setVertexBuffers(0, [vertexBuffer]);
    _device.context.setIndexBuffer(0);
    _device.context.setRasterizerState(_rasterizerState);
    _device.context.setDepthState(_depthState);
    _device.context.setBlendState(_blendState);
    // FIXME: Make the following dynamic:
    _device.context.setUniform2f('texScale', 0.833, 0.46875);
    _device.context.setPrimitiveTopology(GraphicsContext.PrimitiveTopologyTriangles);
    _device.context.setRenderTarget(renderTargetHandle);
    _device.context.draw(6, 0);
  }
}
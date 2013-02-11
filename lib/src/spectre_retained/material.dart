/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

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

part of spectre_retained;

/** A material describes how a mesh is rendered. */
class Material {
    final String name;
    final Renderer renderer;
    final ShaderProgram shader;
    final Map<String, MaterialConstant> constants =
        new Map<String, MaterialConstant>();
    /// Map from shader texture name to asset path.
    final Map<String, String> textures = new Map<String, String>();
    final List<SpectreTexture> _textures = new List<SpectreTexture>();
    final List<SamplerState> _samplers = new List<SamplerState>();

    DepthState _depthState;
    DepthState get depthState => _depthState;
    RasterizerState _rasterizerState;
    RasterizerState get rasterizerState => _rasterizerState;
    BlendState _blendState;
    BlendState get blendState => _blendState;

    Material(this.renderer, this.name, this.shader) {
      _depthState = renderer.device.createDepthState('$name[DS]');
      _blendState = renderer.device.createBlendState('$name[BS]');
      _rasterizerState = renderer.device.createRasterizerState('$name[RS]');
      while (_textures.length < shader.samplers.length) {
        _textures.add(null);
        _samplers.add(null);
      }
      _link();
    }

    /** Clone the material the cloned material will be named [cloneName]. */
    Material clone(String cloneName) {
      Material cloned = new Material(renderer, cloneName, shader);
      // TODO(johnmccutchan): Clone material data.
      return cloned;
    }

    /** Apply this material to be used for rendering */
    void apply(GraphicsDevice device) {
      device.context.setBlendState(_blendState);
      device.context.setRasterizerState(_rasterizerState);
      device.context.setDepthState(_depthState);
      device.context.setShaderProgram(shader);
      constants.forEach((k, v) {
        device.context.setConstant(k, v.value);
      });
      textures.forEach((k, v) {
        int textureUnit = shader.samplers[k].textureUnit;
        Texture texture = renderer.assetManager.getAssetAtPath(v);
        _textures[textureUnit] = texture.texture;
        _samplers[textureUnit] = texture.sampler;
      });
      device.context.setSamplers(0, _samplers);
      device.context.setTextures(0, _textures);
    }

    void _link() {
      constants.clear();
      shader.uniforms.forEach((k, v) {
        constants[k] = new MaterialConstant(k, v.type);
      });
    }

    void updateCameraConstants(Camera camera) {
      if (camera == null) {
        // TODO(johnmccutchan): Do we have a default camera setup?
      }
      mat4 projectionMatrix = camera.projectionMatrix;
      mat4 viewMatrix = camera.lookAtMatrix;
      mat4 projectionViewMatrix = camera.projectionMatrix;
      projectionViewMatrix.multiply(viewMatrix);
      mat4 viewRotationMatrix = makeLookAt(new vec3.zero(),
                                           camera.frontDirection,
                                           new vec3.raw(0.0, 1.0, 0.0));
      mat4 projectionViewRotationMatrix = camera.projectionMatrix;
      projectionViewRotationMatrix.multiply(viewRotationMatrix);
      MaterialConstant constant;
      constant = constants['cameraView'];
      if (constant != null) {
        viewMatrix.copyIntoArray(constant.value);
      }
      constant = constants['cameraProjection'];
      if (constant != null) {
        projectionMatrix.copyIntoArray(constant.value);
      }
      constant = constants['cameraProjectionView'];
      if (constant != null) {
        projectionViewMatrix.copyIntoArray(constant.value);
      }
      constant = constants['cameraViewRotation'];
      if (constant != null) {
        viewRotationMatrix.copyIntoArray(constant.value);
      }
      constant = constants['cameraProjectionViewRotation'];
      if (constant != null) {
        projectionViewRotationMatrix.copyIntoArray(constant.value);
      }
    }

    void updateObjectTransformConstant(mat4 T) {
      MaterialConstant constant;
      constant = constants['objectTransform'];
      if (constant != null) {
        T.copyIntoArray(constant.value);
      }
    }

    void updateViewportConstants(Viewport vp) {
      MaterialConstant constant;
      constant = constants['viewport'];
      if (constant != null) {
        constant.value[0] = vp.x.toDouble();
        constant.value[1] = vp.y.toDouble();
        constant.value[2] = vp.width.toDouble();
        constant.value[3] = vp.height.toDouble();
      }
    }
}

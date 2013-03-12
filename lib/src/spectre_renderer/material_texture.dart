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

part of spectre_renderer;

class MaterialTexture {
  final Renderer renderer;
  final String name;
  final int textureUnit;
  String _texturePath;

  /** The asset path used when linking the texture */
  String get texturePath => _texturePath;
  set texturePath(String path) {
    _texturePath = path;
    link();
  }

  SpectreTexture _texture;
  SpectreTexture get texture => _texture;
  SamplerState sampler;

  /** Construct a new texture */
  MaterialTexture(this.renderer, this.name, this._texturePath,
                  this.textureUnit) {
    sampler = new SamplerState(name, renderer.device);
    link();
  }

  /** Construct a clone of [other] */
  MaterialTexture.clone(MaterialTexture other)
      : renderer = other.renderer,
        name = other.name,
        textureUnit = other.textureUnit {
    sampler = new SamplerState(name, renderer.device);
    sampler.fromJson(sampler.toJson());
    link();
  }

  MaterialTexture.json(this.renderer, Map json) :
      name = json['name'],
      textureUnit = json['textureUnit'] {
    fromJson(json);
  }

  /** Link this texture. A texture must be linked before it can be used. */
  link() {
    var texture = renderer.assetManager.root.getImportedAtPath(_texturePath);
    // TODO(johnmccutchan): Use fallback texture if it can't be found.
    _texture = texture;
  }

  /** Returns a JSON map describing this texture */
  dynamic toJson() {
    Map json = new Map();
    json['name'] = name;
    json['_texturePath'] = texturePath;
    json['sampler'] = sampler.toJson();
    return json;
  }

  void fromJson(dynamic json) {
    texturePath = json['texturePath'];
    sampler.fromJson(json['sampler']);
  }
}
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

class MaterialConstant {
  /** The constant name. This is the same name used in GLSL. */
  final String name;
  /** The constant type. This is the same type used in GLSL. */
  final String type;
  dynamic _value;
  /** The constant value. */
  dynamic get value => _value;

  dynamic _constructValue(String type) {
    switch (type) {
      case 'vec3':
        return new Float32Array(3);
      case 'vec4':
        return new Float32Array(4);
      case 'mat3':
        var v = new Float32Array(9);
        v[0] = 1.0;
        v[4] = 1.0;
        v[8] = 1.0;
        return v;
      case 'mat4':
        var v = new Float32Array(16);
        v[0] = 1.0;
        v[5] = 1.0;
        v[10] = 1.0;
        v[15] = 1.0;
        return v;
    }
    throw new FallThroughError();
  }

  void _copyValue(MaterialConstant destination, MaterialConstant source) {
    assert(destination.value.length == source.value.length);
    for (int i = 0; i < source.value.length; i++) {
      destination.value[i] = source.value[i];
    }
  }

  /** Make a new material constant with [name] of [type]. */
  MaterialConstant(this.name, this.type) {
    _value = _constructValue(type);
  }

  MaterialConstant.clone(MaterialConstant other)
    : name = other.name, type = other.type {
    _value = _constructValue(other.type);
    _copyValue(this, other);
  }

  MaterialConstant.json(Map json) : name = json['name'], type = json['type'] {
    _value = _constructValue(type);
    fromJson(json);

  }

  void fromJson(Map json) {
    for (int i = 0; i < _value.length; i++) {
      _value[i] = json['value'][i];
    }
  }

  /** Returns a JSON map describing this constant */
  Map toJson() {
    Map json = new Map();
    json['name'] = name;
    json['type'] = type;
    json['value'] = new List();
    for (int i = 0; i < _value.length; i++) {
      json['value'].add(_value[i]);
    }
    return json;
  }
}

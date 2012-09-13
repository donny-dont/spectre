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

class JavelineConfigType {
  abstract String serialize(Dynamic o);
  abstract Dynamic deserialize(String data);
  bool istype(Dynamic o) => false;
}

class JavelineConfigType_bool extends JavelineConfigType {
  String serialize(Dynamic o) {
    assert(o is bool);
    return JSON.stringify(o);
  }
  Dynamic deserialize(String data) {
    bool o = JSON.parse(data);
    return o;
  }
  bool istype(Dynamic o) => o is bool;
}

class JavelineConfigType_num extends JavelineConfigType {
  String serialize(Dynamic o) {
    assert(o is num);
    return JSON.stringify(o);
  }
  Dynamic deserialize(String data) {
    num o = JSON.parse(data);
    return o;
  }
  bool istype(Dynamic o) => o is num;
}

class JavelineConfigType_String extends JavelineConfigType {
  String serialize(Dynamic o) {
    return o;
  }
  Dynamic deserialize(Dynamic o) {
    return o;
  }
  bool istype(Dynamic o) => o is String;
}

class JavelineConfigType_vec3 extends JavelineConfigType {
  String serialize(Dynamic o) {
    assert(o is vec3);
    Map<String, num> target = new Map<String, num>();
    target['x'] = o.x;
    target['y'] = o.y;
    target['z'] = o.z;
    return JSON.stringify(target);
  }
  Dynamic deserialize(String data) {
    Map<String, num> src = JSON.parse(data);
    vec3 o = new vec3.zero();
    o.x = src['x'];
    o.y = src['y'];
    o.z = src['z'];
    return o;
  }
  bool istype(Dynamic o) => o is vec3;
}

class JavelineConfigTypes {
  static Map<String, JavelineConfigType> types;
  static init() {
    types = new Map<String, JavelineConfigType>();
    types['vec3'] = new JavelineConfigType_vec3();
    types['bool'] = new JavelineConfigType_bool();
    types['num'] = new JavelineConfigType_num();
    types['String'] = new JavelineConfigType_String();
  }
  static JavelineConfigType find(String name) {
    return JavelineConfigTypes.types[name];
  }
}

typedef Dynamic CreateDefault();

class JavelineConfigVariable {
  String name;
  String type;
  CreateDefault defaultValue;
  Dynamic value;
  JavelineConfigVariable(this.name, this.type, this.defaultValue) {
    value = defaultValue();
  }
  void reset() {
    value = defaultValue(); 
  }
}

typedef ConfigVariableChanged(JavelineConfigVariable variable);

class JavelineConfigStorage {
  static Map<String, JavelineConfigVariable> variables;
  static ConfigVariableChanged notification;
  static void init() {
    notification = null;
    JavelineConfigTypes.init();
    variables = new Map<String, JavelineConfigVariable>();
    variables['camera.eyePosition'] = new JavelineConfigVariable('camera.eyePosition', 'vec3', () => new vec3(0.0, 2.0, 0.0));
    variables['camera.lookAtPosition'] = new JavelineConfigVariable('camera.lookAtPosition', 'vec3', () => new vec3(0.0, 2.0, 2.0));
    variables['drawlist.update'] = new JavelineConfigVariable('drawlist.update', 'bool', () => true);
    variables['javeline.demo'] = new JavelineConfigVariable('javeline.demo', 'String', () => 'Empty');
    variables['demo.hfluid.waveheight'] = new JavelineConfigVariable('demo.hfluid.waveheight', 'num', () => 0.8);
    variables['demo.hfluid.dropheight'] = new JavelineConfigVariable('demo.hfluid.dropheight', 'num', () => 0.3);
    variables['demo.postprocess'] = new JavelineConfigVariable('demo.postprocess', 'String', () => 'blit');
  }

  static void loadVariable(String name) {
    JavelineConfigVariable variable = JavelineConfigStorage.variables[name];
    if (variable == null) {
      return;
    }
    JavelineConfigType type = JavelineConfigTypes.types[variable.type];
    if (type == null) {
      return;
    }
    String json = window.localStorage[name];
    if (json != null) {
      variable.value = type.deserialize(json);  
    } else {
      print('First time seeing $name');
      storeVariable(name);
    }
  }
  
  static void storeVariable(String name) {
    JavelineConfigVariable variable = JavelineConfigStorage.variables[name];
    if (variable == null) {
      return;
    }
    JavelineConfigType type = JavelineConfigTypes.types[variable.type];
    if (type == null) {
      return;
    }
    String json = type.serialize(variable.value);
    window.localStorage[name] = json;
  }
  
  static void load() {
    variables.forEach((k,v) {
      loadVariable(k);
    });
  }
  
  static void store() {
    variables.forEach((k,v) {
      storeVariable(k);
    });
  }
  
  static Dynamic set(String name, Dynamic o,[bool commit=true]) {
    JavelineConfigVariable variable;
    variable = JavelineConfigStorage.variables[name];
    if (variable == null) {
      return;
    }
    variable.value = o;
    if (commit) {
      storeVariable(name);
    }
    return o;
  }
  
  static Dynamic get(String name) {
    JavelineConfigVariable variable;
    variable = JavelineConfigStorage.variables[name];
    if (variable == null) {
      return null;
    }
    return variable.value;
  }
}
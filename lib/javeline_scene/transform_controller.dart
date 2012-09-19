
class TransformController {
  final TransformGraph graph;
  final int handle;
  Map transform;
  Map properties;
  num _t;
  num _direction;
  TransformController(this.graph, this.handle) {
    _t = 0.0;
    _direction = 1.0;
  }
  
  void load(Map o) {
    transform = o;
    properties = o['controller'];
    _setup();
  }
  
  void _setup() {
    if (properties == null) {
      return;
    }
    _t = 0.0;
  }
  
  void _updateDomain() {    
    bool hitMax = false;
    bool hitMin = false;
    if (properties['max'] != null) {
      num maxT = properties['max'];
      if (_t >= maxT) {
        hitMax = true;
      }
    }
    if (properties['min'] != null) {
      num minT = properties['min'];
      if (_t <= minT) {
        hitMin = true;
      }
    }
    
    if (hitMin) {
      if (properties['reset']) {
        _t = 0.0;
      }
      if (properties['flip']) {
        _direction *= -1.0;
      }
    }
    
    if (hitMax) {
      if (properties['flip']) {
        _direction *= -1.0;
      }
    }
  }
  
  num _evaluate() {
    switch (properties['function']) {
      case 'sin':
        return Math.sin(_t).abs();
      case 'cos':
        return Math.cos(_t).abs();
    }
    return 0.0;
  }
  
  void _lerp(List<num> s, List<num> e, List<num> target, num x) {
    int len = s.length;
    for (int i = 0; i < len; i++) {
      num d = e[i]-s[i];
      target[i] = s[i] + x * d;
    }
  }
  
  void _apply(num f_of_t) {
    String target = properties['target'];
    mat4 T = graph.refLocalMatrix(handle);
    T.setIdentity();
    num rotateX = transform['rotateX'];
    num rotateY = transform['rotateY'];
    num rotateZ = transform['rotateZ'];
    List<num> translate = transform['translate'];
    List<num> scale = transform['scale'];
    if (rotateX != null) {
      T.rotateX(rotateX);
    }
    if (rotateY != null) {
      T.rotateY(rotateY);
    }
    if (rotateZ != null) {
      T.rotateZ(rotateZ);
    }
    if (target == 'translate') {
      List<num> translate_start = properties['translate_start'];
      List<num> translate_end = properties['translate_end'];
      translate = new List<num>(3);
      _lerp(translate_start, translate_end, translate, f_of_t);
    }
    if (target == 'scale') {
      List<num> scale_start = properties['scale_start'];
      List<num> scale_end = properties['scale_end'];
      scale = new List<num>(3);
      _lerp(scale_start, scale_end, scale, f_of_t);
    }
    if (translate != null) {
      T.translate(translate[0], translate[1], translate[2]);
    }
    if (scale != null) {
      T.scale(scale[0], scale[1], scale[2]);
    }
  }
  
  void control(num dt) {
    if (properties == null) {
      return;
    }
    _t += dt;
    _updateDomain();
    num f_of_t = _evaluate();
    _apply(f_of_t);
  }
}

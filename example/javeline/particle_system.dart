#library('particle_system');
#import('../../external/DartVectorMath/lib/vector_math_html.dart');
#import('../../lib/spectre.dart');
#import('dart:math', prefix:'Math');

class ParticleSystemBackend {
  int _numParticles;
  num _timeStep;
  num _timeStep2;
  
  vec3 gravityDirection;
  vec3 _min;
  vec3 _max;
  
  int _index;
  
  Math.Random _random;
  
  ParticleSystemBackend(this._numParticles, this._timeStep) {
    gravityDirection = new vec3(0.0, -1.0, 0.0);
    // 5x5x5 box for particles
    _min = new vec3(0.0, 0.0, 0.0);
    _max = new vec3(10.0, 10.0, 10.0);
    _timeStep2 = _timeStep * _timeStep;
    _index = 0;
    _random = new Math.Random();
  }
  
  void setBounds(vec3 min, vec3 max) {
    _min = min;
    _max = max;
  }
  
  num getRandomBetween(num min, num max) {
    num len = max - min;
    return min + _random.nextDouble() * len;
  }
    
  void getRandomPosition(vec3 p) {
    p.x = getRandomBetween(_min.x, _max.x);
    p.y = getRandomBetween(_min.y, _max.y);
    p.z = getRandomBetween(_min.z, _max.z);
  }
  
  bool _clamp(vec3 x, vec3 min, vec3 max) {
    bool clamped = false;
    if (max.x < x.x) {
      clamped = true;
      x.x = max.x;
    }
    
    if (max.y < x.y) {
      clamped = true;
      x.y = max.y;
    }
    
    if (max.z < x.z) {
      clamped = true;
      x.z = max.z;
    }
    
    if (min.x > x.x) {
      clamped = true;
      x.x = min.x;
    }
    
    if (min.y > x.y) {
      clamped = true;
      x.y = min.y;
    }
    if (min.z > x.z) {
      clamped = true;
      x.z = min.z;
    }
    
    return clamped;
    
  }
  
  int get readIndex() => _index;
  int get writeIndex() => (_index+1)%2;
  abstract void applyForces();
  abstract void integrate();
  abstract void satisfyConstraints();
  abstract void copyPositions(Dynamic out, int stride);
  
  void update() {
    applyForces();
    integrate();
    satisfyConstraints();
    // Move index
    //_index = (_index+1)%2;
  }  
}

class ParticleSystemBackendDVM extends ParticleSystemBackend {
  List<vec3> positions0;
  List<vec3> positions1;
  List<vec3> impulses;
  
  ParticleSystemBackendDVM(int numParticles_) : super(numParticles_, 0.016) {
    positions0 = new List<vec3>(_numParticles);
    positions1 = new List<vec3>(_numParticles);
    impulses = new List<vec3>(_numParticles);
    vec3 rp = new vec3.zero();
    for (int i = 0; i < _numParticles; i++) {
      getRandomPosition(rp);
      positions0[i] = new vec3.copy(rp);
      positions1[i] = new vec3.copy(rp);
      impulses[i] = new vec3.zero();
    }
  }
  
  void applyForces() {
    vec3 impulse = new vec3.copy(gravityDirection);
    impulse.scale(10.0);
    impulse.scale(_timeStep2);
    vec3 impulse2 = new vec3.copy(gravityDirection);
    impulse2.scale(-200.0);
    impulse2.scale(_timeStep2);
    final List<vec3> pos = getPositions(readIndex);
    for (int i = 0; i < _numParticles; i++) {
      impulses[i].copyFrom(impulse);
    }
  }
  
  List<vec3> getPositions(int index) {
    if (index == 0) {
      return positions0;
    } else {
      return positions1;
    }
  }
  
  void integrate() {
    final int ri = readIndex;
    final int wi = writeIndex;
    final List<vec3> oldPositions = getPositions(ri);
    final List<vec3> newPositions = getPositions(wi);
    vec3 x = new vec3.zero();
    vec3 oldx = new vec3.zero();
    for (int i = 0; i < _numParticles; i++) {
      x.copyFrom(newPositions[i]);
      oldx.copyFrom(oldPositions[i]);
      // Update old position with position from new positions
      oldPositions[i].copyFrom(x);
      
      // Integrate x
      // x += x-oldx + a * t * t;
      // impulse has a * t * t in it
      // x += (x-oldx) + impulse
      x.add(x);
      x.sub(oldx);
      x.add(impulses[i]);
      // Copy updated x into new positions
      newPositions[i].copyFrom(x);
    }
  }
  
  void bounce(int i, List<vec3> oldPositions, List<vec3> newPositions) {
    vec3 temp = new vec3.zero();
    temp.copyFrom(newPositions[i]);
    /* This:
    temp.scale(2.0);
    oldPositions[i].scale(-1.0);
    oldPositions[i].add(temp);
    or this: */
    newPositions[i].copyFrom(oldPositions[i]);
    oldPositions[i].copyFrom(temp);
  }
  
  void drag(int i, List<vec3> oldPositions, List<vec3> newPositions) {
    
  }
  
  void satisfyConstraints() {
    final int ri = readIndex;
    final int wi = writeIndex;
    final List<vec3> oldPositions = getPositions(ri);
    final List<vec3> newPositions = getPositions(wi);
    vec3 x = new vec3.zero();
    for (int i = 0; i < _numParticles; i++) {
      if (_clamp(newPositions[i], _min, _max)) {
        bounce(i, oldPositions, newPositions);
      }
    }
  }
  
  void copyPositions(Dynamic out, int stride) {
    final List<vec3> pos = getPositions(writeIndex);
    for (int i = 0; i < _numParticles; i++) {
      int index = i * stride;
      out[index] = pos[i].x;
      out[index+1] = pos[i].y;
      out[index+2] = pos[i].z;
    }
  }
} 

class ClothConstraint {
  final int i;
  final int j;
  final num restlength;
  ClothConstraint(this.i, this.j, this.restlength);
}

class ClothSystemBackendDVM extends ParticleSystemBackend {
  List<vec3> positions0;
  List<vec3> positions1;
  List<vec3> impulses;
  List<ClothConstraint> constraints;
  
  num _topHeight;
  num _gapWidth;
  int _gridWidth;
  int _numConstraints;
  bool _sphereEnabled;
  vec3 _sphereCenter;
  num _sphereRadius;
  ClothSystemBackendDVM(int gridWidth) : super(gridWidth*gridWidth, 0.016) {
    _topHeight = 8.0;
    _gapWidth = 0.6;
    _gridWidth = gridWidth;
    _sphereCenter = new vec3.zero();
    _sphereRadius = 0.0;
    positions0 = new List<vec3>(_numParticles);
    positions1 = new List<vec3>(_numParticles);
    impulses = new List<vec3>(_numParticles);
    _sphereEnabled = false;
    resetPositions();
    buildConstraints();
  }
  
  void buildConstraints() {
    _numConstraints = _gridWidth*_gridWidth*2 - _gridWidth - _gridWidth;
    constraints = new List<ClothConstraint>(_numConstraints);
    int i = 0;
    for (int y = 0; y < _gridWidth; y++) {
      for (int x = 0; x < _gridWidth; x++) {
        if (x+1 < _gridWidth) {
          constraints[i] = new ClothConstraint(x+y*_gridWidth, x+1 + y*_gridWidth, _gapWidth);
          i++;
        }
        
        if (y+1 < _gridWidth) {
          constraints[i] = new ClothConstraint(x+y*_gridWidth, x+_gridWidth + y*_gridWidth, _gapWidth);
          i++;
        }
      }
    }
    assert(i == _numConstraints);
  }
  
  void resetPositions() {
    for (int i = 0; i < _gridWidth; i++) {
      for (int j = 0; j < _gridWidth; j++) {
        positions0[i + j*_gridWidth] = new vec3.raw(i*_gapWidth, _topHeight, j*_gapWidth);
        positions1[i + j*_gridWidth] = new vec3.raw(i*_gapWidth, _topHeight, j*_gapWidth);
        impulses[i + j*_gridWidth] = new vec3.zero();
      }
    }
  }
  
  void applyForces() {
    vec3 impulse = new vec3.copy(gravityDirection);
    impulse.scale(10.0);
    impulse.scale(_timeStep2);
    
    final List<vec3> pos = getPositions(readIndex);
    for (int i = 0; i < _numParticles; i++) {
      impulses[i].copyFrom(impulse);
    }
    
    vec3 impulse2 = new vec3.raw(0.0, 0.0, 1.0);
    impulse2.scale(5.0);
    impulse2.scale(_timeStep2);
    for (int i = _gridWidth~/2; i < _gridWidth; i++) {
      for (int j = 0; j < _gridWidth; j++) {
        impulses[j+i*_gridWidth].add(impulse2);
      }
    }
  }
  
  List<vec3> getPositions(int index) {
    if (index == 0) {
      return positions0;
    } else {
      return positions1;
    }
  }
  
  void integrate() {
    final int ri = readIndex;
    final int wi = writeIndex;
    final List<vec3> oldPositions = getPositions(ri);
    final List<vec3> newPositions = getPositions(wi);
    vec3 x = new vec3.zero();
    vec3 oldx = new vec3.zero();
    vec3 temp = new vec3.zero();
    for (int i = 0; i < _numParticles; i++) {
      x.copyFrom(newPositions[i]);
      oldx.copyFrom(oldPositions[i]);
      // Update old position with position from new positions
      oldPositions[i].copyFrom(x);
      
      // x' = 1.99 * x + 0.99 oldx + a*t*t
      temp.copyFrom(x);
      temp.scale(0.99);
      oldx.scale(0.99);
      // x+= 0.99 x ==> 1.99x
      x.add(temp);
      // x+= 0.99 oldx => x = 1.99x + 0.99 oldx
      x.sub(oldx);
      // x+= impulse => x' = 1.99 * x + 0.99 oldx + a*t*t 
      x.add(impulses[i]);
      
      // Copy updated x into new positions
      newPositions[i].copyFrom(x);
    }
  }
  
  void satisfyConstraints() {
    final int ri = readIndex;
    final int wi = writeIndex;
    final List<vec3> oldPositions = getPositions(ri);
    final List<vec3> newPositions = getPositions(wi);
    vec3 x = new vec3.zero();
    
    // Keep inside box
    for (int i = 0; i < _numParticles; i++) {
      _clamp(newPositions[i], _min, _max);
    }
    
    vec3 delta = new vec3.zero();
    vec3 temp = new vec3.zero();
    
    final int numIterations = 5;
    for (int iter = 0; iter < numIterations; iter++) {
      for (int c = 0; c < _numConstraints; c++) {
        final int i = constraints[c].i;
        final int j = constraints[c].j;
        final num restlength = constraints[c].restlength;
        delta.copyFrom(newPositions[j]);
        delta.sub(newPositions[i]);
        num len = delta.length;
        num diff = (len - restlength)/len;
        delta.scale(0.5*diff);
        newPositions[i].add(delta);
        newPositions[j].sub(delta);
        
        if (_sphereEnabled) {
          temp.copyFrom(_sphereCenter);
          temp.sub(newPositions[i]);
          num length = temp.length;
          if (length < _sphereRadius) {
            temp.normalize();
            temp.scale(-_sphereRadius);
            temp.add(_sphereCenter);
            newPositions[i].copyFrom(temp);
          }
          
          temp.copyFrom(_sphereCenter);
          temp.sub(newPositions[j]);
          length = temp.length;
          if (length < _sphereRadius) {
            temp.normalize();
            temp.scale(-_sphereRadius);
            temp.add(_sphereCenter);
            newPositions[j].copyFrom(temp);
          }
        }
      }
      
      newPositions[0].x = 0.0;
      newPositions[0].y = _topHeight;
      newPositions[0].z = 0.0;
      newPositions[_gridWidth-1].x = (_gridWidth-1)*_gapWidth;
      newPositions[_gridWidth-1].y = _topHeight;
      newPositions[_gridWidth-1].z = 0.0;
    }
    // We disable sphere collisions after each frame
    _sphereEnabled = false;
  }
  
  void sphereConstraints(vec3 center, num radius) {
    _sphereEnabled = true;
    _sphereCenter.copyFrom(center);
    _sphereRadius = radius * 1.2;
  }
  
  void copyPositions(Dynamic out, int stride) {
    final List<vec3> pos = getPositions(writeIndex);
    for (int i = 0; i < _numParticles; i++) {
      int index = i * stride;
      out[index] = pos[i].x;
      out[index+1] = pos[i].y;
      out[index+2] = pos[i].z;
    }
  }
  
  void pick(int i, int j, vec3 w) {
    final int wi = writeIndex;
    final List<vec3> newPositions = getPositions(wi);
    int index = i + j * _gridWidth;
    if (index < 0 || index >= _numParticles) {
      return;
    }
    newPositions[index].copyFrom(w);
  }
}